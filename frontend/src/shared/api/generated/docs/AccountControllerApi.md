# AccountControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**changePassword**](#changepassword) | **POST** /api/accounts/change-password | |
|[**deactivateAccount**](#deactivateaccount) | **POST** /api/accounts/deactivate | |
|[**getAccountById**](#getaccountbyid) | **GET** /api/accounts/{accountId} | |
|[**getAccounts**](#getaccounts) | **GET** /api/accounts | |
|[**updateAccountStatus**](#updateaccountstatus) | **PATCH** /api/accounts/{accountId}/status | |

# **changePassword**
> ApiResponseVoid changePassword(changePasswordRequest)


### Example

```typescript
import {
    AccountControllerApi,
    Configuration,
    ChangePasswordRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new AccountControllerApi(configuration);

let changePasswordRequest: ChangePasswordRequest; //

const { status, data } = await apiInstance.changePassword(
    changePasswordRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **changePasswordRequest** | **ChangePasswordRequest**|  | |


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

# **deactivateAccount**
> ApiResponseVoid deactivateAccount()


### Example

```typescript
import {
    AccountControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new AccountControllerApi(configuration);

const { status, data } = await apiInstance.deactivateAccount();
```

### Parameters
This endpoint does not have any parameters.


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

# **getAccountById**
> ApiResponseAccountResponse getAccountById()


### Example

```typescript
import {
    AccountControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new AccountControllerApi(configuration);

let accountId: number; // (default to undefined)

const { status, data } = await apiInstance.getAccountById(
    accountId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **accountId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseAccountResponse**

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

# **getAccounts**
> ApiResponseListAccountResponse getAccounts()


### Example

```typescript
import {
    AccountControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new AccountControllerApi(configuration);

let status: string; // (optional) (default to undefined)

const { status, data } = await apiInstance.getAccounts(
    status
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **status** | [**string**] |  | (optional) defaults to undefined|


### Return type

**ApiResponseListAccountResponse**

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

# **updateAccountStatus**
> ApiResponseAccountResponse updateAccountStatus(updateAccountStatusRequest)


### Example

```typescript
import {
    AccountControllerApi,
    Configuration,
    UpdateAccountStatusRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new AccountControllerApi(configuration);

let accountId: number; // (default to undefined)
let updateAccountStatusRequest: UpdateAccountStatusRequest; //

const { status, data } = await apiInstance.updateAccountStatus(
    accountId,
    updateAccountStatusRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **updateAccountStatusRequest** | **UpdateAccountStatusRequest**|  | |
| **accountId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseAccountResponse**

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

