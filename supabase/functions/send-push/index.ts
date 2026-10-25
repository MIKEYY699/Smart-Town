// Sends a push notification for every new row in `notifications`.
//
// Called by a Database Webhook (INSERT on public.notifications).
// Secrets:
//   FIREBASE_SERVICE_ACCOUNT  the service account JSON from Firebase
//   PUSH_WEBHOOK_SECRET       must match the x-webhook-secret header
import { createClient } from "jsr:@supabase/supabase-js@2";

// The column in `notifications` that holds who the notification is for.
const RECIPIENT_COLUMN = "user_id";

const serviceAccount = JSON.parse(Deno.env.get("FIREBASE_SERVICE_ACCOUNT")!);
const webhookSecret = Deno.env.get("PUSH_WEBHOOK_SECRET")!;

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

let cachedToken: { value: string; expiresAt: number } | null = null;

function base64url(data: string | ArrayBuffer): string {
  const bytes = typeof data === "string"
    ? new TextEncoder().encode(data)
    : new Uint8Array(data);
  let binary = "";
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

// Google OAuth token for the FCM HTTP v1 API, signed with the service account.
async function getAccessToken(): Promise<string> {
  if (cachedToken && cachedToken.expiresAt > Date.now() + 60_000) {
    return cachedToken.value;
  }

  const now = Math.floor(Date.now() / 1000);
  const header = base64url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claims = base64url(JSON.stringify({
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  }));

  const pem = serviceAccount.private_key
    .replace(/-----[^-]+-----/g, "")
    .replace(/\s/g, "");
  const der = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const key = await crypto.subtle.importKey(
    "pkcs8",
    der,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(`${header}.${claims}`),
  );

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${header}.${claims}.${base64url(signature)}`,
    }),
  });
  if (!res.ok) throw new Error(`Google token error: ${await res.text()}`);

  const json = await res.json();
  cachedToken = {
    value: json.access_token,
    expiresAt: Date.now() + json.expires_in * 1000,
  };
  return cachedToken.value;
}

Deno.serve(async (req) => {
  if (req.headers.get("x-webhook-secret") !== webhookSecret) {
    return new Response("Unauthorized", { status: 401 });
  }

  const payload = await req.json();
  const record = payload.record;
  if (payload.type !== "INSERT" || !record) {
    return new Response("Ignored");
  }

  const userId = record[RECIPIENT_COLUMN];
  const { data: devices, error } = await supabase
    .from("device_tokens")
    .select("token")
    .eq("user_id", userId);
  if (error) return new Response(error.message, { status: 500 });
  if (!devices || devices.length === 0) return new Response("No devices");

  const accessToken = await getAccessToken();
  const url =
    `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`;

  const results = await Promise.all(devices.map(async ({ token }) => {
    const res = await fetch(url, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token,
          notification: {
            title: record.title ?? "Smart Town",
            body: record.body ?? "",
          },
          // FCM data values must be strings.
          data: {
            type: String(record.type ?? ""),
            notification_id: String(record.id),
          },
          android: {
            priority: "high",
            notification: { channel_id: "high_importance_channel" },
          },
          apns: { payload: { aps: { sound: "default" } } },
        },
      }),
    });

    // The app was uninstalled or the token expired. Forget it.
    if (res.status === 404) {
      await supabase.from("device_tokens").delete().eq("token", token);
    } else if (!res.ok) {
      console.error(`FCM error for ${token.slice(0, 12)}…: ${await res.text()}`);
    }
    return res.ok;
  }));

  const sent = results.filter(Boolean).length;
  return new Response(`Sent ${sent}/${devices.length}`);
});
