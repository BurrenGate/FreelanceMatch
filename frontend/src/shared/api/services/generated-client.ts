import { API_BASE_URL } from "@/lib/constants";
import { api } from "@/lib/api";
import {
  AuthControllerApi,
  Configuration,
  ContractControllerApi,
  JobControllerApi,
  ProfileControllerApi,
  ProposalControllerApi,
} from "@/shared/api/generated";

const generatedConfig = new Configuration({
  basePath: API_BASE_URL,
});

export const authGeneratedApi = new AuthControllerApi(generatedConfig, API_BASE_URL, api);
export const jobGeneratedApi = new JobControllerApi(generatedConfig, API_BASE_URL, api);
export const proposalGeneratedApi = new ProposalControllerApi(generatedConfig, API_BASE_URL, api);
export const contractGeneratedApi = new ContractControllerApi(generatedConfig, API_BASE_URL, api);
export const profileGeneratedApi = new ProfileControllerApi(generatedConfig, API_BASE_URL, api);
