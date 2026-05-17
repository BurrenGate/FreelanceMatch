# ContractControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**completeContract**](#completecontract) | **POST** /api/contracts/{id}/complete | |
|[**confirmCancellation**](#confirmcancellation) | **POST** /api/contracts/{contractId}/cancel/confirm | |
|[**createContract**](#createcontract) | **POST** /api/contracts | |
|[**deleteContract**](#deletecontract) | **DELETE** /api/contracts/{id} | |
|[**getAllContracts**](#getallcontracts) | **GET** /api/contracts | |
|[**getContractById**](#getcontractbyid) | **GET** /api/contracts/{id} | |
|[**getContractDetails**](#getcontractdetails) | **GET** /api/contracts/{contractId}/details | |
|[**getLastTransactionAmount**](#getlasttransactionamount) | **GET** /api/contracts/{contractId}/last-transaction | |
|[**getMyContracts**](#getmycontracts) | **GET** /api/contracts/my | |
|[**rejectCancellationRequest**](#rejectcancellationrequest) | **POST** /api/contracts/{contractId}/cancel/reject | |
|[**requestCancellation**](#requestcancellation) | **POST** /api/contracts/{contractId}/cancel/request | |
|[**updateContract**](#updatecontract) | **PUT** /api/contracts/{id} | |

# **completeContract**
> ApiResponseVoid completeContract(completeJobRequest)


### Example

```typescript
import {
    ContractControllerApi,
    Configuration,
    CompleteJobRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new ContractControllerApi(configuration);

let id: number; // (default to undefined)
let completeJobRequest: CompleteJobRequest; //

const { status, data } = await apiInstance.completeContract(
    id,
    completeJobRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **completeJobRequest** | **CompleteJobRequest**|  | |
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

# **confirmCancellation**
> ApiResponseMapStringString confirmCancellation()


### Example

```typescript
import {
    ContractControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ContractControllerApi(configuration);

let contractId: number; // (default to undefined)

const { status, data } = await apiInstance.confirmCancellation(
    contractId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **contractId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseMapStringString**

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

# **createContract**
> ApiResponseContract createContract(contractRequest)


### Example

```typescript
import {
    ContractControllerApi,
    Configuration,
    ContractRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new ContractControllerApi(configuration);

let contractRequest: ContractRequest; //

const { status, data } = await apiInstance.createContract(
    contractRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **contractRequest** | **ContractRequest**|  | |


### Return type

**ApiResponseContract**

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

# **deleteContract**
> ApiResponseVoid deleteContract()


### Example

```typescript
import {
    ContractControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ContractControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.deleteContract(
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

# **getAllContracts**
> ApiResponseListContract getAllContracts()


### Example

```typescript
import {
    ContractControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ContractControllerApi(configuration);

const { status, data } = await apiInstance.getAllContracts();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseListContract**

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

# **getContractById**
> ApiResponseContract getContractById()


### Example

```typescript
import {
    ContractControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ContractControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.getContractById(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseContract**

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

# **getContractDetails**
> ApiResponseContractDetailsDTO getContractDetails()


### Example

```typescript
import {
    ContractControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ContractControllerApi(configuration);

let contractId: number; // (default to undefined)

const { status, data } = await apiInstance.getContractDetails(
    contractId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **contractId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseContractDetailsDTO**

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

# **getLastTransactionAmount**
> ApiResponseMapStringObject getLastTransactionAmount()


### Example

```typescript
import {
    ContractControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ContractControllerApi(configuration);

let contractId: number; // (default to undefined)

const { status, data } = await apiInstance.getLastTransactionAmount(
    contractId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **contractId** | [**number**] |  | defaults to undefined|


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

# **getMyContracts**
> ApiResponseListContract getMyContracts()


### Example

```typescript
import {
    ContractControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ContractControllerApi(configuration);

const { status, data } = await apiInstance.getMyContracts();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseListContract**

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

# **rejectCancellationRequest**
> ApiResponseMapStringString rejectCancellationRequest()


### Example

```typescript
import {
    ContractControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ContractControllerApi(configuration);

let contractId: number; // (default to undefined)

const { status, data } = await apiInstance.rejectCancellationRequest(
    contractId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **contractId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseMapStringString**

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

# **requestCancellation**
> ApiResponseMapStringString requestCancellation(cancelContractRequest)


### Example

```typescript
import {
    ContractControllerApi,
    Configuration,
    CancelContractRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new ContractControllerApi(configuration);

let contractId: number; // (default to undefined)
let cancelContractRequest: CancelContractRequest; //

const { status, data } = await apiInstance.requestCancellation(
    contractId,
    cancelContractRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **cancelContractRequest** | **CancelContractRequest**|  | |
| **contractId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseMapStringString**

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

# **updateContract**
> ApiResponseContract updateContract(contractRequest)


### Example

```typescript
import {
    ContractControllerApi,
    Configuration,
    ContractRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new ContractControllerApi(configuration);

let id: number; // (default to undefined)
let contractRequest: ContractRequest; //

const { status, data } = await apiInstance.updateContract(
    id,
    contractRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **contractRequest** | **ContractRequest**|  | |
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseContract**

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

