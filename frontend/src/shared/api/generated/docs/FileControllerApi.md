# FileControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**deleteFile**](#deletefile) | **DELETE** /api/files/{objectName} | |
|[**downloadFile**](#downloadfile) | **GET** /api/files/download/{objectName} | |
|[**getFileUrl**](#getfileurl) | **GET** /api/files/url/{objectName} | |
|[**uploadAudio**](#uploadaudio) | **POST** /api/files/upload/audio | |
|[**uploadAvatar**](#uploadavatar) | **POST** /api/files/upload/avatar | |
|[**uploadChatFile**](#uploadchatfile) | **POST** /api/files/upload/chat | |
|[**uploadClientPhoto**](#uploadclientphoto) | **POST** /api/files/upload/client-photo | |
|[**uploadDocument**](#uploaddocument) | **POST** /api/files/upload/document | |
|[**uploadImage**](#uploadimage) | **POST** /api/files/upload/image | |
|[**uploadVideo**](#uploadvideo) | **POST** /api/files/upload/video | |

# **deleteFile**
> ApiResponseVoid deleteFile()


### Example

```typescript
import {
    FileControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new FileControllerApi(configuration);

let objectName: string; // (default to undefined)

const { status, data } = await apiInstance.deleteFile(
    objectName
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **objectName** | [**string**] |  | defaults to undefined|


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

# **downloadFile**
> File downloadFile()


### Example

```typescript
import {
    FileControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new FileControllerApi(configuration);

let objectName: string; // (default to undefined)

const { status, data } = await apiInstance.downloadFile(
    objectName
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **objectName** | [**string**] |  | defaults to undefined|


### Return type

**File**

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

# **getFileUrl**
> ApiResponseString getFileUrl()


### Example

```typescript
import {
    FileControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new FileControllerApi(configuration);

let objectName: string; // (default to undefined)

const { status, data } = await apiInstance.getFileUrl(
    objectName
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **objectName** | [**string**] |  | defaults to undefined|


### Return type

**ApiResponseString**

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

# **uploadAudio**
> ApiResponseFileUploadResponse uploadAudio()


### Example

```typescript
import {
    FileControllerApi,
    Configuration,
    UploadVideoRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new FileControllerApi(configuration);

let uploadVideoRequest: UploadVideoRequest; // (optional)

const { status, data } = await apiInstance.uploadAudio(
    uploadVideoRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **uploadVideoRequest** | **UploadVideoRequest**|  | |


### Return type

**ApiResponseFileUploadResponse**

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

# **uploadAvatar**
> ApiResponseFileUploadResponse uploadAvatar()


### Example

```typescript
import {
    FileControllerApi,
    Configuration,
    UploadVideoRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new FileControllerApi(configuration);

let uploadVideoRequest: UploadVideoRequest; // (optional)

const { status, data } = await apiInstance.uploadAvatar(
    uploadVideoRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **uploadVideoRequest** | **UploadVideoRequest**|  | |


### Return type

**ApiResponseFileUploadResponse**

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

# **uploadChatFile**
> ApiResponseFileUploadResponse uploadChatFile()


### Example

```typescript
import {
    FileControllerApi,
    Configuration,
    UploadVideoRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new FileControllerApi(configuration);

let uploadVideoRequest: UploadVideoRequest; // (optional)

const { status, data } = await apiInstance.uploadChatFile(
    uploadVideoRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **uploadVideoRequest** | **UploadVideoRequest**|  | |


### Return type

**ApiResponseFileUploadResponse**

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

# **uploadClientPhoto**
> ApiResponseFileUploadResponse uploadClientPhoto()


### Example

```typescript
import {
    FileControllerApi,
    Configuration,
    UploadVideoRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new FileControllerApi(configuration);

let uploadVideoRequest: UploadVideoRequest; // (optional)

const { status, data } = await apiInstance.uploadClientPhoto(
    uploadVideoRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **uploadVideoRequest** | **UploadVideoRequest**|  | |


### Return type

**ApiResponseFileUploadResponse**

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

# **uploadDocument**
> ApiResponseFileUploadResponse uploadDocument()


### Example

```typescript
import {
    FileControllerApi,
    Configuration,
    UploadVideoRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new FileControllerApi(configuration);

let uploadVideoRequest: UploadVideoRequest; // (optional)

const { status, data } = await apiInstance.uploadDocument(
    uploadVideoRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **uploadVideoRequest** | **UploadVideoRequest**|  | |


### Return type

**ApiResponseFileUploadResponse**

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

# **uploadImage**
> ApiResponseFileUploadResponse uploadImage()


### Example

```typescript
import {
    FileControllerApi,
    Configuration,
    UploadVideoRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new FileControllerApi(configuration);

let uploadVideoRequest: UploadVideoRequest; // (optional)

const { status, data } = await apiInstance.uploadImage(
    uploadVideoRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **uploadVideoRequest** | **UploadVideoRequest**|  | |


### Return type

**ApiResponseFileUploadResponse**

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

# **uploadVideo**
> ApiResponseFileUploadResponse uploadVideo()


### Example

```typescript
import {
    FileControllerApi,
    Configuration,
    UploadVideoRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new FileControllerApi(configuration);

let uploadVideoRequest: UploadVideoRequest; // (optional)

const { status, data } = await apiInstance.uploadVideo(
    uploadVideoRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **uploadVideoRequest** | **UploadVideoRequest**|  | |


### Return type

**ApiResponseFileUploadResponse**

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

