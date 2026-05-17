# ProfileControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**addSkillsToCurrentUser**](#addskillstocurrentuser) | **POST** /api/profiles/me/skills | |
|[**getCurrentUserProfile**](#getcurrentuserprofile) | **GET** /api/profiles/me | |
|[**getFreelancerDashboard**](#getfreelancerdashboard) | **GET** /api/profiles/me/dashboard | |
|[**getFreelancerRating**](#getfreelancerrating) | **GET** /api/profiles/{profileId}/rating | |
|[**getFreelancerTotalEarnings**](#getfreelancertotalearnings) | **GET** /api/profiles/{profileId}/earnings | |
|[**isFreelancerAvailable**](#isfreelanceravailable) | **GET** /api/profiles/{profileId}/availability | |
|[**updateCurrentUserProfile**](#updatecurrentuserprofile) | **PUT** /api/profiles/me | |

# **addSkillsToCurrentUser**
> ApiResponseVoid addSkillsToCurrentUser(userSkillDTO)


### Example

```typescript
import {
    ProfileControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfileControllerApi(configuration);

let userSkillDTO: Array<UserSkillDTO>; //

const { status, data } = await apiInstance.addSkillsToCurrentUser(
    userSkillDTO
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **userSkillDTO** | **Array<UserSkillDTO>**|  | |


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

# **getCurrentUserProfile**
> ApiResponseProfileDTO getCurrentUserProfile()


### Example

```typescript
import {
    ProfileControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfileControllerApi(configuration);

const { status, data } = await apiInstance.getCurrentUserProfile();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseProfileDTO**

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

# **getFreelancerDashboard**
> ApiResponseFreelancerDashboardDTO getFreelancerDashboard()


### Example

```typescript
import {
    ProfileControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfileControllerApi(configuration);

const { status, data } = await apiInstance.getFreelancerDashboard();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseFreelancerDashboardDTO**

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

# **getFreelancerRating**
> ApiResponseMapStringObject getFreelancerRating()


### Example

```typescript
import {
    ProfileControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfileControllerApi(configuration);

let profileId: number; // (default to undefined)

const { status, data } = await apiInstance.getFreelancerRating(
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

# **getFreelancerTotalEarnings**
> ApiResponseMapStringObject getFreelancerTotalEarnings()


### Example

```typescript
import {
    ProfileControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfileControllerApi(configuration);

let profileId: number; // (default to undefined)

const { status, data } = await apiInstance.getFreelancerTotalEarnings(
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

# **isFreelancerAvailable**
> ApiResponseMapStringObject isFreelancerAvailable()


### Example

```typescript
import {
    ProfileControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfileControllerApi(configuration);

let profileId: number; // (default to undefined)

const { status, data } = await apiInstance.isFreelancerAvailable(
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

# **updateCurrentUserProfile**
> ApiResponseVoid updateCurrentUserProfile(updateProfileDTO)


### Example

```typescript
import {
    ProfileControllerApi,
    Configuration,
    UpdateProfileDTO
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfileControllerApi(configuration);

let updateProfileDTO: UpdateProfileDTO; //

const { status, data } = await apiInstance.updateCurrentUserProfile(
    updateProfileDTO
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **updateProfileDTO** | **UpdateProfileDTO**|  | |


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

