# AdminJobStatusControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**createManagedJobStatus**](#createmanagedjobstatus) | **POST** /api/job-statuses/manage | |
|[**deleteManagedJobStatus**](#deletemanagedjobstatus) | **DELETE** /api/job-statuses/manage/{statusId} | |
|[**getManagedJobStatuses**](#getmanagedjobstatuses) | **GET** /api/job-statuses/manage | |
|[**updateManagedJobStatus**](#updatemanagedjobstatus) | **PUT** /api/job-statuses/manage/{statusId} | |

# **createManagedJobStatus**
> ApiResponseJobStatusManageResponse createManagedJobStatus(jobStatusUpsertRequest)


### Example

```typescript
import {
    AdminJobStatusControllerApi,
    Configuration,
    JobStatusUpsertRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminJobStatusControllerApi(configuration);

let jobStatusUpsertRequest: JobStatusUpsertRequest; //

const { status, data } = await apiInstance.createManagedJobStatus(
    jobStatusUpsertRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **jobStatusUpsertRequest** | **JobStatusUpsertRequest**|  | |


### Return type

**ApiResponseJobStatusManageResponse**

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

# **deleteManagedJobStatus**
> ApiResponseVoid deleteManagedJobStatus()


### Example

```typescript
import {
    AdminJobStatusControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminJobStatusControllerApi(configuration);

let statusId: number; // (default to undefined)

const { status, data } = await apiInstance.deleteManagedJobStatus(
    statusId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **statusId** | [**number**] |  | defaults to undefined|


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

# **getManagedJobStatuses**
> ApiResponseListJobStatusManageResponse getManagedJobStatuses()


### Example

```typescript
import {
    AdminJobStatusControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminJobStatusControllerApi(configuration);

const { status, data } = await apiInstance.getManagedJobStatuses();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseListJobStatusManageResponse**

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

# **updateManagedJobStatus**
> ApiResponseJobStatusManageResponse updateManagedJobStatus(jobStatusUpsertRequest)


### Example

```typescript
import {
    AdminJobStatusControllerApi,
    Configuration,
    JobStatusUpsertRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminJobStatusControllerApi(configuration);

let statusId: number; // (default to undefined)
let jobStatusUpsertRequest: JobStatusUpsertRequest; //

const { status, data } = await apiInstance.updateManagedJobStatus(
    statusId,
    jobStatusUpsertRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **jobStatusUpsertRequest** | **JobStatusUpsertRequest**|  | |
| **statusId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseJobStatusManageResponse**

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

