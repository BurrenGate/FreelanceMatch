import { Link, useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Briefcase, User, LogOut } from "lucide-react";
import { getUser, getToken, clearAuth } from "@/lib/auth";
import { ROLES } from "@/lib/constants";

export function Navbar() {
  const navigate = useNavigate();
  const token = getToken();
  const user = getUser();

  const handleLogout = () => {
    clearAuth();
    navigate("/login");
  };

  return (
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
          {!token ? (
            <>
              <Button variant="ghost" asChild>
                <Link to="/login">Login</Link>
              </Button>
              <Button asChild>
                <Link to="/register">Sign Up</Link>
              </Button>
            </>
          ) : (
            <>
              <span className="text-sm font-medium text-muted-foreground hidden md:block">
                {user?.roleId === ROLES.CLIENT ? "Client" : "Freelancer"}
              </span>
              <Button variant="outline" size="icon" className="rounded-full" asChild>
                <Link to={user?.roleId === ROLES.CLIENT ? "/client/dashboard" : "/freelancer/dashboard"}>
                  <User className="w-4 h-4" />
                </Link>
              </Button>
              <Button variant="ghost" size="icon" onClick={handleLogout}>
                <LogOut className="w-4 h-4" />
              </Button>
            </>
          )}
        </div>
      </div>
    </nav>
  );
}
