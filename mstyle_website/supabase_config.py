"""
Supabase configuration for MStyle web app.
"""
import os
import time as _time
from supabase import create_client, Client

SUPABASE_URL = os.environ.get(
    'SUPABASE_URL',
    'https://vydcnhmgqovketjqvpoe.supabase.co'
)
SUPABASE_ANON = os.environ.get(
    'SUPABASE_ANON_KEY',
    (
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
        '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ5ZGNuaG1ncW92a2V0anF2cG9lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyMjc4MDMsImV4cCI6MjA5MTgwMzgwM30'
        '.wMFqPcuq_l19zr61-BhRUtGWJyiKa0Rq5300tGntiyE'
    )
)
SUPABASE_SERVICE_ROLE = os.environ.get(
    'SUPABASE_SERVICE_ROLE_KEY',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ5ZGNuaG1ncW92a2V0anF2cG9lIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NjIyNzgwMywiZXhwIjoyMDkxODAzODAzfQ.N7gBt1F2bLulJkD2Uh1nXaTvLkV2fiEAFvnN3qVLYAY'
)


def _create_with_retry(url, key, retries=5, delay=3):
    """Create Supabase client with retry on DNS/network failure."""
    last_err = None
    for attempt in range(retries):
        try:
            client = create_client(url, key)
            # Warm up the connection with a lightweight ping
            try:
                client.table('users').select('id').limit(1).execute()
            except Exception:
                pass  # Ping failure is non-fatal
            print(f"Supabase client created successfully (attempt {attempt+1})")
            return client
        except Exception as e:
            last_err = e
            print(f"Supabase client creation attempt {attempt+1} failed: {e}")
            if attempt < retries - 1:
                _time.sleep(delay)
    # Last resort: return client without ping
    try:
        return create_client(url, key)
    except Exception:
        raise last_err


# Default anon client (for auth operations)
supabase: Client = _create_with_retry(SUPABASE_URL, SUPABASE_ANON)

# Admin client — uses service role key, bypasses RLS.
try:
    supabase_admin: Client = _create_with_retry(SUPABASE_URL, SUPABASE_SERVICE_ROLE)
except Exception as e:
    print(f"WARNING: supabase_admin creation failed: {e}. Falling back to anon client.")
    supabase_admin = supabase
