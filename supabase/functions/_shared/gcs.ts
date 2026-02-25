import { getGoogleAccessToken } from "./google_auth.ts";

/**
 * Upload a stream to GCS using the JSON API (simple upload).
 */
export async function uploadToGcs(bucket: string, objectName: string, stream: ReadableStream, contentType: string) {
    const token = await getGoogleAccessToken();
    const url = `https://storage.googleapis.com/upload/storage/v1/b/${bucket}/o?uploadType=media&name=${encodeURIComponent(objectName)}`;

    // Deno fetch accepts ReadableStream body
    const res = await fetch(url, {
        method: "POST",
        headers: {
            "Authorization": `Bearer ${token}`,
            "Content-Type": contentType
        },
        body: stream,
    });

    if (!res.ok) {
        throw new Error(`GCS Upload Error: ${await res.text()}`);
    }
    return await res.json();
}

/**
 * List objects in a GCS bucket with a given prefix.
 */
export async function listGcsObjects(bucket: string, prefix: string): Promise<string[]> {
    const token = await getGoogleAccessToken();
    const url = `https://storage.googleapis.com/storage/v1/b/${bucket}/o?prefix=${encodeURIComponent(prefix)}`;

    const res = await fetch(url, {
        headers: { "Authorization": `Bearer ${token}` }
    });

    if (!res.ok) {
        throw new Error(`GCS List Error: ${await res.text()}`);
    }

    const data = await res.json();
    return (data.items || []).map((item: any) => item.name);
}

/**
 * Download an object from GCS as JSON.
 */
export async function readGcsObjectJson(bucket: string, objectName: string): Promise<any> {
    const token = await getGoogleAccessToken();
    const url = `https://storage.googleapis.com/storage/v1/b/${bucket}/o/${encodeURIComponent(objectName)}?alt=media`;

    const res = await fetch(url, {
        headers: { "Authorization": `Bearer ${token}` }
    });

    if (!res.ok) {
        throw new Error(`GCS Read Error: ${await res.text()}`);
    }
    return await res.json();
}

/**
 * Delete an object from GCS.
 */
export async function deleteGcsObject(bucket: string, objectName: string): Promise<void> {
    const token = await getGoogleAccessToken();
    const url = `https://storage.googleapis.com/storage/v1/b/${bucket}/o/${encodeURIComponent(objectName)}`;

    const res = await fetch(url, {
        method: "DELETE",
        headers: { "Authorization": `Bearer ${token}` }
    });

    if (!res.ok && res.status !== 404) {
        console.warn(`Failed to delete GCS object ${objectName}: ${await res.text()}`);
    }
}
