# DebugClientControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**testClientFunction**](#testclientfunction) | **GET** /api/debug/test-client-function/{clientId} | |

# **testClientFunction**
> { [key: string]: any; } testClientFunction()


### Example

```typescript
import {
    DebugClientControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new DebugClientControllerApi(configuration);

let clientId: number; // (default to undefined)

const { status, data } = await apiInstance.testClientFunction(
    clientId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **clientId** | [**number**] |  | defaults to undefined|


### Return type

**{ [key: string]: any; }**

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

