# ClientProfileControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**getClientProfile**](#getclientprofile) | **GET** /api/clients/{clientId}/profile | |

# **getClientProfile**
> ApiResponseClientProfileDTO getClientProfile()


### Example

```typescript
import {
    ClientProfileControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ClientProfileControllerApi(configuration);

let clientId: number; // (default to undefined)

const { status, data } = await apiInstance.getClientProfile(
    clientId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **clientId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseClientProfileDTO**

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

