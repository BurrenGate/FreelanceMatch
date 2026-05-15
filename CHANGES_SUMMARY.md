# Сводка изменений - FreelanceMatch

## 📝 Что было добавлено

### 1. Отклонение предложений (Reject Proposal)
Клиенты теперь могут отклонять предложения фрилансеров.

**Файлы:**
- `V27__reject_proposal_and_freelancer_profile.sql` - PL/pgSQL процедура
- `ProposalRepository.rejectProposal()` - вызов процедуры
- `ProposalService.rejectProposal()` - бизнес-логика
- `ProposalController.rejectProposal()` - REST endpoint
- `SecurityConfig` - добавлена авторизация для CLIENT

**Endpoint:** `POST /api/proposals/{proposalId}/reject`

---

### 2. Просмотр профиля фрилансера
Клиенты могут просматривать детальную информацию о фрилансерах.

**Файлы:**
- `V27__reject_proposal_and_freelancer_profile.sql` - PL/pgSQL функции:
  - `get_freelancer_profile()` - основная информация + статистика
  - `get_freelancer_skills()` - навыки фрилансера
  - `get_freelancer_reviews()` - отзывы о фрилансере
  
- `V29__fix_freelancer_profile_functions.sql` - исправления и улучшения:
  - Исправлена `get_freelancer_reviews()` (убрана зависимость от transactions)
  - Улучшена `get_freelancer_profile()` (добавлены fullName, accountStatus)
  - Добавлена колонка `created_at` в таблицу `contracts`

**DTO:**
- `FreelancerProfileDTO` - полный профиль
- `FreelancerSkillDTO` - навыки
- `FreelancerReviewDTO` - отзывы

**Repository:**
- `FreelancerProfileRepository` - вызовы PL/pgSQL функций

**Service:**
- `FreelancerProfileService` - сборка полного профиля

**Controller:**
- `FreelancerProfileController` - REST endpoint

**Endpoint:** `GET /api/freelancers/{freelancerId}/profile`

**Возвращаемые данные:**
- Личная информация (имя, email, bio, avatar)
- Финансовая информация (hourly_rate, total_earnings)
- Статистика (rating, completed_jobs, active_jobs, total_reviews)
- Доступность (is_available)
- Даты (member_since, last_login)
- Статус аккаунта (account_status)
- Список навыков с уровнями
- Последние 10 отзывов

---

### 3. Предложения с данными фрилансеров
Клиенты могут видеть предложения вместе с информацией о фрилансерах.

**Файлы:**
- `V29__fix_freelancer_profile_functions.sql` - функция `get_proposals_with_freelancer_details()`
- `ProposalWithFreelancerDTO` - DTO для предложения с данными фрилансера
- `ProposalRepository.findProposalsWithFreelancerDetails()` - вызов функции
- `ProposalService.getProposalsWithFreelancerDetails()` - бизнес-логика
- `ProposalController` - новый endpoint

**Endpoint:** `GET /api/proposals/job/{jobId}/with-freelancer`

**Возвращаемые данные для каждого предложения:**
- Данные предложения (bid_amount, cover_letter, status, etc.)
- Имя фрилансера
- Email фрилансера
- Hourly rate
- Avatar URL
- Рейтинг
- Количество завершенных работ

---

### 4. Исправление процедуры finalize_proposal_and_create_contract

**Проблема:** Процедура пыталась вставить данные в несуществующие колонки `client_id` и `contract_value`.

**Решение:** `V28__fix_finalize_proposal_procedure.sql`
- Использует правильные колонки: `job_id`, `freelancer_id`, `total_amount`, `status`
- Добавлена проверка статуса предложения
- Улучшена обработка ошибок

---

## 📂 Структура новых файлов

```
src/main/
├── java/sdu/database/piedpiper/
│   ├── controller/
│   │   └── FreelancerProfileController.java (NEW)
│   ├── dto/response/
│   │   ├── FreelancerProfileDTO.java (NEW)
│   │   ├── FreelancerSkillDTO.java (NEW)
│   │   ├── FreelancerReviewDTO.java (NEW)
│   │   └── ProposalWithFreelancerDTO.java (NEW)
│   ├── repository/
│   │   ├── FreelancerProfileRepository.java (NEW)
│   │   └── ProposalRepository.java (UPDATED)
│   ├── service/
│   │   ├── FreelancerProfileService.java (NEW)
│   │   └── ProposalService.java (UPDATED)
│   └── security/
│       └── SecurityConfig.java (UPDATED)
└── resources/db/migration/
    ├── V27__reject_proposal_and_freelancer_profile.sql (NEW)
    ├── V28__fix_finalize_proposal_procedure.sql (NEW)
    └── V29__fix_freelancer_profile_functions.sql (NEW)

Документация:
├── API_DOCUMENTATION.md (NEW)
└── QUICK_START.md (NEW)
```

---

## 🔐 Безопасность

**Обновлена конфигурация SecurityConfig:**
- `/api/proposals/*/reject` - только CLIENT
- `/api/proposals/*/accept` - только CLIENT
- `/api/freelancers/*/profile` - все авторизованные пользователи

---

## 🗄️ База данных

**Новые функции в схеме `job_market`:**
1. `reject_proposal(p_proposal_id)` - PROCEDURE
2. `get_freelancer_profile(p_freelancer_id)` - FUNCTION
3. `get_freelancer_skills(p_freelancer_id)` - FUNCTION
4. `get_freelancer_reviews(p_freelancer_id, p_limit)` - FUNCTION
5. `get_proposals_with_freelancer_details(p_job_id)` - FUNCTION

**Изменения в таблицах:**
- `contracts` - добавлена колонка `created_at TIMESTAMP DEFAULT NOW()`

**Исправленные процедуры:**
- `finalize_proposal_and_create_contract()` - использует правильные колонки

---

## ✅ Тестирование

Все изменения следуют архитектуре проекта:
- ✅ Вся бизнес-логика в PL/pgSQL
- ✅ Spring используется только как посредник
- ✅ Соблюдена структура проекта
- ✅ Добавлена авторизация
- ✅ Логирование
- ✅ Обработка ошибок

---

## 🚀 Запуск

```bash
# Перезапустить приложение для применения миграций
docker-compose down
docker-compose up --build

# Или локально
mvn clean install
mvn spring-boot:run
```

Flyway автоматически применит миграции V27, V28, V29.

---

## 📊 API Endpoints Summary

| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| POST | `/api/proposals/{id}/reject` | CLIENT | Отклонить предложение |
| POST | `/api/proposals/{id}/accept` | CLIENT | Принять предложение |
| GET | `/api/freelancers/{id}/profile` | ALL | Просмотр профиля фрилансера |
| GET | `/api/proposals/job/{id}/with-freelancer` | ALL | Предложения с данными фрилансеров |

---

## 🎯 Результат

Теперь клиенты могут:
1. ✅ Просматривать детальные профили фрилансеров
2. ✅ Видеть все данные фрилансера (имя, email, рейтинг, навыки, отзывы)
3. ✅ Принимать предложения (создается контракт)
4. ✅ Отклонять предложения
5. ✅ Видеть предложения вместе с информацией о фрилансерах

Все работает через PL/pgSQL, Spring только передает данные! 🎉
