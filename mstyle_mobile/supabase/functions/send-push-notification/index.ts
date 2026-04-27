import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const ONESIGNAL_APP_ID  = Deno.env.get("d340ecba-5d1c-4864-a4b9-5895e0cf5a85")!;
const ONESIGNAL_API_KEY = Deno.env.get("qrkrgwqvqehkmjxot7ekanki3")!;
const SUPABASE_URL      = Deno.env.get("https://vydcnhmgqovketjqvpoe.supabase.co")!;
const SB_SERVICE_ROLE_KEY = Deno.env.get("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ5ZGNuaG1ncW92a2V0anF2cG9lIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NjIyNzgwMywiZXhwIjoyMDkxODAzODAzfQ.N7gBt1F2bLulJkD2Uh1nXaTvLkV2fiEAFvnN3qVLYAY")!;

serve(async (req) => {
  try {
    const payload = await req.json();
    const record = payload.record as {
      id: number;
      buyer_email: string;
      message: string;
      type: string;
    };

    if (!record?.buyer_email || !record?.message) {
      return new Response(JSON.stringify({ error: "Missing fields" }), { status: 400 });
    }

    const supabase = createClient(SUPABASE_URL, SB_SERVICE_ROLE_KEY);
    const { data: user, error } = await supabase
      .from("users")
      .select("onesignal_player_id")
      .eq("email", record.buyer_email)
      .maybeSingle();

    if (error || !user?.onesignal_player_id) {
      console.log(`No player ID for ${record.buyer_email}`);
      return new Response(JSON.stringify({ skipped: true }), { status: 200 });
    }

    const response = await fetch("https://onesignal.com/api/v1/notifications", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Basic ${ONESIGNAL_API_KEY}`,
      },
      body: JSON.stringify({
        app_id: ONESIGNAL_APP_ID,
        include_player_ids: [user.onesignal_player_id],
        headings: { en: "MStyle Order Update" },
        contents: { en: record.message },
        data: { type: record.type ?? "order", notification_id: record.id },
      }),
    });

    const result = await response.json();
    console.log("OneSignal response:", JSON.stringify(result));
    return new Response(JSON.stringify({ success: true, result }), { status: 200 });
  } catch (e) {
    console.error("Edge function error:", e);
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }
});
