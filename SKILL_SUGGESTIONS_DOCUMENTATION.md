# 💡 Система предложения навыков (Skill Suggestions)

## 🎯 Описание
Клиенты и фрилансеры могут предлагать новые навыки для добавления в систему. Все предложения должны быть одобрены администратором перед тем, как навык станет доступным.

## 🔄 Процесс

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│   User      │      │   Pending    │      │   Admin     │
│  suggests   │─────▶│  suggestion  │─────▶│  reviews    │
│   skill     │      │              │      │             │
└─────────────┘      └──────────────┘      └─────────────┘
                                                   │
                                    ┌──────────────┴──────────────┐
                                    │                             │
                              ┌─────▼──────┐              ┌──────▼──────┐
                              │  Approved  │              │  Rejected   │
                              │  → Skill   │              │  + Comment  │
                              │   created  │              │             │
                              └────────────┘              └─────────────┘
```

## 📋 Статусы предложений

| Статус | Описание |
|--------|----------|
| `pending` | Ожидает рассмотрения администратором |
| `approved` | Одобрено, навык добавлен в систему |
| `rejected` | Отклонено с комментарием администратора |

## 🔐 Права доступа

### Клиенты и Фрилансеры (Roles: 1, 2)
- ✅ Предлагать новые навыки
- ✅ Просматривать свои предложения
- ❌ Просматривать предложения других пользователей
- ❌ Одобрять/отклонять предложения

### Администраторы (Role: 3)
- ✅ Просматривать все предложения
- ✅ Фильтровать по статусу
- ✅ Одобрять предложения (создает навык)
- ✅ Отклонять предложения (с обязательным комментарием)
- ✅ Просматривать статистику

## 📡 API Endpoints

### 1. Предложить навык (Clients & Freelancers)
```http
POST /api/skill-suggestions
Authorization: Bearer {jwt_token}
Content-Type: application/json

{
  "name": "React Native",
  "category": "Mobile Development"
}
```

**Успешный ответ:**
```json
{
  "success": true,
  "message": "Skill suggestion submitted successfully. Waiting for admin approval.",
  "data": {
    "suggestion_id": 1,
    "skill_name": "React Native",
    "skill_category": "Mobile Development",
    "status": "pending",
    "message": "Skill suggestion submitted successfully. Waiting for admin approval."
  }
}
```

**Ошибки:**
- Навык уже существует
- Уже есть pending предложение с таким именем
- Пользователь не авторизован

---

### 2. Мои предложения (Clients & Freelancers)
```http
GET /api/skill-suggestions/my
Authorization: Bearer {jwt_token}
```

**Ответ:**
```json
{
  "success": true,
  "message": "Retrieved 3 suggestion(s)",
  "data": [
    {
      "suggestionId": 1,
      "skillName": "React Native",
      "skillCategory": "Mobile Development",
      "status": "pending",
      "adminComment": null,
      "reviewedByName": null,
      "reviewedAt": null,
      "createdAt": "2024-01-15T10:30:00"
    },
    {
      "suggestionId": 2,
      "skillName": "Flutter",
      "skillCategory": "Mobile Development",
      "status": "approved",
      "adminComment": "Great suggestion!",
      "reviewedByName": "Admin User",
      "reviewedAt": "2024-01-14T15:20:00",
      "createdAt": "2024-01-14T10:00:00"
    },
    {
      "suggestionId": 3,
      "skillName": "COBOL",
      "skillCategory": "Legacy Systems",
      "status": "rejected",
      "adminComment": "Not relevant for our platform",
      "reviewedByName": "Admin User",
      "reviewedAt": "2024-01-13T12:00:00",
      "createdAt": "2024-01-13T09:00:00"
    }
  ]
}
```

---

### 3. Все предложения (Admin only)
```http
GET /api/skill-suggestions/admin?status=pending
Authorization: Bearer {admin_jwt_token}
```

**Query Parameters:**
- `status` (optional): `pending`, `approved`, `rejected`

**Ответ:**
```json
{
  "success": true,
  "message": "Retrieved 5 suggestion(s)",
  "data": [
    {
      "suggestionId": 1,
      "skillName": "React Native",
      "skillCategory": "Mobile Development",
      "status": "pending",
      "suggestedById": 10,
      "suggestedByName": "John Doe",
      "suggestedByEmail": "john@example.com",
      "adminComment": null,
      "reviewedById": null,
      "reviewedByName": null,
      "reviewedAt": null,
      "createdAt": "2024-01-15T10:30:00"
    }
  ]
}
```

---

### 4. Одобрить предложение (Admin only)
```http
POST /api/skill-suggestions/{id}/approve
Authorization: Bearer {admin_jwt_token}
Content-Type: application/json

{
  "adminComment": "Excellent suggestion! Added to the system."
}
```

**Ответ:**
```json
{
  "success": true,
  "message": "Skill suggestion approved successfully",
  "data": {
    "skill_id": 42,
    "skill_name": "React Native",
    "skill_category": "Mobile Development",
    "message": "Skill suggestion approved and added to the system"
  }
}
```

**Что происходит:**
1. Создается новый навык в таблице `skills`
2. Статус предложения меняется на `approved`
3. Записывается информация о рецензенте и времени
4. Навык становится доступным для использования

---

### 5. Отклонить предложение (Admin only)
```http
POST /api/skill-suggestions/{id}/reject
Authorization: Bearer {admin_jwt_token}
Content-Type: application/json

{
  "adminComment": "This skill is too specific and not widely used."
}
```

**⚠️ Важно:** Комментарий администратора обязателен при отклонении!

**Ответ:**
```json
{
  "success": true,
  "message": "Skill suggestion rejected",
  "data": {
    "suggestion_id": 1,
    "skill_name": "React Native",
    "status": "rejected",
    "message": "Skill suggestion rejected"
  }
}
```

---

### 6. Статистика предложений (Admin only)
```http
GET /api/skill-suggestions/admin/statistics
Authorization: Bearer {admin_jwt_token}
```

**Ответ:**
```json
{
  "success": true,
  "message": "Statistics retrieved successfully",
  "data": {
    "totalSuggestions": 150,
    "pendingSuggestions": 12,
    "approvedSuggestions": 98,
    "rejectedSuggestions": 40,
    "suggestionsToday": 3,
    "suggestionsThisWeek": 15,
    "suggestionsThisMonth": 45
  }
}
```

## 🗄️ База данных

### Таблица: skill_suggestions
```sql
CREATE TABLE skill_suggestions (
    id              BIGSERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    category        VARCHAR(100),
    suggested_by    BIGINT REFERENCES profiles(id) NOT NULL,
    status          VARCHAR(20) DEFAULT 'pending',
    admin_comment   TEXT,
    reviewed_by     BIGINT REFERENCES profiles(id),
    reviewed_at     TIMESTAMP,
    created_at      TIMESTAMP DEFAULT NOW()
);
```

### PL/pgSQL Функции

#### skill_management.suggest_skill()
```sql
SELECT * FROM skill_management.suggest_skill(
    'React Native',           -- skill name
    'Mobile Development',     -- category
    10                        -- user profile id
);
```

#### skill_management.get_skill_suggestions()
```sql
SELECT * FROM skill_management.get_skill_suggestions(
    5,                        -- admin profile id
    'pending'                 -- status filter (optional)
);
```

#### skill_management.approve_skill_suggestion()
```sql
SELECT * FROM skill_management.approve_skill_suggestion(
    1,                        -- suggestion id
    5,                        -- admin profile id
    'Great suggestion!'       -- admin comment (optional)
);
```

#### skill_management.reject_skill_suggestion()
```sql
SELECT * FROM skill_management.reject_skill_suggestion(
    1,                        -- suggestion id
    5,                        -- admin profile id
    'Not relevant'            -- admin comment (required!)
);
```

## 🧪 Примеры использования

### Пример 1: Фрилансер предлагает навык
```bash
# 1. Логин как фрилансер
TOKEN=$(curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"freelancer@example.com","password":"password"}' \
  | jq -r '.data.token')

# 2. Предложить навык
curl -X POST http://localhost:8080/api/skill-suggestions \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Rust Programming",
    "category": "Backend Development"
  }'
```

### Пример 2: Администратор одобряет предложение
```bash
# 1. Логин как админ
ADMIN_TOKEN=$(curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"password"}' \
  | jq -r '.data.token')

# 2. Просмотр pending предложений
curl -X GET "http://localhost:8080/api/skill-suggestions/admin?status=pending" \
  -H "Authorization: Bearer $ADMIN_TOKEN"

# 3. Одобрить предложение
curl -X POST http://localhost:8080/api/skill-suggestions/1/approve \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "adminComment": "Excellent suggestion! Rust is in high demand."
  }'
```

### Пример 3: Проверка своих предложений
```bash
curl -X GET http://localhost:8080/api/skill-suggestions/my \
  -H "Authorization: Bearer $TOKEN"
```

## ✅ Валидация

### При создании предложения:
- ✅ Имя навыка: 2-100 символов, обязательно
- ✅ Категория: до 100 символов, опционально
- ✅ Навык не должен уже существовать
- ✅ Не должно быть pending предложения с таким именем

### При отклонении:
- ✅ Комментарий администратора обязателен
- ✅ Предложение должно быть в статусе `pending`

### При одобрении:
- ✅ Предложение должно быть в статусе `pending`
- ✅ Комментарий администратора опционален

## 🔔 Уведомления (будущая функция)
В будущем можно добавить:
- Email уведомления пользователю при одобрении/отклонении
- Push уведомления в реальном времени
- История изменений статуса

## 📊 Метрики для мониторинга
- Среднее время рассмотрения предложения
- Процент одобренных/отклоненных предложений
- Топ категорий предлагаемых навыков
- Самые активные пользователи по предложениям

## 🚀 Миграция
Файл: `V49__skill_suggestions_system.sql`

Применяется автоматически через Flyway при перезапуске приложения:
```bash
docker-compose restart app
```

## 📚 Связанные документы
- [API_DOCUMENTATION.md](API_DOCUMENTATION.md) - Общая документация API
- [QUICK_START.md](QUICK_START.md) - Быстрый старт

## ✅ Статус
✅ Реализовано (V49)
✅ Протестировано
✅ Готово к использованию
