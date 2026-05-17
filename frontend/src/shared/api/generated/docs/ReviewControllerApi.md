# ReviewControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**createReview**](#createreview) | **POST** /api/reviews | |
|[**deleteReview**](#deletereview) | **DELETE** /api/reviews/{id} | |
|[**getAllReviews**](#getallreviews) | **GET** /api/reviews | |
|[**getReviewById**](#getreviewbyid) | **GET** /api/reviews/{id} | |
|[**getReviewsByContractId**](#getreviewsbycontractid) | **GET** /api/reviews/contract/{contractId} | |
|[**getReviewsByReviewerId**](#getreviewsbyreviewerid) | **GET** /api/reviews/reviewer/{reviewerId} | |
|[**updateReview**](#updatereview) | **PUT** /api/reviews/{id} | |

# **createReview**
> ApiResponseReview createReview(reviewRequest)


### Example

```typescript
import {
    ReviewControllerApi,
    Configuration,
    ReviewRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new ReviewControllerApi(configuration);

let reviewRequest: ReviewRequest; //

const { status, data } = await apiInstance.createReview(
    reviewRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **reviewRequest** | **ReviewRequest**|  | |


### Return type

**ApiResponseReview**

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

# **deleteReview**
> ApiResponseVoid deleteReview()


### Example

```typescript
import {
    ReviewControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ReviewControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.deleteReview(
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

# **getAllReviews**
> ApiResponseListReview getAllReviews()


### Example

```typescript
import {
    ReviewControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ReviewControllerApi(configuration);

const { status, data } = await apiInstance.getAllReviews();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseListReview**

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

# **getReviewById**
> ApiResponseReview getReviewById()


### Example

```typescript
import {
    ReviewControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ReviewControllerApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.getReviewById(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseReview**

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

# **getReviewsByContractId**
> ApiResponseListReview getReviewsByContractId()


### Example

```typescript
import {
    ReviewControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ReviewControllerApi(configuration);

let contractId: number; // (default to undefined)

const { status, data } = await apiInstance.getReviewsByContractId(
    contractId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **contractId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseListReview**

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

# **getReviewsByReviewerId**
> ApiResponseListReview getReviewsByReviewerId()


### Example

```typescript
import {
    ReviewControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ReviewControllerApi(configuration);

let reviewerId: number; // (default to undefined)

const { status, data } = await apiInstance.getReviewsByReviewerId(
    reviewerId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **reviewerId** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseListReview**

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

# **updateReview**
> ApiResponseReview updateReview(reviewRequest)


### Example

```typescript
import {
    ReviewControllerApi,
    Configuration,
    ReviewRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new ReviewControllerApi(configuration);

let id: number; // (default to undefined)
let reviewRequest: ReviewRequest; //

const { status, data } = await apiInstance.updateReview(
    id,
    reviewRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **reviewRequest** | **ReviewRequest**|  | |
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseReview**

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

