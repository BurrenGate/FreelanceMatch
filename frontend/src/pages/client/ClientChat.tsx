import { useEffect, useMemo, useRef, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { toast } from "sonner";
import { Paperclip, Send, Mic, Square, Trash2, Play, Pause, Image as ImageIcon, File as FileIcon, Download, Video as VideoIcon } from "lucide-react";
import { api, chatApi, extractApiMessage, freelancerProfileApi, unwrapData } from "@/lib/api";
import { getUser } from "@/lib/auth";
import type { ChatMessageDTO, ChatPartnerDTO, FileUploadResponse, FreelancerProfileDTO, SendMessageRequest } from "@/shared/api/generated";

export default function ClientChat() {
  const user = getUser();
  const [loading, setLoading] = useState(true);
  const [partners, setPartners] = useState<ChatPartnerDTO[]>([]);
  const [selectedPartnerId, setSelectedPartnerId] = useState<number | null>(null);
  const [messages, setMessages] = useState<ChatMessageDTO[]>([]);
  const [messageText, setMessageText] = useState("");
  const [sending, setSending] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [pendingFile, setPendingFile] = useState<FileUploadResponse | null>(null);
  const [search, setSearch] = useState("");
  const [filter, setFilter] = useState<"all" | "active" | "new">("all");
  const [viewingPartnerId, setViewingPartnerId] = useState<number | null>(null);
  const [viewingPartnerProfile, setViewingPartnerProfile] = useState<FreelancerProfileDTO | null>(null);
  const [loadingPartnerProfile, setLoadingPartnerProfile] = useState(false);
  const [isRecording, setIsRecording] = useState(false);
  const [recordingMs, setRecordingMs] = useState(0);
  const [recordedBlob, setRecordedBlob] = useState<Blob | null>(null);
  const [recordedUrl, setRecordedUrl] = useState<string | null>(null);
  const [playingId, setPlayingId] = useState<string | null>(null);
  const [audioTimes, setAudioTimes] = useState<Record<string, { current: number; duration: number }>>({});
  const mediaInputRef = useRef<HTMLInputElement | null>(null);
  const docInputRef = useRef<HTMLInputElement | null>(null);
  const messagesEndRef = useRef<HTMLDivElement | null>(null);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const recordedChunksRef = useRef<Blob[]>([]);
  const recordingTimerRef = useRef<number | null>(null);
  const audioRefs = useRef<Record<string, HTMLAudioElement | null>>({});

  const formatDuration = (ms: number) => {
    const totalSec = Math.max(0, Math.floor(ms / 1000));
    const mm = String(Math.floor(totalSec / 60)).padStart(2, "0");
    const ss = String(totalSec % 60).padStart(2, "0");
    return `${mm}:${ss}`;
  };

  const formatSeconds = (value: number) => {
    const totalSec = Number.isFinite(value) ? Math.max(0, Math.floor(value)) : 0;
    const mm = String(Math.floor(totalSec / 60)).padStart(2, "0");
    const ss = String(totalSec % 60).padStart(2, "0");
    return `${mm}:${ss}`;
  };

  const isAudioMessage = (m: ChatMessageDTO) => {
    const type = (m.fileType ?? "").toLowerCase();
    const url = (m.fileUrl ?? "").toLowerCase();
    return type.startsWith("audio/") || /\.(mp3|wav|ogg|m4a|webm)(\?|$)/i.test(url);
  };

  const isImageMessage = (m: ChatMessageDTO) => {
    const type = (m.fileType ?? "").toLowerCase();
    const url = (m.fileUrl ?? "").toLowerCase();
    return type.startsWith("image/") || /\.(jpg|jpeg|png|gif|webp|bmp|svg)(\?|$)/i.test(url);
  };

  const isVideoMessage = (m: ChatMessageDTO) => {
    const type = (m.fileType ?? "").toLowerCase();
    const url = (m.fileUrl ?? "").toLowerCase();
    return type.startsWith("video/") || /\.(mp4|webm|mov|m4v|avi|mkv)(\?|$)/i.test(url);
  };

  const getAttachmentName = (m: ChatMessageDTO) => {
    if (m.fileObjectName?.trim()) return m.fileObjectName.trim();
    if (!m.fileUrl) return "attachment";
    try {
      const pathname = new URL(m.fileUrl).pathname;
      const name = pathname.split("/").filter(Boolean).pop();
      return name || "attachment";
    } catch {
      return "attachment";
    }
  };

  const selectedPartner = partners.find((p) => Number(p.partnerId) === selectedPartnerId);
  const selectedConversationId = selectedPartner?.hasConversation ? Number(selectedPartner.conversationId ?? 0) : 0;
  const orderedMessages = [...messages].sort((a, b) => {
    const timeA = a.createdAt ? new Date(a.createdAt).getTime() : 0;
    const timeB = b.createdAt ? new Date(b.createdAt).getTime() : 0;
    if (timeA !== timeB) return timeA - timeB;
    return Number(a.messageId ?? 0) - Number(b.messageId ?? 0);
  });
  const filteredPartners = partners.filter((p) => {
    const name = (p.partnerName ?? "").toLowerCase();
    const role = (p.partnerRole ?? "").toLowerCase();
    const q = search.trim().toLowerCase();
    const bySearch = !q || name.includes(q) || role.includes(q);
    const byFilter =
      filter === "all" ||
      (filter === "active" && Boolean(p.hasConversation)) ||
      (filter === "new" && !p.hasConversation);
    return bySearch && byFilter;
  });

  const loadPartners = async () => {
    try {
      setLoading(true);
      const res = await chatApi.getAvailableChatPartners();
      const list = unwrapData<ChatPartnerDTO[]>(res.data) || [];
      const safe = Array.isArray(list) ? list : [];

      const dedupedMap = new Map<number, ChatPartnerDTO>();
      for (const partner of safe) {
        const partnerId = Number(partner.partnerId ?? 0);
        if (partnerId <= 0) continue;

        const existing = dedupedMap.get(partnerId);
        if (!existing) {
          dedupedMap.set(partnerId, partner);
          continue;
        }

        const existingScore = (existing.hasConversation ? 2 : 0) + (Number(existing.conversationId ?? 0) > 0 ? 1 : 0);
        const nextScore = (partner.hasConversation ? 2 : 0) + (Number(partner.conversationId ?? 0) > 0 ? 1 : 0);
        if (nextScore > existingScore) {
          dedupedMap.set(partnerId, partner);
        }
      }

      const deduped = Array.from(dedupedMap.values());
      setPartners(deduped);
      if (!selectedPartnerId && deduped.length > 0) {
        setSelectedPartnerId(Number(deduped[0].partnerId ?? 0));
      } else if (
        selectedPartnerId &&
        !deduped.some((partner) => Number(partner.partnerId) === selectedPartnerId)
      ) {
        setSelectedPartnerId(deduped.length > 0 ? Number(deduped[0].partnerId ?? 0) : null);
      }
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to load chat partners."));
    } finally {
      setLoading(false);
    }
  };

  const loadMessages = async (conversationId: number) => {
    try {
      const res = await chatApi.getConversationMessages(conversationId, 100, 0);
      const list = unwrapData<ChatMessageDTO[]>(res.data) || [];
      setMessages(Array.isArray(list) ? list : []);
      await chatApi.markMessagesAsRead(conversationId);
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to load messages."));
    }
  };

  useEffect(() => {
    void loadPartners();
  }, []);

  useEffect(() => {
    if (selectedConversationId > 0) {
      void loadMessages(selectedConversationId);
    } else {
      setMessages([]);
    }
  }, [selectedConversationId]);

  useEffect(() => {
    const interval = setInterval(() => {
      void loadPartners();
      if (selectedConversationId > 0) {
        void loadMessages(selectedConversationId);
      }
    }, 10000);
    return () => clearInterval(interval);
  }, [selectedConversationId]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth", block: "end" });
  }, [orderedMessages.length, selectedConversationId]);

  useEffect(() => {
    return () => {
      if (recordingTimerRef.current) {
        window.clearInterval(recordingTimerRef.current);
      }
      if (recordedUrl) {
        URL.revokeObjectURL(recordedUrl);
      }
      streamRef.current?.getTracks().forEach((t) => t.stop());
      Object.values(audioRefs.current).forEach((audio) => audio?.pause());
    };
  }, [recordedUrl]);

  const orderedAudioMessages = useMemo(
    () =>
      orderedMessages.filter((m) => m.fileUrl && isAudioMessage(m)).map((m) => ({
        id: String(m.messageId ?? m.fileUrl),
        url: String(m.fileUrl),
      })),
    [orderedMessages],
  );

  const uploadAttachment = async (file: File): Promise<FileUploadResponse | null> => {
    setUploading(true);
    try {
      const formData = new FormData();
      formData.append("file", file);
      const res = await api.post("/api/files/upload/chat", formData, {
        headers: { "Content-Type": "multipart/form-data" },
      });
      const data = unwrapData<FileUploadResponse>(res.data);
      if (!data?.fileUrl) {
        toast.error("Upload finished but file URL is missing.");
        return null;
      }
      setPendingFile(data);
      toast.success("File attached.");
      return data;
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to upload file."));
      return null;
    } finally {
      setUploading(false);
    }
  };

  const uploadGeneralAttachment = async (file: File) => {
    await uploadAttachment(file);
  };

  const sendMessage = async () => {
    if (!selectedPartnerId) return;
    const text = messageText.trim();
    if (!text && !pendingFile) {
      toast.error("Enter a message or attach a file.");
      return;
    }
    setSending(true);
    try {
      const payload: SendMessageRequest = {
        conversationId: selectedConversationId > 0 ? selectedConversationId : undefined,
        recipientId: selectedConversationId > 0 ? undefined : selectedPartnerId ?? undefined,
        messageText: text || undefined,
        fileObjectName: pendingFile?.objectName,
        fileUrl: pendingFile?.fileUrl,
        fileType: pendingFile?.contentType,
        fileSize: pendingFile?.size,
      };
      await chatApi.sendMessage(payload);
      setMessageText("");
      setPendingFile(null);
      if (selectedConversationId > 0) {
        await loadMessages(selectedConversationId);
      }
      await loadPartners();
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to send message."));
    } finally {
      setSending(false);
    }
  };

  const startRecording = async () => {
    if (!selectedPartnerId || sending || uploading || isRecording) return;
    if (!navigator.mediaDevices?.getUserMedia) {
      toast.error("Voice recording is not supported in this browser.");
      return;
    }
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      streamRef.current = stream;
      const recorder = new MediaRecorder(stream);
      mediaRecorderRef.current = recorder;
      recordedChunksRef.current = [];
      setRecordedBlob(null);
      if (recordedUrl) {
        URL.revokeObjectURL(recordedUrl);
        setRecordedUrl(null);
      }
      setRecordingMs(0);
      recorder.ondataavailable = (event) => {
        if (event.data && event.data.size > 0) {
          recordedChunksRef.current.push(event.data);
        }
      };
      recorder.onstop = () => {
        const mimeType = recorder.mimeType || "audio/webm";
        const blob = new Blob(recordedChunksRef.current, { type: mimeType });
        setRecordedBlob(blob);
        setRecordedUrl(URL.createObjectURL(blob));
        streamRef.current?.getTracks().forEach((t) => t.stop());
        streamRef.current = null;
      };
      recorder.start();
      setIsRecording(true);
      recordingTimerRef.current = window.setInterval(() => {
        setRecordingMs((prev) => prev + 1000);
      }, 1000);
    } catch (error) {
      toast.error(extractApiMessage(error, "Microphone permission denied."));
    }
  };

  const stopRecording = () => {
    if (!mediaRecorderRef.current || mediaRecorderRef.current.state !== "recording") return;
    mediaRecorderRef.current.stop();
    mediaRecorderRef.current = null;
    if (recordingTimerRef.current) {
      window.clearInterval(recordingTimerRef.current);
      recordingTimerRef.current = null;
    }
    setIsRecording(false);
  };

  const discardRecordedAudio = () => {
    if (recordedUrl) {
      URL.revokeObjectURL(recordedUrl);
    }
    setRecordedUrl(null);
    setRecordedBlob(null);
    setRecordingMs(0);
  };

  const sendRecordedAudioDirect = async () => {
    if (!recordedBlob || !selectedPartnerId) return;
    const extension = recordedBlob.type.includes("ogg") ? "ogg" : recordedBlob.type.includes("mp4") ? "m4a" : "webm";
    const file = new File([recordedBlob], `voice-${Date.now()}.${extension}`, {
      type: recordedBlob.type || "audio/webm",
    });
    const uploaded = await uploadAttachment(file);
    if (!uploaded) return;

    setSending(true);
    try {
      const payload: SendMessageRequest = {
        conversationId: selectedConversationId > 0 ? selectedConversationId : undefined,
        recipientId: selectedConversationId > 0 ? undefined : selectedPartnerId ?? undefined,
        fileObjectName: uploaded.objectName,
        fileUrl: uploaded.fileUrl,
        fileType: uploaded.contentType,
        fileSize: uploaded.size,
      };
      await chatApi.sendMessage(payload);
      setPendingFile(null);
      if (selectedConversationId > 0) {
        await loadMessages(selectedConversationId);
      }
      await loadPartners();
      toast.success("Voice message sent.");
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to send voice message."));
    } finally {
      setSending(false);
    }
    discardRecordedAudio();
  };

  const handleAudioPlayPause = (id: string) => {
    const target = audioRefs.current[id];
    if (!target) return;

    if (playingId && playingId !== id) {
      const prev = audioRefs.current[playingId];
      prev?.pause();
      if (prev) prev.currentTime = prev.currentTime;
    }

    if (target.paused) {
      void target.play();
      setPlayingId(id);
    } else {
      target.pause();
      setPlayingId(null);
    }
  };

  const handleAudioTimeUpdate = (id: string) => {
    const audio = audioRefs.current[id];
    if (!audio) return;
    setAudioTimes((prev) => ({
      ...prev,
      [id]: {
        current: audio.currentTime || 0,
        duration: audio.duration || 0,
      },
    }));
  };

  const handleAudioSeek = (id: string, value: number) => {
    const audio = audioRefs.current[id];
    if (!audio) return;
    audio.currentTime = value;
    handleAudioTimeUpdate(id);
  };

  const openPartnerProfile = async (partnerId: number) => {
    setViewingPartnerId(partnerId);
    setViewingPartnerProfile(null);
    setLoadingPartnerProfile(true);
    try {
      const res = await freelancerProfileApi.getFreelancerProfile(partnerId);
      const data = unwrapData<FreelancerProfileDTO>(res.data);
      setViewingPartnerProfile(data ?? null);
    } catch (error) {
      toast.error(extractApiMessage(error, "Failed to load user profile."));
    } finally {
      setLoadingPartnerProfile(false);
    }
  };

  return (
    <div className="space-y-4 animate-in fade-in slide-in-from-bottom-2 duration-300">
      <div className="rounded-2xl border border-slate-200 bg-[linear-gradient(120deg,#0f172a_0%,#1e293b_60%,#0f766e_100%)] p-5 text-white">
        <h2 className="text-2xl font-bold tracking-tight">Messages</h2>
        <p className="mt-1 text-sm text-slate-200">Communicate with freelancers in one focused workspace.</p>
      </div>
      <div className="grid h-[calc(100vh-240px)] min-h-[560px] gap-4 lg:grid-cols-[320px_1fr]">
        <Card className="flex min-h-0 flex-col overflow-hidden border-slate-200">
          <CardHeader className="border-b bg-slate-50">
            <CardTitle className="text-base">Inbox</CardTitle>
          </CardHeader>
          <CardContent className="min-h-0 space-y-3 overflow-y-auto p-3">
            <div className="space-y-2">
              <Input
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Search by name or role..."
              />
              <div className="flex gap-2">
                <Button size="sm" variant={filter === "all" ? "default" : "outline"} onClick={() => setFilter("all")}>All</Button>
                <Button size="sm" variant={filter === "active" ? "default" : "outline"} onClick={() => setFilter("active")}>Active</Button>
                <Button size="sm" variant={filter === "new" ? "default" : "outline"} onClick={() => setFilter("new")}>New</Button>
              </div>
            </div>
            {loading ? (
              <p className="text-sm text-slate-500">Loading...</p>
            ) : !filteredPartners.length ? (
              <p className="text-sm text-slate-500">No partners available yet.</p>
            ) : (
              filteredPartners.map((p) => {
                const pid = Number(p.partnerId ?? 0);
                const active = pid === selectedPartnerId;
                return (
                  <button
                    key={pid}
                    onClick={() => {
                      setSelectedPartnerId(pid);
                    }}
                    className={`w-full rounded-xl border p-3 text-left transition-colors ${active ? "border-cyan-700 bg-cyan-50" : "border-slate-200 bg-white hover:bg-slate-50"}`}
                  >
                    <div className="flex items-start justify-between gap-2">
                      <p className="text-sm font-semibold text-slate-900">{p.partnerName || `User #${p.partnerId}`}</p>
                      {p.hasConversation ? <Badge variant="outline">Active</Badge> : <Badge>New</Badge>}
                    </div>
                    <p className="mt-1 line-clamp-2 text-xs text-slate-600">{p.partnerRole || "Partner"}</p>
                  </button>
                );
              })
            )}
          </CardContent>
        </Card>

        <Card className="flex min-h-0 flex-col overflow-hidden border-slate-200">
          <CardHeader className="border-b bg-white">
            <div className="flex items-center justify-between gap-3">
              <CardTitle className="text-base">
                {selectedPartner
                  ? `Chat with ${selectedPartner.partnerName || `User #${selectedPartner.partnerId}`}`
                  : "Select partner"}
              </CardTitle>
              {selectedPartnerId && (
                <Button size="sm" variant="outline" onClick={() => openPartnerProfile(selectedPartnerId)}>
                  View Profile
                </Button>
              )}
            </div>
          </CardHeader>
          <CardContent className="flex min-h-0 flex-1 flex-col gap-3 p-3">
            <div className="min-h-0 flex-1 space-y-3 overflow-y-auto rounded-xl border border-slate-200 bg-[linear-gradient(180deg,#f8fafc_0%,#f1f5f9_100%)] p-3">
              {!selectedPartnerId ? (
                <p className="text-sm text-slate-500">Choose a partner.</p>
              ) : selectedConversationId <= 0 ? (
                <p className="text-sm text-slate-500">Send first message to start the conversation.</p>
              ) : !messages.length ? (
                <p className="text-sm text-slate-500">No messages yet.</p>
              ) : (
                orderedMessages.map((m) => {
                  const senderId = Number(m.senderId ?? 0);
                  const otherUserId = Number(selectedPartner?.partnerId ?? 0);
                  const isMine = otherUserId > 0 ? senderId !== otherUserId : senderId === Number(user?.id ?? -1);
                  return (
                  <div
                    key={Number(m.messageId ?? Math.random())}
                    className={`flex ${isMine ? "justify-end" : "justify-start"}`}
                  >
                    <div className={`max-w-[85%] rounded-2xl px-3 py-2 shadow-sm ${
                      isMine
                        ? "border border-cyan-700 bg-cyan-700 text-white"
                        : "border border-slate-200 bg-white text-slate-800"
                    }`}>
                      <div className="mb-1 flex items-center justify-between gap-2">
                        <p className={`text-[11px] font-semibold ${isMine ? "text-cyan-100" : "text-slate-500"}`}>
                          {m.senderName || `User #${m.senderId}`}
                        </p>
                        <p className={`text-[10px] ${isMine ? "text-cyan-100" : "text-slate-500"}`}>
                          {m.createdAt ? new Date(m.createdAt).toLocaleString() : ""}
                        </p>
                      </div>
                      {m.messageText && <p className="text-sm">{m.messageText}</p>}
                      {m.fileUrl && isAudioMessage(m) && (() => {
                        const audioId = String(m.messageId ?? m.fileUrl);
                        const times = audioTimes[audioId] ?? { current: 0, duration: 0 };
                        const progressMax = times.duration > 0 ? times.duration : 1;
                        const progressValue = Math.min(times.current, progressMax);
                        const isPlaying = playingId === audioId;
                        return (
                          <div className={`mt-2 min-w-[240px] rounded-2xl border px-3 py-2 ${isMine ? "border-cyan-500/60 bg-cyan-600/70" : "border-slate-200 bg-slate-50"}`}>
                            <div className="flex items-center gap-2">
                              <button
                                type="button"
                                onClick={() => handleAudioPlayPause(audioId)}
                                className={`grid h-8 w-8 place-items-center rounded-full transition ${isMine ? "bg-cyan-100 text-cyan-800 hover:bg-white" : "bg-cyan-700 text-white hover:bg-cyan-800"}`}
                              >
                                {isPlaying ? <Pause className="h-3.5 w-3.5" /> : <Play className="h-3.5 w-3.5" />}
                              </button>
                              <div className="flex-1">
                                <p className={`text-[10px] ${isMine ? "text-cyan-100" : "text-slate-500"}`}>Voice message</p>
                                <input
                                  type="range"
                                  min={0}
                                  max={progressMax}
                                  step={0.1}
                                  value={progressValue}
                                  onChange={(e) => handleAudioSeek(audioId, Number(e.target.value))}
                                  className="mt-1 h-1.5 w-full cursor-pointer accent-cyan-700"
                                />
                              </div>
                              <span className={`text-[10px] tabular-nums ${isMine ? "text-cyan-100" : "text-slate-500"}`}>
                                {formatSeconds(times.current)} / {formatSeconds(times.duration)}
                              </span>
                            </div>
                            <audio
                              ref={(el) => {
                                audioRefs.current[audioId] = el;
                              }}
                              src={m.fileUrl}
                              preload="metadata"
                              className="hidden"
                              onTimeUpdate={() => handleAudioTimeUpdate(audioId)}
                              onLoadedMetadata={() => handleAudioTimeUpdate(audioId)}
                              onPlay={() => setPlayingId(audioId)}
                              onPause={() => setPlayingId((prev) => (prev === audioId ? null : prev))}
                              onEnded={() => {
                                setPlayingId((prev) => (prev === audioId ? null : prev));
                                const audio = audioRefs.current[audioId];
                                if (audio) {
                                  audio.currentTime = 0;
                                }
                                setAudioTimes((prev) => ({
                                  ...prev,
                                  [audioId]: {
                                    current: 0,
                                    duration: prev[audioId]?.duration ?? 0,
                                  },
                                }));
                              }}
                            />
                          </div>
                        );
                      })()}
                      {m.fileUrl && !isAudioMessage(m) && (
                        <>
                          {isImageMessage(m) && (
                            <a href={m.fileUrl} target="_blank" rel="noreferrer" className="mt-2 block">
                              <img
                                src={m.fileUrl}
                                alt={getAttachmentName(m)}
                                className="max-h-64 w-full rounded-xl border border-slate-200 object-cover"
                                loading="lazy"
                              />
                            </a>
                          )}
                          {isVideoMessage(m) && (
                            <div className="mt-2 overflow-hidden rounded-xl border border-slate-200 bg-black/80">
                              <div className={`flex items-center gap-1 px-2 py-1 text-[10px] ${isMine ? "text-cyan-100" : "text-slate-300"}`}>
                                <VideoIcon className="h-3 w-3" /> Video
                              </div>
                              <video src={m.fileUrl} controls className="max-h-72 w-full bg-black" preload="metadata" />
                            </div>
                          )}
                          {!isImageMessage(m) && !isVideoMessage(m) && (
                            <a
                              href={m.fileUrl}
                              target="_blank"
                              rel="noreferrer"
                              download
                              className={`mt-2 inline-flex items-center gap-2 rounded-lg border px-3 py-1.5 text-xs font-medium ${
                                isMine
                                  ? "border-cyan-200 bg-cyan-50 text-cyan-800 hover:bg-white"
                                  : "border-slate-300 bg-slate-100 text-slate-800 hover:bg-slate-200"
                              }`}
                            >
                              <Download className="h-3.5 w-3.5" />
                              {getAttachmentName(m) || "Download file"}
                            </a>
                          )}
                        </>
                      )}
                    </div>
                  </div>
                )})
              )}
              <div ref={messagesEndRef} />
            </div>

            {pendingFile && (
              <div className="flex items-center justify-between gap-3 rounded-md border border-cyan-200 bg-cyan-50 p-2 text-xs text-cyan-800">
                <span>Attached: {pendingFile.fileName || pendingFile.objectName}</span>
                <Button size="sm" variant="ghost" className="h-7 text-cyan-700 hover:bg-cyan-100" onClick={() => setPendingFile(null)}>
                  <Trash2 className="mr-1 h-3.5 w-3.5" /> Remove
                </Button>
              </div>
            )}

            {!isRecording && recordedUrl && (
              <div className="space-y-2 rounded-md border border-cyan-200 bg-cyan-50 p-2">
                <p className="text-xs font-medium text-cyan-800">Recorded voice: {formatDuration(recordingMs)}</p>
                <audio controls src={recordedUrl} className="w-full" />
                <div className="flex gap-2">
                  <Button size="sm" variant="outline" onClick={discardRecordedAudio}>
                    <Trash2 className="mr-1 h-4 w-4" /> Discard
                  </Button>
                  <Button size="sm" onClick={() => void sendRecordedAudioDirect()} disabled={uploading || sending}>
                    Send voice
                  </Button>
                </div>
              </div>
            )}

            <div className="rounded-xl border border-slate-200 bg-white p-2">
              <div className="mb-2 flex flex-wrap gap-2">
                {uploading && <span className="self-center text-xs text-slate-500">Uploading...</span>}
                {isRecording && (
                  <span className="self-center text-xs font-medium text-rose-600">
                    Recording {formatDuration(recordingMs)}
                  </span>
                )}
              </div>
              <div className="flex gap-2">
                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button variant="outline" size="icon" disabled={!selectedPartnerId || uploading || sending}>
                      <Paperclip className="h-4 w-4" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="start">
                    <DropdownMenuItem onClick={() => mediaInputRef.current?.click()}>
                      <ImageIcon className="mr-2 h-4 w-4" /> Media
                    </DropdownMenuItem>
                    <DropdownMenuItem onClick={() => docInputRef.current?.click()}>
                      <FileIcon className="mr-2 h-4 w-4" /> Files
                    </DropdownMenuItem>
                  </DropdownMenuContent>
                </DropdownMenu>
                <Input
                value={messageText}
                onChange={(e) => setMessageText(e.target.value)}
                placeholder="Write a message..."
                disabled={!selectedPartnerId || sending}
              />
              <Button onClick={sendMessage} disabled={!selectedPartnerId || sending || uploading}>
                <Send className="h-4 w-4" />
              </Button>
              <Button
                variant={isRecording ? "destructive" : "outline"}
                onClick={isRecording ? stopRecording : () => void startRecording()}
                disabled={!selectedPartnerId || sending || uploading}
              >
                {isRecording ? <Square className="h-4 w-4" /> : <Mic className="h-4 w-4" />}
              </Button>
            </div>
            </div>

            <input ref={mediaInputRef} type="file" accept="image/*,video/*" className="hidden" onChange={(e) => { const f = e.target.files?.[0]; if (f) void uploadGeneralAttachment(f); e.currentTarget.value = ""; }} />
            <input ref={docInputRef} type="file" className="hidden" onChange={(e) => { const f = e.target.files?.[0]; if (f) void uploadAttachment(f); e.currentTarget.value = ""; }} />
          </CardContent>
        </Card>
      </div>

      <Dialog open={viewingPartnerId !== null} onOpenChange={(open) => !open && setViewingPartnerId(null)}>
        <DialogContent className="max-h-[85vh] overflow-y-auto sm:max-w-2xl">
          <DialogHeader>
            <DialogTitle>Freelancer Profile</DialogTitle>
            <DialogDescription>
              {viewingPartnerProfile?.firstName || viewingPartnerProfile?.lastName
                ? `${viewingPartnerProfile.firstName ?? ""} ${viewingPartnerProfile.lastName ?? ""}`.trim()
                : `Profile summary for freelancer #${viewingPartnerId}`}
            </DialogDescription>
          </DialogHeader>
          {loadingPartnerProfile ? (
            <div className="py-8 text-center text-sm text-slate-500">Loading profile...</div>
          ) : (
            <div className="space-y-4 py-2">
              <section className="rounded-xl border border-slate-200 bg-[linear-gradient(130deg,#0f172a_0%,#1e293b_58%,#0f766e_100%)] p-4 text-white">
                <div className="flex items-start justify-between gap-4">
                  <div className="flex items-center gap-3">
                    <Avatar className="h-12 w-12 border border-white/30">
                      <AvatarFallback className="bg-white/20 text-sm font-semibold text-white">
                        {`${viewingPartnerProfile?.firstName?.charAt(0) ?? ""}${viewingPartnerProfile?.lastName?.charAt(0) ?? ""}`.trim() || "FR"}
                      </AvatarFallback>
                    </Avatar>
                    <div>
                      <p className="text-base font-semibold">
                        {viewingPartnerProfile?.firstName || viewingPartnerProfile?.lastName
                          ? `${viewingPartnerProfile.firstName ?? ""} ${viewingPartnerProfile.lastName ?? ""}`.trim()
                          : `Freelancer #${viewingPartnerId}`}
                      </p>
                      <p className="text-xs text-cyan-100">
                        {viewingPartnerProfile?.email || "Email is hidden"}
                      </p>
                    </div>
                  </div>
                  <Badge className={`${viewingPartnerProfile?.isAvailable ? "bg-emerald-500/20 text-emerald-50 border-emerald-300/40" : "bg-amber-500/20 text-amber-50 border-amber-300/40"}`}>
                    {viewingPartnerProfile?.isAvailable == null ? "Availability unknown" : viewingPartnerProfile?.isAvailable ? "Available now" : "Currently busy"}
                  </Badge>
                </div>
                <div className="mt-4 rounded-lg bg-white/10 p-3">
                  <p className="text-[11px] uppercase tracking-[0.14em] text-cyan-100">Hourly Rate</p>
                  <p className="text-2xl font-bold">
                    {viewingPartnerProfile?.hourlyRate != null
                      ? `$${Number(viewingPartnerProfile.hourlyRate).toLocaleString()}/hr`
                      : "N/A"}
                  </p>
                </div>
              </section>

              <section className="grid gap-3 sm:grid-cols-2">
                <div className="rounded-lg border border-slate-200 bg-slate-50 p-3">
                  <p className="text-xs uppercase tracking-wider text-slate-500">Rating</p>
                  <p className="text-lg font-semibold text-slate-900">
                    {viewingPartnerProfile?.rating != null ? `${Number(viewingPartnerProfile.rating).toFixed(2)} / 5` : "N/A"}
                  </p>
                </div>
                <div className="rounded-lg border border-slate-200 bg-slate-50 p-3">
                  <p className="text-xs uppercase tracking-wider text-slate-500">Total Earnings</p>
                  <p className="text-lg font-semibold text-slate-900">
                    {viewingPartnerProfile?.totalEarnings != null
                      ? `$${Number(viewingPartnerProfile.totalEarnings).toLocaleString()}`
                      : "N/A"}
                  </p>
                </div>
                <div className="rounded-lg border border-slate-200 bg-slate-50 p-3">
                  <p className="text-xs uppercase tracking-wider text-slate-500">Completed Jobs</p>
                  <p className="text-lg font-semibold text-slate-900">
                    {viewingPartnerProfile?.completedJobs != null ? Number(viewingPartnerProfile.completedJobs) : "N/A"}
                  </p>
                </div>
                <div className="rounded-lg border border-slate-200 bg-slate-50 p-3">
                  <p className="text-xs uppercase tracking-wider text-slate-500">Total Reviews</p>
                  <p className="text-lg font-semibold text-slate-900">
                    {viewingPartnerProfile?.totalReviews != null ? Number(viewingPartnerProfile.totalReviews) : "N/A"}
                  </p>
                </div>
              </section>

              <section className="rounded-lg border border-slate-200 bg-white p-4">
                <p className="text-xs font-semibold uppercase tracking-wider text-slate-500">About</p>
                <p className="mt-2 text-sm leading-relaxed text-slate-700">
                  {viewingPartnerProfile?.bio?.trim() || "Freelancer has not added a bio yet."}
                </p>
              </section>

              <section className="rounded-lg border border-slate-200 bg-white p-4">
                <p className="text-xs font-semibold uppercase tracking-wider text-slate-500">Skills</p>
                {!viewingPartnerProfile?.skills?.length ? (
                  <p className="mt-2 text-sm text-slate-500">No skills listed.</p>
                ) : (
                  <div className="mt-3 flex flex-wrap gap-2">
                    {viewingPartnerProfile.skills.map((skill, idx) => (
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
                {!viewingPartnerProfile?.recentReviews?.length ? (
                  <p className="mt-2 text-sm text-slate-500">No recent reviews.</p>
                ) : (
                  <div className="mt-3 space-y-3">
                    {viewingPartnerProfile.recentReviews.slice(0, 3).map((review, idx) => (
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
                  Member since: <span className="font-medium text-slate-700">{viewingPartnerProfile?.memberSince ? new Date(viewingPartnerProfile.memberSince).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" }) : "N/A"}</span>
                </div>
                <div className="rounded-md border border-slate-200 bg-slate-50 p-2.5">
                  Last login: <span className="font-medium text-slate-700">{viewingPartnerProfile?.lastLogin ? new Date(viewingPartnerProfile.lastLogin).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" }) : "N/A"}</span>
                </div>
              </div>
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setViewingPartnerId(null)}>Close</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
