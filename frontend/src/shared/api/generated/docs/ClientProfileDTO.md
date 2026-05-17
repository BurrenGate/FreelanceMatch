# ClientProfileDTO


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**profileId** | **number** |  | [optional] [default to undefined]
**accountId** | **number** |  | [optional] [default to undefined]
**email** | **string** |  | [optional] [default to undefined]
**firstName** | **string** |  | [optional] [default to undefined]
**lastName** | **string** |  | [optional] [default to undefined]
**fullName** | **string** |  | [optional] [default to undefined]
**bio** | **string** |  | [optional] [default to undefined]
**avatarUrl** | **string** |  | [optional] [default to undefined]
**totalSpent** | **number** |  | [optional] [default to undefined]
**postedJobs** | **number** |  | [optional] [default to undefined]
**activeJobs** | **number** |  | [optional] [default to undefined]
**completedJobs** | **number** |  | [optional] [default to undefined]
**totalReviewsGiven** | **number** |  | [optional] [default to undefined]
**averageRatingGiven** | **number** |  | [optional] [default to undefined]
**memberSince** | **string** |  | [optional] [default to undefined]
**lastLogin** | **string** |  | [optional] [default to undefined]
**accountStatus** | **string** |  | [optional] [default to undefined]
**recentJobs** | [**Array&lt;ClientJobDTO&gt;**](ClientJobDTO.md) |  | [optional] [default to undefined]
**recentReviews** | [**Array&lt;ClientReviewDTO&gt;**](ClientReviewDTO.md) |  | [optional] [default to undefined]

## Example

```typescript
import { ClientProfileDTO } from './api';

const instance: ClientProfileDTO = {
    profileId,
    accountId,
    email,
    firstName,
    lastName,
    fullName,
    bio,
    avatarUrl,
    totalSpent,
    postedJobs,
    activeJobs,
    completedJobs,
    totalReviewsGiven,
    averageRatingGiven,
    memberSince,
    lastLogin,
    accountStatus,
    recentJobs,
    recentReviews,
};
```

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
