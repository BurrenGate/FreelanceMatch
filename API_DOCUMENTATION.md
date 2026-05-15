# API Documentation - Freelancer Profile & Proposals

## Новые эндпоинты

### 1. Просмотр профиля фрилансера
**GET** `/api/freelancers/{freelancerId}/profile`

Возвращает полную информацию о фрилансере со статистикой, навыками и отзывами.

**Доступ:** Все авторизованные пользователи

**Response:**
```json
{
  "success": true,
  "message": "Freelancer profile retrieved successfully",
  "data": {
    "profileId": 1,
    "accountId": 1,
    "email": "freelancer@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "fullName": "John Doe",
    "bio": "Experienced developer...",
    "hourlyRate": 50.00,
    "avatarUrl": "https://...",
    "rating": 4.5,
    "totalEarnings": 15000.00,
    "completedJobs": 25,
    "activeJobs": 3,
    "totalReviews": 20,
    "isAvailable": true,
    "memberSince": "2023-01-15T10:30:00",
    "lastLogin": "2024-01-20T14:25:00",
    "accountStatus": "active",
    "skills": [
      {
        "skillId": 1,
        "skillName": "Java",
        "skillCategory": "Programming",
        "skillLevel": "Expert"
      }
    ],
    "recentReviews": [
      {
        "reviewId": 1,
        "contractId": 5,
        "jobTitle": "Build REST API",
        "reviewerName": "Jane Smith",
        "rating": 5,
        "comment": "Excellent work!",
        "reviewDate": "2024-01-10T12:00:00"
      }
    ]
  }
}
```

---

### 2. Отклонить предложение
**POST** `/api/proposals/{proposalId}/reject`

Позволяет клиенту отклонить предложение фрилансера.

**Доступ:** Только CLIENT

**Response:**
```json
{
  "success": true,
  "message": "Proposal rejected successfully.",
  "data": null
}
```

---

### 3. Получить предложения с данными фрилансеров
**GET** `/api/proposals/job/{jobId}/with-freelancer`

Возвращает все предложения для заказа с подробной информацией о каждом фрилансере.

**Доступ:** Все авторизованные пользователи

**Response:**
```json
{
  "success": true,
  "message": "Retrieved 5 proposal(s) with freelancer details",
  "data": [
    {
      "id": 67,
      "jobId": 10,
      "freelancerId": 5,
      "bidAmount": 500.00,
      "deliveryDays": 7,
      "coverLetter": "I am interested in this project...",
      "status": "pending",
      "createdAt": "2024-01-15T10:00:00",
      "freelancerName": "John Doe",
      "freelancerEmail": "john@example.com",
      "freelancerHourlyRate": 50.00,
      "freelancerAvatarUrl": "https://...",
      "freelancerRating": 4.5,
      "freelancerCompletedJobs": 25
    }
  ]
}
```

---

## Изменения в базе данных

### V29 Migration
- Исправлена функция `get_freelancer_reviews` (убрана зависимость от transactions)
- Добавлена колонка `created_at` в таблицу `contracts`
- Улучшена функция `get_freelancer_profile` (добавлены fullName, accountStatus)
- Добавлена функция `get_proposals_with_freelancer_details`

### V28 Migration
- Исправлена процедура `finalize_proposal_and_create_contract` (использует правильные колонки)

### V27 Migration
- Добавлена процедура `reject_proposal`
- Добавлены функции для просмотра профиля фрилансера

---

## Использование

### Для клиентов:
1. Просмотр предложений с информацией о фрилансерах:
   ```
   GET /api/proposals/job/{jobId}/with-freelancer
   ```

2. Просмотр полного профиля фрилансера:
   ```
   GET /api/freelancers/{freelancerId}/profile
   ```

3. Принять предложение:
   ```
   POST /api/proposals/{proposalId}/accept
   ```

4. Отклонить предложение:
   ```
   POST /api/proposals/{proposalId}/reject
   ```

### Для фрилансеров:
1. Просмотр своего профиля или профилей других фрилансеров:
   ```
   GET /api/freelancers/{freelancerId}/profile
   ```


---

## 📌 Фильтрация заказов для фрилансеров

### Важно:
Фрилансеры видят только заказы со статусом **OPEN**. Заказы со статусами **IN_PROGRESS**, **COMPLETED** или **CANCELLED** не показываются в списках и рекомендациях.

### Endpoints с фильтрацией:

1. **GET** `/api/jobs` - Все заказы (только OPEN)
2. **GET** `/api/jobs/recommended` - Рекомендованные заказы (только OPEN с совпадением навыков ≥50%)

### Для клиентов:
Клиенты видят все свои заказы независимо от статуса через:
- **GET** `/api/jobs/my` - Мои заказы (все статусы)

### Статусы заказов:
- **OPEN** (1) - Открыт для предложений ✅ Виден фрилансерам
- **IN_PROGRESS** (2) - В работе ❌ Не виден фрилансерам
- **COMPLETED** (3) - Завершен ❌ Не виден фрилансерам
- **CANCELLED** (4) - Отменен ❌ Не виден фрилансерам
