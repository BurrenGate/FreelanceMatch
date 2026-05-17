# FreelancerProfileControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**getFreelancerProfile**](#getfreelancerprofile) | **GET** /api/freelancers/{freelancerId}/profile | |

# **getFreelancerProfile**
> ApiResponseFreelancerProfileDTO getFreelancerProfile()


### Example

```typescript
import {
    FreelancerProfileControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new FreelancerProfileControllerApi(configuration);

let freelancerId: number; // (default to undefined)

const { status, data } = await apiInstance.getFreelancerProfile(
    freelancerId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **freelancerId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseFreelancerProfileDTO**

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

