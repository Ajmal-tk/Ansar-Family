import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (request.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  let username: string;
  let password: string;
  try {
    const body = await request.json();
    username = typeof body.username === "string" ? body.username.trim() : "";
    password = typeof body.password === "string" ? body.password : "";
  } catch {
    return jsonResponse({ error: "Invalid request" }, 400);
  }

  if (!username || !password) {
    return jsonResponse({ error: "Invalid username or password" }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    console.error("Username login function is missing Supabase configuration");
    return jsonResponse({ error: "Unable to sign in" }, 500);
  }

  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const { data: profile, error: profileError } = await adminClient
    .from("profiles")
    .select("id")
    .eq("username", username)
    .maybeSingle();

  if (profileError) {
    console.error("Username lookup failed:", profileError.message);
    return jsonResponse({ error: "Unable to sign in" }, 500);
  }
  if (!profile) {
    return jsonResponse({ error: "Invalid username or password" }, 401);
  }

  const { data: userData, error: userError } = await adminClient.auth.admin
    .getUserById(profile.id);
  const email = userData.user?.email;
  if (userError || !email) {
    if (userError) console.error("User lookup failed:", userError.message);
    return jsonResponse({ error: "Invalid username or password" }, 401);
  }

  const authClient = createClient(supabaseUrl, anonKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const { data: authData, error: authError } = await authClient.auth
    .signInWithPassword({ email, password });

  if (authError || !authData.session) {
    return jsonResponse({ error: "Invalid username or password" }, 401);
  }

  return jsonResponse({
    access_token: authData.session.access_token,
    refresh_token: authData.session.refresh_token,
  });
});
