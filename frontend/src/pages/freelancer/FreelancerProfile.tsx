import { useEffect, useMemo, useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Progress } from "@/components/ui/progress";
import { Separator } from "@/components/ui/separator";
import { toast } from "sonner";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Calendar,
  DollarSign,
  Link as LinkIcon,
  Loader2,
  Mail,
  PencilLine,
  ShieldCheck,
  Plus,
  Sparkles,
  Star,
  User,
  Wallet,
  X,
  DatabaseZap,
} from "lucide-react";
import { getToken, getUser, setAuth } from "@/lib/auth";
import { api, extractApiMessage, unwrapData } from "@/lib/api";

// Интерфейс навыка внутри профиля пользователя
interface ApiSkill {
  skillId: number;
  skillName: string;
  category: string;
  skillLevel: string;
}

// Интерфейс глобального навыка из словаря (/api/skills)
interface GlobalSkill {
  id: number;
  name: string;
  category: string;
}

interface FreelancerProfileData {
  accountId: number;
  email: string;
  role: string;
  accountStatus: string;
  lastLogin: string | null;
  accountCreatedAt: string;
  profileId: number;
  firstName: string;
  lastName: string;
  bio: string;
  hourlyRate: number;
  avatarUrl: string;
  profileUpdatedAt: string;
  rating: number;
  balance: number;
  skills: ApiSkill[];
}

interface ProfileFormState {
  firstName: string;
  lastName: string;
  bio: string;
  hourlyRate: number;
  avatarUrl: string;
  skills: { skillId: number; skillLevel: number }[];
}

const emptyProfile: FreelancerProfileData = {
  accountId: 0,
  email: "",
  role: "freelancer",
  accountStatus: "active",
  lastLogin: null,
  accountCreatedAt: "",
  profileId: 0,
  firstName: "",
  lastName: "",
  bio: "",
  hourlyRate: 0,
  avatarUrl: "",
  profileUpdatedAt: "",
  rating: 0,
  balance: 0,
  skills: [],
};

function normalizeProfileResponse(payload: unknown): FreelancerProfileData {
  const source =
    payload && typeof payload === "object" && "data" in payload
      ? (payload as { data?: unknown }).data
      : payload;

  const data = (source ?? {}) as Partial<FreelancerProfileData>;

  return {
    accountId: Number(data.accountId ?? 0),
    email: data.email ?? "",
    role: data.role ?? "freelancer",
    accountStatus: data.accountStatus ?? "active",
    lastLogin: data.lastLogin ?? null,
    accountCreatedAt: data.accountCreatedAt ?? "",
    profileId: Number(data.profileId ?? 0),
    firstName: data.firstName ?? "",
    lastName: data.lastName ?? "",
    bio: data.bio ?? "",
    hourlyRate: Number(data.hourlyRate ?? 0),
    avatarUrl: data.avatarUrl ?? "",
    profileUpdatedAt: data.profileUpdatedAt ?? "",
    rating: Number(data.rating ?? 0),
    balance: Number(data.balance ?? 0),
    skills: Array.isArray(data.skills)
  ? data.skills.map((skill: any) => ({
      skillId: Number(skill.skillId ?? skill.id ?? 0), 
      skillName: skill.skillName ?? skill.name ?? "Skill",
      category: skill.category ?? "General",
      skillLevel: String(skill.skillLevel ?? skill.level ?? "1"),
    }))
  : [],
  };
}

function buildFormState(profile: FreelancerProfileData): ProfileFormState {
  return {
    firstName: profile.firstName,
    lastName: profile.lastName,
    bio: profile.bio,
    hourlyRate: profile.hourlyRate,
    avatarUrl: profile.avatarUrl,
    skills: profile.skills.map((s) => ({
      skillId: s.skillId,
      skillLevel: parseInt(s.skillLevel) || 1,
    })),
  };
}

export default function FreelancerProfile() {
  const currentUser = getUser();

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  
  const [profile, setProfile] = useState<FreelancerProfileData>(emptyProfile);
  const [form, setForm] = useState<ProfileFormState>(buildFormState(emptyProfile));
  const [availableSkills, setAvailableSkills] = useState<GlobalSkill[]>([]);

  // Состояния для создания нового навыка
  const [isAddingNewSkill, setIsAddingNewSkill] = useState(false);
  const [newSkillName, setNewSkillName] = useState("");
  const [newSkillCategory, setNewSkillCategory] = useState("");
  const [creatingSkill, setCreatingSkill] = useState(false);

  useEffect(() => {
    const fetchAvailableSkills = async () => {
      try {
        const res = await api.get("/api/skills");
        const data = unwrapData<GlobalSkill[]>(res.data);
        if (Array.isArray(data)) setAvailableSkills(data);
      } catch (error) {
        console.error("Failed to fetch skills library:", error);
      }
    };

    fetchAvailableSkills();
  }, []);

  useEffect(() => {
    const fetchProfile = async () => {
      try {
        setLoading(true);
        const res = await api.get("/api/profiles/me");
        const data = res.data;
        const normalized = normalizeProfileResponse(data);
        setProfile(normalized);
        setForm(buildFormState(normalized));
      } catch (error) {
        console.error("Failed to fetch profile:", error);
        toast.error(extractApiMessage(error, "Network error while loading profile."));
      } finally {
        setLoading(false);
      }
    };

    fetchProfile();
  }, []);

  const completionPercentage = useMemo(() => {
    const checks = [
      Boolean(profile.firstName.trim()),
      Boolean(profile.lastName.trim()),
      Boolean(profile.bio.trim()),
      profile.hourlyRate > 0,
      Boolean(profile.avatarUrl.trim()),
      profile.skills.length > 0,
    ];

    const completed = checks.filter(Boolean).length;
    return Math.round((completed / checks.length) * 100);
  }, [profile]);

  const initials =
    `${profile.firstName.charAt(0)}${profile.lastName.charAt(0)}`.trim().toUpperCase() || "FR";

  const memberSince = profile.accountCreatedAt
    ? new Date(profile.accountCreatedAt).toLocaleDateString("en-US", {
        month: "short",
        year: "numeric",
      })
    : "Recently";

  const lastUpdated = profile.profileUpdatedAt
    ? new Date(profile.profileUpdatedAt).toLocaleDateString("en-US", {
        month: "short",
        day: "numeric",
        year: "numeric",
      })
    : "Not available";

  const lastLogin = profile.lastLogin
    ? new Date(profile.lastLogin).toLocaleDateString("en-US", {
        month: "short",
        day: "numeric",
        year: "numeric",
      })
    : "No recent activity";

  const topCategories = Array.from(new Set(profile.skills.map((skill) => skill.category))).slice(0, 3);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;

    setForm((prev) => ({
      ...prev,
      [name]: name === "hourlyRate" ? Math.max(0, Number(value) || 0) : value,
    }));
  };

  const handleCancel = () => {
    setForm(buildFormState(profile));
    setIsEditing(false);
    setIsAddingNewSkill(false);
  };

  // Метод для создания глобального навыка (POST /api/skills)
  const handleCreateGlobalSkill = async () => {
    if (!newSkillName.trim() || !newSkillCategory.trim()) {
      toast.error("Name and Category are required to create a new skill.");
      return;
    }

    setCreatingSkill(true);
    try {
      const res = await api.post("/api/skills", {
          id: 0, // Бекенд назначит новый ID
          name: newSkillName.trim(),
          category: newSkillCategory.trim(),
      });
      const createdSkill = unwrapData<GlobalSkill>(res.data); // Получаем созданный навык { id, name, category }
      
      // Добавляем в глобальный список
      setAvailableSkills((prev) => [...prev, createdSkill]);
      
      // Автоматически добавляем в форму текущего пользователя
      setForm((prev) => ({
        ...prev,
        skills: [...prev.skills, { skillId: createdSkill.id, skillLevel: 1 }]
      }));

      toast.success(`Skill "${createdSkill.name}" created and added!`);
      setNewSkillName("");
      setNewSkillCategory("");
      setIsAddingNewSkill(false);
    } catch (error) {
      console.error("Failed to create skill:", error);
      toast.error(extractApiMessage(error, "Error creating skill."));
    } finally {
      setCreatingSkill(false);
    }
  };

  const handleSaveProfile = async () => {
    if (!form.firstName.trim() || !form.lastName.trim()) {
      toast.error("First name and last name are required.");
      return;
    }

    setSaving(true);

    try {
      await api.put("/api/profiles/me", {
          firstName: form.firstName.trim(),
          lastName: form.lastName.trim(),
          bio: form.bio.trim(),
          hourlyRate: form.hourlyRate,
          avatarUrl: form.avatarUrl.trim(),
      });

      // Сохраняем навыки через отдельный эндпоинт POST /api/profiles/me/skills
      try {
        await api.post("/api/profiles/me/skills", form.skills);
      } catch {
        toast.error("Profile info saved, but failed to update skills.");
      }

      // Обновляем данные профиля целиком, чтобы UI синхронизировался с сервером
      const refreshRes = await api.get("/api/profiles/me");
      const refreshedData = refreshRes.data;
      const mergedProfile = normalizeProfileResponse(refreshedData);

      setProfile(mergedProfile);
      setForm(buildFormState(mergedProfile));
      setIsEditing(false);

      const token = getToken();
      if (token && currentUser) {
        setAuth(token, {
          ...currentUser,
          firstName: mergedProfile.firstName,
          lastName: mergedProfile.lastName,
          hourlyRate: mergedProfile.hourlyRate,
        });
      }

      toast.success("Profile updated successfully.");
    } catch (error) {
      console.error("Failed to save profile:", error);
      toast.error(extractApiMessage(error, "Network error. Please try again."));
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex min-h-[520px] flex-col items-center justify-center gap-4">
        <div className="flex h-14 w-14 items-center justify-center rounded-full bg-primary/10">
          <Loader2 className="h-7 w-7 animate-spin text-primary" />
        </div>
        <div className="space-y-1 text-center">
          <p className="font-medium text-foreground">Loading your profile</p>
          <p className="text-sm text-muted-foreground">We are preparing your freelancer workspace.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-7xl space-y-8 pb-12">
      <section className="relative overflow-hidden rounded-3xl border border-border/60 bg-gradient-to-br from-emerald-50 via-background to-amber-50 shadow-sm">
        <div className="absolute inset-y-0 right-0 hidden w-1/3 bg-[radial-gradient(circle_at_top,rgba(16,185,129,0.18),transparent_60%)] lg:block" />
        <div className="relative grid gap-8 px-6 py-8 md:px-8 lg:grid-cols-[1.3fr_0.7fr] lg:px-10">
          <div className="space-y-6">
            <div className="flex flex-wrap items-center gap-3">
              <Badge className="rounded-full border-0 bg-emerald-100 px-3 py-1 text-emerald-800 hover:bg-emerald-100">
                <ShieldCheck className="mr-1 h-3.5 w-3.5" />
                {profile.accountStatus}
              </Badge>
              <Badge variant="outline" className="rounded-full bg-background/70 px-3 py-1">
                {profile.role}
              </Badge>
            </div>

            <div className="flex flex-col gap-5 md:flex-row md:items-center">
              <Avatar className="h-24 w-24 border-4 border-background shadow-lg">
                <AvatarImage src={profile.avatarUrl} alt={`${profile.firstName} ${profile.lastName}`} />
                <AvatarFallback className="bg-primary/10 text-2xl font-bold text-primary">
                  {initials}
                </AvatarFallback>
              </Avatar>

              <div className="space-y-3">
                <div>
                  <h1 className="text-3xl font-bold tracking-tight text-foreground md:text-4xl">
                    {profile.firstName || "Your"} {profile.lastName || "Profile"}
                  </h1>
                  <p className="mt-2 max-w-2xl text-sm leading-6 text-muted-foreground md:text-base">
                    Present your expertise with a clean, credible profile. Clients see your hourly
                    rate, background, and core skills here first.
                  </p>
                </div>

                <div className="flex flex-wrap gap-3 text-sm text-muted-foreground">
                  <div className="flex items-center gap-2 rounded-full bg-background/80 px-3 py-1.5">
                    <Mail className="h-4 w-4 text-primary" />
                    <span>{profile.email}</span>
                  </div>
                  <div className="flex items-center gap-2 rounded-full bg-background/80 px-3 py-1.5">
                    <Calendar className="h-4 w-4 text-primary" />
                    <span>Member since {memberSince}</span>
                  </div>
                </div>
              </div>
            </div>

            <div className="grid gap-3 sm:grid-cols-3">
              <Card className="border-white/60 bg-white/70 shadow-none backdrop-blur">
                <CardContent className="flex items-center gap-3 p-4">
                  <div className="rounded-xl bg-amber-100 p-2.5 text-amber-700">
                    <Star className="h-5 w-5" />
                  </div>
                  <div>
                    <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">Rating</p>
                    <p className="text-xl font-semibold text-foreground">{profile.rating.toFixed(1)}</p>
                  </div>
                </CardContent>
              </Card>

              <Card className="border-white/60 bg-white/70 shadow-none backdrop-blur">
                <CardContent className="flex items-center gap-3 p-4">
                  <div className="rounded-xl bg-emerald-100 p-2.5 text-emerald-700">
                    <DollarSign className="h-5 w-5" />
                  </div>
                  <div>
                    <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">Rate</p>
                    <p className="text-xl font-semibold text-foreground">${profile.hourlyRate}/hr</p>
                  </div>
                </CardContent>
              </Card>

              <Card className="border-white/60 bg-white/70 shadow-none backdrop-blur">
                <CardContent className="flex items-center gap-3 p-4">
                  <div className="rounded-xl bg-sky-100 p-2.5 text-sky-700">
                    <Wallet className="h-5 w-5" />
                  </div>
                  <div>
                    <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">Balance</p>
                    <p className="text-xl font-semibold text-foreground">${profile.balance}</p>
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>

          <Card className="border-border/60 bg-background/90 shadow-sm">
            <CardHeader className="pb-4">
              <CardTitle className="flex items-center gap-2 text-lg">
                <Sparkles className="h-5 w-5 text-primary" />
                Profile strength
              </CardTitle>
              <CardDescription>
                A complete profile improves trust and helps clients evaluate you faster.
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-5">
              <div className="space-y-2">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-muted-foreground">Completion</span>
                  <span className="font-semibold text-foreground">{completionPercentage}%</span>
                </div>
                <Progress value={completionPercentage} className="h-2.5" />
              </div>

              <div className="space-y-3 rounded-2xl bg-muted/40 p-4">
                <div className="flex items-start gap-3">
                  <Mail className="mt-0.5 h-4 w-4 text-primary" />
                  <div>
                    <p className="text-sm font-medium text-foreground">Account email</p>
                    <p className="text-sm text-muted-foreground">{profile.email || "Not provided"}</p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <Calendar className="mt-0.5 h-4 w-4 text-primary" />
                  <div>
                    <p className="text-sm font-medium text-foreground">Last profile update</p>
                    <p className="text-sm text-muted-foreground">{lastUpdated}</p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <User className="mt-0.5 h-4 w-4 text-primary" />
                  <div>
                    <p className="text-sm font-medium text-foreground">Recent sign-in</p>
                    <p className="text-sm text-muted-foreground">{lastLogin}</p>
                  </div>
                </div>
              </div>

              <div className="flex flex-wrap gap-2">
                {topCategories.length > 0 ? (
                  topCategories.map((category) => (
                    <Badge key={category} variant="secondary" className="rounded-full px-3 py-1">
                      {category}
                    </Badge>
                  ))
                ) : (
                  <p className="text-sm text-muted-foreground">Add more profile details to show your specialization.</p>
                )}
              </div>
            </CardContent>
          </Card>
        </div>
      </section>

      <div className="grid gap-8 lg:grid-cols-[0.9fr_1.1fr]">
        <div className="space-y-6">
          <Card className="border-border/60 shadow-sm">
            <CardHeader>
              <CardTitle>Public summary</CardTitle>
              <CardDescription>This block reflects the data clients will immediately notice.</CardDescription>
            </CardHeader>
            <CardContent className="space-y-5">
              <div className="rounded-2xl border border-border/60 bg-muted/20 p-4">
                <p className="text-sm leading-7 text-foreground">
                  {profile.bio?.trim() || "Add a short bio to explain your expertise, process, and ideal projects."}
                </p>
              </div>

              <Separator />

              <div className="grid gap-4 sm:grid-cols-2">
                <div className="rounded-2xl bg-muted/30 p-4">
                  <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">Hourly rate</p>
                  <p className="mt-2 text-2xl font-semibold text-foreground">${profile.hourlyRate}</p>
                </div>
                <div className="rounded-2xl bg-muted/30 p-4">
                  <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">Skills</p>
                  <p className="mt-2 text-2xl font-semibold text-foreground">{profile.skills.length}</p>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="border-border/60 shadow-sm">
            <CardHeader>
              <CardTitle>Your Verified Skills</CardTitle>
              <CardDescription>These skills are registered to your profile.</CardDescription>
            </CardHeader>
            <CardContent className="space-y-3">
              {profile.skills.length > 0 ? (
                profile.skills.map((skill) => (
                  <div
                    key={skill.skillId}
                    className="flex items-center justify-between rounded-2xl border border-border/60 px-4 py-3"
                  >
                    <div>
                      <p className="font-medium text-foreground">{skill.skillName}</p>
                      <p className="text-sm text-muted-foreground">{skill.category}</p>
                    </div>
                    <Badge variant="outline" className="rounded-full px-3 py-1">
                      Level {skill.skillLevel}
                    </Badge>
                  </div>
                ))
              ) : (
                <div className="rounded-2xl border border-dashed border-border p-5 text-sm text-muted-foreground">
                  No skills returned by the API yet.
                </div>
              )}
            </CardContent>
          </Card>
        </div>

        <Card className="border-border/60 shadow-sm">
          <CardHeader className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <CardTitle>Edit profile</CardTitle>
              <CardDescription>
                Update the fields supported by `PUT /api/profiles/me`.
              </CardDescription>
            </div>
            <div className="flex gap-2">
              {isEditing ? (
                <>
                  <Button variant="outline" onClick={handleCancel} disabled={saving}>
                    <X className="mr-2 h-4 w-4" />
                    Cancel
                  </Button>
                  <Button onClick={handleSaveProfile} disabled={saving}>
                    {saving ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
                    {saving ? "Saving..." : "Save changes"}
                  </Button>
                </>
              ) : (
                <Button onClick={() => setIsEditing(true)}>
                  <PencilLine className="mr-2 h-4 w-4" />
                  Edit profile
                </Button>
              )}
            </div>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="grid gap-5 md:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="firstName">
                  First name <span className="text-red-500">*</span>
                </Label>
                <Input
                  id="firstName"
                  name="firstName"
                  value={form.firstName}
                  onChange={handleChange}
                  disabled={!isEditing || saving}
                  placeholder="Ruslan"
                  className="h-11"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="lastName">
                  Last name <span className="text-red-500">*</span>
                </Label>
                <Input
                  id="lastName"
                  name="lastName"
                  value={form.lastName}
                  onChange={handleChange}
                  disabled={!isEditing || saving}
                  placeholder="Kol"
                  className="h-11"
                />
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="avatarUrl">Avatar URL</Label>
              <div className="relative">
                <LinkIcon className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  id="avatarUrl"
                  name="avatarUrl"
                  value={form.avatarUrl}
                  onChange={handleChange}
                  disabled={!isEditing || saving}
                  placeholder="https://some-url"
                  className="h-11 pl-9"
                />
              </div>
              <p className="text-xs text-muted-foreground">Use a public image URL for a professional headshot.</p>
            </div>

            <div className="space-y-2">
              <Label htmlFor="bio">Professional bio</Label>
              <Textarea
                id="bio"
                name="bio"
                rows={7}
                value={form.bio}
                onChange={handleChange}
                disabled={!isEditing || saving}
                placeholder="Freelancer"
                className="resize-y leading-6"
              />
              <p className="text-xs text-muted-foreground">
                Focus on specialization, experience, and the value you bring to projects.
              </p>
            </div>

            <div className="grid gap-5 md:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="hourlyRate">Hourly rate (USD)</Label>
                <div className="relative">
                  <span className="absolute left-3 top-1/2 -translate-y-1/2 text-sm font-medium text-muted-foreground">
                    $
                  </span>
                  <Input
                    id="hourlyRate"
                    name="hourlyRate"
                    type="number"
                    min="0"
                    step="1"
                    value={form.hourlyRate}
                    onChange={handleChange}
                    disabled={!isEditing || saving}
                    className="h-11 pl-8"
                  />
                </div>
              </div>

              <div className="rounded-2xl bg-muted/30 p-4">
                <p className="text-xs uppercase tracking-[0.18em] text-muted-foreground">Preview</p>
                <p className="mt-2 text-sm text-muted-foreground">Your profile will show:</p>
                <p className="mt-3 text-2xl font-semibold text-foreground">${form.hourlyRate}/hr</p>
              </div>
            </div>

            <Separator />

            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <Label className="text-base font-semibold">Skills & Expertise</Label>
                <Badge variant="outline" className="font-normal rounded-full">
                  {form.skills.length} skills selected
                </Badge>
              </div>

              <div className="flex flex-wrap gap-2 min-h-[48px] p-3 rounded-2xl border border-dashed border-border/60 bg-muted/20">
                {form.skills.length > 0 ? (
                  form.skills.map((s, idx) => {
                    // Используем as.id так как GlobalSkill содержит id, а не skillId
                    const skillInfo = availableSkills.find(as => as.id === s.skillId);
                    return (
                      <Badge key={idx} variant="secondary" className="pl-3 pr-1 py-1 gap-2 h-8 bg-background border shadow-sm rounded-full">
                        <span className="font-medium">{skillInfo?.name || `Skill #${s.skillId}`}</span>
                        <button
                          type="button"
                          onClick={() => setForm(f => ({ ...f, skills: f.skills.filter((_, i) => i !== idx) }))}
                          disabled={!isEditing || saving}
                          className="hover:bg-muted rounded-full p-0.5 transition-colors"
                        >
                          <X className="w-3.5 h-3.5" />
                        </button>
                      </Badge>
                    );
                  })
                ) : (
                  <p className="text-sm text-muted-foreground w-full text-center py-1">No skills selected. Add some below.</p>
                )}
              </div>

              {isEditing && (
                <div className="space-y-4 pt-2">
                  <div className="flex items-center gap-3">
                    <div className="flex-1">
                      <Select
                        disabled={saving || isAddingNewSkill}
                        onValueChange={(val) => {
                          const skillId = parseInt(val);
                          if (!form.skills.some(fs => fs.skillId === skillId)) {
                            setForm(f => ({ ...f, skills: [...f.skills, { skillId, skillLevel: 1 }] }));
                          }
                        }}
                      >
                        <SelectTrigger className="h-11">
                          <SelectValue placeholder="Add an existing skill..." />
                        </SelectTrigger>
                        <SelectContent>
                          {availableSkills
                            .filter(as => !form.skills.some(fs => fs.skillId === as.id))
                            .map(as => (
                              <SelectItem key={as.id} value={String(as.id)}>
                                {as.name} <span className="text-muted-foreground ml-1 text-xs">({as.category})</span>
                              </SelectItem>
                            ))
                          }
                        </SelectContent>
                      </Select>
                    </div>
                    <Button 
                      type="button" 
                      variant="secondary" 
                      className="h-11"
                      onClick={() => setIsAddingNewSkill(!isAddingNewSkill)}
                      disabled={saving}
                    >
                      {isAddingNewSkill ? <X className="h-4 w-4" /> : <Plus className="h-4 w-4 mr-2" />}
                      {isAddingNewSkill ? "Cancel" : "New"}
                    </Button>
                  </div>

                  {/* UI для создания нового навыка в БД */}
                  {isAddingNewSkill && (
                    <Card className="border-emerald-100 bg-emerald-50/50 shadow-sm">
                      <CardContent className="p-4 space-y-3">
                        <div className="flex items-center gap-2 text-sm font-medium text-emerald-800">
                          <DatabaseZap className="h-4 w-4" />
                          Add new skill to the global library
                        </div>
                        <div className="flex flex-col sm:flex-row gap-3">
                          <Input 
                            placeholder="Skill Name (e.g. React Native)" 
                            value={newSkillName}
                            onChange={(e) => setNewSkillName(e.target.value)}
                            className="bg-background h-10"
                            disabled={creatingSkill}
                          />
                          <Input 
                            placeholder="Category (e.g. Mobile Dev)" 
                            value={newSkillCategory}
                            onChange={(e) => setNewSkillCategory(e.target.value)}
                            className="bg-background h-10"
                            disabled={creatingSkill}
                          />
                          <Button 
                            type="button" 
                            onClick={handleCreateGlobalSkill}
                            disabled={creatingSkill || !newSkillName.trim()}
                            className="h-10 whitespace-nowrap"
                          >
                            {creatingSkill ? <Loader2 className="h-4 w-4 animate-spin" /> : "Create & Select"}
                          </Button>
                        </div>
                      </CardContent>
                    </Card>
                  )}
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
