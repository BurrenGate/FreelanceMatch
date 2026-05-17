# Milestone-Based Payments Documentation

## 📝 Обзор

Система частичной оплаты контрактов через milestones (этапы). Позволяет разбить контракт на несколько этапов и оплачивать каждый этап отдельно по мере выполнения работы.

## 🎯 Концепция

**Milestone (Этап)** - это часть работы по контракту с:
- Названием и описанием
- Суммой оплаты
- Сроком выполнения (опционально)
- Статусом (pending, in_progress, completed, paid)

## 🗄️ База данных

### Таблица contract_milestones:
- `id` - ID этапа
- `contract_id` - ID контракта
- `title` - Название этапа
- `description` - Описание
- `amount` - Сумма оплаты
- `status` - Статус (pending, in_progress, completed, paid)
- `due_date` - Срок выполнения
- `completed_at` - Время завершения
- `paid_at` - Время оплаты
- `created_at` - Время создания

### Новые поля в contracts:
- `paid_amount` - Уже оплаченная сумма
- `remaining_amount` - Остаток к оплате

### PL/pgSQL Функции:

1. **create_milestone** - Создать этап
2. **update_milestone_status** - Обновить статус этапа
3. **pay_milestone** - Оплатить завершенный этап
4. **get_contract_milestones** - Получить все этапы контракта
5. **get_contract_payment_summary** - Получить сводку по оплатам

---

## 🔌 API Endpoints

### 1. Создать этап
**POST** `/api/contracts/{contractId}/milestones`

**Request Body:**
```json
{
  "title": "Design Phase",
  "description": "Create UI/UX designs and mockups",
  "amount": 1500.00,
  "dueDate": "2024-02-15"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Milestone created successfully",
  "data": {
    "milestoneId": 123
  }
}
```

**Ограничения:**
- Контракт должен быть активным
- Сумма всех этапов не может превышать сумму контракта
- Название обязательно
- Сумма должна быть больше нуля

---

### 2. Получить все этапы контракта
**GET** `/api/contracts/{contractId}/milestones`

**Response:**
```json
{
  "success": true,
  "message": "Retrieved 3 milestone(s)",
  "data": [
    {
      "milestoneId": 123,
      "title": "Design Phase",
      "description": "Create UI/UX designs and mockups",
      "amount": 1500.00,
      "status": "completed",
      "dueDate": "2024-02-15",
      "completedAt": "2024-02-14T15:30:00",
      "paidAt": null,
      "createdAt": "2024-01-20T10:00:00"
    },
    {
      "milestoneId": 124,
      "title": "Development Phase",
      "description": "Implement frontend and backend",
      "amount": 2500.00,
      "status": "in_progress",
      "dueDate": "2024-03-01",
      "completedAt": null,
      "paidAt": null,
      "createdAt": "2024-01-20T10:05:00"
    }
  ]
}
```

---

### 3. Получить сводку по оплатам
**GET** `/api/contracts/{contractId}/payment-summary`

**Response:**
```json
{
  "success": true,
  "message": "Payment summary retrieved successfully",
  "data": {
    "contractId": 5,
    "totalAmount": 5000.00,
    "paidAmount": 1500.00,
    "remainingAmount": 3500.00,
    "totalMilestones": 3,
    "pendingMilestones": 0,
    "completedMilestones": 1,
    "paidMilestones": 1
  }
}
```

---

### 4. Обновить статус этапа
**PUT** `/api/contracts/{contractId}/milestones/{milestoneId}/status`

**Request Body:**
```json
{
  "status": "completed"
}
```

**Возможные статусы:**
- `pending` - Ожидает начала
- `in_progress` - В работе
- `completed` - Завершен (готов к оплате)
- `paid` - Оплачен

**Response:**
```json
{
  "success": true,
  "message": "Milestone status updated to completed",
  "data": {
    "status": "completed"
  }
}
```

---

### 5. Оплатить этап
**POST** `/api/contracts/{contractId}/milestones/{milestoneId}/pay`

**Response:**
```json
{
  "success": true,
  "message": "Milestone paid successfully. Transaction created.",
  "data": {
    "transactionId": 456
  }
}
```

**Что происходит:**
1. Создается транзакция типа `milestone_payment`
2. Статус этапа меняется на `paid`
3. Обновляется `paid_amount` и `remaining_amount` в контракте

**Ограничения:**
- Этап должен быть в статусе `completed`
- Оплачивать может только клиент
- Пользователь должен быть участником контракта

---

## 🔄 Workflow

### Типичный сценарий использования:

```
1. Контракт создан (total_amount = 5000)
   ↓
2. Создаются этапы:
   - Design: 1500
   - Development: 2500
   - Testing: 1000
   ↓
3. Фрилансер работает над Design
   - Статус: pending → in_progress
   ↓
4. Фрилансер завершает Design
   - Статус: in_progress → completed
   ↓
5. Клиент проверяет и оплачивает
   - Статус: completed → paid
   - paid_amount: 0 → 1500
   - remaining_amount: 5000 → 3500
   ↓
6. Повторяется для следующих этапов
```

---

## 🧪 Примеры использования

### Сценарий 1: Создание этапов для контракта

```bash
# 1. Создать первый этап
curl -X POST http://localhost:8080/api/contracts/5/milestones \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Design Phase",
    "description": "UI/UX design and mockups",
    "amount": 1500.00,
    "dueDate": "2024-02-15"
  }'

# 2. Создать второй этап
curl -X POST http://localhost:8080/api/contracts/5/milestones \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Development Phase",
    "description": "Frontend and backend implementation",
    "amount": 2500.00,
    "dueDate": "2024-03-01"
  }'

# 3. Создать третий этап
curl -X POST http://localhost:8080/api/contracts/5/milestones \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Testing Phase",
    "description": "QA and bug fixes",
    "amount": 1000.00,
    "dueDate": "2024-03-15"
  }'
```

---

### Сценарий 2: Работа над этапом и оплата

```bash
# 1. Фрилансер начинает работу
curl -X PUT http://localhost:8080/api/contracts/5/milestones/123/status \
  -H "Authorization: Bearer FREELANCER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "in_progress"}'

# 2. Фрилансер завершает работу
curl -X PUT http://localhost:8080/api/contracts/5/milestones/123/status \
  -H "Authorization: Bearer FREELANCER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "completed"}'

# 3. Клиент проверяет сводку
curl -X GET http://localhost:8080/api/contracts/5/payment-summary \
  -H "Authorization: Bearer CLIENT_TOKEN"

# 4. Клиент оплачивает этап
curl -X POST http://localhost:8080/api/contracts/5/milestones/123/pay \
  -H "Authorization: Bearer CLIENT_TOKEN"
```

---

### Сценарий 3: Просмотр всех этапов

```bash
# Получить все этапы контракта
curl -X GET http://localhost:8080/api/contracts/5/milestones \
  -H "Authorization: Bearer TOKEN"

# Response покажет:
# - Какие этапы завершены
# - Какие в работе
# - Какие оплачены
# - Сроки выполнения
```

---

## 🎨 Frontend интеграция

### Пример React компонента:

```javascript
const MilestoneManager = ({ contractId }) => {
  const [milestones, setMilestones] = useState([]);
  const [summary, setSummary] = useState(null);

  // Загрузить этапы
  const fetchMilestones = async () => {
    const response = await fetch(`/api/contracts/${contractId}/milestones`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    const data = await response.json();
    setMilestones(data.data);
  };

  // Загрузить сводку
  const fetchSummary = async () => {
    const response = await fetch(`/api/contracts/${contractId}/payment-summary`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    const data = await response.json();
    setSummary(data.data);
  };

  // Создать этап
  const createMilestone = async (milestone) => {
    await fetch(`/api/contracts/${contractId}/milestones`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(milestone)
    });
    fetchMilestones();
    fetchSummary();
  };

  // Обновить статус
  const updateStatus = async (milestoneId, status) => {
    await fetch(`/api/contracts/${contractId}/milestones/${milestoneId}/status`, {
      method: 'PUT',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ status })
    });
    fetchMilestones();
  };

  // Оплатить этап
  const payMilestone = async (milestoneId) => {
    await fetch(`/api/contracts/${contractId}/milestones/${milestoneId}/pay`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${token}` }
    });
    fetchMilestones();
    fetchSummary();
  };

  return (
    <div>
      {/* Payment Summary */}
      {summary && (
        <div className="payment-summary">
          <h3>Payment Summary</h3>
          <p>Total: ${summary.totalAmount}</p>
          <p>Paid: ${summary.paidAmount}</p>
          <p>Remaining: ${summary.remainingAmount}</p>
          <ProgressBar 
            value={summary.paidAmount} 
            max={summary.totalAmount} 
          />
        </div>
      )}

      {/* Milestones List */}
      <div className="milestones">
        {milestones.map(milestone => (
          <MilestoneCard
            key={milestone.milestoneId}
            milestone={milestone}
            onUpdateStatus={updateStatus}
            onPay={payMilestone}
          />
        ))}
      </div>

      {/* Create Milestone Button */}
      <button onClick={() => setShowCreateModal(true)}>
        Add Milestone
      </button>
    </div>
  );
};
```

---

## 🔐 Безопасность

- Все endpoints требуют JWT аутентификации
- Пользователь должен быть участником контракта
- Только клиент может оплачивать этапы
- Сумма всех этапов не может превышать сумму контракта

---

## 💡 Преимущества

1. **Снижение рисков** - Клиент платит по мере выполнения работы
2. **Мотивация** - Фрилансер получает оплату за каждый завершенный этап
3. **Прозрачность** - Обе стороны видят прогресс и оплаты
4. **Гибкость** - Можно создавать любое количество этапов
5. **Контроль** - Клиент проверяет работу перед оплатой каждого этапа

---

## 📊 Статусы этапов

| Статус | Описание | Кто меняет |
|--------|----------|------------|
| `pending` | Ожидает начала | Любой участник |
| `in_progress` | В работе | Обычно фрилансер |
| `completed` | Завершен, готов к оплате | Обычно фрилансер |
| `paid` | Оплачен | Автоматически при оплате |

---

## ⚠️ Важные моменты

1. **Сумма этапов**: Сумма всех этапов не должна превышать сумму контракта
2. **Оплата**: Можно оплатить только завершенные этапы (status = completed)
3. **Транзакции**: При оплате создается транзакция типа `milestone_payment`
4. **Прогресс**: `paid_amount` и `remaining_amount` обновляются автоматически
