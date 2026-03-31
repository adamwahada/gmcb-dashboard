
-- Table for MAB establishment settings
CREATE TABLE public.mab_establishments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  address TEXT,
  manager_name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.mab_establishments ENABLE ROW LEVEL SECURITY;

-- For now, public read/write since MAB doesn't use Supabase Auth yet
CREATE POLICY "Allow public read mab_establishments"
  ON public.mab_establishments FOR SELECT USING (true);
CREATE POLICY "Allow public update mab_establishments"
  ON public.mab_establishments FOR UPDATE USING (true);
CREATE POLICY "Allow public insert mab_establishments"
  ON public.mab_establishments FOR INSERT WITH CHECK (true);

-- Table for storage zones
CREATE TABLE public.mab_zones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  establishment_id UUID REFERENCES public.mab_establishments(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.mab_zones ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read mab_zones"
  ON public.mab_zones FOR SELECT USING (true);
CREATE POLICY "Allow public insert mab_zones"
  ON public.mab_zones FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update mab_zones"
  ON public.mab_zones FOR UPDATE USING (true);
CREATE POLICY "Allow public delete mab_zones"
  ON public.mab_zones FOR DELETE USING (true);

-- Table for operators
CREATE TABLE public.mab_operators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  establishment_id UUID REFERENCES public.mab_establishments(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'Opérateur',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.mab_operators ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read mab_operators"
  ON public.mab_operators FOR SELECT USING (true);
CREATE POLICY "Allow public insert mab_operators"
  ON public.mab_operators FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update mab_operators"
  ON public.mab_operators FOR UPDATE USING (true);
CREATE POLICY "Allow public delete mab_operators"
  ON public.mab_operators FOR DELETE USING (true);

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION public.update_mab_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

CREATE TRIGGER update_mab_establishments_updated_at
  BEFORE UPDATE ON public.mab_establishments
  FOR EACH ROW EXECUTE FUNCTION public.update_mab_updated_at();

-- Seed default establishment
INSERT INTO public.mab_establishments (slug, name, address, manager_name)
VALUES ('balthazar', 'Le Balthazar Bar', '12 Rue de la République, Tunis', 'Marc Dupont');

-- Seed default zones
INSERT INTO public.mab_zones (establishment_id, name, sort_order)
SELECT id, 'Bar principal', 0 FROM public.mab_establishments WHERE slug = 'balthazar'
UNION ALL
SELECT id, 'Réserve', 1 FROM public.mab_establishments WHERE slug = 'balthazar'
UNION ALL
SELECT id, 'Cave', 2 FROM public.mab_establishments WHERE slug = 'balthazar';

-- Seed default operators
INSERT INTO public.mab_operators (establishment_id, name, role)
SELECT id, 'Marc D.', 'Responsable' FROM public.mab_establishments WHERE slug = 'balthazar'
UNION ALL
SELECT id, 'Sophie L.', 'Opérateur' FROM public.mab_establishments WHERE slug = 'balthazar';
