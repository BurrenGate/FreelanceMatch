# Быстрый старт - Тестирование новых функций

## 🚀 Запуск приложения

```bash
# Остановить контейнеры (если запущены)
docker-compose down

# Пересобрать и запустить
docker-compose up --build
```

Или локально:
```bash
mvn clean install
mvn spring-boot:run
```

## 📋 Миграции будут применены автоматически:
- V27: Reject proposal + Freelancer profile functions
- V28: Fix finalize_proposal_and_create_contract
- V29: Fix get_freelancer_reviews + Proposals with freelancer details

---

## 🧪 Тестирование API

### 1. Логин (получить JWT токен)

**CLIENT:**
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "bob.johnson2@gmail.com",
    "password": "961cd8d3f2521783015b97fe1a80c721"
  }'
```

Сохраните токен из ответа: `"data": "eyJhbGc..."`

---

### 2. Просмотр предложений с данными фрилансеров

```bash
curl -X GET http://localhost:8080/api/proposals/job/{JOB_ID}/with-freelancer \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Пример:**
```bash
curl -X GET http://localhost:8080/api/proposals/job/1/with-freelancer \
  -H "Authorization: Bearer eyJhbGc..."
```

---

### 3. Просмотр профиля фрилансера

```bash
curl -X GET http://localhost:8080/api/freelancers/{FREELANCER_ID}/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Пример:**
```bash
curl -X GET http://localhost:8080/api/freelancers/5/profile \
  -H "Authorization: Bearer eyJhbGc..."
```

---

### 4. Принять предложение (CLIENT only)

```bash
curl -X POST http://localhost:8080/api/proposals/{PROPOSAL_ID}/accept \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Пример:**
```bash
curl -X POST http://localhost:8080/api/proposals/67/accept \
  -H "Authorization: Bearer eyJhbGc..."
```

---

### 5. Отклонить предложение (CLIENT only)

```bash
curl -X POST http://localhost:8080/api/proposals/{PROPOSAL_ID}/reject \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Пример:**
```bash
curl -X POST http://localhost:8080/api/proposals/67/reject \
  -H "Authorization: Bearer eyJhbGc..."
```

---

## 🌐 Swagger UI

Откройте в браузере:
```
http://localhost:8080/swagger-ui.html
```

Там можно протестировать все эндпоинты через UI.

---

## 📊 Проверка данных в БД

```bash
# Подключиться к PostgreSQL
docker exec -it freelancematch-db-1 psql -U user -d freelance

# Проверить предложения
SELECT id, job_id, freelancer_id, status FROM proposals;

# Проверить контракты
SELECT id, job_id, freelancer_id, status, created_at FROM contracts;

# Проверить профили
SELECT id, first_name, last_name, hourly_rate FROM profiles;
```

---

## ✅ Что должно работать:

1. ✅ Клиент может просматривать предложения с полной информацией о фрилансерах
2. ✅ Клиент может просматривать детальный профиль фрилансера (навыки, отзывы, статистика)
3. ✅ Клиент может принять предложение (создается контракт)
4. ✅ Клиент может отклонить предложение (статус меняется на 'rejected')
5. ✅ Все данные фрилансера доступны (имя, email, рейтинг, заработок и т.д.)

---

## 🐛 Если возникли проблемы:

1. Проверьте логи:
```bash
docker-compose logs -f app
```

2. Проверьте, что миграции применились:
```bash
docker exec -it freelancematch-db-1 psql -U user -d freelance -c "SELECT version FROM flyway_schema_history ORDER BY installed_rank DESC LIMIT 5;"
```

Должны быть версии: V27, V28, V29

3. Проверьте, что функции созданы:
```bash
docker exec -it freelancematch-db-1 psql -U user -d freelance -c "\df job_market.*"
```
