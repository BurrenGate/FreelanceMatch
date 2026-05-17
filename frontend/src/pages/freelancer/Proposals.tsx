import { useEffect, useMemo, useState, type ElementType } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  FileText,
  Send,
  Eye,
  MessageCircle,
  XCircle,
  CheckCircle2,
  Clock,
  DollarSign,
  Search,
  Hourglass,
  Sparkles,
  Briefcase,
} from "lucide-react";
import { api, extractApiMessage, unwrapData } from "@/lib/api";
import { getUser } from "@/lib/auth";
import { toast } from "sonner";
import type { Proposal } from "@/shared/api/generated";

interface ProposalDetails {
  id: number;
  jobId: number;
  freelancerId?: number;
  jobTitle: string;
  bidAmount: number;
  coverLetterSnippet: string;
  status: string;
  submittedAt: string | null;
}

interface ProposalDetailedDto {
  id?: number;
  jobId?: number;
  freelancerId?: number;
  jobTitle?: string;
  bidAmount?: number;
  coverLetter?: string;
  status?: string;
  createdAt?: string;
}

const activeStatuses = ["pending", "submitted", "viewed", "interviewing"];
const archivedStatuses = ["accepted", "rejected", "withdrawn"];

export default function ProposalsView() {
  const currentUser = getUser();
  const [proposals, setProposals] = useState<ProposalDetails[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState("active");

  useEffect(() => {
    const fetchProposals = async () => {
      setLoading(true);
      try {
        const response = await api.get("/api/proposals/detailed");
        const data = unwrapData<ProposalDetailedDto[] | Proposal[]>(response.data);
        const safe = Array.isArray(data) ? data : [];

        const mapped: ProposalDetails[] = safe.map((item) => ({
          id: Number(item.id ?? 0),
          jobId: Number(item.jobId ?? 0),
          freelancerId: (item as ProposalDetailedDto).freelancerId != null ? Number((item as ProposalDetailedDto).freelancerId) : undefined,
          jobTitle: (item as ProposalDetailedDto).jobTitle || `Project / Job #${item.jobId ?? "N/A"}`,
          bidAmount: Number(item.bidAmount ?? 0),
          coverLetterSnippet: String(item.coverLetter ?? ""),
          status: String(item.status ?? "submitted").toLowerCase(),
          submittedAt: item.createdAt ?? null,
        }));

        const ownOnly = mapped.filter((proposal) => {
          if (proposal.freelancerId == null || currentUser?.id == null) return true;
          return Number(proposal.freelancerId) === Number(currentUser.id);
        });

        setProposals(ownOnly);
      } catch (error) {
        toast.error(extractApiMessage(error, "Failed to fetch proposals."));
        setProposals([]);
      } finally {
        setLoading(false);
      }
    };

    fetchProposals();
  }, [currentUser?.id]);

  const filteredProposals = useMemo(() => {
    return proposals.filter((proposal) => {
      if (activeTab === "active") return activeStatuses.includes(proposal.status);
      if (activeTab === "archived") return archivedStatuses.includes(proposal.status);
      return true;
    });
  }, [proposals, activeTab]);

  const stats = useMemo(() => {
    const active = proposals.filter((proposal) => activeStatuses.includes(proposal.status)).length;
    const accepted = proposals.filter((proposal) => proposal.status === "accepted").length;
    const totalBid = proposals.reduce((sum, proposal) => sum + proposal.bidAmount, 0);
    return { active, accepted, totalBid };
  }, [proposals]);

  return (
    <div className="mx-auto max-w-7xl space-y-6 animate-in fade-in slide-in-from-bottom-2 duration-300">
      <section className="relative overflow-hidden rounded-2xl border border-slate-200 bg-[linear-gradient(135deg,#0f172a_0%,#155e75_52%,#0f766e_100%)] p-6 text-white shadow-xl md:p-8">
        <div className="pointer-events-none absolute -right-20 -top-20 h-56 w-56 rounded-full bg-cyan-300/20 blur-3xl" />
        <div className="pointer-events-none absolute -bottom-16 -left-10 h-48 w-48 rounded-full bg-emerald-300/20 blur-3xl" />
        <div className="relative flex flex-col gap-5 md:flex-row md:items-end md:justify-between">
          <div>
            <p className="mb-2 inline-flex items-center gap-2 rounded-full bg-white/10 px-3 py-1 text-xs font-semibold uppercase tracking-[0.14em] text-cyan-100">
              <Sparkles className="h-3.5 w-3.5" /> Proposal Pipeline
            </p>
            <h1 className="text-3xl font-bold tracking-tight md:text-4xl">My Proposals</h1>
            <p className="mt-2 max-w-2xl text-sm text-slate-200 md:text-base">
              Track where every application stands, respond faster, and convert interviews into contracts.
            </p>
          </div>
          <div className="grid grid-cols-3 gap-2">
            <StatPill label="Total" value={proposals.length} />
            <StatPill label="Active" value={stats.active} />
            <StatPill label="Accepted" value={stats.accepted} />
          </div>
        </div>
      </section>

      <section className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm md:p-5">
        <div className="mb-4 flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.16em] text-cyan-700">Total Bid Value</p>
            <p className="text-2xl font-bold text-slate-900">${stats.totalBid.toLocaleString("en-US", { maximumFractionDigits: 2 })}</p>
          </div>
          <Badge variant="outline" className="w-fit text-xs">{filteredProposals.length} visible proposals</Badge>
        </div>

        <Tabs defaultValue="active" onValueChange={setActiveTab} className="w-full">
          <TabsList className="mb-6 grid w-full max-w-[420px] grid-cols-2">
            <TabsTrigger value="active">Active Proposals</TabsTrigger>
            <TabsTrigger value="archived">Archived</TabsTrigger>
          </TabsList>

          <div className="space-y-4">
            {loading ? (
              Array.from({ length: 3 }).map((_, i) => (
                <Card key={i} className="animate-pulse border-slate-200 bg-muted/40">
                  <CardContent className="h-36 p-6"></CardContent>
                </Card>
              ))
            ) : filteredProposals.length === 0 ? (
              <Card className="border-dashed border-2 border-slate-300 bg-transparent">
                <CardContent className="flex flex-col items-center justify-center p-16 text-center">
                  <div className="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-muted">
                    <FileText className="h-8 w-8 text-muted-foreground" />
                  </div>
                  <h3 className="text-xl font-semibold">No proposals found</h3>
                  <p className="mt-2 max-w-md text-muted-foreground">
                    {activeTab === "active"
                      ? "You have no active applications right now. Explore jobs and send your next proposal."
                      : "Archived proposals will appear here once statuses are closed."}
                  </p>
                  {activeTab === "active" && (
                    <Button
                      className="mt-6 gap-2"
                      onClick={() => {
                        window.dispatchEvent(new CustomEvent("freelancer:navigate", { detail: { page: "jobs" } }));
                      }}
                    >
                      <Search className="h-4 w-4" /> Browse Jobs
                    </Button>
                  )}
                </CardContent>
              </Card>
            ) : (
              filteredProposals.map((proposal) => (
                <ProposalCard key={proposal.id} proposal={proposal} />
              ))
            )}
          </div>
        </Tabs>
      </section>
    </div>
  );
}

function StatPill({ label, value }: { label: string; value: number }) {
  return (
    <Card className="border-white/20 bg-white/10 text-white">
      <CardContent className="p-3">
        <p className="text-[11px] uppercase tracking-wider text-cyan-100">{label}</p>
        <p className="text-xl font-semibold">{value}</p>
      </CardContent>
    </Card>
  );
}

function ProposalCard({ proposal }: { proposal: ProposalDetails }) {
  const statusConfig: Record<string, { icon: ElementType; label: string; color: string; rail: string }> = {
    pending: { icon: Hourglass, label: "Pending", color: "bg-yellow-100 text-yellow-700 border-yellow-200", rail: "bg-yellow-400" },
    submitted: { icon: Send, label: "Submitted", color: "bg-slate-100 text-slate-700 border-slate-200", rail: "bg-slate-300" },
    viewed: { icon: Eye, label: "Viewed by client", color: "bg-blue-100 text-blue-700 border-blue-200", rail: "bg-blue-400" },
    interviewing: { icon: MessageCircle, label: "Interviewing", color: "bg-purple-100 text-purple-700 border-purple-200", rail: "bg-purple-500" },
    accepted: { icon: CheckCircle2, label: "Accepted", color: "bg-emerald-100 text-emerald-700 border-emerald-200", rail: "bg-emerald-500" },
    rejected: { icon: XCircle, label: "Declined", color: "bg-red-100 text-red-700 border-red-200", rail: "bg-red-400" },
    withdrawn: { icon: Clock, label: "Withdrawn", color: "bg-slate-100 text-slate-500 border-slate-200", rail: "bg-slate-300" },
  };

  const config = statusConfig[proposal.status] || statusConfig.submitted;
  const StatusIcon = config.icon;
  const submitDate = proposal.submittedAt
    ? new Date(proposal.submittedAt).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })
    : "Recently";

  return (
    <Card className="overflow-hidden border-slate-200 shadow-sm transition hover:border-cyan-300 hover:shadow-md">
      <div className="flex">
        <div className={`w-1 shrink-0 ${config.rail}`} />
        <CardContent className="flex min-w-0 flex-1 flex-col gap-6 p-6 md:flex-row">
          <div className="min-w-0 flex-1 space-y-3">
            <div className="flex items-start justify-between gap-4">
              <h3 className="truncate text-lg font-semibold leading-tight text-slate-900 transition-colors hover:text-primary">
                {proposal.jobTitle}
              </h3>
            </div>

            <div className="flex flex-wrap items-center gap-3">
              <Badge variant="outline" className={`gap-1.5 px-2.5 py-0.5 ${config.color}`}>
                <StatusIcon className="h-3.5 w-3.5" />
                {config.label}
              </Badge>
              <span className="text-sm text-muted-foreground">Submitted: {submitDate}</span>
              <span className="text-sm text-muted-foreground">Job #{proposal.jobId}</span>
            </div>

            <p className="mt-2 line-clamp-2 text-sm leading-relaxed text-muted-foreground">
              {proposal.coverLetterSnippet ? `"${proposal.coverLetterSnippet}"` : "No cover letter preview."}
            </p>
          </div>

          <div className="flex w-full shrink-0 flex-row items-center justify-between gap-4 border-t pt-4 md:w-auto md:flex-col md:items-end md:justify-center md:border-t-0 md:border-l md:pl-6 md:pt-0">
            <div className="text-left md:text-right">
              <div className="flex items-center gap-0.5 text-lg font-bold text-foreground md:justify-end">
                <DollarSign className="h-4 w-4 text-muted-foreground" />
                {proposal.bidAmount.toLocaleString("en-US", { minimumFractionDigits: 2 })}
              </div>
              <p className="mt-1 text-xs font-medium uppercase tracking-wider text-muted-foreground">Proposed Bid</p>
            </div>

            <div className="flex w-full items-center gap-2 md:w-auto">
              <Button variant="outline" size="sm" className="w-full md:w-auto">View Details</Button>
              {proposal.status === "interviewing" && (
                <Button size="sm" className="w-full gap-2 md:w-auto">
                  <MessageCircle className="h-4 w-4" />
                  Open Chat
                </Button>
              )}
            </div>
          </div>
        </CardContent>
      </div>
    </Card>
  );
}
