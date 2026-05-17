# ProfileSkillControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**deleteMySkill**](#deletemyskill) | **DELETE** /api/profile-skills/me/{skillId} | |
|[**getMyAvailableSkills**](#getmyavailableskills) | **GET** /api/profile-skills/me/available | |
|[**getMySkills**](#getmyskills) | **GET** /api/profile-skills/me | |
|[**upsertMySkill**](#upsertmyskill) | **PUT** /api/profile-skills/me | |

# **deleteMySkill**
> ApiResponseVoid deleteMySkill()


### Example

```typescript
import {
    ProfileSkillControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfileSkillControllerApi(configuration);

let skillId: number; // (default to undefined)

const { status, data } = await apiInstance.deleteMySkill(
    skillId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
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

# **getMyAvailableSkills**
> ApiResponseListProfileSkillResponse getMyAvailableSkills()


### Example

```typescript
import {
    ProfileSkillControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfileSkillControllerApi(configuration);

const { status, data } = await apiInstance.getMyAvailableSkills();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseListProfileSkillResponse**

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

# **getMySkills**
> ApiResponseListProfileSkillResponse getMySkills()


### Example

```typescript
import {
    ProfileSkillControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfileSkillControllerApi(configuration);

const { status, data } = await apiInstance.getMySkills();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseListProfileSkillResponse**

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

# **upsertMySkill**
> ApiResponseVoid upsertMySkill(upsertProfileSkillRequest)


### Example

```typescript
import {
    ProfileSkillControllerApi,
    Configuration,
    UpsertProfileSkillRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfileSkillControllerApi(configuration);

let upsertProfileSkillRequest: UpsertProfileSkillRequest; //

const { status, data } = await apiInstance.upsertMySkill(
    upsertProfileSkillRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **upsertProfileSkillRequest** | **UpsertProfileSkillRequest**|  | |


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

