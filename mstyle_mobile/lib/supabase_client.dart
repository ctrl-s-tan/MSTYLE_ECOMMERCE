import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Supabase singleton ───────────────────────────────────────────────────────
// Replace the values below with your actual project URL and anon key.
// Settings → API in your Supabase dashboard.
const String supabaseUrl  = 'https://vydcnhmgqovketjqvpoe.supabase.co';
const String supabaseAnon = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ5ZGNuaG1ncW92a2V0anF2cG9lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyMjc4MDMsImV4cCI6MjA5MTgwMzgwM30.wMFqPcuq_l19zr61-BhRUtGWJyiKa0Rq5300tGntiyE';

// Access the client anywhere: supabase.auth, supabase.from(...)
final supabase = Supabase.instance.client;
