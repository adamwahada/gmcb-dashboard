
-- ============================================
-- SECURITY FIX: Lock down all MAB tables to authenticated users only
-- ============================================

-- Drop all permissive (public) policies on mab_establishments
DROP POLICY IF EXISTS "Allow public read mab_establishments" ON mab_establishments;
DROP POLICY IF EXISTS "Allow public update mab_establishments" ON mab_establishments;
DROP POLICY IF EXISTS "Allow public insert mab_establishments" ON mab_establishments;

-- Create authenticated-only policies for mab_establishments
CREATE POLICY "Authenticated read mab_establishments" ON mab_establishments FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated insert mab_establishments" ON mab_establishments FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated update mab_establishments" ON mab_establishments FOR UPDATE TO authenticated USING (true);

-- Drop all permissive policies on mab_zones
DROP POLICY IF EXISTS "Allow public read mab_zones" ON mab_zones;
DROP POLICY IF EXISTS "Allow public insert mab_zones" ON mab_zones;
DROP POLICY IF EXISTS "Allow public update mab_zones" ON mab_zones;
DROP POLICY IF EXISTS "Allow public delete mab_zones" ON mab_zones;

-- Create authenticated-only policies for mab_zones
CREATE POLICY "Authenticated read mab_zones" ON mab_zones FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated insert mab_zones" ON mab_zones FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated update mab_zones" ON mab_zones FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Authenticated delete mab_zones" ON mab_zones FOR DELETE TO authenticated USING (true);

-- Drop all permissive policies on mab_operators
DROP POLICY IF EXISTS "Allow public read mab_operators" ON mab_operators;
DROP POLICY IF EXISTS "Allow public insert mab_operators" ON mab_operators;
DROP POLICY IF EXISTS "Allow public update mab_operators" ON mab_operators;
DROP POLICY IF EXISTS "Allow public delete mab_operators" ON mab_operators;

-- Create authenticated-only policies for mab_operators
CREATE POLICY "Authenticated read mab_operators" ON mab_operators FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated insert mab_operators" ON mab_operators FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated update mab_operators" ON mab_operators FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Authenticated delete mab_operators" ON mab_operators FOR DELETE TO authenticated USING (true);

-- Drop all permissive policies on mab_sessions
DROP POLICY IF EXISTS "Allow public read mab_sessions" ON mab_sessions;
DROP POLICY IF EXISTS "Allow public insert mab_sessions" ON mab_sessions;
DROP POLICY IF EXISTS "Allow public update mab_sessions" ON mab_sessions;

-- Create authenticated-only policies for mab_sessions
CREATE POLICY "Authenticated read mab_sessions" ON mab_sessions FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated insert mab_sessions" ON mab_sessions FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated update mab_sessions" ON mab_sessions FOR UPDATE TO authenticated USING (true);

-- Drop all permissive policies on mab_session_items
DROP POLICY IF EXISTS "Allow public read mab_session_items" ON mab_session_items;
DROP POLICY IF EXISTS "Allow public insert mab_session_items" ON mab_session_items;
DROP POLICY IF EXISTS "Allow public update mab_session_items" ON mab_session_items;

-- Create authenticated-only policies for mab_session_items
CREATE POLICY "Authenticated read mab_session_items" ON mab_session_items FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated insert mab_session_items" ON mab_session_items FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated update mab_session_items" ON mab_session_items FOR UPDATE TO authenticated USING (true);

-- ============================================
-- SECURITY FIX: Make mab-photos bucket private
-- ============================================
UPDATE storage.buckets SET public = false WHERE id = 'mab-photos';

-- Drop public storage policies
DROP POLICY IF EXISTS "Anyone can upload mab photos" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view mab photos" ON storage.objects;

-- Create authenticated-only storage policies
CREATE POLICY "Authenticated upload mab photos" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'mab-photos');
CREATE POLICY "Authenticated view mab photos" ON storage.objects FOR SELECT TO authenticated USING (bucket_id = 'mab-photos');

-- ============================================
-- Helper function: get MAB role from email
-- ============================================
CREATE OR REPLACE FUNCTION public.get_mab_role(user_email text)
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT CASE 
    WHEN user_email LIKE 'manager@%' THEN 'manager'
    ELSE 'operator'
  END
$$;
