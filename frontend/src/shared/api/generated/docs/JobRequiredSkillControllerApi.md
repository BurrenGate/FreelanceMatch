# JobRequiredSkillControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**addRequiredSkill**](#addrequiredskill) | **POST** /api/jobs/{jobId}/required-skills | |
|[**getRequiredSkills**](#getrequiredskills) | **GET** /api/jobs/{jobId}/required-skills | |
|[**removeRequiredSkill**](#removerequiredskill) | **DELETE** /api/jobs/{jobId}/required-skills/{skillId} | |

# **addRequiredSkill**
> ApiResponseVoid addRequiredSkill(jobRequiredSkillRequest)


### Example

```typescript
import {
    JobRequiredSkillControllerApi,
    Configuration,
    JobRequiredSkillRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new JobRequiredSkillControllerApi(configuration);

let jobId: number; // (default to undefined)
let jobRequiredSkillRequest: JobRequiredSkillRequest; //

const { status, data } = await apiInstance.addRequiredSkill(
    jobId,
    jobRequiredSkillRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **jobRequiredSkillRequest** | **JobRequiredSkillRequest**|  | |
| **jobId** | [**number**] |  | defaults to undefined|


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

# **getRequiredSkills**
> ApiResponseListJobRequiredSkillResponse getRequiredSkills()


### Example

```typescript
import {
    JobRequiredSkillControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new JobRequiredSkillControllerApi(configuration);

let jobId: number; // (default to undefined)

const { status, data } = await apiInstance.getRequiredSkills(
    jobId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **jobId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseListJobRequiredSkillResponse**

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

# **removeRequiredSkill**
> ApiResponseVoid removeRequiredSkill()


### Example

```typescript
import {
    JobRequiredSkillControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new JobRequiredSkillControllerApi(configuration);

let jobId: number; // (default to undefined)
let skillId: number; // (default to undefined)

const { status, data } = await apiInstance.removeRequiredSkill(
    jobId,
    skillId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **jobId** | [**number**] |  | defaults to undefined|
| **skillId** | [**number**] |  | defaults to undefined|


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

