# JobControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**createJob**](#createjob) | **POST** /api/jobs | |
|[**deleteJob**](#deletejob) | **DELETE** /api/jobs/{id} | |
|[**getActiveJobsCount**](#getactivejobscount) | **GET** /api/jobs/{profileId}/active-count | |
|[**getAllJobs**](#getalljobs) | **GET** /api/jobs | |
|[**getJobById**](#getjobbyid) | **GET** /api/jobs/{id} | |
|[**getJobSkills**](#getjobskills) | **GET** /api/jobs/{jobId}/skills | |
|[**getMatchingFreelancers**](#getmatchingfreelancers) | **GET** /api/jobs/{id}/match | |
|[**getMyJobs**](#getmyjobs) | **GET** /api/jobs/my | |
|[**getRecommendedJobs**](#getrecommendedjobs) | **GET** /api/jobs/recommended | |
|[**getSkillMatchCount**](#getskillmatchcount) | **GET** /api/jobs/{jobId}/skill-match/{profileId} | |
|[**updateJob**](#updatejob) | **PUT** /api/jobs/{id} | |

# **createJob**
> ApiResponseVoid createJob(jobDTO)


### Example

```typescript
import {
    JobControllerApi,
    Configuration,
    JobDTO
} from './api';

const configuration = new Configuration();
const apiInstance = new JobControllerApi(configuration);

let jobDTO: JobDTO; //

const { status, data } = await apiInstance.createJob(
    jobDTO
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **jobDTO** | **JobDTO**|  | |


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

# **deleteJob**
> ApiResponseVoid deleteJob()


### Example

```typescript
import {
    JobControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new JobControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.deleteJob(
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

# **getActiveJobsCount**
> ApiResponseMapStringObject getActiveJobsCount()


### Example

```typescript
import {
    JobControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new JobControllerApi(configuration);

let profileId: number; // (default to undefined)

const { status, data } = await apiInstance.getActiveJobsCount(
    profileId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **profileId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseMapStringObject**

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

# **getAllJobs**
> ApiResponseListJob getAllJobs()


### Example

```typescript
import {
    JobControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new JobControllerApi(configuration);

const { status, data } = await apiInstance.getAllJobs();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseListJob**

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

# **getJobById**
> ApiResponseJob getJobById()


### Example

```typescript
import {
    JobControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new JobControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.getJobById(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseJob**

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

# **getJobSkills**
> ApiResponseListJobSkillDTO getJobSkills()


### Example

```typescript
import {
    JobControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new JobControllerApi(configuration);

let jobId: number; // (default to undefined)

const { status, data } = await apiInstance.getJobSkills(
    jobId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **jobId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseListJobSkillDTO**

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

# **getMatchingFreelancers**
> ApiResponseListFreelancerMatch getMatchingFreelancers()


### Example

```typescript
import {
    JobControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new JobControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.getMatchingFreelancers(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseListFreelancerMatch**

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

# **getMyJobs**
> ApiResponseListJob getMyJobs()


### Example

```typescript
import {
    JobControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new JobControllerApi(configuration);

const { status, data } = await apiInstance.getMyJobs();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseListJob**

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

# **getRecommendedJobs**
> ApiResponseListRecommendedJobDTO getRecommendedJobs()


### Example

```typescript
import {
    JobControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new JobControllerApi(configuration);

const { status, data } = await apiInstance.getRecommendedJobs();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseListRecommendedJobDTO**

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

# **getSkillMatchCount**
> ApiResponseMapStringObject getSkillMatchCount()


### Example

```typescript
import {
    JobControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new JobControllerApi(configuration);

let jobId: number; // (default to undefined)
let profileId: number; // (default to undefined)

const { status, data } = await apiInstance.getSkillMatchCount(
    jobId,
    profileId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **jobId** | [**number**] |  | defaults to undefined|
| **profileId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseMapStringObject**

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

# **updateJob**
> ApiResponseVoid updateJob(jobDTO)


### Example

```typescript
import {
    JobControllerApi,
    Configuration,
    JobDTO
} from './api';

const configuration = new Configuration();
const apiInstance = new JobControllerApi(configuration);

let id: number; // (default to undefined)
let jobDTO: JobDTO; //

const { status, data } = await apiInstance.updateJob(
    id,
    jobDTO
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **jobDTO** | **JobDTO**|  | |
| **id** | [**number**] |  | defaults to undefined|


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

