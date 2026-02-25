import * as jose from "https://deno.land/x/jose@v5.2.2/index.ts";

let cachedToken: string | null = null;
let tokenExpiry: number = 0;

/**
 * Exchange Service Account JSON for an OAuth 2.0 access token via JWT assertion.
 * Caches token until 5 mins before expiry.
 */
export async function getGoogleAccessToken(): Promise<string> {
    if (cachedToken && Date.now() < tokenExpiry) {
        return cachedToken;
    }

    const saBase64 = Deno.env.get("GOOGLE_SA_JSON_B64");
    if (!saBase64) {
        throw new Error("Missing GOOGLE_SA_JSON_B64 secret in Supabase");
    }

    // Decode base64
    const saJsonRaw = new TextDecoder().decode(
        Uint8Array.from(atob(saBase64), c => c.charCodeAt(0))
    );
    const sa = JSON.parse(saJsonRaw);

    if (!sa.private_key || !sa.client_email) {
        throw new Error("Invalid Service Account JSON format");
    }

    // Import private key for RS256
    const privateKey = await jose.importPKCS8(sa.private_key, "RS256");

    // Create JWT Assertion
    const jwt = await new jose.SignJWT({
        iss: sa.client_email,
        scope: "https://www.googleapis.com/auth/cloud-platform",
        aud: "https://oauth2.googleapis.com/token"
    })
        .setProtectedHeader({ alg: "RS256", typ: "JWT" })
        .setIssuedAt()
        .setExpirationTime("1h")
        .sign(privateKey);

    // Request OAuth Token
    const res = await fetch("https://oauth2.googleapis.com/token", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: new URLSearchParams({
            grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
            assertion: jwt
        })
    });

    if (!res.ok) {
        const errText = await res.text();
        throw new Error(`Google Auth Token Exchange Error: ${errText}`);
    }

    const data = await res.json();
    cachedToken = data.access_token;
    // Buffer of 5 minutes (300 seconds)
    tokenExpiry = Date.now() + (data.expires_in - 300) * 1000;

    return cachedToken!;
}
