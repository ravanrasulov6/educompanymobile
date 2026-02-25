import { getDocument } from "npm:pdfjs-dist@3.11.174/legacy/build/pdf.js";

/**
 * Extracts raw selectable text if the PDF is not strictly a scanned image.
 * Returns empty array if mostly images/scanned.
 */
export async function tryExtractNativePdfText(pdfUrl: string): Promise<string[]> {
    try {
        const loadingTask = getDocument(pdfUrl);
        const pdf = await loadingTask.promise;
        const numPages = pdf.numPages;

        const pagesText: string[] = [];
        let totalTextLength = 0;

        for (let i = 1; i <= numPages; i++) {
            const page = await pdf.getPage(i);
            const content = await page.getTextContent();
            const textLines = content.items.map((item: any) => item.str).join(" ");

            totalTextLength += textLines.trim().length;
            pagesText.push(textLines.trim());
        }

        // If the entire PDF has less than 50 characters of actual text, it's likely a scan.
        if (totalTextLength < 50 && numPages > 0) return [];

        return pagesText;
    } catch (e) {
        console.warn("Native PDF extraction failed, falling back to OCR", e);
        return [];
    }
}
