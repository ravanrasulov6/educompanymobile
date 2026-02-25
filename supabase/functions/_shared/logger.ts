/**
 * Structured logger for Edge Functions.
 * Logs are visible in Supabase Dashboard → Edge Functions → Logs.
 */
export class Logger {
    private functionName: string;

    constructor(functionName: string) {
        this.functionName = functionName;
    }

    info(message: string, data?: Record<string, unknown>) {
        console.log(JSON.stringify({
            level: "INFO",
            fn: this.functionName,
            msg: message,
            ...data,
            ts: new Date().toISOString(),
        }));
    }

    warn(message: string, data?: Record<string, unknown>) {
        console.warn(JSON.stringify({
            level: "WARN",
            fn: this.functionName,
            msg: message,
            ...data,
            ts: new Date().toISOString(),
        }));
    }

    error(message: string, error?: unknown, data?: Record<string, unknown>) {
        const errStr = error instanceof Error
            ? { error_message: error.message, error_stack: error.stack }
            : { error_message: String(error) };

        console.error(JSON.stringify({
            level: "ERROR",
            fn: this.functionName,
            msg: message,
            ...errStr,
            ...data,
            ts: new Date().toISOString(),
        }));
    }
}
