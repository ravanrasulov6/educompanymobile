import { getGoogleAccessToken } from "./google_auth.ts";

/**
 * Start async BatchProcessDocuments operation.
 * Output will be written to gcsOutputPrefix.
 */
export async function batchProcessDocument(gcsInputUri: string, gcsOutputPrefix: string) {
    const token = await getGoogleAccessToken();
    const projectId = Deno.env.get("GOOGLE_CLOUD_PROJECT_ID");
    const location = Deno.env.get("GOOGLE_CLOUD_LOCATION");
    const processorId = Deno.env.get("DOCUMENT_AI_PROCESSOR_ID");

    if (!projectId || !location || !processorId) {
        throw new Error("Missing Document AI environment variables (Project/Location/ProcessorID)");
    }

    const url = `https://documentai.googleapis.com/v1/projects/${projectId}/locations/${location}/processors/${processorId}:batchProcess`;

    const res = await fetch(url, {
        method: "POST",
        headers: {
            "Authorization": `Bearer ${token}`,
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            inputDocuments: {
                gcsDocuments: {
                    documents: [{ gcsUri: gcsInputUri, mimeType: "application/pdf" }]
                }
            },
            documentOutputConfig: {
                gcsOutputConfig: { gcsUri: gcsOutputPrefix }
            }
        })
    });

    if (!res.ok) {
        throw new Error(`DocAI Batch Error: ${await res.text()}`);
    }
    return await res.json(); // { name: 'projects/.../operations/...' }
}

/**
 * Sync process for single images/short docs
 */
export async function processDocumentSync(base64Content: string, mimeType: string) {
    const token = await getGoogleAccessToken();
    const projectId = Deno.env.get("GOOGLE_CLOUD_PROJECT_ID");
    const location = Deno.env.get("GOOGLE_CLOUD_LOCATION");
    const processorId = Deno.env.get("DOCUMENT_AI_PROCESSOR_ID");

    const url = `https://documentai.googleapis.com/v1/projects/${projectId}/locations/${location}/processors/${processorId}:process`;

    const res = await fetch(url, {
        method: "POST",
        headers: {
            "Authorization": `Bearer ${token}`,
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            rawDocument: { content: base64Content, mimeType }
        })
    });

    if (!res.ok) {
        throw new Error(`DocAI Sync Error: ${await res.text()}`);
    }
    return await res.json();
}

/**
 * Poll LRO operation name with exponential-ish backoff.
 * Updates heartbeat automatically if callback provided.
 */
export async function pollOperation(operationName: string, heartbeatCb?: () => Promise<void>) {
    const token = await getGoogleAccessToken();
    const url = `https://documentai.googleapis.com/v1/${operationName}`;

    for (let i = 0; i < 90; i++) { // max ~15 mins
        const res = await fetch(url, { headers: { "Authorization": `Bearer ${token}` } });
        if (!res.ok) throw new Error(`Poll Error: ${await res.text()}`);

        const data = await res.json();
        if (data.done) {
            if (data.error) throw new Error(`Document AI Operation Failed: ${JSON.stringify(data.error)}`);
            return data;
        }

        if (heartbeatCb && i % 3 === 0) {
            await heartbeatCb().catch(e => console.error("Heartbeat fail", e));
        }

        await new Promise(r => setTimeout(r, 10000)); // 10s wait
    }
    throw new Error("Polling timeout after 15 minutes");
}

/**
 * Get LRO operation status exactly once.
 */
export async function getOperationStatus(operationName: string) {
    const token = await getGoogleAccessToken();
    const url = `https://documentai.googleapis.com/v1/${operationName}`;

    const res = await fetch(url, { headers: { "Authorization": `Bearer ${token}` } });
    if (!res.ok) throw new Error(`Operation Status Error: ${await res.text()}`);

    return await res.json();
}
