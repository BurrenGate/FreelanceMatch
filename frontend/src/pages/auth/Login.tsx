import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { ArrowRight, LockKeyhole, ShieldCheck } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { toast } from "sonner";
import { ROLES } from "@/lib/constants";
import { setAuth } from "@/lib/auth";
import { authApi, extractApiMessage } from "@/lib/api";
import type { LoginRequest } from "@/shared/api/generated";

export default function Login() {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);
    const formData = new FormData(e.currentTarget);
    const email = formData.get("email") as string;
    const password = formData.get("password") as string;

    try {
      const payload: LoginRequest = { email, password };
      const res = await authApi.login(payload);
      const result = res.data;

      if (result.success && result.data) {
        const token = result.data;
        const base64Url = token.split(".")[1];
        const base64 = base64Url.replace(/-/g, "+").replace(/_/g, "/");
        const jsonPayload = decodeURIComponent(
          window
            .atob(base64)
            .split("")
            .map((char) => `%${(`00${char.charCodeAt(0).toString(16)}`).slice(-2)}`)
            .join(""),
        );

        const decodedToken = JSON.parse(jsonPayload);
        const user = {
          id: 0,
          email: decodedToken.sub,
          roleId: decodedToken.roleId,
          firstName: "User",
          lastName: "",
        };

        setAuth(token, user);
        toast.success("Welcome back to Freelance Matcher");
        navigate(user.roleId === ROLES.CLIENT ? "/client/dashboard" : "/freelancer/dashboard");
      } else {
        toast.error(result.message || "Invalid credentials");
      }
    } catch (error) {
      console.error("Login error:", error);
      toast.error(extractApiMessage(error, "An error occurred during login."));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="relative isolate min-h-[calc(100vh-10rem)] overflow-hidden px-4 py-12">
      <div className="pointer-events-none absolute inset-0 -z-10 bg-[radial-gradient(circle_at_top_left,_rgba(14,165,233,0.16),_transparent_40%),radial-gradient(circle_at_bottom_right,_rgba(16,185,129,0.14),_transparent_35%)]" />

      <div className="mx-auto grid w-full max-w-5xl items-center gap-8 lg:grid-cols-[0.95fr_1.05fr]">
        <div className="hidden space-y-4 rounded-2xl border border-slate-200 bg-white/85 p-7 shadow-xl backdrop-blur md:block animate-in fade-in-0 slide-in-from-left-4 duration-500">
          <Badge className="w-fit bg-slate-900 text-white hover:bg-slate-900">Secure Workspace</Badge>
          <h1 className="text-3xl font-bold tracking-tight text-slate-900">Sign in to continue your projects</h1>
          <p className="text-sm leading-relaxed text-slate-600">
            Manage proposals, contracts, and payments in one professional workspace designed for clients and freelancers.
          </p>
          <div className="space-y-3 pt-2 text-sm text-slate-700">
            <p className="inline-flex items-center gap-2"><ShieldCheck className="h-4 w-4 text-emerald-600" /> JWT-protected sessions</p>
            <p className="inline-flex items-center gap-2"><LockKeyhole className="h-4 w-4 text-cyan-700" /> Contract-first collaboration flow</p>
          </div>
        </div>

        <Card className="w-full border-slate-200 bg-white/95 shadow-2xl backdrop-blur animate-in fade-in-0 slide-in-from-bottom-4 duration-500">
          <CardHeader className="space-y-2">
            <CardTitle className="text-2xl font-bold text-slate-900">Sign in</CardTitle>
            <CardDescription>Use your work account to access Freelance Matcher dashboard</CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium text-slate-900">Email</label>
                <Input name="email" type="email" placeholder="you@company.com" required className="h-11" />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-slate-900">Password</label>
                <Input name="password" type="password" required className="h-11" />
              </div>
              <Button type="submit" className="h-11 w-full" disabled={loading}>
                {loading ? "Authenticating..." : "Continue"}
                {!loading && <ArrowRight className="ml-2 h-4 w-4" />}
              </Button>
              <p className="text-center text-sm text-muted-foreground">
                Don&apos;t have an account?{" "}
                <Link to="/register" className="font-semibold text-primary hover:underline">
                  Create one
                </Link>
              </p>
            </form>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
