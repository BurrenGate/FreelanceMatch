import { useMemo, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { ArrowLeft, ArrowRight, BadgeCheck, BriefcaseBusiness, CircleUserRound, ShieldCheck } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { toast } from "sonner";
import { authApi, extractApiMessage } from "@/lib/api";
import type { RegisterRequest } from "@/shared/api/generated";

type RegisterStep = 1 | 2 | 3;
type RegisterFormState = {
  firstName: string;
  lastName: string;
  email: string;
  password: string;
  hourlyRate: string;
};

export default function Register() {
  const navigate = useNavigate();
  const [role, setRole] = useState("2");
  const [loading, setLoading] = useState(false);
  const [step, setStep] = useState<RegisterStep>(1);
  const [formState, setFormState] = useState<RegisterFormState>({
    firstName: "",
    lastName: "",
    email: "",
    password: "",
    hourlyRate: "",
  });

  const progress = useMemo(() => (step / 3) * 100, [step]);

  const goNext = () => setStep((prev) => (prev < 3 ? (prev + 1) as RegisterStep : prev));
  const goBack = () => setStep((prev) => (prev > 1 ? (prev - 1) as RegisterStep : prev));

  const validateCurrentStep = () => {
    if (step === 1) {
      if (!formState.firstName.trim() || !formState.lastName.trim()) {
        toast.error("Please fill in all required fields before continuing.");
        return false;
      }
      return true;
    }
    if (step === 2) {
      if (!formState.email.trim() || !formState.password.trim()) {
        toast.error("Please fill in all required fields before continuing.");
        return false;
      }
      if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formState.email.trim())) {
        toast.error("Please enter a valid email.");
        return false;
      }
      return true;
    }

    if (role === "2") {
      if (!formState.hourlyRate.trim() || Number(formState.hourlyRate) <= 0) {
        toast.error("Please provide a valid hourly rate.");
        return false;
      }
    }

    return true;
  };

  const handleNext = (e: React.MouseEvent<HTMLButtonElement>) => {
    e.preventDefault();
    if (validateCurrentStep()) {
      goNext();
    }
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (step < 3) {
      if (validateCurrentStep()) {
        goNext();
      }
      return;
    }

    if (!validateCurrentStep()) return;

    setLoading(true);

    const body: RegisterRequest = {
      firstName: formState.firstName.trim(),
      lastName: formState.lastName.trim(),
      email: formState.email.trim(),
      password: formState.password,
      roleId: Number(role),
    };

    if (role === "2") {
      body.hourlyRate = Number(formState.hourlyRate);
    }

    try {
      await authApi.register(body);
      toast.success("Account created successfully. Please sign in.");
      navigate("/login");
    } catch (error) {
      toast.error(extractApiMessage(error, "Registration failed"));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="relative isolate min-h-[calc(100vh-10rem)] overflow-hidden px-4 py-12">
      <div className="pointer-events-none absolute inset-0 -z-10 bg-[radial-gradient(circle_at_top_right,_rgba(14,165,233,0.18),_transparent_40%),radial-gradient(circle_at_bottom_left,_rgba(16,185,129,0.16),_transparent_35%)]" />

      <div className="mx-auto grid w-full max-w-6xl items-start gap-8 lg:grid-cols-[0.82fr_1.18fr]">
        <Card className="hidden border-slate-200 bg-white/85 p-1 shadow-xl backdrop-blur lg:block animate-in fade-in-0 slide-in-from-left-4 duration-500">
          <CardContent className="space-y-5 p-6">
            <Badge className="w-fit bg-slate-900 text-white hover:bg-slate-900">Onboarding Flow</Badge>
            <h2 className="text-2xl font-bold tracking-tight text-slate-900">Professional registration in three steps</h2>
            <p className="text-sm leading-relaxed text-slate-600">
              Set your role, secure your account, and complete profile details to unlock the full workflow from jobs to contracts.
            </p>
            <div className="space-y-3 text-sm text-slate-700">
              <p className="inline-flex items-center gap-2"><CircleUserRound className="h-4 w-4 text-cyan-700" /> Step 1: Identity and role</p>
              <p className="inline-flex items-center gap-2"><ShieldCheck className="h-4 w-4 text-emerald-700" /> Step 2: Account security</p>
              <p className="inline-flex items-center gap-2"><BriefcaseBusiness className="h-4 w-4 text-indigo-700" /> Step 3: Work preferences</p>
            </div>
          </CardContent>
        </Card>

        <Card className="w-full border-slate-200 bg-white/95 shadow-2xl backdrop-blur animate-in fade-in-0 slide-in-from-bottom-4 duration-500">
          <CardHeader className="space-y-4 pb-2">
            <div className="flex items-center justify-between">
              <CardTitle className="text-2xl font-bold text-slate-900">Create account</CardTitle>
              <Badge variant="secondary" className="bg-slate-900 text-white">Step {step} of 3</Badge>
            </div>
            <Progress value={progress} className="h-2" />
            <Tabs defaultValue="2" value={role} onValueChange={setRole} className="w-full">
              <TabsList className="grid w-full grid-cols-2">
                <TabsTrigger value="2">Freelancer</TabsTrigger>
                <TabsTrigger value="1">Client</TabsTrigger>
              </TabsList>
            </Tabs>
          </CardHeader>

          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-5">
              {step === 1 && (
                <div className="grid gap-4 animate-in fade-in-0 slide-in-from-right-3 duration-300 sm:grid-cols-2">
                  <div className="space-y-2">
                    <label className="text-sm font-medium text-slate-900">First Name</label>
                    <Input
                      name="firstName"
                      placeholder="Richard"
                      className="h-11"
                      required
                      value={formState.firstName}
                      onChange={(e) => setFormState((prev) => ({ ...prev, firstName: e.target.value }))}
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-sm font-medium text-slate-900">Last Name</label>
                    <Input
                      name="lastName"
                      placeholder="Hendricks"
                      className="h-11"
                      required
                      value={formState.lastName}
                      onChange={(e) => setFormState((prev) => ({ ...prev, lastName: e.target.value }))}
                    />
                  </div>
                </div>
              )}

              {step === 2 && (
                <div className="space-y-4 animate-in fade-in-0 slide-in-from-right-3 duration-300">
                  <div className="space-y-2">
                    <label className="text-sm font-medium text-slate-900">Work Email</label>
                    <Input
                      name="email"
                      type="email"
                      placeholder="you@company.com"
                      className="h-11"
                      required
                      value={formState.email}
                      onChange={(e) => setFormState((prev) => ({ ...prev, email: e.target.value }))}
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-sm font-medium text-slate-900">Password</label>
                    <Input
                      name="password"
                      type="password"
                      className="h-11"
                      required
                      value={formState.password}
                      onChange={(e) => setFormState((prev) => ({ ...prev, password: e.target.value }))}
                    />
                  </div>
                </div>
              )}

              {step === 3 && (
                <div className="space-y-4 animate-in fade-in-0 slide-in-from-right-3 duration-300">
                  {role === "2" ? (
                    <div className="space-y-2">
                      <label className="text-sm font-medium text-slate-900">Hourly Rate (USD)</label>
                      <Input
                        name="hourlyRate"
                        type="number"
                        placeholder="85"
                        min="1"
                        className="h-11"
                        required
                        value={formState.hourlyRate}
                        onChange={(e) => setFormState((prev) => ({ ...prev, hourlyRate: e.target.value }))}
                      />
                      <p className="text-xs text-muted-foreground">This helps clients estimate project budget and shortlist faster.</p>
                    </div>
                  ) : (
                    <div className="rounded-lg border border-emerald-200 bg-emerald-50 p-4 text-sm text-emerald-900">
                      Client profile is ready. You can define project budgets and required skills after sign up.
                    </div>
                  )}
                  <div className="rounded-lg border border-slate-200 bg-slate-50 p-4 text-sm text-slate-700">
                    <p className="inline-flex items-center gap-2 font-medium text-slate-900"><BadgeCheck className="h-4 w-4 text-cyan-700" /> Final confirmation</p>
                    <p className="mt-1">By creating an account, you agree to operate professionally and keep project data accurate.</p>
                  </div>
                </div>
              )}

              <div className="flex flex-wrap items-center justify-between gap-3 pt-1">
                <Button type="button" variant="ghost" onClick={goBack} disabled={step === 1 || loading}>
                  <ArrowLeft className="mr-2 h-4 w-4" />
                  Back
                </Button>

                <div className="flex items-center gap-3">
                  {step < 3 ? (
                    <Button type="button" onClick={handleNext}>
                      Continue
                      <ArrowRight className="ml-2 h-4 w-4" />
                    </Button>
                  ) : (
                    <Button type="submit" disabled={loading}>
                      {loading ? "Creating account..." : "Create account"}
                    </Button>
                  )}
                </div>
              </div>

              <p className="text-center text-sm text-muted-foreground">
                Already have an account?{" "}
                <Link to="/login" className="font-semibold text-primary hover:underline">
                  Sign in
                </Link>
              </p>
            </form>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
