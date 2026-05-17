import { useState, useEffect } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Textarea } from "@/components/ui/textarea";
import { 
  Briefcase, DollarSign, Clock, 
  CheckCircle, ExternalLink, FileText, Sparkles, Loader2
} from "lucide-react";
import { toast } from "sonner";
import { contractApi, extractApiMessage, jobApi, unwrapData } from "@/lib/api";
import type { Contract, ContractDetailsDTO, Job, JobSkillDTO } from "@/shared/api/generated";

// Интерфейс, отражающий JOIN таблиц contracts, jobs и profiles(client)
interface ContractDetails {
  id: number;
  jobId: number;
  title: string;              // из jobs.title
  clientName: string;         // из profiles.first_name + last_name
  clientAvatar: string | null;// из profiles.avatar_url
  totalAmount: number;        // из contracts.total_amount
  budgetType: string;         // из jobs.budget_type
  status: string;             // из contracts.status
  createdAt: string;          // из jobs.created_at (или contracts.created_at)
}

interface JobPreview {
  id: number;
  title: string;
  description: string;
  budgetType: string;
  minBudget: number;
  maxBudget: number;
  statusName: string;
  skills: string[];
}

function normalizeContractStatus(status?: string): "active" | "completed" {
  const value = String(status ?? "").toUpperCase();
  if (value.includes("COMPLETED")) return "completed";
  return "active";
}

export default function ContractsView() {
  const [contracts, setContracts] = useState<ContractDetails[]>([]);
  const [contractDetailsById, setContractDetailsById] = useState<Record<number, ContractDetailsDTO>>({});
  const [viewingJob, setViewingJob] = useState<JobPreview | null>(null);
  const [loadingJobPreview, setLoadingJobPreview] = useState(false);
  const [requestingCancelContract, setRequestingCancelContract] = useState<ContractDetails | null>(null);
  const [cancelReason, setCancelReason] = useState("");
  const [submittingCancel, setSubmittingCancel] = useState(false);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState("all");

  const fetchContracts = async () => {
    setLoading(true);
    try {
      const contractsRes = await contractApi.getMyContracts();
      const contractsData = unwrapData<Contract[]>(contractsRes.data) || [];
      if (!Array.isArray(contractsData)) {
        setContracts([]);
        return;
      }

      const contractsForUi = await Promise.all(
        contractsData.map(async (contract) => {
          const contractId = Number(contract.id ?? 0);
          const fallbackJobId = Number(contract.jobId ?? 0);
          let details: ContractDetailsDTO | null = null;

          try {
            const detailsRes = await contractApi.getContractDetails(contractId);
            details = unwrapData<ContractDetailsDTO>(detailsRes.data);
          } catch {
            details = null;
          }

          const resolvedJobId = details?.jobId ?? fallbackJobId;
          const title = details?.jobTitle?.trim() || `Job #${resolvedJobId || "N/A"}`;
          const clientName = details?.clientName?.trim() || `Client #${details?.clientId ?? "N/A"}`;
          const amount = Number(details?.totalAmount ?? contract.totalAmount ?? 0);
          const status = normalizeContractStatus(details?.status ?? contract.status);
          const createdAt = details?.createdAt || String(contract.createdAt ?? new Date().toISOString());

          return {
            id: contractId,
            jobId: Number(details?.jobId ?? fallbackJobId),
            title,
            clientName,
            clientAvatar: null,
            totalAmount: Number.isFinite(amount) ? amount : 0,
            budgetType: "fixed",
            status,
            createdAt,
          } as ContractDetails;
        }),
      );

      setContracts(contractsForUi);
      const detailsEntries = await Promise.all(
        contractsForUi.map(async (contract) => {
          try {
            const detailsRes = await contractApi.getContractDetails(contract.id);
            const details = unwrapData<ContractDetailsDTO>(detailsRes.data);
            return [contract.id, details] as const;
          } catch {
            return [contract.id, null] as const;
          }
        }),
      );
      setContractDetailsById(
        detailsEntries.reduce<Record<number, ContractDetailsDTO>>((acc, [id, details]) => {
          if (details) acc[id] = details;
          return acc;
        }, {}),
      );
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to fetch contracts."));
      setContracts([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchContracts().catch((error) => {
      toast.error(extractApiMessage(error, "Failed to fetch contracts."));
      setContracts([]);
      setLoading(false);
    });
  }, []);

  // Фильтрация контрактов на основе выбранной вкладки
  const filteredContracts = contracts.filter(contract => {
    if (activeTab === "all") return true;
    return contract.status === activeTab;
  });

  const activeCount = contracts.filter((contract) => contract.status === "active").length;
  const completedCount = contracts.filter((contract) => contract.status === "completed").length;
  const totalValue = contracts.reduce((sum, contract) => sum + Number(contract.totalAmount || 0), 0);

  const openOriginalJob = async (jobId: number) => {
    if (!jobId) return;
    setLoadingJobPreview(true);
    setViewingJob(null);
    try {
      const [jobRes, skillsRes] = await Promise.all([
        jobApi.getJobById(jobId),
        jobApi.getJobSkills(jobId),
      ]);
      const job = unwrapData<Job>(jobRes.data);
      const skills = unwrapData<JobSkillDTO[]>(skillsRes.data);
      setViewingJob({
        id: Number(job.id ?? jobId),
        title: String(job.title ?? `Job #${jobId}`),
        description: String(job.description ?? "No description provided."),
        budgetType: String(job.budgetType ?? "fixed"),
        minBudget: Number(job.minBudget ?? 0),
        maxBudget: Number(job.maxBudget ?? 0),
        statusName: String(job.statusName ?? "N/A"),
        skills: (Array.isArray(skills) ? skills : [])
          .map((skill) => String(skill.skillName ?? "").trim())
          .filter(Boolean),
      });
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to load original job."));
    } finally {
      setLoadingJobPreview(false);
    }
  };

  const submitCancellationRequest = async () => {
    if (!requestingCancelContract) return;
    const reason = cancelReason.trim();
    if (!reason) {
      toast.error("Please provide a cancellation reason.");
      return;
    }

    setSubmittingCancel(true);
    try {
      await contractApi.requestCancellation(requestingCancelContract.id, { reason });
      toast.success("Cancellation request sent.");
      setRequestingCancelContract(null);
      setCancelReason("");
      await fetchContracts();
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to request cancellation."));
    } finally {
      setSubmittingCancel(false);
    }
  };

  return (
    <div className="mx-auto max-w-7xl space-y-6 animate-in fade-in slide-in-from-bottom-2 duration-300">
      <section className="relative overflow-hidden rounded-2xl border border-slate-200 bg-[linear-gradient(135deg,#0f172a_0%,#155e75_52%,#0f766e_100%)] p-6 text-white shadow-xl md:p-8">
        <div className="pointer-events-none absolute -right-20 -top-20 h-56 w-56 rounded-full bg-cyan-300/20 blur-3xl" />
        <div className="pointer-events-none absolute -bottom-16 -left-10 h-48 w-48 rounded-full bg-emerald-300/20 blur-3xl" />
        <div className="relative flex flex-col gap-5 md:flex-row md:items-end md:justify-between">
          <div>
            <p className="mb-2 inline-flex items-center gap-2 rounded-full bg-white/10 px-3 py-1 text-xs font-semibold uppercase tracking-[0.14em] text-cyan-100">
              <Sparkles className="h-3.5 w-3.5" /> Delivery Workspace
            </p>
            <h1 className="text-3xl font-bold tracking-tight md:text-4xl">My Contracts</h1>
            <p className="mt-2 max-w-2xl text-sm text-slate-200 md:text-base">
              Track active commitments, stay aligned with clients, and close contracts confidently.
            </p>
          </div>
          <div className="grid grid-cols-3 gap-2">
            <Card className="border-white/20 bg-white/10 text-white">
              <CardContent className="p-3">
                <p className="text-[11px] uppercase tracking-wider text-cyan-100">Total</p>
                <p className="text-xl font-semibold">{contracts.length}</p>
              </CardContent>
            </Card>
            <Card className="border-white/20 bg-white/10 text-white">
              <CardContent className="p-3">
                <p className="text-[11px] uppercase tracking-wider text-cyan-100">Active</p>
                <p className="text-xl font-semibold">{activeCount}</p>
              </CardContent>
            </Card>
            <Card className="border-white/20 bg-white/10 text-white">
              <CardContent className="p-3">
                <p className="text-[11px] uppercase tracking-wider text-cyan-100">Completed</p>
                <p className="text-xl font-semibold">{completedCount}</p>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      <section className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm md:p-5">
        <div className="mb-4 flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.16em] text-cyan-700">Portfolio Value</p>
            <p className="text-2xl font-bold text-slate-900">${totalValue.toLocaleString("en-US", { maximumFractionDigits: 2 })}</p>
          </div>
          <Badge variant="outline" className="w-fit text-xs">{filteredContracts.length} visible contracts</Badge>
        </div>

        <Tabs defaultValue="all" onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full max-w-md grid-cols-3">
            <TabsTrigger value="all">All Contracts</TabsTrigger>
            <TabsTrigger value="active">Active</TabsTrigger>
            <TabsTrigger value="completed">Completed</TabsTrigger>
          </TabsList>

          <div className="mt-6 space-y-4">
            {loading ? (
              Array.from({ length: 3 }).map((_, i) => (
                <Card key={i} className="animate-pulse border-slate-200 bg-muted/40">
                  <CardContent className="h-36 p-6"></CardContent>
                </Card>
              ))
            ) : filteredContracts.length === 0 ? (
              <Card className="border-dashed border-2 border-slate-300 bg-transparent">
                <CardContent className="flex flex-col items-center justify-center p-12 text-center">
                  <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-primary/10">
                    <Briefcase className="h-6 w-6 text-primary" />
                  </div>
                  <h3 className="text-lg font-semibold">No contracts found</h3>
                  <p className="mt-1 max-w-sm text-muted-foreground">
                    {activeTab === "active"
                      ? "You don't have any ongoing projects right now. Open Find Work to send new proposals."
                      : "You don't have contracts in this state yet."}
                  </p>
                </CardContent>
              </Card>
            ) : (
              filteredContracts.map((contract) => (
                <ContractCard
                  key={contract.id}
                  contract={contract}
                  details={contractDetailsById[contract.id]}
                  onRefresh={fetchContracts}
                  onOpenOriginalJob={openOriginalJob}
                  onRequestCancellation={(item) => {
                    setRequestingCancelContract(item);
                    setCancelReason("");
                  }}
                />
              ))
            )}
          </div>
        </Tabs>
      </section>

      <Dialog open={loadingJobPreview || !!viewingJob} onOpenChange={(open) => !open && setViewingJob(null)}>
        <DialogContent className="sm:max-w-2xl">
          <DialogHeader>
            <DialogTitle>Original Job</DialogTitle>
            <DialogDescription>Review the original project brief and scope.</DialogDescription>
          </DialogHeader>
          {loadingJobPreview ? (
            <div className="flex items-center gap-2 py-6 text-sm text-slate-600">
              <Loader2 className="h-4 w-4 animate-spin" />
              Loading job details...
            </div>
          ) : viewingJob ? (
            <div className="space-y-5">
              <div className="rounded-xl border border-slate-200 bg-gradient-to-r from-slate-50 to-cyan-50 p-4">
                <h3 className="text-lg font-semibold text-slate-900">{viewingJob.title}</h3>
                <p className="mt-2 text-sm leading-relaxed text-slate-700">{viewingJob.description}</p>
              </div>

              <div className="grid grid-cols-3 gap-3">
                <div className="rounded-lg border border-slate-200 bg-white p-3">
                  <p className="text-[11px] font-semibold uppercase tracking-wider text-slate-500">Job ID</p>
                  <p className="mt-1 text-sm font-semibold text-slate-900">#{viewingJob.id}</p>
                </div>
                <div className="rounded-lg border border-slate-200 bg-white p-3">
                  <p className="text-[11px] font-semibold uppercase tracking-wider text-slate-500">Type</p>
                  <p className="mt-1 text-sm font-semibold text-slate-900">{viewingJob.budgetType}</p>
                </div>
                <div className="rounded-lg border border-slate-200 bg-white p-3">
                  <p className="text-[11px] font-semibold uppercase tracking-wider text-slate-500">Status</p>
                  <p className="mt-1 text-sm font-semibold text-slate-900">{viewingJob.statusName}</p>
                </div>
              </div>

              <div className="rounded-lg border border-slate-200 bg-white p-3">
                <p className="text-[11px] font-semibold uppercase tracking-wider text-slate-500">Budget Range</p>
                <p className="mt-1 text-sm font-semibold text-slate-900">
                  ${viewingJob.minBudget.toLocaleString()} - ${viewingJob.maxBudget.toLocaleString()}
                </p>
              </div>

              <div className="rounded-lg border border-slate-200 bg-white p-3">
                <p className="text-[11px] font-semibold uppercase tracking-wider text-slate-500">Required Skills</p>
                <div className="mt-2 flex flex-wrap gap-2">
                  {viewingJob.skills.length > 0 ? viewingJob.skills.map((skill) => (
                    <Badge key={skill} variant="outline" className="bg-cyan-50 text-cyan-900">{skill}</Badge>
                  )) : <p className="text-sm text-slate-500">No skills listed.</p>}
                </div>
              </div>
            </div>
          ) : null}
        </DialogContent>
      </Dialog>

      <Dialog open={!!requestingCancelContract} onOpenChange={(open) => !open && setRequestingCancelContract(null)}>
        <DialogContent className="sm:max-w-lg">
          <DialogHeader>
            <DialogTitle>Request Cancellation</DialogTitle>
            <DialogDescription>
              Explain the reason clearly. The client will review your request before confirming.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-3">
            <div className="rounded-lg border border-slate-200 bg-slate-50 p-3">
              <p className="text-sm font-semibold text-slate-900">{requestingCancelContract?.title}</p>
              <p className="text-xs text-slate-500">Contract #{requestingCancelContract?.id}</p>
            </div>
            <Textarea
              rows={5}
              placeholder="Write your cancellation reason..."
              value={cancelReason}
              onChange={(e) => setCancelReason(e.target.value)}
              disabled={submittingCancel}
            />
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setRequestingCancelContract(null)} disabled={submittingCancel}>
              Back
            </Button>
            <Button variant="destructive" onClick={submitCancellationRequest} disabled={submittingCancel || !cancelReason.trim()}>
              {submittingCancel ? "Sending..." : "Send Request"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

function ContractCard({
  contract,
  details,
  onRefresh,
  onOpenOriginalJob,
  onRequestCancellation,
}: {
  contract: ContractDetails;
  details?: ContractDetailsDTO;
  onRefresh: () => Promise<void>;
  onOpenOriginalJob: (jobId: number) => Promise<void>;
  onRequestCancellation: (contract: ContractDetails) => void;
}) {
  const isHourly = contract.budgetType === "hourly";
  const isActive = contract.status === "active";
  const cancellationRequested = Boolean(details?.cancellationRequestedAt);
  const requestedByMe =
    cancellationRequested &&
    details?.cancellationRequestedBy != null &&
    details?.freelancerId != null &&
    Number(details.cancellationRequestedBy) === Number(details.freelancerId);

  const getInitials = (name: string) => {
    return name.split(" ").map(n => n[0]).join("").substring(0, 2).toUpperCase();
  };

  const startDate = new Date(contract.createdAt).toLocaleDateString("en-US", {
    month: "short", day: "numeric", year: "numeric"
  });

  return (
    <Card className="overflow-hidden border-slate-200 shadow-sm transition hover:border-cyan-300 hover:shadow-md">
      <div className={`h-1 w-full ${isActive ? "bg-emerald-500" : "bg-slate-300"}`} />
      <CardContent className="p-0">
        <div className="flex flex-col gap-6 p-5 sm:p-6 md:flex-row md:items-center md:justify-between">
          <div className="flex min-w-0 flex-1 gap-4">
            <Avatar className="mt-1 hidden h-12 w-12 shrink-0 border sm:block">
              <AvatarImage src={contract.clientAvatar || ""} alt={contract.clientName} />
              <AvatarFallback className="bg-primary/5 font-medium text-primary">
                {getInitials(contract.clientName)}
              </AvatarFallback>
            </Avatar>

            <div className="min-w-0 space-y-1.5">
              <div className="flex flex-wrap items-center gap-2">
                <h3 className="truncate text-lg font-semibold transition-colors hover:text-primary">
                  {contract.title}
                </h3>
                <Badge
                  variant={isActive ? "default" : "secondary"}
                  className={isActive ? "border-transparent bg-emerald-100 text-emerald-800 hover:bg-emerald-100/80" : ""}
                >
                  {isActive ? <Clock className="mr-1 h-3 w-3" /> : <CheckCircle className="mr-1 h-3 w-3" />}
                  {contract.status.charAt(0).toUpperCase() + contract.status.slice(1)}
                </Badge>
              </div>

              <div className="flex flex-wrap items-center gap-x-4 gap-y-2 text-sm text-muted-foreground">
                <span className="font-medium text-foreground">{contract.clientName}</span>
                <span className="hidden sm:inline">•</span>
                <span>Started {startDate}</span>
                <span className="hidden sm:inline">•</span>
                <span>Contract #{contract.id}</span>
              </div>
            </div>
          </div>

          <div className="flex shrink-0 flex-row items-center justify-between gap-4 border-t pt-4 md:flex-col md:items-end md:justify-center md:border-t-0 md:pt-0">
            <div className="text-left md:text-right">
              <div className="flex items-center gap-1 text-lg font-bold md:justify-end">
                <DollarSign className="h-5 w-5 text-muted-foreground" />
                {contract.totalAmount.toLocaleString("en-US", { minimumFractionDigits: 2 })}
                {isHourly && <span className="text-sm font-normal text-muted-foreground">/hr</span>}
              </div>
              <p className="mt-0.5 text-xs font-medium uppercase tracking-wider text-muted-foreground">
                {isHourly ? "Hourly Rate" : "Fixed Price"}
              </p>
            </div>

            <div className="flex items-center gap-2">
              <Button size="sm" variant="outline" onClick={() => void onOpenOriginalJob(contract.jobId)}>
                <ExternalLink className="mr-2 h-4 w-4" /> View Job
              </Button>
              {isActive && !cancellationRequested && (
                <Button size="sm" variant="outline">
                  <FileText className="mr-2 h-4 w-4" /> Submit Work
                </Button>
              )}
              {isActive && !cancellationRequested && (
                <Button
                  size="sm"
                  variant="destructive"
                  onClick={() => onRequestCancellation(contract)}
                >
                  Request Cancellation
                </Button>
              )}
              {isActive && cancellationRequested && requestedByMe && (
                <Badge className="border-amber-200 bg-amber-50 text-amber-700">
                  Cancellation requested
                </Badge>
              )}
              {isActive && cancellationRequested && !requestedByMe && (
                <>
                  <Button
                    size="sm"
                    variant="destructive"
                    onClick={async () => {
                      try {
                        await contractApi.confirmCancellation(contract.id);
                        toast.success("Cancellation confirmed.");
                        await onRefresh();
                      } catch (error) {
                        toast.error(extractApiMessage(error, "Failed to confirm cancellation."));
                      }
                    }}
                  >
                    Confirm Cancellation
                  </Button>
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={async () => {
                      try {
                        await contractApi.rejectCancellationRequest(contract.id);
                        toast.success("Cancellation request rejected.");
                        await onRefresh();
                      } catch (error) {
                        toast.error(extractApiMessage(error, "Failed to reject cancellation."));
                      }
                    }}
                  >
                    Reject Cancellation
                  </Button>
                </>
              )}
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
