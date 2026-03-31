
-- Create mab_sessions table
CREATE TABLE public.mab_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  establishment_id uuid NOT NULL REFERENCES public.mab_establishments(id) ON DELETE CASCADE,
  zone_id uuid REFERENCES public.mab_zones(id) ON DELETE SET NULL,
  zone_name text NOT NULL,
  operator_name text NOT NULL DEFAULT 'Opérateur',
  status text NOT NULL DEFAULT 'in_progress',
  started_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  total_items integer NOT NULL DEFAULT 0,
  total_photos integer NOT NULL DEFAULT 0,
  duration_minutes integer,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.mab_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read mab_sessions" ON public.mab_sessions FOR SELECT USING (true);
CREATE POLICY "Allow public insert mab_sessions" ON public.mab_sessions FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update mab_sessions" ON public.mab_sessions FOR UPDATE USING (true);

-- Create mab_session_items table
CREATE TABLE public.mab_session_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id uuid NOT NULL REFERENCES public.mab_sessions(id) ON DELETE CASCADE,
  product_name text NOT NULL,
  category text NOT NULL DEFAULT '',
  quantity integer NOT NULL DEFAULT 0,
  unit text NOT NULL DEFAULT 'bouteilles',
  photo_url text,
  stock_level text NOT NULL DEFAULT 'ok',
  note text,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.mab_session_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read mab_session_items" ON public.mab_session_items FOR SELECT USING (true);
CREATE POLICY "Allow public insert mab_session_items" ON public.mab_session_items FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update mab_session_items" ON public.mab_session_items FOR UPDATE USING (true);

-- Create storage bucket for photos
INSERT INTO storage.buckets (id, name, public) VALUES ('mab-photos', 'mab-photos', true);

-- Storage policies
CREATE POLICY "Anyone can upload mab photos" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'mab-photos');
CREATE POLICY "Anyone can view mab photos" ON storage.objects FOR SELECT USING (bucket_id = 'mab-photos');
