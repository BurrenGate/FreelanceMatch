# SkillSuggestionControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**approveSkillSuggestion**](#approveskillsuggestion) | **POST** /api/skill-suggestions/{id}/approve | |
|[**getAllSkillSuggestions**](#getallskillsuggestions) | **GET** /api/skill-suggestions/admin | |
|[**getMySkillSuggestions**](#getmyskillsuggestions) | **GET** /api/skill-suggestions/my | |
|[**getSuggestionStatistics**](#getsuggestionstatistics) | **GET** /api/skill-suggestions/admin/statistics | |
|[**rejectSkillSuggestion**](#rejectskillsuggestion) | **POST** /api/skill-suggestions/{id}/reject | |
|[**suggestSkill**](#suggestskill) | **POST** /api/skill-suggestions | |

# **approveSkillSuggestion**
> ApiResponseMapStringObject approveSkillSuggestion()


### Example

```typescript
import {
    SkillSuggestionControllerApi,
    Configuration,
    ReviewSkillSuggestionRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new SkillSuggestionControllerApi(configuration);

let id: number; // (default to undefined)
let reviewSkillSuggestionRequest: ReviewSkillSuggestionRequest; // (optional)

const { status, data } = await apiInstance.approveSkillSuggestion(
    id,
    reviewSkillSuggestionRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **reviewSkillSuggestionRequest** | **ReviewSkillSuggestionRequest**|  | |
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseMapStringObject**

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

# **getAllSkillSuggestions**
> ApiResponseListSkillSuggestionDTO getAllSkillSuggestions()


### Example

```typescript
import {
    SkillSuggestionControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new SkillSuggestionControllerApi(configuration);

let status: string; // (optional) (default to undefined)

const { status, data } = await apiInstance.getAllSkillSuggestions(
    status
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **status** | [**string**] |  | (optional) defaults to undefined|


### Return type

**ApiResponseListSkillSuggestionDTO**

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

# **getMySkillSuggestions**
> ApiResponseListMySkillSuggestionDTO getMySkillSuggestions()


### Example

```typescript
import {
    SkillSuggestionControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new SkillSuggestionControllerApi(configuration);

const { status, data } = await apiInstance.getMySkillSuggestions();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseListMySkillSuggestionDTO**

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

# **getSuggestionStatistics**
> ApiResponseSkillSuggestionStatsDTO getSuggestionStatistics()


### Example

```typescript
import {
    SkillSuggestionControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new SkillSuggestionControllerApi(configuration);

const { status, data } = await apiInstance.getSuggestionStatistics();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**ApiResponseSkillSuggestionStatsDTO**

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

# **rejectSkillSuggestion**
> ApiResponseMapStringObject rejectSkillSuggestion(reviewSkillSuggestionRequest)


### Example

```typescript
import {
    SkillSuggestionControllerApi,
    Configuration,
    ReviewSkillSuggestionRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new SkillSuggestionControllerApi(configuration);

let id: number; // (default to undefined)
let reviewSkillSuggestionRequest: ReviewSkillSuggestionRequest; //

const { status, data } = await apiInstance.rejectSkillSuggestion(
    id,
    reviewSkillSuggestionRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **reviewSkillSuggestionRequest** | **ReviewSkillSuggestionRequest**|  | |
| **id** | [**number**] |  | defaults to undefined|


### Return type

**ApiResponseMapStringObject**

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

# **suggestSkill**
> ApiResponseMapStringObject suggestSkill(suggestSkillRequest)


### Example

```typescript
import {
    SkillSuggestionControllerApi,
    Configuration,
    SuggestSkillRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new SkillSuggestionControllerApi(configuration);

let suggestSkillRequest: SuggestSkillRequest; //

const { status, data } = await apiInstance.suggestSkill(
    suggestSkillRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **suggestSkillRequest** | **SuggestSkillRequest**|  | |


### Return type

**ApiResponseMapStringObject**

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

