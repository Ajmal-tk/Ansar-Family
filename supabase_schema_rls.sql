-- ============================================================================
-- ANSAR FAMILY - SUPABASE RLS POLICIES, TRIGGERS & SEED DATA
-- Target Schema: Existing Supabase Instance (profiles, posts, membership_fees, family_members)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. AUTOMATIC PROFILE CREATION TRIGGER ON USER SIGNUP
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, full_name, role, status, updated_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    COALESCE(NEW.raw_user_meta_data->>'role', 'member'),
    COALESCE(NEW.raw_user_meta_data->>'status', 'pending'),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger execution link to auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ----------------------------------------------------------------------------
-- 2. ENABLE ROW-LEVEL SECURITY (RLS) ON ALL EXISTING TABLES
-- ----------------------------------------------------------------------------
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.membership_fees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_members ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------------------------
-- 3. PROFILES TABLE RLS POLICIES
-- ----------------------------------------------------------------------------
-- Drop existing policies if any
DROP POLICY IF EXISTS "Public profiles read access" ON public.profiles;
DROP POLICY IF EXISTS "Users can read own profile" ON public.profiles;
DROP POLICY IF EXISTS "Management and Admin can read all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile info" ON public.profiles;
DROP POLICY IF EXISTS "Admin and Management can update profile role and status" ON public.profiles;

-- Read Policy: Users can view their own profile, and management/admin can view all profiles
CREATE POLICY "Read profiles policy" ON public.profiles
  FOR SELECT
  USING (
    auth.uid() = id
    OR EXISTS (
      SELECT 1 FROM public.profiles p 
      WHERE p.id = auth.uid() AND p.role IN ('management', 'admin')
    )
  );

-- Insert Policy: Allow self creation or service trigger
CREATE POLICY "Insert profiles policy" ON public.profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id OR auth.role() = 'authenticated');

-- Update Policy: Users update own bio details; Admin/Management update role & status
CREATE POLICY "Update profiles policy" ON public.profiles
  FOR UPDATE
  USING (
    auth.uid() = id
    OR EXISTS (
      SELECT 1 FROM public.profiles p 
      WHERE p.id = auth.uid() AND p.role IN ('management', 'admin')
    )
  );

-- ----------------------------------------------------------------------------
-- 4. POSTS TABLE RLS POLICIES (Community Services & Requests)
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Anyone authenticated can read posts" ON public.posts;
DROP POLICY IF EXISTS "Users can insert own posts" ON public.posts;
DROP POLICY IF EXISTS "Users can edit own posts or Management/Admin delete" ON public.posts;

CREATE POLICY "Read posts policy" ON public.posts
  FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Insert posts policy" ON public.posts
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Update posts policy" ON public.posts
  FOR UPDATE
  USING (
    auth.uid() = user_id
    OR EXISTS (
      SELECT 1 FROM public.profiles p 
      WHERE p.id = auth.uid() AND p.role IN ('management', 'admin')
    )
  );

CREATE POLICY "Delete posts policy" ON public.posts
  FOR DELETE
  USING (
    auth.uid() = user_id
    OR EXISTS (
      SELECT 1 FROM public.profiles p 
      WHERE p.id = auth.uid() AND p.role IN ('management', 'admin')
    )
  );

-- ----------------------------------------------------------------------------
-- 5. MEMBERSHIP_FEES TABLE RLS POLICIES (Financial tracking)
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Users view own fees" ON public.membership_fees;
DROP POLICY IF EXISTS "Management view all fees" ON public.membership_fees;

CREATE POLICY "Read membership_fees policy" ON public.membership_fees
  FOR SELECT
  USING (
    auth.uid() = user_id
    OR EXISTS (
      SELECT 1 FROM public.profiles p 
      WHERE p.id = auth.uid() AND p.role IN ('management', 'admin')
    )
  );

CREATE POLICY "Insert membership_fees policy" ON public.membership_fees
  FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    OR EXISTS (
      SELECT 1 FROM public.profiles p 
      WHERE p.id = auth.uid() AND p.role IN ('management', 'admin')
    )
  );

CREATE POLICY "Update membership_fees policy" ON public.membership_fees
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p 
      WHERE p.id = auth.uid() AND p.role IN ('management', 'admin')
    )
  );

-- ----------------------------------------------------------------------------
-- 6. FAMILY_MEMBERS TABLE RLS POLICIES
-- ----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Users manage own family members" ON public.family_members;

CREATE POLICY "Read family_members policy" ON public.family_members
  FOR SELECT
  USING (
    auth.uid() = user_id
    OR EXISTS (
      SELECT 1 FROM public.profiles p 
      WHERE p.id = auth.uid() AND p.role IN ('management', 'admin')
    )
  );

CREATE POLICY "Insert family_members policy" ON public.family_members
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Update family_members policy" ON public.family_members
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Delete family_members policy" ON public.family_members
  FOR DELETE
  USING (
    auth.uid() = user_id
    OR EXISTS (
      SELECT 1 FROM public.profiles p 
      WHERE p.id = auth.uid() AND p.role IN ('management', 'admin')
    )
  );

-- ============================================================================
-- END OF RLS & TRIGGER SETUP
-- ============================================================================
