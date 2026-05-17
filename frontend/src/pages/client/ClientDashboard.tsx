import { useState, useEffect, useMemo } from "react";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { toast } from "sonner";
import {
  FileText,
  Plus,
  Briefcase,
  CheckCircle2,
  LayoutDashboard,
  Users,
  ChevronRight,
  Check,
  Settings,
  Sparkles,
  TrendingUp,
  FolderKanban,
  Pencil,
  Trash2,
} from "lucide-react";
import { getUser } from "@/lib/auth";
import { contractApi, extractApiMessage, freelancerProfileApi, jobApi, jobRequiredSkillApi, profileApi, proposalApi, skillApi, suggestSkill, transactionApi, unwrapData } from "@/lib/api";
import type { CancelContractRequest, CompleteJobRequest, Contract as ApiContract, ContractDetailsDTO, FreelancerProfileDTO, Job as ApiJob, JobDTO, JobRequiredSkillResponse, ProfileDTO, Proposal as ApiProposal, Skill as ApiSkill, TransactionRequest } from "@/shared/api/generated";
import ClientProfile from "./ClientProfile";
import ClientChat from "./ClientChat";

interface ProposalView {
  id: number;
  jobId: number;
  freelancerId: number;
  bidAmount: number;
  deliveryDays?: number;
  coverLetter: string;
  status: string;
}

interface PostedJob {
  id: number;
  clientId?: number;
  title: string;
  description: string;
  budgetType?: string;
  minBudget?: number;
  maxBudget?: number;
  statusName?: string;
  createdAt?: string;
  proposals: ProposalView[];
  requiredSkillIds: number[];
}

interface Contract {
  id: number;
  title: string;
  freelancerName: string;
  budget: number;
  status: string;
  jobId?: number;
  freelancerId?: number;
}

interface SkillOption {
  id: number;
  name: string;
  category?: string;
}

const mapProposalToView = (proposal: ApiProposal): ProposalView => ({
  id: Number(proposal.id ?? 0),
  jobId: Number(proposal.jobId ?? 0),
  freelancerId: Number(proposal.freelancerId ?? 0),
  bidAmount: Number(proposal.bidAmount ?? 0),
  deliveryDays: proposal.deliveryDays ? Number(proposal.deliveryDays) : undefined,
  coverLetter: proposal.coverLetter ?? "",
  status: proposal.status ?? "PENDING",
});

function statusTone(status?: string) {
  const value = (status || "").toUpperCase();
  if (value.includes("COMPLETED")) return "bg-emerald-100 text-emerald-800 border-emerald-200";
  if (value.includes("IN_PROGRESS") || value.includes("IN PROGRESS")) return "bg-sky-100 text-sky-800 border-sky-200";
  if (value.includes("OPEN")) return "bg-amber-100 text-amber-800 border-amber-200";
  return "bg-slate-100 text-slate-700 border-slate-200";
}

function isJobOpen(status?: string) {
  return (status ?? "").toUpperCase().includes("OPEN");
}

function canDeleteContract(status?: string) {
  const value = (status ?? "").toUpperCase();
  return value.includes("COMPLETED") || value.includes("REJECTED");
}

export default function ClientDashboard() {
  const user = getUser();

  const [activePage, setActivePage] = useState("overview");
  const [clientProfile, setClientProfile] = useState<ProfileDTO | null>(null);
  const [postedJobs, setPostedJobs] = useState<PostedJob[]>([]);
  const [contracts, setContracts] = useState<Contract[]>([]);
  const [contractDetailsById, setContractDetailsById] = useState<Record<number, ContractDetailsDTO>>({});
  const [paidAmountByContractId, setPaidAmountByContractId] = useState<Record<number, number>>({});
  const [loadingJobs, setLoadingJobs] = useState(true);
  const [loadingContracts, setLoadingContracts] = useState(true);
  const [jobsFilter, setJobsFilter] = useState<"all" | "open" | "in_progress" | "completed">("all");
  const [jobsSearch, setJobsSearch] = useState("");

  const [jobTitle, setJobTitle] = useState("");
  const [jobDescription, setJobDescription] = useState("");
  const [jobBudgetType, setJobBudgetType] = useState("fixed");
  const [jobMinBudget, setJobMinBudget] = useState("");
  const [jobMaxBudget, setJobMaxBudget] = useState("");
  const [skills, setSkills] = useState<SkillOption[]>([]);
  const [selectedSkillIds, setSelectedSkillIds] = useState<number[]>([]);
  const [postingJob, setPostingJob] = useState(false);
  const [editingJob, setEditingJob] = useState<PostedJob | null>(null);
  const [editJobTitle, setEditJobTitle] = useState("");
  const [editJobDescription, setEditJobDescription] = useState("");
  const [editJobBudgetType, setEditJobBudgetType] = useState("fixed");
  const [editJobMinBudget, setEditJobMinBudget] = useState("");
  const [editJobMaxBudget, setEditJobMaxBudget] = useState("");
  const [editSelectedSkillIds, setEditSelectedSkillIds] = useState<number[]>([]);
  const [savingEditJob, setSavingEditJob] = useState(false);
  const [deletingJob, setDeletingJob] = useState<PostedJob | null>(null);
  const [deletingInProgress, setDeletingInProgress] = useState(false);
  const [expandedOtherProposals, setExpandedOtherProposals] = useState<Record<number, boolean>>({});
  const [rejectingProposalId, setRejectingProposalId] = useState<number | null>(null);
  const [hiringProposalId, setHiringProposalId] = useState<number | null>(null);
  const [viewingFreelancerId, setViewingFreelancerId] = useState<number | null>(null);
  const [freelancerProfile, setFreelancerProfile] = useState<FreelancerProfileDTO | null>(null);
  const [loadingFreelancerProfile, setLoadingFreelancerProfile] = useState(false);
  const [showSuggestSkillDialog, setShowSuggestSkillDialog] = useState(false);
  const [suggestedSkillName, setSuggestedSkillName] = useState("");
  const [suggestedSkillCategory, setSuggestedSkillCategory] = useState("");
  const [suggestingSkill, setSuggestingSkill] = useState(false);

  const [completingContract, setCompletingContract] = useState<Contract | null>(null);
  const [deletingContract, setDeletingContract] = useState<Contract | null>(null);
  const [deletingContractInProgress, setDeletingContractInProgress] = useState(false);
  const [partialPaymentContract, setPartialPaymentContract] = useState<Contract | null>(null);
  const [partialPaymentAmount, setPartialPaymentAmount] = useState("");
  const [processingPartialPayment, setProcessingPartialPayment] = useState(false);
  const [requestingCancelContract, setRequestingCancelContract] = useState<Contract | null>(null);
  const [cancelReason, setCancelReason] = useState("");
  const [processingCancelRequest, setProcessingCancelRequest] = useState(false);
  const [confirmingCancelId, setConfirmingCancelId] = useState<number | null>(null);
  const [rejectingCancelId, setRejectingCancelId] = useState<number | null>(null);
  const [rating, setRating] = useState("");
  const [feedbackText, setFeedbackText] = useState("");
  const [submittingComplete, setSubmittingComplete] = useState(false);

  const clientDisplayName = clientProfile?.firstName?.trim() || user?.firstName || "Client";
  const parsedMinBudget = Number(jobMinBudget);
  const parsedMaxBudget = Number(jobMaxBudget);
  const isBudgetValid =
    Number.isFinite(parsedMinBudget) &&
    Number.isFinite(parsedMaxBudget) &&
    parsedMinBudget > 0 &&
    parsedMaxBudget > 0 &&
    parsedMaxBudget >= parsedMinBudget;
  const isPublishDisabled =
    postingJob ||
    !jobTitle.trim() ||
    !jobDescription.trim() ||
    !jobMinBudget.trim() ||
    !jobMaxBudget.trim() ||
    !isBudgetValid ||
    selectedSkillIds.length === 0;
  const filteredJobs = useMemo(() => {
    const search = jobsSearch.trim().toLowerCase();
    return postedJobs.filter((job) => {
      const status = (job.statusName ?? "").toUpperCase();
      const byFilter =
        jobsFilter === "all" ||
        (jobsFilter === "open" && status.includes("OPEN")) ||
        (jobsFilter === "in_progress" && (status.includes("IN_PROGRESS") || status.includes("IN PROGRESS"))) ||
        (jobsFilter === "completed" && status.includes("COMPLETED"));

      const bySearch =
        !search ||
        job.title.toLowerCase().includes(search) ||
        job.description.toLowerCase().includes(search);

      return byFilter && bySearch;
    });
  }, [postedJobs, jobsFilter, jobsSearch]);

  const mapJob = (job: ApiJob): PostedJob => ({
    id: Number(job.id ?? 0),
    clientId: job.clientId ? Number(job.clientId) : undefined,
    title: job.title ?? `Job #${job.id}`,
    description: job.description ?? "",
    budgetType: job.budgetType ?? "fixed",
    minBudget: job.minBudget ? Number(job.minBudget) : undefined,
    maxBudget: job.maxBudget ? Number(job.maxBudget) : undefined,
    statusName: job.statusName ?? "OPEN",
    createdAt: job.createdAt,
    proposals: [],
    requiredSkillIds: [],
  });

  const refreshJobsAndProposals = async (withLoader = false) => {
    try {
      if (withLoader) setLoadingJobs(true);
      const jobsRes = await jobApi.getMyJobs();
      const jobs = unwrapData<ApiJob[]>(jobsRes.data) || [];
      if (Array.isArray(jobs)) {
        const jobsWithProposals = await Promise.all(
          jobs.map(async (job) => {
            const propsRes = await proposalApi.getProposalsByJobId(Number(job.id));
            const proposals = unwrapData<ApiProposal[]>(propsRes.data);
            const reqSkillsRes = await jobRequiredSkillApi.getRequiredSkills(Number(job.id));
            const reqSkills = unwrapData<JobRequiredSkillResponse[]>(reqSkillsRes.data);
            return {
              ...mapJob(job),
              proposals: Array.isArray(proposals) ? proposals.map(mapProposalToView) : [],
              requiredSkillIds: Array.isArray(reqSkills)
                ? reqSkills.map((s) => Number(s.skillId ?? 0)).filter((id) => id > 0)
                : [],
            };
          }),
        );
        setPostedJobs(jobsWithProposals);
      } else {
        toast.error("Failed to load jobs.");
      }
    } catch (error) {
      toast.error(extractApiMessage(error, "Network error while loading jobs."));
    } finally {
      if (withLoader) setLoadingJobs(false);
    }
  };

  const refreshContracts = async (withLoader = false) => {
    try {
      if (withLoader) setLoadingContracts(true);
      const contractsRes = await contractApi.getMyContracts();
      const contractsData = unwrapData<ApiContract[]>(contractsRes.data) || [];
      if (!Array.isArray(contractsData)) {
        setContracts([]);
        return;
      }

      const contractsForUi = await Promise.all(
        contractsData.map(async (contract) => {
          const jobId = Number(contract.jobId ?? 0);
          let jobTitle = `Job #${jobId}`;

          if (jobId > 0) {
            try {
              const jobRes = await jobApi.getJobById(jobId);
              const job = unwrapData<ApiJob>(jobRes.data);
              if (job?.title) jobTitle = job.title;
            } catch {
              // no-op
            }
          }

          return {
            id: Number(contract.id ?? 0),
            jobId,
            freelancerId: contract.freelancerId ? Number(contract.freelancerId) : undefined,
            title: jobTitle,
            freelancerName: `Freelancer #${contract.freelancerId ?? "N/A"}`,
            budget: Number(contract.totalAmount ?? 0),
            status: String(contract.status ?? "IN_PROGRESS").replaceAll("_", " "),
          } as Contract;
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
      const paymentEntries = await Promise.all(
        contractsForUi.map(async (contract) => {
          try {
            const txRes = await transactionApi.getTransactionsByContractId(contract.id);
            const txs = unwrapData<Array<{ amount?: number; type?: string }>>(txRes.data) || [];
            const paid = Array.isArray(txs)
              ? txs.reduce((sum, tx) => {
                  const amount = Number(tx.amount ?? 0);
                  const type = String(tx.type ?? "").toUpperCase();
                  if (!Number.isFinite(amount) || amount <= 0) return sum;
                  if (type.includes("PAYMENT")) return sum + amount;
                  return sum;
                }, 0)
              : 0;
            return [contract.id, paid] as const;
          } catch {
            return [contract.id, 0] as const;
          }
        }),
      );
      setPaidAmountByContractId(
        paymentEntries.reduce<Record<number, number>>((acc, [id, paid]) => {
          acc[id] = paid;
          return acc;
        }, {}),
      );
    } catch (error) {
      toast.error(extractApiMessage(error, "Network error while loading contracts."));
    } finally {
      if (withLoader) setLoadingContracts(false);
    }
  };

  useEffect(() => {
    const fetchCurrentProfile = async () => {
      try {
        const profileRes = await profileApi.getCurrentUserProfile();
        const profileData = unwrapData<ProfileDTO>(profileRes.data);
        if (profileData) {
          setClientProfile(profileData);
        }
      } catch (error) {
        toast.error(extractApiMessage(error, "Failed to load profile data."));
      }
    };

    const fetchSkills = async () => {
      try {
        const skillsRes = await skillApi.getAllSkills();
        const skillsData = unwrapData<ApiSkill[]>(skillsRes.data) || [];
        if (Array.isArray(skillsData)) {
          setSkills(
            skillsData.map((s) => ({
              id: Number(s.id ?? 0),
              name: s.name ?? `Skill #${s.id}`,
              category: s.category,
            })).filter((s) => s.id > 0),
          );
        }
      } catch (error) {
        toast.error(extractApiMessage(error, "Failed to load skills."));
      }
    };

    fetchCurrentProfile();
    fetchSkills();
    refreshJobsAndProposals(true);
    refreshContracts(true);
  }, []);

  const toggleSkill = (skillId: number) => {
    setSelectedSkillIds((prev) => (prev.includes(skillId) ? prev.filter((id) => id !== skillId) : [...prev, skillId]));
  };

  const handleAcceptProposal = async (jobId: number, proposalId: number) => {
    const targetJob = postedJobs.find((job) => job.id === jobId);
    if (!targetJob) return;

    const hiringLocked =
      targetJob.proposals.some((p) => p.status.toUpperCase() === "ACCEPTED") ||
      (targetJob.statusName ?? "").toUpperCase().includes("IN_PROGRESS") ||
      (targetJob.statusName ?? "").toUpperCase().includes("COMPLETED");
    if (hiringLocked) {
      toast.error("Hiring is already closed for this job.");
      return;
    }

    try {
      setHiringProposalId(proposalId);
      await proposalApi.acceptProposal(proposalId);
      await refreshJobsAndProposals();
      await refreshContracts(false);
      toast.success("Freelancer hired successfully.");
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to accept proposal."));
    } finally {
      setHiringProposalId(null);
    }
  };

  const handleRejectProposal = async (_jobId: number, proposalId: number) => {
    try {
      setRejectingProposalId(proposalId);
      await proposalApi.rejectProposal(proposalId);
      await refreshJobsAndProposals();
      toast.success("Proposal rejected.");
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to reject proposal."));
    } finally {
      setRejectingProposalId(null);
    }
  };

  const openFreelancerProfile = async (freelancerId: number) => {
    setViewingFreelancerId(freelancerId);
    setFreelancerProfile(null);
    setLoadingFreelancerProfile(true);
    try {
      const profileRes = await freelancerProfileApi.getFreelancerProfile(freelancerId);
      const profileData = unwrapData<FreelancerProfileDTO>(profileRes.data);
      setFreelancerProfile(profileData ?? null);
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to load freelancer profile."));
    } finally {
      setLoadingFreelancerProfile(false);
    }
  };

  const handlePostJob = async () => {
    if (!jobTitle.trim() || !jobDescription.trim() || !jobMinBudget || !jobMaxBudget) {
      toast.error("Please fill in all fields.");
      return;
    }
    if (!selectedSkillIds.length) {
      toast.error("Please select at least one required skill.");
      return;
    }

    setPostingJob(true);
    try {
      const min = Number(jobMinBudget);
      const max = Number(jobMaxBudget);
      const payload: JobDTO = {
        title: jobTitle.trim(),
        description: jobDescription.trim(),
        budget: Number.isFinite(max) && max > 0 ? max : min,
        requiredSkillIds: selectedSkillIds,
      };

      const res = await jobApi.createJob(payload);
      unwrapData<ApiJob>(res.data);
      toast.success("Job posted successfully!");
      await refreshJobsAndProposals();
      setJobTitle("");
      setJobDescription("");
      setJobMinBudget("");
      setJobMaxBudget("");
      setJobBudgetType("fixed");
      setSelectedSkillIds([]);
      setActivePage("my-jobs");
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to post job."));
    } finally {
      setPostingJob(false);
    }
  };

  const openEditJob = (job: PostedJob) => {
    setEditingJob(job);
    setEditJobTitle(job.title);
    setEditJobDescription(job.description);
    setEditJobBudgetType(job.budgetType || "fixed");
    setEditJobMinBudget(String(job.minBudget ?? ""));
    setEditJobMaxBudget(String(job.maxBudget ?? ""));
    setEditSelectedSkillIds(job.requiredSkillIds || []);
  };

  const toggleEditSkill = (skillId: number) => {
    setEditSelectedSkillIds((prev) => (prev.includes(skillId) ? prev.filter((id) => id !== skillId) : [...prev, skillId]));
  };


  const handleUpdateJob = async () => {
    if (!editingJob) return;
    const min = Number(editJobMinBudget);
    const max = Number(editJobMaxBudget);
    if (!editJobTitle.trim() || !editJobDescription.trim() || !editJobMinBudget.trim() || !editJobMaxBudget.trim()) {
      toast.error("Please fill in all fields.");
      return;
    }
    if (!Number.isFinite(min) || !Number.isFinite(max) || min <= 0 || max <= 0 || max < min) {
      toast.error("Please provide a valid budget range.");
      return;
    }
    if (!editSelectedSkillIds.length) {
      toast.error("Please select at least one required skill.");
      return;
    }

    setSavingEditJob(true);
    try {
      const payload: JobDTO = {
        title: editJobTitle.trim(),
        description: editJobDescription.trim(),
        budget: max,
        requiredSkillIds: editSelectedSkillIds,
      };
      await jobApi.updateJob(editingJob.id, payload);

      const currentReqSkillsRes = await jobRequiredSkillApi.getRequiredSkills(editingJob.id);
      const currentReqSkills = unwrapData<JobRequiredSkillResponse[]>(currentReqSkillsRes.data) || [];
      const currentIds = new Set((Array.isArray(currentReqSkills) ? currentReqSkills : []).map((s) => Number(s.skillId ?? 0)).filter((id) => id > 0));
      const nextIds = new Set(editSelectedSkillIds);

      const toAdd = [...nextIds].filter((id) => !currentIds.has(id));
      const toRemove = [...currentIds].filter((id) => !nextIds.has(id));

      await Promise.all(toAdd.map((skillId) => jobRequiredSkillApi.addRequiredSkill(editingJob.id, { skillId })));
      await Promise.all(toRemove.map((skillId) => jobRequiredSkillApi.removeRequiredSkill(editingJob.id, skillId)));
      await refreshJobsAndProposals();
      toast.success("Job updated successfully.");
      setEditingJob(null);
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to update job."));
    } finally {
      setSavingEditJob(false);
    }
  };

  const handleDeleteJob = async () => {
    if (!deletingJob) return;
    if (!isJobOpen(deletingJob.statusName)) {
      toast.error("Only OPEN jobs can be deleted.");
      return;
    }
    setDeletingInProgress(true);
    try {
      await jobApi.deleteJob(deletingJob.id);
      await refreshJobsAndProposals();
      toast.success("Job deleted.");
      setDeletingJob(null);
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to delete job."));
    } finally {
      setDeletingInProgress(false);
    }
  };

  const handleCompleteContract = async () => {
    if (!completingContract || !rating || !feedbackText.trim()) {
      toast.error("Please fill in all fields.");
      return;
    }

    setSubmittingComplete(true);
    try {
      const payload: CompleteJobRequest = {
        contractId: completingContract.id,
        rating: parseFloat(rating),
        feedback: feedbackText,
      };

      await contractApi.completeContract(completingContract.id, payload);
      toast.success("Contract completed!");
      await refreshContracts(false);
      await refreshJobsAndProposals();
      setCompletingContract(null);
      setRating("");
      setFeedbackText("");
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to complete contract."));
    } finally {
      setSubmittingComplete(false);
    }
  };

  const handleDeleteContract = async () => {
    if (!deletingContract) return;
    if (!canDeleteContract(deletingContract.status)) {
      toast.error("Only COMPLETED or REJECTED contracts can be deleted.");
      return;
    }
    setDeletingContractInProgress(true);
    try {
      await contractApi.deleteContract(deletingContract.id);
      toast.success("Contract deleted.");
      setDeletingContract(null);
      await refreshContracts(false);
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to delete contract."));
    } finally {
      setDeletingContractInProgress(false);
    }
  };

  const handlePartialPayment = async () => {
    if (!partialPaymentContract) return;
    const amount = Number(partialPaymentAmount);
    if (!Number.isFinite(amount) || amount <= 0) {
      toast.error("Enter a valid partial payment amount.");
      return;
    }
    const alreadyPaid = paidAmountByContractId[partialPaymentContract.id] ?? 0;
    const remaining = Math.max(0, partialPaymentContract.budget - alreadyPaid);
    if (amount > remaining) {
      toast.error(`Amount exceeds remaining balance ($${remaining.toLocaleString()}).`);
      return;
    }
    const payload: TransactionRequest = {
      contractId: partialPaymentContract.id,
      amount,
      type: "PARTIAL_PAYMENT",
    };
    setProcessingPartialPayment(true);
    try {
      await transactionApi.createTransaction(payload);
      toast.success("Partial payment recorded.");
      setPartialPaymentContract(null);
      setPartialPaymentAmount("");
      await refreshContracts(false);
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to process partial payment."));
    } finally {
      setProcessingPartialPayment(false);
    }
  };

  const handleRequestCancellation = async () => {
    if (!requestingCancelContract) return;
    setProcessingCancelRequest(true);
    try {
      const payload: CancelContractRequest = {
        reason: cancelReason.trim() || undefined,
      };
      await contractApi.requestCancellation(requestingCancelContract.id, payload);
      toast.success("Cancellation request submitted.");
      setRequestingCancelContract(null);
      setCancelReason("");
      await refreshContracts(false);
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to request cancellation."));
    } finally {
      setProcessingCancelRequest(false);
    }
  };

  const handleConfirmCancellation = async (contractId: number) => {
    try {
      setConfirmingCancelId(contractId);
      await contractApi.confirmCancellation(contractId);
      toast.success("Cancellation confirmed.");
      await refreshContracts(false);
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to confirm cancellation."));
    } finally {
      setConfirmingCancelId(null);
    }
  };

  const handleRejectCancellation = async (contractId: number) => {
    try {
      setRejectingCancelId(contractId);
      await contractApi.rejectCancellationRequest(contractId);
      toast.success("Cancellation request rejected.");
      await refreshContracts(false);
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to reject cancellation request."));
    } finally {
      setRejectingCancelId(null);
    }
  };

  const handleSuggestSkill = async () => {
    const name = suggestedSkillName.trim();
    if (!name) {
      toast.error("Skill name is required.");
      return;
    }
    setSuggestingSkill(true);
    try {
      await suggestSkill({
        name,
        category: suggestedSkillCategory.trim() || undefined,
      });
      toast.success("Skill suggestion sent.");
      setShowSuggestSkillDialog(false);
      setSuggestedSkillName("");
      setSuggestedSkillCategory("");
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to send skill suggestion."));
    } finally {
      setSuggestingSkill(false);
    }
  };

  const stats = useMemo(() => {
    const totalJobs = postedJobs.length;
    const totalProposals = postedJobs.reduce((acc, job) => acc + (job.proposals?.length || 0), 0);
    const activeContracts = contracts.filter(
      (c) => !c.status.toUpperCase().includes("COMPLETED"),
    ).length;
    return { totalJobs, totalProposals, activeContracts };
  }, [postedJobs, contracts]);

  const renderOverview = () => (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-2 duration-300">
      <section className="relative overflow-hidden rounded-2xl border border-slate-200 bg-[linear-gradient(135deg,#0f172a_0%,#1e293b_55%,#0f766e_100%)] p-6 text-white shadow-xl md:p-8">
        <div className="pointer-events-none absolute -right-20 -top-20 h-56 w-56 rounded-full bg-cyan-300/20 blur-3xl" />
        <div className="pointer-events-none absolute -bottom-16 -left-10 h-48 w-48 rounded-full bg-emerald-300/20 blur-3xl" />
        <div className="relative flex flex-col gap-5 md:flex-row md:items-end md:justify-between">
          <div>
            <p className="mb-2 inline-flex items-center gap-2 rounded-full bg-white/10 px-3 py-1 text-xs font-semibold uppercase tracking-[0.14em] text-cyan-100">
              <Sparkles className="h-3.5 w-3.5" /> Client Workspace
            </p>
            <h1 className="text-3xl font-bold tracking-tight md:text-4xl">Welcome back, {clientDisplayName}</h1>
            <p className="mt-2 max-w-2xl text-sm text-slate-200 md:text-base">
              Track your hiring pipeline, compare proposals, and move projects from scope to successful payout.
            </p>
          </div>
          <Button onClick={() => setActivePage("post-job")} className="h-11 bg-white text-slate-900 hover:bg-slate-100">
            <Plus className="mr-2 h-4 w-4" /> New Job
          </Button>
        </div>
      </section>

      <section className="grid gap-4 md:grid-cols-3">
        <Card className="border-slate-200">
          <CardContent className="p-5">
            <div className="mb-2 flex items-center justify-between">
              <p className="text-xs font-semibold uppercase tracking-wider text-slate-500">Posted Jobs</p>
              <FolderKanban className="h-4 w-4 text-cyan-700" />
            </div>
            <p className="text-3xl font-bold text-slate-900">{stats.totalJobs}</p>
          </CardContent>
        </Card>
        <Card className="border-slate-200">
          <CardContent className="p-5">
            <div className="mb-2 flex items-center justify-between">
              <p className="text-xs font-semibold uppercase tracking-wider text-slate-500">Total Proposals</p>
              <Users className="h-4 w-4 text-cyan-700" />
            </div>
            <p className="text-3xl font-bold text-slate-900">{stats.totalProposals}</p>
          </CardContent>
        </Card>
        <Card className="border-slate-200">
          <CardContent className="p-5">
            <div className="mb-2 flex items-center justify-between">
              <p className="text-xs font-semibold uppercase tracking-wider text-slate-500">Active Contracts</p>
              <TrendingUp className="h-4 w-4 text-cyan-700" />
            </div>
            <p className="text-3xl font-bold text-slate-900">{stats.activeContracts}</p>
          </CardContent>
        </Card>
      </section>

      <section className="grid gap-5 md:grid-cols-2">
        <Card className="border-slate-200">
          <CardHeader>
            <CardTitle className="text-lg">Recent Jobs</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            {postedJobs.slice(0, 4).map((job) => (
              <div key={job.id} className="rounded-lg border border-slate-200 bg-white p-3">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <p className="font-semibold text-slate-900">{job.title}</p>
                    <p className="text-xs text-slate-500">{job.proposals.length} proposals</p>
                  </div>
                  <Badge className={statusTone(job.statusName)}>{job.statusName?.replaceAll("_", " ")}</Badge>
                </div>
              </div>
            ))}
            {!postedJobs.length && <p className="text-sm text-slate-500">No jobs yet.</p>}
          </CardContent>
        </Card>

        <Card className="border-slate-200">
          <CardHeader>
            <CardTitle className="text-lg">Recent Contracts</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            {contracts.slice(0, 4).map((contract) => (
              <div key={contract.id} className="rounded-lg border border-slate-200 bg-white p-3">
                <div className="flex items-start justify-between gap-3">
                  <div className="flex items-center gap-3">
                    <Avatar className="h-8 w-8 border">
                      <AvatarFallback className="bg-cyan-100 text-cyan-800">{contract.freelancerName.charAt(0)}</AvatarFallback>
                    </Avatar>
                    <div>
                      <p className="font-semibold text-slate-900">{contract.title}</p>
                      <p className="text-xs text-slate-500">{contract.freelancerName}</p>
                    </div>
                  </div>
                  <p className="text-sm font-semibold text-slate-900">${contract.budget.toLocaleString()}</p>
                </div>
              </div>
            ))}
            {!contracts.length && <p className="text-sm text-slate-500">No contracts yet.</p>}
          </CardContent>
        </Card>
      </section>
    </div>
  );

  const renderMyJobs = () => (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-2 duration-300">
      <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
        <div className="flex flex-col gap-3 md:flex-row md:items-end md:justify-between">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.16em] text-cyan-700">Hiring Pipeline</p>
            <h2 className="mt-1 text-2xl font-bold tracking-tight">My Job Postings</h2>
            <p className="text-sm text-slate-500">Track live opportunities, evaluate bids, and hire with confidence.</p>
          </div>
          <div className="flex items-center gap-2">
            <Badge variant="outline" className="h-9 rounded-full px-3 text-xs">{postedJobs.length} jobs</Badge>
            <Button onClick={() => setActivePage("post-job")} className="gap-2">
              <Plus className="h-4 w-4" /> Post a Job
            </Button>
          </div>
        </div>
        <div className="mt-4 grid gap-3 md:grid-cols-[1fr_auto]">
          <Input
            value={jobsSearch}
            onChange={(e) => setJobsSearch(e.target.value)}
            placeholder="Search jobs by title or description..."
            className="h-10"
          />
          <div className="grid grid-cols-2 gap-2 sm:grid-cols-4">
            <Button
              type="button"
              variant={jobsFilter === "all" ? "default" : "outline"}
              size="sm"
              onClick={() => setJobsFilter("all")}
            >
              All
            </Button>
            <Button
              type="button"
              variant={jobsFilter === "open" ? "default" : "outline"}
              size="sm"
              onClick={() => setJobsFilter("open")}
            >
              Open
            </Button>
            <Button
              type="button"
              variant={jobsFilter === "in_progress" ? "default" : "outline"}
              size="sm"
              onClick={() => setJobsFilter("in_progress")}
            >
              In Progress
            </Button>
            <Button
              type="button"
              variant={jobsFilter === "completed" ? "default" : "outline"}
              size="sm"
              onClick={() => setJobsFilter("completed")}
            >
              Completed
            </Button>
          </div>
        </div>
      </div>

      {loadingJobs ? (
        <div className="space-y-4">{[1, 2].map((i) => <Card key={i} className="h-44 animate-pulse bg-muted/50" />)}</div>
      ) : !filteredJobs.length ? (
        <Card className="border-dashed border-slate-300 p-14 text-center">
          <FileText className="mx-auto mb-4 h-10 w-10 text-slate-400" />
          <p className="text-lg font-semibold">No jobs found</p>
          <p className="mt-1 text-sm text-slate-500">Try adjusting the search or selected status filter.</p>
        </Card>
      ) : (
        <div className="space-y-5">
          {filteredJobs.map((job) => (
            <Card key={job.id} className="overflow-hidden border-slate-200 shadow-sm">
              <CardHeader className="border-b bg-gradient-to-r from-slate-50 to-white">
                <div className="flex flex-col gap-3 md:flex-row md:items-start md:justify-between">
                  <div>
                    <CardTitle className="text-xl text-slate-900">{job.title}</CardTitle>
                    <CardDescription className="mt-1 line-clamp-2">{job.description}</CardDescription>
                    <div className="mt-3 flex flex-wrap gap-2">
                      <Badge variant="outline" className="text-[11px]">ID #{job.id}</Badge>
                      <Badge variant="outline" className="text-[11px]">{job.proposals.length} proposals</Badge>
                    </div>
                    <p className="mt-2 text-xs text-slate-500">
                      {job.createdAt
                        ? `Posted ${new Date(job.createdAt).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })}`
                        : "Recently posted"}
                    </p>
                  </div>
                  <div className="space-y-2 text-right md:min-w-[190px]">
                    <Badge className={statusTone(job.statusName)}>{job.statusName?.replaceAll("_", " ")}</Badge>
                    <div className="rounded-md border border-slate-200 bg-white px-3 py-2 shadow-sm">
                      <p className="text-[11px] font-semibold uppercase tracking-wider text-slate-500">Budget</p>
                      <p className="text-sm font-semibold text-slate-800">
                        {job.minBudget || job.maxBudget
                          ? `$${(job.minBudget ?? 0).toLocaleString()} - $${(job.maxBudget ?? 0).toLocaleString()}`
                          : "Not specified"}
                        {job.budgetType === "hourly" ? " / hr" : ""}
                      </p>
                    </div>
                    <div className="flex justify-end gap-2">
                      <Button size="sm" variant="outline" className="h-8" onClick={() => openEditJob(job)}>
                        <Pencil className="mr-1 h-3.5 w-3.5" /> Edit
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        className="h-8 border-red-200 text-red-700 hover:bg-red-50"
                        disabled={!isJobOpen(job.statusName)}
                        onClick={() => setDeletingJob(job)}
                      >
                        <Trash2 className="mr-1 h-3.5 w-3.5" /> Delete
                      </Button>
                    </div>
                    {!isJobOpen(job.statusName) && (
                      <p className="text-[11px] text-amber-700">Only OPEN jobs can be deleted</p>
                    )}
                  </div>
                </div>
              </CardHeader>

              <CardContent className="space-y-4 p-6">
                <div className="flex items-center justify-between">
                  <p className="text-xs font-semibold uppercase tracking-wider text-slate-500">Proposals</p>
                  <p className="text-xs text-slate-500">{job.proposals.length} total</p>
                </div>
                {!job.proposals.length ? (
                  <div className="rounded-lg border border-dashed border-slate-300 p-5 text-sm text-slate-500">Waiting for incoming proposals.</div>
                ) : (
                  <>
                    {(() => {
                      const acceptedProposal = job.proposals.find((p) => p.status.toUpperCase() === "ACCEPTED");
                      const otherProposals = acceptedProposal ? job.proposals.filter((p) => p.id !== acceptedProposal.id) : job.proposals;
                      const showOthers = expandedOtherProposals[job.id] ?? false;
                      const proposalsToRender = acceptedProposal ? (showOthers ? otherProposals : []) : otherProposals;

                      return (
                        <>
                          {acceptedProposal && (
                            <div className="rounded-xl border border-emerald-200 bg-emerald-50/70 p-4">
                              <div className="mb-3 flex items-center justify-between gap-3">
                                <p className="text-xs font-semibold uppercase tracking-wider text-emerald-700">Selected Freelancer</p>
                                <Badge className="border-emerald-300 bg-emerald-100 text-emerald-800">Accepted</Badge>
                              </div>
                              <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
                                <div>
                                  <p className="text-lg font-semibold text-slate-900">Freelancer #{acceptedProposal.freelancerId}</p>
                                  <p className="text-sm text-slate-600">
                                    {acceptedProposal.deliveryDays ? `Delivery in ${acceptedProposal.deliveryDays} days` : "Delivery timeline not specified"}
                                  </p>
                                </div>
                                <div className="text-left md:text-right">
                                  <p className="text-xs uppercase tracking-wider text-slate-500">Bid</p>
                                  <p className="text-lg font-bold text-slate-900">${acceptedProposal.bidAmount.toLocaleString()}</p>
                                </div>
                              </div>
                              <p className="mt-3 text-sm text-slate-700">{acceptedProposal.coverLetter || "No cover letter provided."}</p>
                              <div className="mt-4 flex flex-wrap gap-2">
                                <Button size="sm" variant="outline" onClick={() => openFreelancerProfile(acceptedProposal.freelancerId)}>
                                  View Profile
                                </Button>
                                {!!otherProposals.length && (
                                  <Button
                                    size="sm"
                                    variant="outline"
                                    onClick={() => setExpandedOtherProposals((prev) => ({ ...prev, [job.id]: !showOthers }))}
                                  >
                                    {showOthers ? `Hide other proposals (${otherProposals.length})` : `Show other proposals (${otherProposals.length})`}
                                  </Button>
                                )}
                              </div>
                            </div>
                          )}

                          {!!proposalsToRender.length && (
                            <div className="grid gap-4 md:grid-cols-2">
                              {proposalsToRender.map((proposal) => {
                      const hasAcceptedProposal =
                        job.proposals.some((p) => p.status.toUpperCase() === "ACCEPTED") ||
                        (job.statusName ?? "").toUpperCase().includes("IN_PROGRESS") ||
                        (job.statusName ?? "").toUpperCase().includes("COMPLETED");
                      const canHire =
                        !hasAcceptedProposal &&
                        !["ACCEPTED", "REJECTED", "WITHDRAWN"].includes(proposal.status.toUpperCase());

                                return (
                      <div key={proposal.id} className="rounded-xl border border-slate-200 bg-white p-4 shadow-sm transition-all hover:-translate-y-0.5 hover:shadow-md">
                        <div className="mb-3 flex items-start justify-between">
                          <div>
                            <p className="font-semibold text-slate-900">Freelancer #{proposal.freelancerId}</p>
                            <p className="text-xs text-slate-500">
                              {proposal.deliveryDays ? `Delivery in ${proposal.deliveryDays} days` : "Delivery timeline not specified"}
                            </p>
                          </div>
                          <p className="font-bold text-slate-900">${proposal.bidAmount.toLocaleString()}</p>
                        </div>
                        <p className="mb-4 line-clamp-3 text-sm leading-relaxed text-slate-600">{proposal.coverLetter || "No cover letter provided."}</p>
                        <div className="mb-4 flex items-center justify-between rounded-md bg-slate-50 px-3 py-2 text-xs text-slate-600">
                          <span>Status</span>
                          <span className="font-semibold">{proposal.status}</span>
                        </div>
                        {proposal.status === "ACCEPTED" ? (
                          <div className="inline-flex items-center gap-2 rounded-md border border-emerald-200 bg-emerald-50 px-3 py-2 text-sm font-medium text-emerald-700">
                            <CheckCircle2 className="h-4 w-4" /> Accepted
                          </div>
                        ) : (
                          <div className="flex gap-2">
                            <Button
                              size="sm"
                              className="w-full"
                              disabled={!canHire || hiringProposalId === proposal.id}
                              onClick={() => handleAcceptProposal(job.id, proposal.id)}
                            >
                              {hiringProposalId === proposal.id ? "Hiring..." : "Hire Freelancer"}
                            </Button>
                            <Button
                              size="sm"
                              variant="outline"
                              className="w-full"
                              onClick={() => openFreelancerProfile(proposal.freelancerId)}
                            >
                              View Profile
                            </Button>
                            <Button
                              size="sm"
                              variant="outline"
                              className="w-full border-red-200 text-red-700 hover:bg-red-50"
                              disabled={rejectingProposalId === proposal.id || proposal.status.toUpperCase() === "ACCEPTED"}
                              onClick={() => handleRejectProposal(job.id, proposal.id)}
                            >
                              {rejectingProposalId === proposal.id ? "Rejecting..." : "Reject"}
                            </Button>
                          </div>
                        )}
                        {!canHire && proposal.status.toUpperCase() !== "ACCEPTED" && (
                          <p className="mt-3 text-xs font-medium text-amber-700">Hiring is closed for this job.</p>
                        )}
                      </div>
                    );
                              })}
                            </div>
                          )}
                        </>
                      );
                    })()}
                  </>
                )}
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );

  const renderPostJob = () => (
    <div className="mx-auto max-w-3xl space-y-6 animate-in fade-in slide-in-from-bottom-2 duration-300">
      <div>
        <h2 className="text-2xl font-bold tracking-tight">Post a New Job</h2>
        <p className="text-sm text-slate-500">Create a clear, professional brief to attract qualified freelancers faster.</p>
      </div>

      <Card className="overflow-hidden border-slate-200 shadow-lg">
        <div className="border-b border-slate-200 bg-[linear-gradient(120deg,#0f172a_0%,#1e293b_65%,#155e75_100%)] p-5 text-white">
          <p className="text-xs font-semibold uppercase tracking-[0.16em] text-cyan-100">Project Intake</p>
          <p className="mt-1 text-lg font-semibold">Describe scope, budget, and execution model</p>
        </div>
        <CardContent className="space-y-7 p-7">
          <div className="space-y-2">
            <Label htmlFor="jobTitle" className="text-slate-900">Project Title</Label>
            <Input
              id="jobTitle"
              className="h-11"
              placeholder="e.g. Build customer support dashboard in React"
              value={jobTitle}
              onChange={(e) => setJobTitle(e.target.value)}
            />
            <p className="text-xs text-slate-500">Use a precise title so freelancers can quickly evaluate fit.</p>
          </div>

          <div className="space-y-2">
            <Label htmlFor="jobDesc" className="text-slate-900">Project Description</Label>
            <Textarea
              id="jobDesc"
              rows={7}
              placeholder="Describe goals, required skills, milestones, and expected delivery."
              value={jobDescription}
              onChange={(e) => setJobDescription(e.target.value)}
            />
            <p className="text-xs text-slate-500">Well-defined scope leads to stronger proposals and fewer revisions.</p>
          </div>

          <div className="grid gap-5 md:grid-cols-3">
            <div className="space-y-2">
              <Label className="text-slate-900">Payment Type</Label>
              <Select value={jobBudgetType} onValueChange={setJobBudgetType}>
                <SelectTrigger className="h-11"><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="fixed">Fixed Price</SelectItem>
                  <SelectItem value="hourly">Hourly</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label className="text-slate-900">Minimum ($)</Label>
              <Input type="number" className="h-11" value={jobMinBudget} onChange={(e) => setJobMinBudget(e.target.value)} placeholder="1000" />
            </div>
            <div className="space-y-2">
              <Label className="text-slate-900">Maximum ($)</Label>
              <Input type="number" className="h-11" value={jobMaxBudget} onChange={(e) => setJobMaxBudget(e.target.value)} placeholder="3000" />
            </div>
          </div>

          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <Label className="text-slate-900">Required Skills</Label>
              <div className="flex items-center gap-2">
                <p className="text-xs text-slate-500">{selectedSkillIds.length} selected</p>
                <Button type="button" size="sm" variant="outline" onClick={() => setShowSuggestSkillDialog(true)}>
                  Suggest Skill
                </Button>
              </div>
            </div>
            <div className="max-h-44 overflow-y-auto rounded-lg border border-slate-200 bg-white p-3">
              {!skills.length ? (
                <p className="text-sm text-slate-500">No skills available.</p>
              ) : (
                <div className="flex flex-wrap gap-2">
                  {skills.map((skill) => {
                    const selected = selectedSkillIds.includes(skill.id);
                    return (
                      <button
                        key={skill.id}
                        type="button"
                        onClick={() => toggleSkill(skill.id)}
                        className={`rounded-full border px-3 py-1.5 text-xs font-medium transition-colors ${
                          selected
                            ? "border-cyan-700 bg-cyan-700 text-white"
                            : "border-slate-300 bg-slate-50 text-slate-700 hover:border-slate-400"
                        }`}
                      >
                        {skill.name}
                      </button>
                    );
                  })}
                </div>
              )}
            </div>
            <p className="text-xs text-slate-500">Choose skills required for this job to improve proposal matching quality.</p>
          </div>

          <div className="rounded-lg border border-slate-200 bg-slate-50 p-4">
            <p className="text-xs font-semibold uppercase tracking-wider text-slate-500">Live Preview</p>
            <p className="mt-1 text-base font-semibold text-slate-900">{jobTitle.trim() || "Untitled project"}</p>
            <p className="mt-2 text-sm text-slate-600 line-clamp-2">{jobDescription.trim() || "Your project summary will appear here."}</p>
            <p className="mt-2 text-sm font-medium text-slate-800">
              Budget: {jobMinBudget || jobMaxBudget ? `$${Number(jobMinBudget || 0).toLocaleString()} - $${Number(jobMaxBudget || 0).toLocaleString()}` : "Not specified"}
              {jobBudgetType === "hourly" ? " / hr" : ""}
            </p>
          </div>
        </CardContent>
        <CardFooter className="flex justify-end gap-3 border-t bg-slate-50 p-5">
          <div className="mr-auto text-xs text-slate-500">
            {!isPublishDisabled
              ? "Ready to publish"
              : "Fill title, description, valid budget, and select at least one skill"}
          </div>
          <Button variant="ghost" onClick={() => setActivePage("my-jobs")}>Cancel</Button>
          <Button onClick={handlePostJob} disabled={isPublishDisabled} className="min-w-[150px]">
            {postingJob ? "Publishing..." : "Publish Job"}
          </Button>
        </CardFooter>
      </Card>
    </div>
  );

  const renderContracts = () => (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-2 duration-300">
      <div>
        <h2 className="text-2xl font-bold tracking-tight">Contracts & Payments</h2>
        <p className="text-sm text-slate-500">Manage active agreements, close delivery, and track payouts.</p>
      </div>

      <section className="grid gap-4 md:grid-cols-3">
        <Card className="border-slate-200">
          <CardContent className="p-5">
            <p className="text-xs font-semibold uppercase tracking-wider text-slate-500">Total Contracts</p>
            <p className="mt-1 text-3xl font-bold text-slate-900">{contracts.length}</p>
          </CardContent>
        </Card>
        <Card className="border-slate-200">
          <CardContent className="p-5">
            <p className="text-xs font-semibold uppercase tracking-wider text-slate-500">Active</p>
            <p className="mt-1 text-3xl font-bold text-slate-900">
              {contracts.filter((c) => !c.status.toUpperCase().includes("COMPLETED")).length}
            </p>
          </CardContent>
        </Card>
        <Card className="border-slate-200">
          <CardContent className="p-5">
            <p className="text-xs font-semibold uppercase tracking-wider text-slate-500">Completed</p>
            <p className="mt-1 text-3xl font-bold text-slate-900">
              {contracts.filter((c) => c.status.toUpperCase().includes("COMPLETED")).length}
            </p>
          </CardContent>
        </Card>
      </section>

      {loadingContracts ? (
        <div className="grid gap-4 md:grid-cols-2">{[1, 2].map((i) => <Card key={i} className="h-44 animate-pulse bg-muted/50" />)}</div>
      ) : !contracts.length ? (
        <Card className="border-dashed border-slate-300 p-14 text-center">
          <Briefcase className="mx-auto mb-4 h-10 w-10 text-slate-400" />
          <p className="text-lg font-semibold">No active contracts</p>
        </Card>
      ) : (
        <div className="grid gap-4 md:grid-cols-2">
          {contracts.map((contract) => {
            const normalizedStatus = contract.status.toUpperCase().replaceAll(" ", "_");
            const completed = normalizedStatus.includes("COMPLETED");
            const cancelled =
              normalizedStatus.includes("CANCELLED") ||
              normalizedStatus.includes("CANCELED");
            const rejected = normalizedStatus.includes("REJECTED");
            const closed = completed || cancelled;
            const contractDetails = contractDetailsById[contract.id];
            const hasPendingCancellation =
              normalizedStatus.includes("CANCELLATION_REQUESTED") ||
              (Boolean(contractDetails?.cancellationRequestedBy || contractDetails?.cancellationRequestedAt) &&
                !cancelled &&
                !rejected);
            const isCancellationRequester =
              contractDetails?.cancellationRequestedBy != null &&
              contractDetails?.clientId != null &&
              Number(contractDetails.cancellationRequestedBy) === Number(contractDetails.clientId);
            const canModerateCancellation = hasPendingCancellation && !isCancellationRequester;
            const paidAmount = paidAmountByContractId[contract.id] ?? 0;
            const remainingAmount = Math.max(0, contract.budget - paidAmount);
            return (
              <Card key={contract.id} className="overflow-hidden border-slate-200">
                <CardHeader className="border-b bg-gradient-to-r from-slate-50 to-white">
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <CardTitle className="text-lg">{contract.title}</CardTitle>
                      <CardDescription>{contract.freelancerName} · Contract #{contract.id}</CardDescription>
                    </div>
                    <Badge className={statusTone(contract.status)}>{contract.status}</Badge>
                  </div>
                </CardHeader>
                <CardContent className="space-y-4 p-4">
                  <div className="rounded-lg border border-slate-200 bg-slate-50 p-3">
                    <p className="text-[11px] font-semibold uppercase tracking-wider text-slate-500">Total Amount</p>
                    <p className="text-xl font-bold text-slate-900">${contract.budget.toLocaleString()}</p>
                    <p className="mt-1 text-xs text-slate-600">
                      Paid: ${paidAmount.toLocaleString()} · Remaining: ${remainingAmount.toLocaleString()}
                    </p>
                  </div>
                  {cancelled && (
                    <div className="rounded-lg border border-red-200 bg-red-50 p-3">
                      <p className="text-xs font-semibold uppercase tracking-wider text-red-700">Contract Cancelled</p>
                      <p className="mt-1 text-sm text-red-900">
                        This contract was cancelled and is now closed.
                      </p>
                    </div>
                  )}
                  {!cancelled && hasPendingCancellation && (
                    <div className="rounded-lg border border-amber-200 bg-amber-50 p-3">
                      <p className="text-xs font-semibold uppercase tracking-wider text-amber-700">Cancellation Requested</p>
                      <p className="mt-1 text-sm text-amber-900">
                        {contractDetails?.cancellationRequesterName || "A party"} requested cancellation
                        {contractDetails?.cancellationReason ? `: ${contractDetails.cancellationReason}` : "."}
                      </p>
                    </div>
                  )}
                  <div className="flex flex-wrap gap-2">
                    {!closed && <Button onClick={() => setCompletingContract(contract)}>Review & Pay</Button>}
                    {!closed && (
                      <Button
                        variant="outline"
                        onClick={() => {
                          setPartialPaymentContract(contract);
                          setPartialPaymentAmount("");
                        }}
                      >
                        Partial Pay
                      </Button>
                    )}
                    {!closed && (
                      <Button
                        variant="outline"
                        disabled={hasPendingCancellation}
                        onClick={() => {
                          setRequestingCancelContract(contract);
                          setCancelReason("");
                        }}
                      >
                        Request Cancel
                      </Button>
                    )}
                    {!closed && canModerateCancellation && (
                      <Button
                        variant="outline"
                        disabled={confirmingCancelId === contract.id}
                        onClick={() => handleConfirmCancellation(contract.id)}
                      >
                        {confirmingCancelId === contract.id ? "Confirming..." : "Confirm Cancel"}
                      </Button>
                    )}
                    {!closed && canModerateCancellation && (
                      <Button
                        variant="outline"
                        disabled={rejectingCancelId === contract.id}
                        onClick={() => handleRejectCancellation(contract.id)}
                      >
                        {rejectingCancelId === contract.id ? "Rejecting..." : "Reject Cancel"}
                      </Button>
                    )}
                    {canDeleteContract(contract.status) && (
                      <Button variant="outline" className="border-red-200 text-red-700 hover:bg-red-50" onClick={() => setDeletingContract(contract)}>
                        Delete
                      </Button>
                    )}
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );

  return (
    <div className="flex min-h-screen bg-slate-100/70">
      <aside className="hidden w-72 flex-col border-r border-slate-200 bg-white md:flex">
        <div className="border-b border-slate-200 p-5">
          <div className="flex items-center gap-3">
            <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-slate-900 text-white">C</div>
            <div>
              <p className="text-sm font-semibold text-slate-900">Client Portal</p>
              <p className="text-xs text-slate-500">Freelance Matcher</p>
            </div>
          </div>
          <Button className="mt-4 w-full" onClick={() => setActivePage("post-job")}>
            <Plus className="mr-2 h-4 w-4" /> Post a New Job
          </Button>
        </div>

        <nav className="flex-1 space-y-1 p-4">
          {[
            { id: "overview", label: "Dashboard", icon: LayoutDashboard },
            { id: "my-jobs", label: "My Jobs", icon: FileText },
            { id: "chat", label: "Chat", icon: Users },
            { id: "contracts", label: "Contracts", icon: Briefcase },
            { id: "profile", label: "Settings", icon: Settings },
          ].map((item) => {
            const isActive = activePage === item.id;
            return (
              <button
                key={item.id}
                onClick={() => setActivePage(item.id)}
                className={`flex w-full items-center justify-between rounded-lg px-3 py-2.5 text-sm font-medium transition-colors ${
                  isActive ? "bg-slate-900 text-white" : "text-slate-600 hover:bg-slate-100"
                }`}
              >
                <span className="flex items-center gap-2">
                  <item.icon className="h-4.5 w-4.5" />
                  {item.label}
                </span>
                {isActive && <ChevronRight className="h-4 w-4" />}
              </button>
            );
          })}
        </nav>

        <div className="border-t border-slate-200 p-4">
          <button onClick={() => setActivePage("profile")} className="flex w-full items-center gap-3 rounded-lg p-2 hover:bg-slate-100">
            <Avatar className="h-9 w-9 border"><AvatarFallback>{clientDisplayName.charAt(0) || "C"}</AvatarFallback></Avatar>
            <div className="text-left">
              <p className="text-sm font-semibold text-slate-900">{clientDisplayName}</p>
              <p className="text-xs text-slate-500">Account settings</p>
            </div>
          </button>
        </div>
      </aside>

      <main className="flex-1 p-6 lg:p-8">
        <div className="mx-auto max-w-7xl">
          {activePage === "overview" && renderOverview()}
          {activePage === "my-jobs" && renderMyJobs()}
          {activePage === "chat" && <ClientChat />}
          {activePage === "post-job" && renderPostJob()}
          {activePage === "contracts" && renderContracts()}
          {activePage === "profile" && <ClientProfile />}
        </div>
      </main>

      <Dialog open={!!completingContract} onOpenChange={(open) => !open && setCompletingContract(null)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Complete & Pay</DialogTitle>
            <DialogDescription>
              Finalize "{completingContract?.title}" and release payment.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div className="rounded-lg border border-emerald-200 bg-emerald-50 p-3 text-sm">
              Amount to pay: <span className="font-semibold">${Math.max(0, (completingContract?.budget ?? 0) - (paidAmountByContractId[completingContract?.id ?? 0] ?? 0)).toLocaleString()}</span>
            </div>
            <div className="space-y-2">
              <Label>Rating</Label>
              <Select value={rating} onValueChange={setRating}>
                <SelectTrigger><SelectValue placeholder="Select rating" /></SelectTrigger>
                <SelectContent>
                  {[5, 4, 3, 2, 1].map((val) => (
                    <SelectItem key={val} value={String(val)}>{val} Stars</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label>Feedback</Label>
              <Textarea rows={4} value={feedbackText} onChange={(e) => setFeedbackText(e.target.value)} />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setCompletingContract(null)}>Cancel</Button>
            <Button onClick={handleCompleteContract} disabled={submittingComplete}>
              <Check className="mr-2 h-4 w-4" />
              {submittingComplete ? "Processing..." : "Approve & Pay"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={!!editingJob} onOpenChange={(open) => !open && setEditingJob(null)}>
        <DialogContent className="sm:max-w-2xl">
          <DialogHeader>
            <DialogTitle>Edit Job</DialogTitle>
            <DialogDescription>Update details and required skills for this job posting.</DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div className="space-y-2">
              <Label>Project Title</Label>
              <Input value={editJobTitle} onChange={(e) => setEditJobTitle(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label>Description</Label>
              <Textarea rows={5} value={editJobDescription} onChange={(e) => setEditJobDescription(e.target.value)} />
            </div>
            <div className="grid gap-4 md:grid-cols-3">
              <div className="space-y-2">
                <Label>Payment Type</Label>
                <Select value={editJobBudgetType} onValueChange={setEditJobBudgetType}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="fixed">Fixed Price</SelectItem>
                    <SelectItem value="hourly">Hourly</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label>Minimum ($)</Label>
                <Input type="number" value={editJobMinBudget} onChange={(e) => setEditJobMinBudget(e.target.value)} />
              </div>
              <div className="space-y-2">
                <Label>Maximum ($)</Label>
                <Input type="number" value={editJobMaxBudget} onChange={(e) => setEditJobMaxBudget(e.target.value)} />
              </div>
            </div>

            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <Label>Required Skills</Label>
                <Button type="button" size="sm" variant="outline" onClick={() => setShowSuggestSkillDialog(true)}>
                  Suggest Skill
                </Button>
              </div>
              <div className="max-h-40 overflow-y-auto rounded-lg border border-slate-200 p-3">
                <div className="flex flex-wrap gap-2">
                  {skills.map((skill) => {
                    const selected = editSelectedSkillIds.includes(skill.id);
                    return (
                      <button
                        key={`edit-skill-${skill.id}`}
                        type="button"
                        onClick={() => toggleEditSkill(skill.id)}
                        className={`rounded-full border px-3 py-1.5 text-xs font-medium ${
                          selected ? "border-cyan-700 bg-cyan-700 text-white" : "border-slate-300 bg-slate-50 text-slate-700"
                        }`}
                      >
                        {skill.name}
                      </button>
                    );
                  })}
                </div>
              </div>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setEditingJob(null)}>Cancel</Button>
            <Button onClick={handleUpdateJob} disabled={savingEditJob}>
              {savingEditJob ? "Saving..." : "Save Changes"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={!!deletingJob} onOpenChange={(open) => !open && setDeletingJob(null)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Delete Job</DialogTitle>
            <DialogDescription>
              Are you sure you want to delete <span className="font-semibold text-foreground">{deletingJob?.title}</span>? This action cannot be undone.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDeletingJob(null)}>Cancel</Button>
            <Button variant="destructive" onClick={handleDeleteJob} disabled={deletingInProgress}>
              {deletingInProgress ? "Deleting..." : "Delete Job"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={!!deletingContract} onOpenChange={(open) => !open && setDeletingContract(null)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Delete Contract</DialogTitle>
            <DialogDescription>
              Delete contract <span className="font-semibold text-foreground">#{deletingContract?.id}</span>? This action cannot be undone.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDeletingContract(null)}>Cancel</Button>
            <Button variant="destructive" onClick={handleDeleteContract} disabled={deletingContractInProgress}>
              {deletingContractInProgress ? "Deleting..." : "Delete Contract"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={!!partialPaymentContract} onOpenChange={(open) => !open && setPartialPaymentContract(null)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Partial Payment</DialogTitle>
            <DialogDescription>
              Record partial payment for contract #{partialPaymentContract?.id}.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-3 py-2">
            <div className="space-y-2">
              <Label>Amount ($)</Label>
              <Input type="number" value={partialPaymentAmount} onChange={(e) => setPartialPaymentAmount(e.target.value)} placeholder="e.g. 500" />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setPartialPaymentContract(null)}>Cancel</Button>
            <Button onClick={handlePartialPayment} disabled={processingPartialPayment}>
              {processingPartialPayment ? "Processing..." : "Submit Payment"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={!!requestingCancelContract} onOpenChange={(open) => !open && setRequestingCancelContract(null)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Request Cancellation</DialogTitle>
            <DialogDescription>
              Send cancellation request for contract #{requestingCancelContract?.id}.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-2 py-2">
            <Label>Reason (optional)</Label>
            <Textarea rows={4} value={cancelReason} onChange={(e) => setCancelReason(e.target.value)} placeholder="Describe why this contract should be cancelled..." />
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setRequestingCancelContract(null)}>Cancel</Button>
            <Button onClick={handleRequestCancellation} disabled={processingCancelRequest}>
              {processingCancelRequest ? "Sending..." : "Send Request"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={viewingFreelancerId !== null} onOpenChange={(open) => !open && setViewingFreelancerId(null)}>
        <DialogContent className="max-h-[85vh] overflow-y-auto sm:max-w-2xl">
          <DialogHeader>
            <DialogTitle>Freelancer Profile</DialogTitle>
            <DialogDescription>
              {freelancerProfile?.firstName || freelancerProfile?.lastName
                ? `${freelancerProfile.firstName ?? ""} ${freelancerProfile.lastName ?? ""}`.trim()
                : `Profile summary for freelancer #${viewingFreelancerId}`}
            </DialogDescription>
          </DialogHeader>
          {loadingFreelancerProfile ? (
            <div className="py-8 text-center text-sm text-slate-500">Loading profile...</div>
          ) : (
            <div className="space-y-4 py-2">
              <section className="rounded-xl border border-slate-200 bg-[linear-gradient(130deg,#0f172a_0%,#1e293b_58%,#0f766e_100%)] p-4 text-white">
                <div className="flex items-start justify-between gap-4">
                  <div className="flex items-center gap-3">
                    <Avatar className="h-12 w-12 border border-white/30">
                      <AvatarFallback className="bg-white/20 text-sm font-semibold text-white">
                        {`${freelancerProfile?.firstName?.charAt(0) ?? ""}${freelancerProfile?.lastName?.charAt(0) ?? ""}`.trim() || "FR"}
                      </AvatarFallback>
                    </Avatar>
                    <div>
                      <p className="text-base font-semibold">
                        {freelancerProfile?.firstName || freelancerProfile?.lastName
                          ? `${freelancerProfile.firstName ?? ""} ${freelancerProfile.lastName ?? ""}`.trim()
                          : `Freelancer #${viewingFreelancerId}`}
                      </p>
                      <p className="text-xs text-cyan-100">
                        {freelancerProfile?.email || "Email is hidden"}
                      </p>
                    </div>
                  </div>
                  <Badge className={`${freelancerProfile?.isAvailable ? "bg-emerald-500/20 text-emerald-50 border-emerald-300/40" : "bg-amber-500/20 text-amber-50 border-amber-300/40"}`}>
                    {freelancerProfile?.isAvailable == null ? "Availability unknown" : freelancerProfile?.isAvailable ? "Available now" : "Currently busy"}
                  </Badge>
                </div>
                <div className="mt-4 rounded-lg bg-white/10 p-3">
                  <p className="text-[11px] uppercase tracking-[0.14em] text-cyan-100">Hourly Rate</p>
                  <p className="text-2xl font-bold">
                    {freelancerProfile?.hourlyRate != null
                      ? `$${Number(freelancerProfile.hourlyRate).toLocaleString()}/hr`
                      : "N/A"}
                  </p>
                </div>
              </section>

              <section className="grid gap-3 sm:grid-cols-2">
                <div className="rounded-lg border border-slate-200 bg-slate-50 p-3">
                  <p className="text-xs uppercase tracking-wider text-slate-500">Rating</p>
                  <p className="text-lg font-semibold text-slate-900">
                    {freelancerProfile?.rating != null ? `${Number(freelancerProfile.rating).toFixed(2)} / 5` : "N/A"}
                  </p>
                </div>
                <div className="rounded-lg border border-slate-200 bg-slate-50 p-3">
                  <p className="text-xs uppercase tracking-wider text-slate-500">Total Earnings</p>
                  <p className="text-lg font-semibold text-slate-900">
                    {freelancerProfile?.totalEarnings != null
                      ? `$${Number(freelancerProfile.totalEarnings).toLocaleString()}`
                      : "N/A"}
                  </p>
                </div>
                <div className="rounded-lg border border-slate-200 bg-slate-50 p-3">
                  <p className="text-xs uppercase tracking-wider text-slate-500">Completed Jobs</p>
                  <p className="text-lg font-semibold text-slate-900">
                    {freelancerProfile?.completedJobs != null ? Number(freelancerProfile.completedJobs) : "N/A"}
                  </p>
                </div>
                <div className="rounded-lg border border-slate-200 bg-slate-50 p-3">
                  <p className="text-xs uppercase tracking-wider text-slate-500">Total Reviews</p>
                  <p className="text-lg font-semibold text-slate-900">
                    {freelancerProfile?.totalReviews != null ? Number(freelancerProfile.totalReviews) : "N/A"}
                  </p>
                </div>
              </section>

              <section className="rounded-lg border border-slate-200 bg-white p-4">
                <p className="text-xs font-semibold uppercase tracking-wider text-slate-500">About</p>
                <p className="mt-2 text-sm leading-relaxed text-slate-700">
                  {freelancerProfile?.bio?.trim() || "Freelancer has not added a bio yet."}
                </p>
              </section>

              <section className="rounded-lg border border-slate-200 bg-white p-4">
                <p className="text-xs font-semibold uppercase tracking-wider text-slate-500">Skills</p>
                {!freelancerProfile?.skills?.length ? (
                  <p className="mt-2 text-sm text-slate-500">No skills listed.</p>
                ) : (
                  <div className="mt-3 flex flex-wrap gap-2">
                    {freelancerProfile.skills.map((skill, idx) => (
                      <Badge key={`${skill.skillName ?? "skill"}-${idx}`} variant="outline" className="bg-slate-50">
                        {skill.skillName ?? "Skill"}
                        {skill.yearsExperience != null ? ` · ${skill.yearsExperience}y` : ""}
                      </Badge>
                    ))}
                  </div>
                )}
              </section>

              <section className="rounded-lg border border-slate-200 bg-white p-4">
                <p className="text-xs font-semibold uppercase tracking-wider text-slate-500">Recent Reviews</p>
                {!freelancerProfile?.recentReviews?.length ? (
                  <p className="mt-2 text-sm text-slate-500">No recent reviews.</p>
                ) : (
                  <div className="mt-3 space-y-3">
                    {freelancerProfile.recentReviews.slice(0, 3).map((review, idx) => (
                      <div key={`${review.clientName ?? "review"}-${idx}`} className="rounded-md border border-slate-200 bg-slate-50 p-3">
                        <div className="flex items-center justify-between gap-3">
                          <p className="text-sm font-semibold text-slate-900">{review.clientName ?? "Client"}</p>
                          <p className="text-xs font-medium text-slate-600">
                            {review.rating != null ? `${Number(review.rating).toFixed(1)} / 5` : "No rating"}
                          </p>
                        </div>
                        <p className="mt-1 text-sm text-slate-600">{review.comment?.trim() || "No comment provided."}</p>
                      </div>
                    ))}
                  </div>
                )}
              </section>

              <div className="grid gap-3 text-xs text-slate-500 sm:grid-cols-2">
                <div className="rounded-md border border-slate-200 bg-slate-50 p-2.5">
                  Member since: <span className="font-medium text-slate-700">{freelancerProfile?.memberSince ? new Date(freelancerProfile.memberSince).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" }) : "N/A"}</span>
                </div>
                <div className="rounded-md border border-slate-200 bg-slate-50 p-2.5">
                  Last login: <span className="font-medium text-slate-700">{freelancerProfile?.lastLogin ? new Date(freelancerProfile.lastLogin).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" }) : "N/A"}</span>
                </div>
              </div>
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setViewingFreelancerId(null)}>Close</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={showSuggestSkillDialog} onOpenChange={(open) => !open && setShowSuggestSkillDialog(false)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Suggest Skill</DialogTitle>
            <DialogDescription>Suggest a missing skill for admin review.</DialogDescription>
          </DialogHeader>
          <div className="space-y-3 py-1">
            <div className="space-y-2">
              <Label htmlFor="suggestedSkillName">Skill Name</Label>
              <Input
                id="suggestedSkillName"
                value={suggestedSkillName}
                onChange={(e) => setSuggestedSkillName(e.target.value)}
                placeholder="e.g. Three.js"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="suggestedSkillCategory">Category (optional)</Label>
              <Input
                id="suggestedSkillCategory"
                value={suggestedSkillCategory}
                onChange={(e) => setSuggestedSkillCategory(e.target.value)}
                placeholder="e.g. Frontend"
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowSuggestSkillDialog(false)}>Cancel</Button>
            <Button onClick={handleSuggestSkill} disabled={suggestingSkill}>
              {suggestingSkill ? "Sending..." : "Send Suggestion"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

    </div>
  );
}
