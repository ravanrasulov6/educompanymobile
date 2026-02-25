import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { handleCors, jsonResponse, errorResponse } from "../_shared/cors.ts";
import { createServiceClient, getUserId } from "../_shared/supabase-client.ts";
import { Logger } from "../_shared/logger.ts";
import { PDFDocument, rgb, StandardFonts } from "https://esm.sh/pdf-lib@1.17.1";
import * as docx from "npm:docx@8.5.0";

const log = new Logger("export-document");

serve(async (req: Request) => {
    const corsResp = handleCors(req);
    if (corsResp) return corsResp;

    try {
        const userId = await getUserId(req);
        if (!userId) return errorResponse("Unauthorized", 401);

        const { source_type, source_id, format, include_questions } = await req.json();

        if (!["document", "transcript"].includes(source_type)) {
            return errorResponse("Invalid source_type");
        }
        if (!["pdf", "docx"].includes(format)) {
            return errorResponse("Invalid format");
        }

        const supabase = createServiceClient();

        let title = "Sənəd Export";
        let textContent = "";
        const timestamp = Date.now();
        let fileName = `export_${timestamp}.${format}`;

        if (source_type === "document") {
            const { data: doc } = await supabase.from("ai_documents").select("*").eq("id", source_id).single();
            if (!doc || doc.user_id !== userId) return errorResponse("Sənəd tapılmadı və ya icazəniz yoxdur", 404);
            title = doc.file_name;
            fileName = `doc_${doc.id.substring(0, 8)}.${format}`;

            const { data: pages } = await supabase.from("ai_document_pages")
                .select("text").eq("document_id", source_id).order("page_no");
            if (pages) textContent = pages.map(p => p.text).join("\n\n");
        } else if (source_type === "transcript") {
            const { data: trans } = await supabase.from("ai_transcripts").select("*").eq("id", source_id).single();
            if (!trans || trans.user_id !== userId) return errorResponse("Səs tapılmadı", 404);
            title = trans.title;
            fileName = `audio_${trans.id.substring(0, 8)}.${format}`;
            textContent = trans.full_text;
        }

        // Fetch Questions
        let questions: any[] = [];
        if (include_questions) {
            const { data: qData } = await supabase.from("ai_questions")
                .select("*").eq(source_type === "document" ? "document_id" : "transcript_id", source_id).order("created_at");
            if (qData) questions = qData;
        }

        let fileBytes: Uint8Array;
        if (format === "pdf") {
            fileBytes = await generatePdf(title, textContent, questions);
        } else {
            fileBytes = await generateDocx(title, textContent, questions);
        }

        // Upload to Storage
        const storagePath = `${userId}/${fileName}`;
        const { error: uploadError } = await supabase.storage.from("ai-exports").upload(storagePath, fileBytes, {
            contentType: format === "pdf" ? "application/pdf" : "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            upsert: true
        });

        if (uploadError) throw new Error(`Export yüklənmə xətası: ${uploadError.message}`);

        // Store in DB
        const { data: exportRecord } = await supabase.from("ai_exports").insert({
            user_id: userId,
            source_type,
            source_id,
            format,
            storage_path: storagePath,
            file_name: fileName,
            file_size_bytes: fileBytes.length
        }).select().single();

        // Signed URL
        const { data: urlData } = await supabase.storage.from("ai-exports").createSignedUrl(storagePath, 3600);

        return jsonResponse({
            success: true,
            export_id: exportRecord?.id,
            download_url: urlData?.signedUrl
        });

    } catch (err) {
        log.error("Export xətası", err);
        return errorResponse("Daxili server xətası", 500);
    }
});

async function generatePdf(title: string, text: string, questions: any[]): Promise<Uint8Array> {
    const pdfDoc = await PDFDocument.create();

    // Custom font for Azerbaijani chars (AZE)
    let customFont;
    try {
        const fontData = await Deno.readFile(new URL("../_assets/fonts/NotoSans-Regular.ttf", import.meta.url));
        customFont = await pdfDoc.embedFont(fontData);
    } catch (e) {
        log.warn("NotoSans font file not found, using base font workaround (AZE chars may strip)");
        customFont = await pdfDoc.embedFont(StandardFonts.Helvetica);
        // Transliterate if we are using Helvetica, to avoid breaking chars
        text = text.replace(/ə/g, "e").replace(/Ə/g, "E")
            .replace(/ğ/g, "g").replace(/Ğ/g, "G")
            .replace(/ş/g, "s").replace(/Ş/g, "S");
    }

    // Add page
    let page = pdfDoc.addPage();
    const { width, height } = page.getSize();
    let y = height - 50;

    const drawText = (line: string, size = 12, isBold = false) => {
        if (y < 50) {
            page = pdfDoc.addPage();
            y = height - 50;
        }
        try {
            // Trim very long strings that might overflow bounds
            page.drawText(line.substring(0, 150), { x: 50, y, size, font: customFont, color: rgb(0, 0, 0) });
        } catch (e) { /* ignore Unsupported characters */ }
        y -= (size + 5);
    };

    drawText(title, 18, true);
    y -= 20;
    drawText(text ? "Text budur:" : "Sənəd xülasəsi/Məlumat:", 14, true);
    y -= 10;

    const lines = text.split("\n");
    for (const line of lines) {
        if (!line.trim()) { y -= 10; continue; }
        // Simple word wrap
        const words = line.split(" ");
        let currentLine = "";
        for (const word of words) {
            if (currentLine.length + word.length > 80) {
                drawText(currentLine);
                currentLine = word + " ";
            } else {
                currentLine += word + " ";
            }
        }
        if (currentLine) drawText(currentLine);
    }

    if (questions && questions.length > 0) {
        y -= 20;
        drawText("Suallar:", 16, true);
        y -= 10;

        questions.forEach((q, i) => {
            drawText(`${i + 1}. ${q.question_text}`, 12, true);
            if (q.options) {
                const opts = typeof q.options === 'string' ? JSON.parse(q.options) : q.options;
                opts.forEach((opt: string, j: number) => {
                    drawText(`   ${String.fromCharCode(65 + j)}) ${opt}`);
                });
            }
            if (q.answer_key) {
                drawText(`   Cavab: ${q.answer_key}`);
            }
            y -= 10;
        });
    }

    return await pdfDoc.save();
}

async function generateDocx(title: string, text: string, questions: any[]): Promise<Uint8Array> {
    const children: any[] = [];

    children.push(new docx.Paragraph({
        text: title,
        heading: docx.HeadingLevel.HEADING_1,
        spacing: { after: 400 }
    }));

    if (text) {
        children.push(new docx.Paragraph({
            text: "Text budur:",
            heading: docx.HeadingLevel.HEADING_2,
            spacing: { after: 200 }
        }));

        const lines = text.split("\n");
        for (const line of lines) {
            if (line.trim()) {
                children.push(new docx.Paragraph({ text: line, spacing: { after: 120 } }));
            }
        }
    }

    if (questions && questions.length > 0) {
        children.push(new docx.Paragraph({
            text: "Suallar:",
            heading: docx.HeadingLevel.HEADING_2,
            spacing: { before: 400, after: 200 }
        }));

        questions.forEach((q, i) => {
            children.push(new docx.Paragraph({
                text: `${i + 1}. ${q.question_text}`,
                heading: docx.HeadingLevel.HEADING_3,
                spacing: { before: 200 }
            }));

            if (q.options) {
                const opts = typeof q.options === 'string' ? JSON.parse(q.options) : q.options;
                opts.forEach((opt: string, j: number) => {
                    children.push(new docx.Paragraph({
                        text: `${String.fromCharCode(65 + j)}) ${opt}`,
                        bullet: { level: 0 }
                    }));
                });
            }
            if (q.answer_key) {
                children.push(new docx.Paragraph({
                    children: [
                        new docx.TextRun({ text: "Cavab: ", bold: true }),
                        new docx.TextRun({ text: q.answer_key })
                    ]
                }));
            }
        });
    }

    const doc = new docx.Document({
        sections: [{ properties: {}, children: children }]
    });

    // docx.Packer.toBuffer returns a Buffer/ArrayBuffer which can be wrapped in Uint8Array
    const buffer = await docx.Packer.toBuffer(doc);
    return new Uint8Array(buffer);
}
