import axios from "axios";
import { API_BASE_URL } from "@/lib/constants";
import { clearAuth, getToken } from "@/lib/auth";
import {
  AccountControllerApi,
  AuthControllerApi,
  ChatControllerApi,
  ClientProfileControllerApi,
  Configuration,
  ContractControllerApi,
  FreelancerProfileControllerApi,
  JobControllerApi,
  JobRequiredSkillControllerApi,
  ProfileControllerApi,
  ProfileSkillControllerApi,
  ProposalControllerApi,
  SkillSuggestionControllerApi,
  SkillControllerApi,
  TransactionControllerApi,
} from "@/shared/api/generated";
import type { SuggestSkillRequest } from "@/shared/api/generated";
  
export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
}

function isApiResponse<T>(value: unknown): value is ApiResponse<T> {
  return Boolean(value && typeof value === "object" && "success" in (value as Record<string, unknown>) && "data" in (value as Record<string, unknown>));
}

export function unwrapData<T>(payload: ApiResponse<T> | T): T {
  return isApiResponse<T>(payload) ? payload.data : payload;
}

export function extractApiMessage(error: unknown, fallback = "Request failed"): string {
  if (axios.isAxiosError(error)) {
    const message = (error.response?.data as { message?: unknown } | undefined)?.message;
    if (typeof message === "string" && message.trim()) {
      return message;
    }
  }

  if (error instanceof Error && error.message.trim()) {
    return error.message;
  }

  return fallback;
}

export const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

api.interceptors.request.use((config) => {
  const token = getToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (axios.isAxiosError(error) && error.response?.status === 401) {
      clearAuth();
      if (typeof window !== "undefined") {
        const currentPath = window.location.pathname;
        if (currentPath !== "/login" && currentPath !== "/register") {
          window.location.href = "/login";
        }
      }
    }

    return Promise.reject(error);
  },
);

const generatedConfig = new Configuration({
  basePath: API_BASE_URL,
});

export const authApi = new AuthControllerApi(generatedConfig, API_BASE_URL, api);
export const accountApi = new AccountControllerApi(generatedConfig, API_BASE_URL, api);
export const chatApi = new ChatControllerApi(generatedConfig, API_BASE_URL, api);
export const clientProfileApi = new ClientProfileControllerApi(generatedConfig, API_BASE_URL, api);
export const jobApi = new JobControllerApi(generatedConfig, API_BASE_URL, api);
export const proposalApi = new ProposalControllerApi(generatedConfig, API_BASE_URL, api);
export const contractApi = new ContractControllerApi(generatedConfig, API_BASE_URL, api);
export const jobRequiredSkillApi = new JobRequiredSkillControllerApi(generatedConfig, API_BASE_URL, api);
export const profileApi = new ProfileControllerApi(generatedConfig, API_BASE_URL, api);
export const profileSkillApi = new ProfileSkillControllerApi(generatedConfig, API_BASE_URL, api);
export const freelancerProfileApi = new FreelancerProfileControllerApi(generatedConfig, API_BASE_URL, api);
export const skillApi = new SkillControllerApi(generatedConfig, API_BASE_URL, api);
export const skillSuggestionApi = new SkillSuggestionControllerApi(generatedConfig, API_BASE_URL, api);
export const transactionApi = new TransactionControllerApi(generatedConfig, API_BASE_URL, api);

export async function suggestSkill(payload: SuggestSkillRequest) {
  const res = await skillSuggestionApi.suggestSkill(payload);
  return unwrapData<Record<string, unknown> | null>(res.data);
}
