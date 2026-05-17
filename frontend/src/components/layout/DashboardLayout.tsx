import { Outlet, useNavigate, Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Briefcase, LogOut, User } from "lucide-react";
import { getUser, clearAuth } from "@/lib/auth";
import { ROLES } from "@/lib/constants";

export function DashboardLayout() {
  const navigate = useNavigate();
  const user = getUser();

  const handleLogout = () => {
    clearAuth();
    navigate("/");
  };

  const roleName = user?.roleId === ROLES.CLIENT ? "Client" : "Freelancer";

  return (
    <div className="flex min-h-screen flex-col bg-background">
      <nav className="sticky top-0 z-50 w-full border-b bg-card/80 backdrop-blur-md">
        <div className="container mx-auto flex h-16 items-center justify-between px-4">
          <Link
            to="/"
            className="flex items-center gap-2 font-bold text-xl tracking-tighter text-foreground"
          >
            <div className="bg-primary p-1.5 rounded-md">
              <Briefcase className="w-4 h-4 text-primary-foreground" />
            </div>
            Freelance Matcher
          </Link>

          <div className="flex items-center gap-3">
            <div className="flex items-center gap-2 rounded-full bg-muted px-3 py-1.5">
              <User className="w-3.5 h-3.5 text-muted-foreground" />
              <span className="text-sm font-medium text-muted-foreground">
                {user?.firstName} · {roleName}
              </span>
            </div>
            <Button variant="ghost" size="sm" onClick={handleLogout} className="gap-2">
              <LogOut className="w-4 h-4" />
              <span className="hidden sm:inline">Logout</span>
            </Button>
          </div>
        </div>
      </nav>

      <main className="flex-1 container mx-auto px-4 py-8">
        <Outlet />
      </main>
    </div>
  );
}
