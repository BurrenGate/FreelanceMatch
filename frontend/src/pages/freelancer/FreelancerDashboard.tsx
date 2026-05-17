import { useState, useEffect, type ElementType } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuLabel,
  DropdownMenuSeparator, DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { toast } from "sonner";
import { 
  Search, DollarSign, Briefcase, User, Bell, 
  LayoutDashboard, LogOut, ChevronRight,
  TrendingUp, CheckCircle, FileText, Sparkles, Star, CheckCheck, Users
} from "lucide-react";
import { getUser } from "@/lib/auth";
import { api, extractApiMessage, unwrapData } from "@/lib/api";
import FreelancerProfile from "./FreelancerProfile";
import ContractsView from "./Contracts";
import ProposalsView from "./Proposals";
import FindWorkView from "./FindWorkView";
import ClientChat from "@/pages/client/ClientChat";

// --- Интерфейсы ---
interface FreelancerDashboardStats {
  activeContracts: number;
  averageRating: number;
  completedJobs: number;
  jobSuccessScore: number;
  pendingProposals: number;
  recentActivity: DashboardActivity[];
  totalEarnings: number;
  totalProposalsSubmitted: number;
}

interface DashboardActivity {
  id?: number | string;
  title?: string;
  description?: string;
  time?: string;
}

export default function FreelancerAppLayout() {
  const user = getUser();
  const [activePage, setActivePage] = useState("dashboard");
  const [findWorkPrefillJobId, setFindWorkPrefillJobId] = useState<string | null>(null);
  const displayName = user?.firstName?.trim() || "Freelancer";

  const navItems = [
    { id: "dashboard", label: "Dashboard", icon: LayoutDashboard },
    { id: "jobs", label: "Find Work", icon: Search },
    { id: "chat", label: "Chat", icon: Users },
    { id: "contracts", label: "My Contracts", icon: Briefcase },
    { id: "proposals", label: "Proposals", icon: FileText },
  ];

  useEffect(() => {
    const handler = (event: Event) => {
      const customEvent = event as CustomEvent<{ page?: string; jobId?: number | string }>;
      const page = customEvent.detail?.page;
      if (page) setActivePage(page);
      if (page === "jobs" && customEvent.detail?.jobId != null) {
        setFindWorkPrefillJobId(String(customEvent.detail.jobId));
      }
    };

    window.addEventListener("freelancer:navigate", handler as EventListener);
    return () => window.removeEventListener("freelancer:navigate", handler as EventListener);
  }, []);

  return (
    <div className="flex min-h-screen bg-slate-100/70">
      <aside className="hidden w-72 flex-col border-r border-slate-200 bg-white md:flex">
        <div className="border-b border-slate-200 p-5">
          <div className="flex items-center gap-3">
            <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-slate-900 text-white">F</div>
            <div>
              <p className="text-sm font-semibold text-slate-900">Freelancer Hub</p>
              <p className="text-xs text-slate-500">Pied Piper Marketplace</p>
            </div>
          </div>
          <Button className="mt-4 w-full" onClick={() => setActivePage("jobs")}>
            <Search className="mr-2 h-4 w-4" /> Find New Work
          </Button>
        </div>

        <nav className="flex-1 space-y-1 p-4">
          {navItems.map((item) => (
            <NavItem
              key={item.id}
              icon={item.icon}
              label={item.label}
              isActive={activePage === item.id}
              onClick={() => setActivePage(item.id)}
            />
          ))}
        </nav>

        <div className="border-t border-slate-200 p-4">
          <button
            onClick={() => setActivePage("profile")}
            className="flex w-full items-center gap-3 rounded-lg p-2 text-left hover:bg-slate-100"
          >
            <Avatar className="h-9 w-9 border">
              <AvatarImage src="/placeholder-avatar.jpg" alt={displayName} />
              <AvatarFallback className="bg-cyan-100 text-cyan-800">
                {displayName.charAt(0)}
              </AvatarFallback>
            </Avatar>
            <div>
              <p className="text-sm font-semibold text-slate-900">{displayName}</p>
              <p className="text-xs text-slate-500">View profile</p>
            </div>
          </button>
        </div>
      </aside>

      <main className="flex-1 flex min-w-0 flex-col">
        <header className="sticky top-0 z-10 flex h-16 items-center justify-between border-b border-slate-200 bg-white px-6">
          <div className="md:hidden text-lg font-bold text-primary">PP</div>
          
          <div className="flex-1 flex items-center justify-end gap-4">
            <Button variant="ghost" size="icon" className="relative text-muted-foreground hover:text-foreground">
              <Bell className="w-5 h-5" />
              <span className="absolute top-2 right-2 w-2 h-2 bg-red-500 rounded-full"></span>
            </Button>
            
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" className="relative h-9 w-9 rounded-full">
                    <Avatar className="h-9 w-9 border">
                    <AvatarImage src="/placeholder-avatar.jpg" alt={displayName} />
                    <AvatarFallback className="bg-primary/10 text-primary">
                      {displayName.charAt(0)}
                    </AvatarFallback>
                  </Avatar>
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent className="w-56" align="end" forceMount>
                <DropdownMenuLabel className="font-normal">
                  <div className="flex flex-col space-y-1">
                    <p className="text-sm font-medium leading-none">{displayName}</p>
                    <p className="text-xs leading-none text-muted-foreground">{user?.email || "user@example.com"}</p>
                  </div>
                </DropdownMenuLabel>
                <DropdownMenuSeparator />
                <DropdownMenuItem onClick={() => setActivePage("profile")} className="cursor-pointer">
                  <User className="mr-2 h-4 w-4" />
                  <span>My Profile</span>
                </DropdownMenuItem>
                <DropdownMenuItem className="cursor-pointer text-red-600 focus:text-red-600 focus:bg-red-50">
                  <LogOut className="mr-2 h-4 w-4" />
                  <span>Log out</span>
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </header>

        <div className="flex-1 overflow-auto p-6 lg:p-8">
          {activePage === "dashboard" && <DashboardOverview onNavigate={setActivePage} />}
          {activePage === "jobs" && <FindWorkView prefillJobId={findWorkPrefillJobId} />}
          {activePage === "chat" && <ClientChat />}
          {activePage === "contracts" && <ContractsView />}
          {activePage === "proposals" && <ProposalsView />}
          {activePage === "profile" && <FreelancerProfile />}
        </div>
      </main>
    </div>
  );
}

function NavItem({ icon: Icon, label, isActive, onClick }: { icon: ElementType; label: string; isActive: boolean; onClick: () => void }) {
  return (
    <button
      onClick={onClick}
      className={`flex w-full items-center justify-between rounded-lg px-3 py-2.5 text-sm font-medium transition-colors ${
        isActive ? "bg-slate-900 text-white" : "text-slate-600 hover:bg-slate-100"
      }`}
    >
      <span className="flex items-center gap-2">
        <Icon className="h-4 w-4" />
        {label}
      </span>
      {isActive && <ChevronRight className="h-4 w-4" />}
    </button>
  );
}

function StatCard({
  title,
  value,
  icon: Icon,
  trend,
  trendColor = "text-slate-500",
}: {
  title: string;
  value: string | number;
  icon: ElementType;
  trend?: string;
  trendColor?: string;
}) {
  return (
    <Card className="border-slate-200">
      <CardContent className="p-5">
        <div className="mb-2 flex items-center justify-between">
          <p className="text-xs font-semibold uppercase tracking-wider text-slate-500">{title}</p>
          <Icon className="h-4 w-4 text-cyan-700" />
        </div>
        <div className="text-3xl font-bold text-slate-900">{value}</div>
        {trend && <p className={`text-xs mt-1 ${trendColor}`}>{trend}</p>}
      </CardContent>
    </Card>
  );
}

function DashboardOverview({ onNavigate }: { onNavigate: (page: string) => void }) {
  const user = getUser();
  const [dashboardStats, setDashboardStats] = useState<FreelancerDashboardStats | null>(null);
  const [loadingStats, setLoadingStats] = useState(true);

  useEffect(() => {
    const fetchDashboardStats = async () => {
      try {
        setLoadingStats(true);
        const res = await api.get("/api/profiles/me/dashboard");
        const data = unwrapData<FreelancerDashboardStats>(res.data);
        setDashboardStats(data);
      } catch (error) {
        console.error("Failed to fetch dashboard stats:", error);
        toast.error(extractApiMessage(error, "Network error while loading dashboard stats."));
      } finally {
        setLoadingStats(false);
      }
    };

    fetchDashboardStats();
  }, []);

  return (
    <div className="mx-auto max-w-7xl space-y-6 animate-in fade-in slide-in-from-bottom-2 duration-300">
      <section className="relative overflow-hidden rounded-2xl border border-slate-200 bg-[linear-gradient(135deg,#0f172a_0%,#155e75_52%,#0f766e_100%)] p-6 text-white shadow-xl md:p-8">
        <div className="pointer-events-none absolute -right-20 -top-20 h-56 w-56 rounded-full bg-cyan-300/20 blur-3xl" />
        <div className="pointer-events-none absolute -bottom-16 -left-10 h-48 w-48 rounded-full bg-emerald-300/20 blur-3xl" />
        <div className="relative flex flex-col gap-5 md:flex-row md:items-end md:justify-between">
          <div>
            <p className="mb-2 inline-flex items-center gap-2 rounded-full bg-white/10 px-3 py-1 text-xs font-semibold uppercase tracking-[0.14em] text-cyan-100">
              <Sparkles className="h-3.5 w-3.5" /> Freelancer Workspace
            </p>
            <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
              Welcome back, {user?.firstName || "Freelancer"}
            </h1>
            <p className="mt-2 max-w-2xl text-sm text-slate-200 md:text-base">
              Keep your pipeline healthy, grow your earnings, and stay on top of active deliveries.
            </p>
          </div>
          <div className="flex gap-2">
            <Button onClick={() => onNavigate("jobs")} className="h-11 bg-white text-slate-900 hover:bg-slate-100">
              Find New Work
            </Button>
            <Button variant="secondary" className="h-11 border-white/30 bg-white/10 text-white hover:bg-white/20" onClick={() => onNavigate("proposals")}>
              View Proposals
            </Button>
          </div>
        </div>
      </section>

      {loadingStats ? (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {[1, 2, 3, 4].map(i => (
            <Card key={i} className="h-28 animate-pulse border-none bg-muted/50"></Card>
          ))}
        </div>
      ) : (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <StatCard title="Total Earnings" value={`$${dashboardStats?.totalEarnings?.toLocaleString() || "0.00"}`} icon={DollarSign} />
          <StatCard title="Active Contracts" value={dashboardStats?.activeContracts || 0} icon={Briefcase} />
          <StatCard title="Pending Proposals" value={dashboardStats?.pendingProposals || 0} icon={FileText} />
          <StatCard 
            title="Job Success Score" 
            value={`${dashboardStats?.jobSuccessScore || 0}%`} 
            icon={TrendingUp} 
            trend={dashboardStats && dashboardStats.jobSuccessScore >= 90 ? "Top Rated" : undefined} 
            trendColor="text-green-600" 
          />
        </div>
      )}

      <section className="grid gap-5 lg:grid-cols-3">
        <Card className="border-slate-200 lg:col-span-2">
          <CardHeader>
            <CardTitle className="text-lg">Recent Activity</CardTitle>
            <CardDescription>Your latest proposals and contract updates.</CardDescription>
          </CardHeader>
          <CardContent className="min-h-[100px]">
            <div className="space-y-4">
              {dashboardStats?.recentActivity && dashboardStats.recentActivity.length > 0 ? (
                dashboardStats.recentActivity.map((activity, index) => (
                  <div key={activity.id || index} className="flex items-center gap-4 border-b pb-4 text-sm last:border-0 last:pb-0">
                    <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-blue-100 text-blue-600">
                      <CheckCircle className="h-5 w-5" />
                    </div>
                    <div className="flex-1">
                      <p className="font-medium">{activity.title || "Activity update"}</p>
                      <p className="text-muted-foreground">{activity.description || "New event occurred."}</p>
                    </div>
                    <span className="text-xs text-muted-foreground">{activity.time || "Recently"}</span>
                  </div>
                ))
              ) : (
                <p className="py-4 text-center text-sm text-muted-foreground">No recent activity to display.</p>
              )}
            </div>
          </CardContent>
        </Card>

        <Card className="border-slate-200">
          <CardHeader>
            <CardTitle className="text-lg">Performance Snapshot</CardTitle>
            <CardDescription>How clients see your profile right now.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="rounded-lg border border-slate-200 bg-slate-50 p-3">
              <p className="text-xs font-semibold uppercase tracking-wider text-slate-500">Average Rating</p>
              <p className="mt-1 flex items-center gap-2 text-lg font-semibold text-slate-900">
                <Star className="h-4 w-4 text-amber-500" />
                {dashboardStats?.averageRating ? Number(dashboardStats.averageRating).toFixed(2) : "N/A"}
              </p>
            </div>
            <div className="rounded-lg border border-slate-200 bg-slate-50 p-3">
              <p className="text-xs font-semibold uppercase tracking-wider text-slate-500">Completed Jobs</p>
              <p className="mt-1 flex items-center gap-2 text-lg font-semibold text-slate-900">
                <CheckCheck className="h-4 w-4 text-emerald-600" />
                {dashboardStats?.completedJobs || 0}
              </p>
            </div>
            <div className="rounded-lg border border-slate-200 bg-slate-50 p-3">
              <p className="text-xs font-semibold uppercase tracking-wider text-slate-500">Total Proposals Sent</p>
              <p className="mt-1 flex items-center gap-2 text-lg font-semibold text-slate-900">
                <FileText className="h-4 w-4 text-cyan-700" />
                {dashboardStats?.totalProposalsSubmitted || 0}
              </p>
            </div>
            <div className="grid grid-cols-2 gap-2 pt-1">
              <Button variant="outline" size="sm" onClick={() => onNavigate("profile")}>Update Profile</Button>
              <Button size="sm" onClick={() => onNavigate("contracts")}>Open Contracts</Button>
            </div>
          </CardContent>
        </Card>
      </section>
    </div>
  );
}
