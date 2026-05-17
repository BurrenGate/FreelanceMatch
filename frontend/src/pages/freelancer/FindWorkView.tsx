import { useEffect, useMemo, useState, type FormEvent } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Avatar,
  AvatarFallback,
  AvatarImage,
} from "@/components/ui/avatar";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Briefcase,
  Calendar,
  Check,
  Clock3,
  DollarSign,
  Loader2,
  Search,
  SlidersHorizontal,
  Sparkles,
  Star,
  Target,
  UserRound,
  XCircle,
} from "lucide-react";
import { api, clientProfileApi, extractApiMessage, jobApi, profileSkillApi, skillApi, unwrapData } from "@/lib/api";
import { toast } from "sonner";
import type { ClientProfileDTO, Job, JobSkillDTO, ProfileSkillResponse, Proposal } from "@/shared/api/generated";

type JobItem = Job & { skills?: string[] };

interface SkillOption {
  id: number;
  name: string;
}

type EndpointTab = "all" | "recommended";
type SortBy = "newest" | "budget_desc" | "budget_asc";

export default function FindWorkView({ prefillJobId }: { prefillJobId?: string | null }) {
  const [jobs, setJobs] = useState<JobItem[]>([]);
  const [availableSkills, setAvailableSkills] = useState<SkillOption[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<EndpointTab>("all");

  const [searchTerm, setSearchTerm] = useState("");
  const [showFilters, setShowFilters] = useState(false);
  const [budgetType, setBudgetType] = useState<string>("all");
  const [minBudget, setMinBudget] = useState<string>("");
  const [maxBudget, setMaxBudget] = useState<string>("");
  const [selectedSkills, setSelectedSkills] = useState<string[]>([]);
  const [sortBy, setSortBy] = useState<SortBy>("newest");

  const [applyingJobId, setApplyingJobId] = useState<number | null>(null);
  const [bidAmount, setBidAmount] = useState<string>("");
  const [coverLetter, setCoverLetter] = useState<string>("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [appliedJobIds, setAppliedJobIds] = useState<Set<number>>(new Set());
  const [viewingClientId, setViewingClientId] = useState<number | null>(null);
  const [loadingClient, setLoadingClient] = useState(false);
  const [clientAccount, setClientAccount] = useState<ClientProfileDTO | null>(null);
  const [clientCache, setClientCache] = useState<Record<number, ClientProfileDTO>>({});

  useEffect(() => {
    const fetchJobs = async () => {
      setLoading(true);
      try {
        const enrichJobsWithSkills = async (rawJobs: Job[]) => {
          const baseJobs = (Array.isArray(rawJobs) ? rawJobs : []).map((job) => ({
            ...job,
            skills: [] as string[],
          }));

          return Promise.all(
            baseJobs.map(async (job) => {
              try {
                const skillsRes = await jobApi.getJobSkills(Number(job.id));
                const skillsData = unwrapData<JobSkillDTO[]>(skillsRes.data);
                const jobSkills = (Array.isArray(skillsData) ? skillsData : [])
                  .map((skill) => String(skill.skillName ?? "").trim())
                  .filter((name) => name.length > 0);

                return { ...job, skills: jobSkills };
              } catch {
                return { ...job, skills: [] };
              }
            }),
          );
        };

        if (activeTab === "recommended") {
          const [allJobsRes, mySkillsRes] = await Promise.all([
            api.get("/api/jobs"),
            profileSkillApi.getMySkills(),
          ]);

          const allRaw = unwrapData<Job[]>(allJobsRes.data);
          const mySkillsRaw = unwrapData<ProfileSkillResponse[]>(mySkillsRes.data);
          const mySkillSet = new Set(
            (Array.isArray(mySkillsRaw) ? mySkillsRaw : [])
              .map((s) => String(s.skillName ?? "").trim().toLowerCase())
              .filter(Boolean),
          );

          const allWithSkills = await enrichJobsWithSkills(Array.isArray(allRaw) ? allRaw : []);
          const skillMatchedJobs = allWithSkills.filter((job) =>
            (job.skills || []).some((skill) => mySkillSet.has(skill.toLowerCase())),
          );
          setJobs(skillMatchedJobs);
        } else {
          const response = await api.get("/api/jobs");
          const data = unwrapData<Job[]>(response.data);
          const jobsWithSkills = await enrichJobsWithSkills(Array.isArray(data) ? data : []);
          setJobs(jobsWithSkills);
        }
      } catch (error) {
        toast.error(extractApiMessage(error, "Failed to fetch jobs."));
        setJobs([]);
      } finally {
        setLoading(false);
      }
    };

    fetchJobs();
  }, [activeTab]);

  useEffect(() => {
    const fetchMyProposals = async () => {
      try {
        const res = await api.get("/api/proposals");
        const proposals = unwrapData<Proposal[]>(res.data);
        const ids = new Set(
          (Array.isArray(proposals) ? proposals : [])
            .map((proposal) => Number(proposal.jobId ?? 0))
            .filter((id) => id > 0),
        );
        setAppliedJobIds(ids);
      } catch {
        setAppliedJobIds(new Set());
      }
    };

    fetchMyProposals();
  }, []);

  useEffect(() => {
    const fetchSkills = async () => {
      try {
        const res = await skillApi.getAllSkills();
        const data = unwrapData<Array<{ id?: number; name?: string }>>(res.data);
        const normalized = (Array.isArray(data) ? data : [])
          .map((skill) => ({
            id: Number(skill.id ?? 0),
            name: String(skill.name ?? "").trim(),
          }))
          .filter((skill) => skill.id > 0 && skill.name.length > 0);

        setAvailableSkills(normalized);
      } catch (error) {
        console.error("Failed to fetch skills:", error);
        setAvailableSkills([]);
      }
    };

    fetchSkills();
  }, []);

  useEffect(() => {
    if (prefillJobId && prefillJobId.trim()) {
      setSearchTerm(prefillJobId.trim());
    }
  }, [prefillJobId]);

  const activeFiltersCount =
    (budgetType !== "all" ? 1 : 0) +
    (minBudget ? 1 : 0) +
    (maxBudget ? 1 : 0) +
    selectedSkills.length;

  const filteredJobs = useMemo(() => {
    const filtered = jobs.filter((job) => {
      const searchLower = searchTerm.toLowerCase();
      const matchesSearch =
        job.title.toLowerCase().includes(searchLower) ||
        job.description.toLowerCase().includes(searchLower) ||
        (job.skills || []).some((skill) => skill.toLowerCase().includes(searchLower)) ||
        String(job.id ?? "").includes(searchLower);

      const matchesBudgetType = budgetType === "all" || job.budgetType === budgetType;

      const filterMin = Number(minBudget);
      const filterMax = Number(maxBudget);
      let matchesBudgetRange = true;

      if (!Number.isNaN(filterMin) && minBudget && job.maxBudget < filterMin) matchesBudgetRange = false;
      if (!Number.isNaN(filterMax) && maxBudget && job.minBudget > filterMax) matchesBudgetRange = false;

      const matchesSkills =
        selectedSkills.length === 0 ||
        selectedSkills.every((skill) => (job.skills || []).includes(skill));

      return matchesSearch && matchesBudgetType && matchesBudgetRange && matchesSkills;
    });

    return filtered.sort((a, b) => {
      if (sortBy === "newest") {
        return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
      }

      const budgetA = Math.max(a.minBudget || 0, a.maxBudget || 0);
      const budgetB = Math.max(b.minBudget || 0, b.maxBudget || 0);

      if (sortBy === "budget_desc") return budgetB - budgetA;
      return budgetA - budgetB;
    });
  }, [jobs, searchTerm, budgetType, minBudget, maxBudget, selectedSkills, sortBy]);

  const closeApplyModal = () => {
    setApplyingJobId(null);
    setBidAmount("");
    setCoverLetter("");
  };

  const handleApplySubmit = async (e: FormEvent) => {
    e.preventDefault();
    if (!applyingJobId) return;
    if (appliedJobIds.has(applyingJobId)) {
      toast.message("You already submitted a proposal for this job.");
      closeApplyModal();
      return;
    }

    setIsSubmitting(true);
    try {
      await api.post("/api/proposals/submit", {
        jobId: applyingJobId,
        bidAmount: parseFloat(bidAmount),
        coverLetter,
      });

      toast.success("Proposal submitted successfully.");
      setAppliedJobIds((prev) => new Set(prev).add(applyingJobId));
      closeApplyModal();
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to submit proposal."));
    } finally {
      setIsSubmitting(false);
    }
  };

  const toggleSkill = (skill: string) => {
    setSelectedSkills((prev) =>
      prev.includes(skill) ? prev.filter((s) => s !== skill) : [...prev, skill],
    );
  };

  const clearFilters = () => {
    setBudgetType("all");
    setMinBudget("");
    setMaxBudget("");
    setSelectedSkills([]);
  };

  const openClientAccount = async (clientId: number) => {
    setViewingClientId(clientId);
    if (clientCache[clientId]) {
      setClientAccount(clientCache[clientId]);
      return;
    }

    setLoadingClient(true);
    setClientAccount(null);
    try {
      const res = await clientProfileApi.getClientProfile(clientId);
      const data = unwrapData<ClientProfileDTO>(res.data);
      setClientAccount(data ?? null);
      setClientCache((prev) => ({ ...prev, [clientId]: data ?? {} }));
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to load client profile."));
    } finally {
      setLoadingClient(false);
    }
  };

  return (
    <div className="mx-auto max-w-7xl space-y-6 animate-in fade-in slide-in-from-bottom-2 duration-300">
      <section className="relative overflow-hidden rounded-2xl border border-slate-200 bg-[linear-gradient(135deg,#0f172a_0%,#1e293b_50%,#0f766e_100%)] p-6 text-white shadow-xl md:p-8">
        <div className="pointer-events-none absolute -right-20 -top-20 h-56 w-56 rounded-full bg-cyan-300/20 blur-3xl" />
        <div className="pointer-events-none absolute -bottom-16 -left-10 h-48 w-48 rounded-full bg-emerald-300/20 blur-3xl" />
        <div className="relative flex flex-col gap-5 md:flex-row md:items-end md:justify-between">
          <div>
            <p className="mb-2 inline-flex items-center gap-2 rounded-full bg-white/10 px-3 py-1 text-xs font-semibold uppercase tracking-[0.14em] text-cyan-100">
              <Sparkles className="h-3.5 w-3.5" /> Opportunity Feed
            </p>
            <h1 className="text-3xl font-bold tracking-tight md:text-4xl">Find your next project</h1>
            <p className="mt-2 max-w-2xl text-sm text-slate-200 md:text-base">
              Browse curated opportunities, filter fast, and send strong proposals with confidence.
            </p>
          </div>
          <div className="grid grid-cols-2 gap-2">
            <Card className="border-white/20 bg-white/10 text-white">
              <CardContent className="p-3">
                <p className="text-[11px] uppercase tracking-wider text-cyan-100">Available jobs</p>
                <p className="text-xl font-semibold">{jobs.length}</p>
              </CardContent>
            </Card>
            <Card className="border-white/20 bg-white/10 text-white">
              <CardContent className="p-3">
                <p className="text-[11px] uppercase tracking-wider text-cyan-100">Matching now</p>
                <p className="text-xl font-semibold">{filteredJobs.length}</p>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      <section className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm md:p-5">
        <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <div className="flex items-center gap-2">
            <Button variant={activeTab === "all" ? "default" : "outline"} onClick={() => setActiveTab("all")}>
              <Briefcase className="mr-2 h-4 w-4" /> All Jobs
            </Button>
            <Button variant={activeTab === "recommended" ? "default" : "outline"} onClick={() => setActiveTab("recommended")}>
              <Star className="mr-2 h-4 w-4" /> Recommended
            </Button>
          </div>
          <div className="flex items-center gap-2">
            <Button variant={showFilters ? "default" : "outline"} onClick={() => setShowFilters((v) => !v)}>
              <SlidersHorizontal className="mr-2 h-4 w-4" /> Filters
              {activeFiltersCount > 0 && (
                <span className="ml-1 rounded-full bg-background px-2 py-0.5 text-xs text-foreground">
                  {activeFiltersCount}
                </span>
              )}
            </Button>
            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value as SortBy)}
              className="h-10 rounded-md border border-input bg-background px-3 text-sm"
            >
              <option value="newest">Sort: Newest</option>
              <option value="budget_desc">Sort: Budget high to low</option>
              <option value="budget_asc">Sort: Budget low to high</option>
            </select>
          </div>
        </div>

        <div className="mt-4 grid gap-3 md:grid-cols-[1fr_auto]">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              placeholder="Search by title, keyword, or skill"
              className="h-11 pl-9"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
            {searchTerm && (
              <button
                type="button"
                onClick={() => setSearchTerm("")}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
              >
                <XCircle className="h-4 w-4" />
              </button>
            )}
          </div>
          <div className="flex items-center gap-2 text-xs text-slate-500">
            <Target className="h-4 w-4" />
            {filteredJobs.length} matches
          </div>
        </div>

        {showFilters && (
          <div className="mt-4 space-y-4 rounded-xl border border-slate-200 bg-slate-50 p-4">
            <div className="flex items-center justify-between">
              <p className="text-sm font-semibold text-slate-900">Advanced filters</p>
              {activeFiltersCount > 0 && (
                <Button variant="ghost" size="sm" onClick={clearFilters}>
                  Clear all
                </Button>
              )}
            </div>

            <div className="grid gap-4 md:grid-cols-3">
              <div className="space-y-2">
                <Label>Project Type</Label>
                <div className="flex flex-wrap gap-2">
                  {["all", "hourly", "fixed"].map((type) => (
                    <Badge
                      key={type}
                      variant={budgetType === type ? "default" : "outline"}
                      className="cursor-pointer"
                      onClick={() => setBudgetType(type)}
                    >
                      {type === "all" ? "Any" : type === "hourly" ? "Hourly" : "Fixed"}
                    </Badge>
                  ))}
                </div>
              </div>

              <div className="space-y-2">
                <Label>Budget Min / Max ($)</Label>
                <div className="grid grid-cols-2 gap-2">
                  <Input type="number" placeholder="Min" value={minBudget} onChange={(e) => setMinBudget(e.target.value)} />
                  <Input type="number" placeholder="Max" value={maxBudget} onChange={(e) => setMaxBudget(e.target.value)} />
                </div>
              </div>

              <div className="space-y-2">
                <Label>Skills</Label>
                <div className="flex flex-wrap gap-2">
                  {availableSkills.map((skill) => {
                    const isSelected = selectedSkills.includes(skill.name);
                    return (
                      <Badge
                        key={skill.id}
                        variant={isSelected ? "default" : "secondary"}
                        className="cursor-pointer"
                        onClick={() => toggleSkill(skill.name)}
                      >
                        {isSelected && <Check className="mr-1 h-3 w-3" />}
                        {skill.name}
                      </Badge>
                    );
                  })}
                  {availableSkills.length === 0 && (
                    <p className="text-xs text-slate-500">Skills are unavailable right now.</p>
                  )}
                </div>
              </div>
            </div>
          </div>
        )}
      </section>

      <section className="space-y-4">
        {loading ? (
          <div className="space-y-4">
            {[1, 2, 3].map((i) => (
              <Card key={i} className="h-44 animate-pulse bg-muted/50" />
            ))}
          </div>
        ) : filteredJobs.length === 0 ? (
          <Card className="border-dashed border-slate-300 p-12 text-center">
            <Search className="mx-auto mb-4 h-9 w-9 text-slate-400" />
            <p className="text-lg font-semibold">No jobs found</p>
            <p className="mt-1 text-sm text-slate-500">Try expanding your filters or using broader keywords.</p>
            {(activeFiltersCount > 0 || searchTerm) && (
              <Button className="mt-4" variant="outline" onClick={() => { clearFilters(); setSearchTerm(""); }}>
                Reset filters
              </Button>
            )}
          </Card>
        ) : (
          filteredJobs.map((job) => {
            const alreadyApplied = appliedJobIds.has(Number(job.id));
            const postedDate = job.createdAt
              ? new Date(job.createdAt).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })
              : "Recently posted";

            return (
              <Card key={job.id} className="overflow-hidden border-slate-200 shadow-sm transition hover:border-cyan-300 hover:shadow-md">
                <CardHeader className="border-b bg-gradient-to-r from-slate-50 to-white pb-4">
                  <div className="flex flex-col gap-3 md:flex-row md:items-start md:justify-between">
                    <div>
                      <CardTitle className="text-xl text-slate-900">{job.title}</CardTitle>
                      <CardDescription className="mt-1 line-clamp-2 text-sm leading-relaxed">{job.description}</CardDescription>
                    </div>
                    <div className="rounded-md border border-slate-200 bg-white px-3 py-2 text-right">
                      <p className="text-[11px] font-semibold uppercase tracking-wider text-slate-500">Budget</p>
                      <p className="text-sm font-semibold text-slate-900">
                        ${Number(job.minBudget || 0).toLocaleString()} - ${Number(job.maxBudget || 0).toLocaleString()}
                      </p>
                      <p className="text-xs text-slate-500">{job.budgetType === "hourly" ? "Hourly" : "Fixed price"}</p>
                    </div>
                  </div>
                </CardHeader>
                <CardContent className="space-y-4 p-5">
                  <div className="flex flex-wrap items-center gap-2 text-xs text-slate-500">
                    <span className="inline-flex items-center gap-1 rounded-full bg-slate-100 px-2 py-1">
                      <Calendar className="h-3.5 w-3.5" /> Posted {postedDate}
                    </span>
                    <span className="inline-flex items-center gap-1 rounded-full bg-slate-100 px-2 py-1">
                      <Clock3 className="h-3.5 w-3.5" /> {job.statusName?.replaceAll("_", " ") || "Open"}
                    </span>
                    <span className="inline-flex items-center gap-1 rounded-full bg-slate-100 px-2 py-1">
                      <DollarSign className="h-3.5 w-3.5" /> ID #{job.id}
                    </span>
                  </div>

                  <div className="flex flex-wrap gap-2">
                    {(job.skills || []).length > 0 ? (
                      job.skills?.map((skill) => (
                        <Badge key={skill} variant="outline" className="bg-cyan-50 text-cyan-900">
                          {skill}
                        </Badge>
                      ))
                    ) : (
                      <p className="text-xs text-slate-500">No skills listed.</p>
                    )}
                  </div>

                  <div className="flex justify-end">
                    <div className="flex gap-2">
                      {alreadyApplied && (
                        <Badge variant="secondary" className="border-emerald-200 bg-emerald-50 text-emerald-700">
                          Proposal sent
                        </Badge>
                      )}
                      <Button variant="outline" onClick={() => openClientAccount(job.clientId)}>
                        <UserRound className="mr-2 h-4 w-4" />
                        Client Account
                      </Button>
                      <Button disabled={alreadyApplied} onClick={() => setApplyingJobId(job.id)}>
                        {alreadyApplied ? "Already Applied" : "Apply Now"}
                      </Button>
                    </div>
                  </div>
                </CardContent>
              </Card>
            );
          })
        )}
      </section>

      <Dialog open={!!applyingJobId} onOpenChange={(open) => !open && closeApplyModal()}>
        <DialogContent className="sm:max-w-xl">
          <form onSubmit={handleApplySubmit} className="space-y-4">
            <DialogHeader>
              <DialogTitle>Submit Proposal</DialogTitle>
              <DialogDescription>
                Send a tailored offer with a clear budget and concise plan.
              </DialogDescription>
            </DialogHeader>

            <div className="space-y-2">
              <Label htmlFor="bidAmount">Your Bid ($)</Label>
              <Input
                id="bidAmount"
                type="number"
                min={1}
                required
                placeholder="e.g. 1200"
                value={bidAmount}
                onChange={(e) => setBidAmount(e.target.value)}
                disabled={isSubmitting}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="coverLetter">Cover Letter</Label>
              <Textarea
                id="coverLetter"
                required
                rows={7}
                placeholder="Explain your relevant experience, your plan, timeline, and expected outcome."
                value={coverLetter}
                onChange={(e) => setCoverLetter(e.target.value)}
                disabled={isSubmitting}
              />
            </div>

            <DialogFooter>
              <Button type="button" variant="outline" onClick={closeApplyModal} disabled={isSubmitting}>
                Cancel
              </Button>
              <Button type="submit" disabled={isSubmitting || !bidAmount || !coverLetter.trim()}>
                {isSubmitting ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Submitting...
                  </>
                ) : (
                  "Submit Proposal"
                )}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      <Dialog open={!!viewingClientId} onOpenChange={(open) => !open && setViewingClientId(null)}>
        <DialogContent className="sm:max-w-2xl">
          <DialogHeader>
            <DialogTitle>Client Profile</DialogTitle>
            <DialogDescription>
              Public profile details for client #{viewingClientId}
            </DialogDescription>
          </DialogHeader>

          {loadingClient ? (
            <div className="flex items-center gap-2 py-6 text-sm text-slate-600">
              <Loader2 className="h-4 w-4 animate-spin" />
              Loading client profile...
            </div>
          ) : clientAccount ? (
            <div className="space-y-4 py-1">
              <div className="rounded-xl border border-slate-200 bg-gradient-to-r from-slate-50 to-cyan-50 p-4">
                <div className="flex items-start gap-3">
                  <Avatar className="h-12 w-12 border">
                    <AvatarImage src={clientAccount.avatarUrl || ""} alt={clientAccount.fullName || "Client"} />
                    <AvatarFallback className="bg-cyan-100 text-cyan-800">
                      {(clientAccount.fullName || clientAccount.firstName || "C").charAt(0).toUpperCase()}
                    </AvatarFallback>
                  </Avatar>
                  <div className="min-w-0 flex-1">
                    <p className="text-xs font-semibold uppercase tracking-wider text-slate-500">Client</p>
                    <p className="truncate text-base font-semibold text-slate-900">
                  {clientAccount.fullName || `${clientAccount.firstName ?? ""} ${clientAccount.lastName ?? ""}`.trim() || "N/A"}
                    </p>
                    <p className="truncate text-xs text-slate-500">{clientAccount.email || "Email hidden"}</p>
                  </div>
                  <Badge className="border-emerald-200 bg-emerald-50 text-emerald-700">
                    {clientAccount.accountStatus || "ACTIVE"}
                  </Badge>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
                <div className="rounded-lg border border-slate-200 bg-white p-3">
                  <p className="text-[11px] font-semibold uppercase tracking-wider text-slate-500">Posted</p>
                  <p className="mt-1 text-base font-semibold text-slate-900">{clientAccount.postedJobs ?? 0}</p>
                </div>
                <div className="rounded-lg border border-slate-200 bg-white p-3">
                  <p className="text-[11px] font-semibold uppercase tracking-wider text-slate-500">Active</p>
                  <p className="mt-1 text-base font-semibold text-slate-900">{clientAccount.activeJobs ?? 0}</p>
                </div>
                <div className="rounded-lg border border-slate-200 bg-white p-3">
                  <p className="text-[11px] font-semibold uppercase tracking-wider text-slate-500">Spent</p>
                  <p className="mt-1 text-base font-semibold text-slate-900">
                    {clientAccount.totalSpent != null ? `$${Number(clientAccount.totalSpent).toLocaleString()}` : "N/A"}
                  </p>
                </div>
                <div className="rounded-lg border border-slate-200 bg-white p-3">
                  <p className="text-[11px] font-semibold uppercase tracking-wider text-slate-500">Rating</p>
                  <p className="mt-1 text-base font-semibold text-slate-900">
                    {clientAccount.averageRatingGiven != null ? Number(clientAccount.averageRatingGiven).toFixed(2) : "N/A"}
                  </p>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div className="rounded-lg border border-slate-200 bg-slate-50 p-3">
                  <p className="text-[11px] font-semibold uppercase tracking-wider text-slate-500">Member Since</p>
                  <p className="text-sm font-medium text-slate-900">
                    {clientAccount.memberSince
                      ? new Date(clientAccount.memberSince).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })
                      : "N/A"}
                  </p>
                </div>
                <div className="rounded-lg border border-slate-200 bg-slate-50 p-3">
                  <p className="text-[11px] font-semibold uppercase tracking-wider text-slate-500">Last Login</p>
                  <p className="text-sm font-medium text-slate-900">
                    {clientAccount.lastLogin
                      ? new Date(clientAccount.lastLogin).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })
                      : "N/A"}
                  </p>
                </div>
              </div>

              <div className="rounded-lg border border-slate-200 bg-white p-4">
                <p className="text-[11px] font-semibold uppercase tracking-wider text-slate-500">Bio</p>
                <p className="mt-2 text-sm leading-relaxed text-slate-800">
                  {clientAccount.bio?.trim() || "Client has not added a bio yet."}
                </p>
              </div>
            </div>
          ) : (
            <p className="py-4 text-sm text-slate-500">Client profile is unavailable.</p>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
