import { createContext, useContext, useEffect, useState, ReactNode } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import { supabase } from "@/integrations/supabase/client";
import type { Session } from "@supabase/supabase-js";
import { Loader2 } from "lucide-react";

interface GMCBAuthContextType {
  session: Session | null;
  loading: boolean;
  signOut: () => Promise<void>;
}

const GMCBAuthContext = createContext<GMCBAuthContextType>({
  session: null,
  loading: true,
  signOut: async () => {},
});

export const useGMCBAuth = () => useContext(GMCBAuthContext);

export const GMCBAuthProvider = ({ children }: { children: ReactNode }) => {
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);
  const [isAdmin, setIsAdmin] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    // Check if user is an admin via sessionStorage
    const userType = sessionStorage.getItem("userType");
    if (userType === "admin") {
      setIsAdmin(true);
      setLoading(false);
      return;
    }

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      setLoading(false);

      if (!session && location.pathname.startsWith("/clients/gmcb")) {
        navigate("/app/gmcb");
      }
    });

    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setLoading(false);

      if (!session && location.pathname.startsWith("/clients/gmcb")) {
        navigate("/app/gmcb");
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  const signOut = async () => {
    if (isAdmin) {
      navigate("/clients");
      return;
    }
    await supabase.auth.signOut();
    navigate("/app/gmcb");
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background">
        <Loader2 className="h-8 w-8 animate-spin text-teal-500" />
      </div>
    );
  }

  // Admin bypass — skip Supabase auth check
  if (isAdmin) {
    return (
      <GMCBAuthContext.Provider value={{ session, loading, signOut }}>
        {children}
      </GMCBAuthContext.Provider>
    );
  }

  if (!session) {
    return null;
  }

  // Check that the user email matches gmcb client OR is an admin
  const email = session.user?.email || "";
  const isAdminEmail = email === "admin@octomiro.ai";
  const isGmcbClient = email.endsWith("@octomiro.ai") && email.startsWith("gmcb");
  if (!isAdminEmail && !isGmcbClient) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background">
        <div className="text-center space-y-4">
          <p className="text-destructive font-medium">Accès non autorisé</p>
          <p className="text-sm text-muted-foreground">Ce compte n'a pas accès à l'espace GMCB.</p>
          <button onClick={signOut} className="text-sm text-teal-500 hover:underline">Se déconnecter</button>
        </div>
      </div>
    );
  }

  return (
    <GMCBAuthContext.Provider value={{ session, loading, signOut }}>
      {children}
    </GMCBAuthContext.Provider>
  );
};
