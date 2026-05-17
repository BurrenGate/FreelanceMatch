# ProposalControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**acceptProposal**](#acceptproposal) | **POST** /api/proposals/{proposalId}/accept | |
|[**deleteProposal**](#deleteproposal) | **DELETE** /api/proposals/{id} | |
|[**getAllProposals**](#getallproposals) | **GET** /api/proposals | |
|[**getAllProposalsDetailed**](#getallproposalsdetailed) | **GET** /api/proposals/detailed | |
|[**getProposalById**](#getproposalbyid) | **GET** /api/proposals/{id} | |
|[**getProposalsByJobId**](#getproposalsbyjobid) | **GET** /api/proposals/job/{jobId} | |
|[**getProposalsWithFreelancerDetails**](#getproposalswithfreelancerdetails) | **GET** /api/proposals/job/{jobId}/with-freelancer | |
|[**rejectProposal**](#rejectproposal) | **POST** /api/proposals/{proposalId}/reject | |
|[**submitProposal**](#submitproposal) | **POST** /api/proposals/submit | |
|[**updateProposal**](#updateproposal) | **PUT** /api/proposals/{id} | |

# **acceptProposal**
> ApiResponseVoid acceptProposal()


### Example

```typescript
import {
    ProposalControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProposalControllerApi(configuration);

let proposalId: number; // (default to undefined)

const { status, data } = await apiInstance.acceptProposal(
    proposalId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **proposalId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseVoid**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteProposal**
> ApiResponseVoid deleteProposal()


### Example

```typescript
import {
    ProposalControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProposalControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.deleteProposal(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseVoid**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAllProposals**
> ApiResponseListProposal getAllProposals()


### Example

```typescript
import {
    ProposalControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProposalControllerApi(configuration);

const { status, data } = await apiInstance.getAllProposals();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseListProposal**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAllProposalsDetailed**
> ApiResponseListProposalDetailDTO getAllProposalsDetailed()


### Example

```typescript
import {
    ProposalControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProposalControllerApi(configuration);

const { status, data } = await apiInstance.getAllProposalsDetailed();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseListProposalDetailDTO**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getProposalById**
> ApiResponseProposal getProposalById()


### Example

```typescript
import {
    ProposalControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProposalControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.getProposalById(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseProposal**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getProposalsByJobId**
> ApiResponseListProposal getProposalsByJobId()


### Example

```typescript
import {
    ProposalControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProposalControllerApi(configuration);

let jobId: number; // (default to undefined)

const { status, data } = await apiInstance.getProposalsByJobId(
    jobId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **jobId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseListProposal**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getProposalsWithFreelancerDetails**
> ApiResponseListProposalWithFreelancerDTO getProposalsWithFreelancerDetails()


### Example

```typescript
import {
    ProposalControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProposalControllerApi(configuration);

let jobId: number; // (default to undefined)

const { status, data } = await apiInstance.getProposalsWithFreelancerDetails(
    jobId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **jobId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseListProposalWithFreelancerDTO**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rejectProposal**
> ApiResponseVoid rejectProposal()


### Example

```typescript
import {
    ProposalControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProposalControllerApi(configuration);

let proposalId: number; // (default to undefined)

const { status, data } = await apiInstance.rejectProposal(
    proposalId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **proposalId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseVoid**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **submitProposal**
> ApiResponseVoid submitProposal(submitProposalRequest)


### Example

```typescript
import {
    ProposalControllerApi,
    Configuration,
    SubmitProposalRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new ProposalControllerApi(configuration);

let submitProposalRequest: SubmitProposalRequest; //

const { status, data } = await apiInstance.submitProposal(
    submitProposalRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **submitProposalRequest** | **SubmitProposalRequest**|  | |


### Return type

**ApiResponseVoid**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateProposal**
> ApiResponseProposal updateProposal(proposalUpdateRequest)


### Example

```typescript
import {
    ProposalControllerApi,
    Configuration,
    ProposalUpdateRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new ProposalControllerApi(configuration);

let id: number; // (default to undefined)
let proposalUpdateRequest: ProposalUpdateRequest; //

const { status, data } = await apiInstance.updateProposal(
    id,
    proposalUpdateRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **proposalUpdateRequest** | **ProposalUpdateRequest**|  | |
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseProposal**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

