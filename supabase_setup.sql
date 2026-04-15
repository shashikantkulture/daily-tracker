-- ==========================================
-- SUPABASE SETUP SCRIPT - Daily Task SaaS
-- ==========================================

-- 1. TABLES
-- Profiles: Extends Supabase Auth users
CREATE TABLE profiles (
  id uuid REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  name text,
  email text,
  role text CHECK (role IN ('admin', 'client')) DEFAULT 'client',
  updated_at timestamp with time zone DEFAULT now()
);

-- Clients: Links business names to profiles
CREATE TABLE clients (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  business_name text NOT NULL,
  created_at timestamp with time zone DEFAULT now()
);

-- Tasks: Individual work items
CREATE TABLE tasks (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  status text CHECK (status IN ('pending', 'completed')) DEFAULT 'pending',
  created_at timestamp with time zone DEFAULT now()
);

-- Work Sessions: Timer logs
CREATE TABLE work_sessions (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  start_time timestamp with time zone NOT NULL,
  end_time timestamp with time zone,
  duration_minutes float DEFAULT 0,
  is_active boolean DEFAULT true
);

-- Content Stats: For ROI calculation
CREATE TABLE content_stats (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  posts_count int DEFAULT 0,
  reels_count int DEFAULT 0,
  updated_at timestamp with time zone DEFAULT now()
);

-- Packages: Expiry tracking
CREATE TABLE packages (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  start_date date NOT NULL,
  duration_days int NOT NULL,
  created_at timestamp with time zone DEFAULT now()
);

-- Emoji Feedback
CREATE TABLE emoji_feedback (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  task_id uuid REFERENCES tasks(id) ON DELETE CASCADE,
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  emoji text NOT NULL,
  created_at timestamp with time zone DEFAULT now()
);

-- 2. SECURITY (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE work_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE emoji_feedback ENABLE ROW LEVEL SECURITY;

-- Helper function for Admin check
CREATE OR REPLACE FUNCTION is_admin() RETURNS boolean AS $$
  SELECT role = 'admin' FROM profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER;

-- Policies
CREATE POLICY "Admins can manage everything" ON profiles FOR ALL USING (is_admin());
CREATE POLICY "Admins can manage clients" ON clients FOR ALL USING (is_admin());
CREATE POLICY "Admins can manage tasks" ON tasks FOR ALL USING (is_admin());
CREATE POLICY "Admins can manage sessions" ON work_sessions FOR ALL USING (is_admin());
CREATE POLICY "Admins can manage stats" ON content_stats FOR ALL USING (is_admin());
CREATE POLICY "Admins can manage packages" ON packages FOR ALL USING (is_admin());
CREATE POLICY "Admins can manage feedback" ON emoji_feedback FOR ALL USING (is_admin());

CREATE POLICY "Clients can view own profile" ON profiles FOR SELECT USING (id = auth.uid());
CREATE POLICY "Clients can view own data" ON clients FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Clients can view own tasks" ON tasks FOR SELECT USING (client_id IN (SELECT id FROM clients WHERE user_id = auth.uid()));
CREATE POLICY "Clients can view own sessions" ON work_sessions FOR SELECT USING (client_id IN (SELECT id FROM clients WHERE user_id = auth.uid()));
CREATE POLICY "Clients can view own stats" ON content_stats FOR SELECT USING (client_id IN (SELECT id FROM clients WHERE user_id = auth.uid()));
CREATE POLICY "Clients can view own packages" ON packages FOR SELECT USING (client_id IN (SELECT id FROM clients WHERE user_id = auth.uid()));
CREATE POLICY "Clients can view/add own feedback" ON emoji_feedback FOR ALL USING (client_id IN (SELECT id FROM clients WHERE user_id = auth.uid()));

-- 3. TRIGGER: Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, name, role)
  VALUES (new.id, new.email, new.raw_user_meta_data->>'full_name', 
    CASE WHEN new.email = 'singhshashikant301@gmail.com' THEN 'admin' ELSE 'client' END);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 4. DATA MIGRATION (Seed Default Clients)
-- Note: These will need to be linked to user accounts manually later via 'user_id'
INSERT INTO clients (id, business_name) VALUES 
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'DIGITAL JUGGLER'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'KALRAJ THAKUR'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'SHIKHAR'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', 'FLOWGREEN'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55', 'GROWGREEN'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a66', 'SAM RENISSA'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a77', 'VARCHAS');

INSERT INTO tasks (client_id, title) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Reel 1'), ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Reel 2'), ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Reel 3'), ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Reel 4'), ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Reel 5'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Video 1'), ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Video 2'), ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Video 3'), ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Video 4'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'Daily Post'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', 'Content Task'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55', 'Daily Post'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a66', 'YouTube Upload'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a77', 'Post (Alternate Day)');

-- 5. SAMPLE DASHBOARD DATA (For Testing)
INSERT INTO content_stats (client_id, posts_count, reels_count) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 12, 8),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 5, 2);

INSERT INTO packages (client_id, start_date, duration_days) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', CURRENT_DATE - INTERVAL '10 days', 30),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', CURRENT_DATE - INTERVAL '5 days', 15);
