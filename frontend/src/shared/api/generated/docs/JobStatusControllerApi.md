# JobStatusControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**getJobStatus**](#getjobstatus) | **GET** /api/jobs/{jobId}/status | |
|[**updateJobStatus**](#updatejobstatus) | **PUT** /api/jobs/{jobId}/status | |

# **getJobStatus**
> ApiResponseJobStatusResponse getJobStatus()


### Example

```typescript
import {
    JobStatusControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new JobStatusControllerApi(configuration);

let jobId: number; // (default to undefined)

const { status, data } = await apiInstance.getJobStatus(
    jobId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **jobId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseJobStatusResponse**

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

# **updateJobStatus**
> ApiResponseJobStatusResponse updateJobStatus(updateJobStatusRequest)


### Example

```typescript
import {
    JobStatusControllerApi,
    Configuration,
    UpdateJobStatusRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new JobStatusControllerApi(configuration);

let jobId: number; // (default to undefined)
let updateJobStatusRequest: UpdateJobStatusRequest; //

const { status, data } = await apiInstance.updateJobStatus(
    jobId,
    updateJobStatusRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **updateJobStatusRequest** | **UpdateJobStatusRequest**|  | |
| **jobId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseJobStatusResponse**

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

