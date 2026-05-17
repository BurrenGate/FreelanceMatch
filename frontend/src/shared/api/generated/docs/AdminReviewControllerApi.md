# AdminReviewControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**createManagedReview**](#createmanagedreview) | **POST** /api/reviews/manage | |
|[**deleteManagedReview**](#deletemanagedreview) | **DELETE** /api/reviews/manage/{id} | |
|[**getManagedReviewById**](#getmanagedreviewbyid) | **GET** /api/reviews/manage/{id} | |
|[**getManagedReviews**](#getmanagedreviews) | **GET** /api/reviews/manage | |
|[**updateManagedReview**](#updatemanagedreview) | **PUT** /api/reviews/manage/{id} | |

# **createManagedReview**
> ApiResponseReviewManageResponse createManagedReview(reviewUpsertRequest)


### Example

```typescript
import {
    AdminReviewControllerApi,
    Configuration,
    ReviewUpsertRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminReviewControllerApi(configuration);

let reviewUpsertRequest: ReviewUpsertRequest; //

const { status, data } = await apiInstance.createManagedReview(
    reviewUpsertRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **reviewUpsertRequest** | **ReviewUpsertRequest**|  | |


### Return type

**ApiResponseReviewManageResponse**

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

# **deleteManagedReview**
> ApiResponseVoid deleteManagedReview()


### Example

```typescript
import {
    AdminReviewControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminReviewControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.deleteManagedReview(
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

# **getManagedReviewById**
> ApiResponseReviewManageResponse getManagedReviewById()


### Example

```typescript
import {
    AdminReviewControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminReviewControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.getManagedReviewById(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseReviewManageResponse**

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

# **getManagedReviews**
> ApiResponseListReviewManageResponse getManagedReviews()


### Example

```typescript
import {
    AdminReviewControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminReviewControllerApi(configuration);

let contractId: number; // (optional) (default to undefined)
let reviewerId: number; // (optional) (default to undefined)

const { status, data } = await apiInstance.getManagedReviews(
    contractId,
    reviewerId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **contractId** | [**number**] |  | (optional) defaults to undefined|
| **reviewerId** | [**number**] |  | (optional) defaults to undefined|


### Return type

**ApiResponseListReviewManageResponse**

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

# **updateManagedReview**
> ApiResponseReviewManageResponse updateManagedReview(reviewUpsertRequest)


### Example

```typescript
import {
    AdminReviewControllerApi,
    Configuration,
    ReviewUpsertRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminReviewControllerApi(configuration);

let id: number; // (default to undefined)
let reviewUpsertRequest: ReviewUpsertRequest; //

const { status, data } = await apiInstance.updateManagedReview(
    id,
    reviewUpsertRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **reviewUpsertRequest** | **ReviewUpsertRequest**|  | |
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseReviewManageResponse**

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

