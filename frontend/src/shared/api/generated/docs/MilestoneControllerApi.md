# MilestoneControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**createMilestone**](#createmilestone) | **POST** /api/contracts/{contractId}/milestones | |
|[**getContractMilestones**](#getcontractmilestones) | **GET** /api/contracts/{contractId}/milestones | |
|[**getPaymentSummary**](#getpaymentsummary) | **GET** /api/contracts/{contractId}/payment-summary | |
|[**payMilestone**](#paymilestone) | **POST** /api/contracts/{contractId}/milestones/{milestoneId}/pay | |
|[**updateMilestoneStatus**](#updatemilestonestatus) | **PUT** /api/contracts/{contractId}/milestones/{milestoneId}/status | |

# **createMilestone**
> ApiResponseMapStringLong createMilestone(createMilestoneRequest)


### Example

```typescript
import {
    MilestoneControllerApi,
    Configuration,
    CreateMilestoneRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new MilestoneControllerApi(configuration);

let contractId: number; // (default to undefined)
let createMilestoneRequest: CreateMilestoneRequest; //

const { status, data } = await apiInstance.createMilestone(
    contractId,
    createMilestoneRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **createMilestoneRequest** | **CreateMilestoneRequest**|  | |
| **contractId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseMapStringLong**

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

# **getContractMilestones**
> ApiResponseListMilestoneDTO getContractMilestones()


### Example

```typescript
import {
    MilestoneControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new MilestoneControllerApi(configuration);

let contractId: number; // (default to undefined)

const { status, data } = await apiInstance.getContractMilestones(
    contractId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **contractId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseListMilestoneDTO**

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

# **getPaymentSummary**
> ApiResponsePaymentSummaryDTO getPaymentSummary()


### Example

```typescript
import {
    MilestoneControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new MilestoneControllerApi(configuration);

let contractId: number; // (default to undefined)

const { status, data } = await apiInstance.getPaymentSummary(
    contractId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **contractId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponsePaymentSummaryDTO**

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

# **payMilestone**
> ApiResponseMapStringLong payMilestone()


### Example

```typescript
import {
    MilestoneControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new MilestoneControllerApi(configuration);

let contractId: number; // (default to undefined)
let milestoneId: number; // (default to undefined)

const { status, data } = await apiInstance.payMilestone(
    contractId,
    milestoneId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **contractId** | [**number**] |  | defaults to undefined|
| **milestoneId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseMapStringLong**

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

# **updateMilestoneStatus**
> ApiResponseMapStringString updateMilestoneStatus(requestBody)


### Example

```typescript
import {
    MilestoneControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new MilestoneControllerApi(configuration);

let contractId: number; // (default to undefined)
let milestoneId: number; // (default to undefined)
let requestBody: { [key: string]: string; }; //

const { status, data } = await apiInstance.updateMilestoneStatus(
    contractId,
    milestoneId,
    requestBody
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **requestBody** | **{ [key: string]: string; }**|  | |
| **contractId** | [**number**] |  | defaults to undefined|
| **milestoneId** | [**number**] |  | defaults to undefined|


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

