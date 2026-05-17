# TransactionControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**createTransaction**](#createtransaction) | **POST** /api/transactions | |
|[**deleteTransaction**](#deletetransaction) | **DELETE** /api/transactions/{id} | |
|[**getAllTransactions**](#getalltransactions) | **GET** /api/transactions | |
|[**getTransactionById**](#gettransactionbyid) | **GET** /api/transactions/{id} | |
|[**getTransactionsByContractId**](#gettransactionsbycontractid) | **GET** /api/transactions/contract/{contractId} | |
|[**getTransactionsByType**](#gettransactionsbytype) | **GET** /api/transactions/type/{type} | |
|[**updateTransaction**](#updatetransaction) | **PUT** /api/transactions/{id} | |

# **createTransaction**
> ApiResponseTransaction createTransaction(transactionRequest)


### Example

```typescript
import {
    TransactionControllerApi,
    Configuration,
    TransactionRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new TransactionControllerApi(configuration);

let transactionRequest: TransactionRequest; //

const { status, data } = await apiInstance.createTransaction(
    transactionRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **transactionRequest** | **TransactionRequest**|  | |


### Return type

**ApiResponseTransaction**

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

# **deleteTransaction**
> ApiResponseVoid deleteTransaction()


### Example

```typescript
import {
    TransactionControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new TransactionControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.deleteTransaction(
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

# **getAllTransactions**
> ApiResponseListTransaction getAllTransactions()


### Example

```typescript
import {
    TransactionControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new TransactionControllerApi(configuration);

const { status, data } = await apiInstance.getAllTransactions();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseListTransaction**

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

# **getTransactionById**
> ApiResponseTransaction getTransactionById()


### Example

```typescript
import {
    TransactionControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new TransactionControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.getTransactionById(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseTransaction**

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

# **getTransactionsByContractId**
> ApiResponseListTransaction getTransactionsByContractId()


### Example

```typescript
import {
    TransactionControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new TransactionControllerApi(configuration);

let contractId: number; // (default to undefined)

const { status, data } = await apiInstance.getTransactionsByContractId(
    contractId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **contractId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseListTransaction**

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

# **getTransactionsByType**
> ApiResponseListTransaction getTransactionsByType()


### Example

```typescript
import {
    TransactionControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new TransactionControllerApi(configuration);

let type: string; // (default to undefined)

const { status, data } = await apiInstance.getTransactionsByType(
    type
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **type** | [**string**] |  | defaults to undefined|


### Return type

**ApiResponseListTransaction**

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

# **updateTransaction**
> ApiResponseTransaction updateTransaction(transactionRequest)


### Example

```typescript
import {
    TransactionControllerApi,
    Configuration,
    TransactionRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new TransactionControllerApi(configuration);

let id: number; // (default to undefined)
let transactionRequest: TransactionRequest; //

const { status, data } = await apiInstance.updateTransaction(
    id,
    transactionRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **transactionRequest** | **TransactionRequest**|  | |
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseTransaction**

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

