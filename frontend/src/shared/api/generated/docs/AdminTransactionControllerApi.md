# AdminTransactionControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**createManagedTransaction**](#createmanagedtransaction) | **POST** /api/transactions/manage | |
|[**deleteManagedTransaction**](#deletemanagedtransaction) | **DELETE** /api/transactions/manage/{id} | |
|[**getManagedTransactionById**](#getmanagedtransactionbyid) | **GET** /api/transactions/manage/{id} | |
|[**getManagedTransactions**](#getmanagedtransactions) | **GET** /api/transactions/manage | |
|[**updateManagedTransaction**](#updatemanagedtransaction) | **PUT** /api/transactions/manage/{id} | |

# **createManagedTransaction**
> ApiResponseTransactionManageResponse createManagedTransaction(transactionUpsertRequest)


### Example

```typescript
import {
    AdminTransactionControllerApi,
    Configuration,
    TransactionUpsertRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminTransactionControllerApi(configuration);

let transactionUpsertRequest: TransactionUpsertRequest; //

const { status, data } = await apiInstance.createManagedTransaction(
    transactionUpsertRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **transactionUpsertRequest** | **TransactionUpsertRequest**|  | |


### Return type

**ApiResponseTransactionManageResponse**

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

# **deleteManagedTransaction**
> ApiResponseVoid deleteManagedTransaction()


### Example

```typescript
import {
    AdminTransactionControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminTransactionControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.deleteManagedTransaction(
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

# **getManagedTransactionById**
> ApiResponseTransactionManageResponse getManagedTransactionById()


### Example

```typescript
import {
    AdminTransactionControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminTransactionControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.getManagedTransactionById(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseTransactionManageResponse**

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

# **getManagedTransactions**
> ApiResponseListTransactionManageResponse getManagedTransactions()


### Example

```typescript
import {
    AdminTransactionControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminTransactionControllerApi(configuration);

let contractId: number; // (optional) (default to undefined)
let type: string; // (optional) (default to undefined)

const { status, data } = await apiInstance.getManagedTransactions(
    contractId,
    type
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **contractId** | [**number**] |  | (optional) defaults to undefined|
| **type** | [**string**] |  | (optional) defaults to undefined|


### Return type

**ApiResponseListTransactionManageResponse**

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

# **updateManagedTransaction**
> ApiResponseTransactionManageResponse updateManagedTransaction(transactionUpsertRequest)


### Example

```typescript
import {
    AdminTransactionControllerApi,
    Configuration,
    TransactionUpsertRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminTransactionControllerApi(configuration);

let id: number; // (default to undefined)
let transactionUpsertRequest: TransactionUpsertRequest; //

const { status, data } = await apiInstance.updateManagedTransaction(
    id,
    transactionUpsertRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **transactionUpsertRequest** | **TransactionUpsertRequest**|  | |
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseTransactionManageResponse**

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

