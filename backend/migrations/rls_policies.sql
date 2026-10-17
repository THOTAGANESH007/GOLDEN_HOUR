-- =====================================================================
-- Golden Hour — Supabase Row Level Security (RLS) Policies
-- =====================================================================

-- 1. Enable RLS on all core tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE scan_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- 2. Drop existing policies if any
DROP POLICY IF EXISTS "Users can view own user record" ON users;
DROP POLICY IF EXISTS "Users can manage own profile" ON profiles;
DROP POLICY IF EXISTS "Users can manage own emergency contacts" ON emergency_contacts;
DROP POLICY IF EXISTS "Users can manage own documents" ON documents;
DROP POLICY IF EXISTS "Users can view own scan events" ON scan_events;

-- 3. Create per-user access control policies (JWT auth.uid() matching)
CREATE POLICY "Users can view own user record" ON users
    FOR ALL USING (auth.uid() = id);

CREATE POLICY "Users can manage own profile" ON profiles
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own emergency contacts" ON emergency_contacts
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own documents" ON documents
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own scan events" ON scan_events
    FOR ALL USING (auth.uid() = user_id);
