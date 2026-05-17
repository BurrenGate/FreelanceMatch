import { useState, useEffect } from "react";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { toast } from "sonner";
import { 
  User, Mail, Clock, Calendar, Shield, 
  Loader2, CheckCircle2, AlertCircle
} from "lucide-react";
import { clearAuth, getToken, getUser, setAuth } from "@/lib/auth";
import { accountApi, api, extractApiMessage, profileApi, unwrapData } from "@/lib/api";
import type { AccountResponse, ChangePasswordRequest, FileUploadResponse, ProfileDTO, UpdateProfileDTO } from "@/shared/api/generated";

// --- Интерфейсы на основе ваших таблиц ---
interface AccountData {
  id: number;
  email: string;
  status: string;
  lastLogin: string | null;
  createdAt: string | null;
  role: string;
}

interface ProfileData {
  id: number;
  accountId: number;
  firstName: string;
  lastName: string;
  bio: string;
  avatarUrl: string;
  // hourlyRate скрыт/не используется активно для клиента, но присутствует в модели
  hourlyRate?: number; 
  updatedAt: string | null;
}

export default function ClientProfile() {
  const user = getUser();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [uploadingPhoto, setUploadingPhoto] = useState(false);
  const [changePasswordOpen, setChangePasswordOpen] = useState(false);
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmNewPassword, setConfirmNewPassword] = useState("");
  const [changingPassword, setChangingPassword] = useState(false);
  const [deactivateOpen, setDeactivateOpen] = useState(false);
  const [deactivating, setDeactivating] = useState(false);

  // Состояния форм
  const [account, setAccount] = useState<AccountData | null>(null);
  const [profile, setProfile] = useState<ProfileData>({
    id: 0, accountId: 0, firstName: "", lastName: "", bio: "", avatarUrl: "", updatedAt: null
  });

  const hydrateLatestAccount = async (base: AccountData): Promise<AccountData> => {
    if (base.id <= 0) return base;
    try {
      const accountRes = await accountApi.getAccountById(base.id);
      const latest = unwrapData<AccountResponse>(accountRes.data);
      return {
        ...base,
        status: latest?.status ?? base.status,
        lastLogin: latest?.lastLogin ?? base.lastLogin,
        createdAt: latest?.createdAt ?? base.createdAt,
      };
    } catch {
      return base;
    }
  };

  useEffect(() => {
    const mapProfile = (data: ProfileDTO): { account: AccountData; profile: ProfileData } => ({
      account: {
        id: Number(data.accountId ?? 0),
        email: data.email ?? user?.email ?? "",
        status: data.accountStatus ?? "active",
        lastLogin: data.lastLogin ?? null,
        createdAt: data.accountCreatedAt ?? null,
        role: data.role ?? "client",
      },
      profile: {
        id: Number(data.profileId ?? 0),
        accountId: Number(data.accountId ?? 0),
        firstName: data.firstName ?? "",
        lastName: data.lastName ?? "",
        bio: data.bio ?? "",
        avatarUrl: data.avatarUrl ?? "",
        hourlyRate: data.hourlyRate ?? undefined,
        updatedAt: data.profileUpdatedAt ?? null,
      },
    });

    const fetchUserData = async () => {
      try {
        setLoading(true);
        const res = await profileApi.getCurrentUserProfile();
        const data = unwrapData<ProfileDTO>(res.data);
        const mapped = mapProfile(data);
        setAccount(await hydrateLatestAccount(mapped.account));
        setProfile(mapped.profile);
      } catch (error) {
        toast.error(extractApiMessage(error, "Failed to load profile data."));
      } finally {
        setLoading(false);
      }
    };

    fetchUserData();
  }, []);

  const handleSaveProfile = async () => {
    if (!profile.firstName.trim() || !profile.lastName.trim()) {
      toast.error("First name and last name are required.");
      return;
    }

    setSaving(true);
    try {
      const payload: UpdateProfileDTO = {
        firstName: profile.firstName.trim(),
        lastName: profile.lastName.trim(),
        bio: profile.bio.trim(),
        avatarUrl: profile.avatarUrl.trim(),
      };
      await profileApi.updateCurrentUserProfile(payload);

      const refreshedRes = await profileApi.getCurrentUserProfile();
      const refreshed = unwrapData<ProfileDTO>(refreshedRes.data);

      const baseAccount: AccountData = {
        id: Number(refreshed.accountId ?? 0),
        email: refreshed.email ?? account?.email ?? "",
        status: refreshed.accountStatus ?? "active",
        lastLogin: refreshed.lastLogin ?? null,
        createdAt: refreshed.accountCreatedAt ?? null,
        role: refreshed.role ?? "client",
      };
      setAccount(await hydrateLatestAccount(baseAccount));
      setProfile({
        id: Number(refreshed.profileId ?? 0),
        accountId: Number(refreshed.accountId ?? 0),
        firstName: refreshed.firstName ?? "",
        lastName: refreshed.lastName ?? "",
        bio: refreshed.bio ?? "",
        avatarUrl: refreshed.avatarUrl ?? "",
        hourlyRate: refreshed.hourlyRate ?? undefined,
        updatedAt: refreshed.profileUpdatedAt ?? null,
      });

      const token = getToken();
      if (token && user) {
        setAuth(token, {
          ...user,
          firstName: refreshed.firstName ?? user.firstName,
          lastName: refreshed.lastName ?? user.lastName,
        });
      }

      toast.success("Profile updated successfully!");
    } catch (error) {
      toast.error(extractApiMessage(error, "Error saving profile."));
    } finally {
      setSaving(false);
    }
  };

  const handleUploadClientPhoto = async (file: File) => {
    if (!file) return;
    setUploadingPhoto(true);
    try {
      const formData = new FormData();
      formData.append("file", file);
      const res = await api.post("/api/files/upload/client-photo", formData, {
        headers: { "Content-Type": "multipart/form-data" },
      });
      const uploadData = unwrapData<FileUploadResponse>(res.data);
      const nextAvatarUrl = uploadData?.fileUrl?.trim();
      if (!nextAvatarUrl) {
        toast.error("Upload succeeded but avatar URL was not returned.");
        return;
      }
      const payload: UpdateProfileDTO = {
        firstName: profile.firstName.trim(),
        lastName: profile.lastName.trim(),
        bio: profile.bio.trim(),
        avatarUrl: nextAvatarUrl,
      };
      await profileApi.updateCurrentUserProfile(payload);

      const refreshedRes = await profileApi.getCurrentUserProfile();
      const refreshed = unwrapData<ProfileDTO>(refreshedRes.data);
      setProfile((prev) => ({
        ...prev,
        firstName: refreshed.firstName ?? prev.firstName,
        lastName: refreshed.lastName ?? prev.lastName,
        bio: refreshed.bio ?? prev.bio,
        avatarUrl: refreshed.avatarUrl ?? nextAvatarUrl,
        updatedAt: refreshed.profileUpdatedAt ?? prev.updatedAt,
      }));
      toast.success("Profile picture uploaded and saved.");
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to upload profile picture."));
    } finally {
      setUploadingPhoto(false);
    }
  };

  const handleChangePassword = async () => {
    if (!currentPassword.trim() || !newPassword.trim() || !confirmNewPassword.trim()) {
      toast.error("Fill in all password fields.");
      return;
    }
    if (newPassword !== confirmNewPassword) {
      toast.error("New password and confirmation do not match.");
      return;
    }
    if (newPassword.length < 8) {
      toast.error("New password must be at least 8 characters.");
      return;
    }

    setChangingPassword(true);
    try {
      const payload: ChangePasswordRequest = {
        currentPassword,
        newPassword,
        confirmPassword: confirmNewPassword,
      };
      await accountApi.changePassword(payload);

      toast.success("Password changed successfully.");
      setChangePasswordOpen(false);
      setCurrentPassword("");
      setNewPassword("");
      setConfirmNewPassword("");
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to change password."));
    } finally {
      setChangingPassword(false);
    }
  };

  const handleDeactivateAccount = async () => {
    setDeactivating(true);
    try {
      await accountApi.deactivateAccount();
      clearAuth();
      toast.success("Account deactivated.");
      if (typeof window !== "undefined") {
        window.location.href = "/login";
      }
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to deactivate account."));
    } finally {
      setDeactivating(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-[60vh]">
        <div className="flex flex-col items-center gap-2 text-muted-foreground">
          <Loader2 className="w-8 h-8 animate-spin text-primary" />
          <p>Loading profile...</p>
        </div>
      </div>
    );
  }

  const formatDate = (dateString?: string) => {
    if (!dateString) return "N/A";
    return new Date(dateString).toLocaleDateString("en-US", {
      year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit'
    });
  };

  return (
    <div className="max-w-5xl mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-2">
      
      {/* Page Header */}
      <div>
        <h1 className="text-3xl font-bold tracking-tight text-foreground">Account Settings</h1>
        <p className="text-muted-foreground mt-1">Manage your public profile and account security.</p>
      </div>

      <Tabs defaultValue="profile" className="space-y-6">
        <TabsList className="grid w-full max-w-md grid-cols-2 h-12 items-center bg-muted/50 p-1 rounded-xl">
          <TabsTrigger value="profile" className="gap-2 text-base rounded-lg data-[state=active]:shadow-sm">
            <User className="w-4 h-4" /> Public Profile
          </TabsTrigger>
          <TabsTrigger value="account" className="gap-2 text-base rounded-lg data-[state=active]:shadow-sm">
            <Shield className="w-4 h-4" /> Account Details
          </TabsTrigger>
        </TabsList>

        {/* --- Tab 1: Public Profile (таблица profiles) --- */}
        <TabsContent value="profile" className="space-y-6">
          <Card className="border-t-4 border-t-primary shadow-sm">
            <CardHeader>
              <CardTitle>Company & Personal Info</CardTitle>
              <CardDescription>
                This information will be displayed publicly to freelancers when you post jobs.
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-8">
              
              {/* Avatar Section */}
              <div className="flex flex-col sm:flex-row items-center sm:items-start gap-6">
                <div className="relative group">
                    <Avatar className="w-24 h-24 border-4 border-background shadow-md">
                      <AvatarImage src={profile.avatarUrl} />
                      <AvatarFallback className="text-2xl font-bold bg-primary/10 text-primary">
                        {profile.firstName?.charAt(0)}{profile.lastName?.charAt(0)}
                      </AvatarFallback>
                    </Avatar>
                </div>
                <div className="space-y-1 text-center sm:text-left">
                  <h3 className="font-medium">Profile Picture</h3>
                  <p className="text-sm text-muted-foreground max-w-xs">
                    Upload a photo or paste an image URL.
                  </p>
                  <div className="pt-2">
                    <Input
                      type="file"
                      accept="image/*"
                      disabled={uploadingPhoto}
                      onChange={(e) => {
                        const file = e.target.files?.[0];
                        if (file) {
                          void handleUploadClientPhoto(file);
                        }
                        e.currentTarget.value = "";
                      }}
                      className="h-11 max-w-sm"
                    />
                    <p className="mt-1 text-xs text-muted-foreground">
                      {uploadingPhoto ? "Uploading..." : "Supported: common image formats (JPG, PNG, WebP)."}
                    </p>
                  </div>
                </div>
              </div>

              <div className="border-t"></div>

              {/* Form Fields */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <Label htmlFor="firstName">First Name</Label>
                  <Input 
                    id="firstName" 
                    value={profile.firstName} 
                    onChange={(e) => setProfile({...profile, firstName: e.target.value})}
                    className="h-11"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="lastName">Last Name</Label>
                  <Input 
                    id="lastName" 
                    value={profile.lastName} 
                    onChange={(e) => setProfile({...profile, lastName: e.target.value})}
                    className="h-11"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="bio">Bio / Company Description</Label>
                <Textarea 
                  id="bio" 
                  rows={5}
                  placeholder="Tell freelancers about your company, your mission, and the kind of work you do..."
                  value={profile.bio} 
                  onChange={(e) => setProfile({...profile, bio: e.target.value})}
                  className="resize-none"
                />
                <p className="text-xs text-muted-foreground text-right">Brief description for your profile.</p>
              </div>

              <div className="space-y-2">
                <Label htmlFor="avatarUrl">Avatar URL</Label>
                <Input
                  id="avatarUrl"
                  placeholder="https://example.com/avatar.png"
                  value={profile.avatarUrl}
                  onChange={(e) => setProfile({ ...profile, avatarUrl: e.target.value })}
                  className="h-11"
                />
              </div>

            </CardContent>
            <CardFooter className="bg-muted/10 border-t p-6 flex justify-between items-center">
              <p className="text-sm text-muted-foreground flex items-center gap-1">
                <Clock className="w-4 h-4" /> Last updated: {profile.updatedAt ? new Date(profile.updatedAt).toLocaleDateString() : "N/A"}
              </p>
              <Button onClick={handleSaveProfile} disabled={saving} className="min-w-[140px] gap-2">
                {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <CheckCircle2 className="w-4 h-4" />}
                {saving ? "Saving..." : "Save Profile"}
              </Button>
            </CardFooter>
          </Card>
        </TabsContent>

        {/* --- Tab 2: Account Details (таблица accounts) --- */}
        <TabsContent value="account" className="space-y-6">
          <Card className="shadow-sm">
            <CardHeader>
              <CardTitle>Account Security</CardTitle>
              <CardDescription>
                Manage your credentials and view account status.
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              
              <div className="flex flex-col md:flex-row gap-8">
                {/* Email Section */}
                <div className="flex-1 space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="email">Email Address</Label>
                    <div className="relative">
                      <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                      <Input 
                        id="email" 
                        type="email" 
                        value={account?.email} 
                        readOnly
                        className="pl-9 h-11 bg-muted/30 text-muted-foreground cursor-not-allowed"
                      />
                    </div>
                    <p className="text-xs text-muted-foreground flex items-center gap-1 mt-1">
                      <AlertCircle className="w-3 h-3" /> Contact support to change your email.
                    </p>
                  </div>

                  <div className="space-y-2 pt-2">
                    <Label>Password</Label>
                    <Button variant="outline" className="w-full justify-start h-11 text-muted-foreground">
                      ••••••••••••••••
                    </Button>
                    <div className="text-right mt-1">
                      <Button variant="link" className="h-auto p-0 text-sm" onClick={() => setChangePasswordOpen(true)}>
                        Change Password
                      </Button>
                    </div>
                  </div>
                </div>

                {/* Status & Stats Section (Read-only) */}
                <div className="flex-1 bg-muted/20 border rounded-xl p-6 space-y-6">
                  <h3 className="font-semibold text-sm uppercase tracking-wider text-muted-foreground border-b pb-2">
                    Account Status
                  </h3>
                  
                  <div className="space-y-4">
                    <div className="flex justify-between items-center">
                      <span className="text-sm font-medium">Status</span>
                      <Badge variant={account?.status === 'active' ? 'default' : 'destructive'} className="bg-green-100 text-green-800 hover:bg-green-100">
                        {account?.status?.toUpperCase()}
                      </Badge>
                    </div>
                    
                    <div className="flex justify-between items-center">
                      <span className="text-sm font-medium flex items-center gap-2">
                        <Calendar className="w-4 h-4 text-muted-foreground" /> Member Since
                      </span>
                      <span className="text-sm text-muted-foreground">{formatDate(account?.createdAt || undefined)}</span>
                    </div>

                    <div className="flex justify-between items-center">
                      <span className="text-sm font-medium flex items-center gap-2">
                        <Clock className="w-4 h-4 text-muted-foreground" /> Last Login
                      </span>
                      <span className="text-sm text-muted-foreground">{formatDate(account?.lastLogin || undefined)}</span>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-sm font-medium">Role</span>
                      <span className="text-sm text-muted-foreground uppercase">{account?.role || "client"}</span>
                    </div>
                  </div>
                </div>
              </div>

            </CardContent>
          </Card>

          {/* Danger Zone */}
          <Card className="border-red-200 bg-red-50/50 shadow-sm">
            <CardHeader>
              <CardTitle className="text-red-600">Danger Zone</CardTitle>
              <CardDescription>Irreversible actions regarding your account.</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <div>
                  <h4 className="font-medium text-foreground">Deactivate Account</h4>
                  <p className="text-sm text-muted-foreground mt-1">
                    This will hide your profile and active job postings. You can reactivate it later.
                  </p>
                </div>
                <Button variant="destructive" className="shrink-0" onClick={() => setDeactivateOpen(true)}>
                  Deactivate Account
                </Button>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      <Dialog open={changePasswordOpen} onOpenChange={setChangePasswordOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Change Password</DialogTitle>
            <DialogDescription>
              Update your account password. Use a strong password with at least 8 characters.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-3 py-2">
            <div className="space-y-2">
              <Label htmlFor="currentPassword">Current Password</Label>
              <Input
                id="currentPassword"
                type="password"
                value={currentPassword}
                onChange={(e) => setCurrentPassword(e.target.value)}
                autoComplete="current-password"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="newPassword">New Password</Label>
              <Input
                id="newPassword"
                type="password"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                autoComplete="new-password"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="confirmNewPassword">Confirm New Password</Label>
              <Input
                id="confirmNewPassword"
                type="password"
                value={confirmNewPassword}
                onChange={(e) => setConfirmNewPassword(e.target.value)}
                autoComplete="new-password"
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setChangePasswordOpen(false)}>Cancel</Button>
            <Button onClick={handleChangePassword} disabled={changingPassword}>
              {changingPassword ? "Changing..." : "Update Password"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={deactivateOpen} onOpenChange={setDeactivateOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Deactivate Account</DialogTitle>
            <DialogDescription>
              This action will deactivate your account and sign you out immediately.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDeactivateOpen(false)}>Cancel</Button>
            <Button variant="destructive" onClick={handleDeactivateAccount} disabled={deactivating}>
              {deactivating ? "Deactivating..." : "Deactivate"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
