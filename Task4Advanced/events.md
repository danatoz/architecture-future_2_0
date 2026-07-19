# Каталог доменных событий

## Соглашения

- **Формат именования**: `{Домен}.{Агрегат}.{ДействиеВПрошедшемВремени}` (PascalCase)
- **Версионирование**: каждое событие имеет `eventVersion: int` (начинается с 1)
- **Транспорт**: Apache Kafka, топики по шаблону `{domain}.{context}.{event-name}`
- **Schema Registry**: Avro / Protobuf, все схемы зарегистрированы в Schema Registry

---

## Patient Management

### `PatientManagement.Patient.PatientRegistered`

| Поле | Тип | Описание |
|---|---|---|
| `eventId` | UUID | Идентификатор события |
| `eventVersion` | int | Версия схемы (1) |
| `occurredAt` | datetime | Время наступления |
| `patientId` | UUID | Идентификатор пациента |
| `fullName` | string | Полное имя |
| `dateOfBirth` | date | Дата рождения |
| `email` | string | Электронная почта |
| `phone` | string | Номер телефона |
| `insurancePolicyNumber` | string | Номер полиса (optional) |

**Семантика**: Пациент зарегистрирован в системе. Это базовое событие, после которого пациент может записаться на приём, получить счёт и т.д.

### `PatientManagement.Patient.PatientUpdated`

**Семантика**: Изменены персональные данные или контактная информация пациента. Содержит только изменённые поля (partial update).

---

## Appointment Scheduling

### `Scheduling.Appointment.AppointmentScheduled`

| Поле | Тип | Описание |
|---|---|---|
| `eventId` | UUID | Идентификатор события |
| `eventVersion` | int | Версия схемы (1) |
| `occurredAt` | datetime | Время наступления |
| `appointmentId` | UUID | Идентификатор записи |
| `patientId` | UUID | Пациент |
| `doctorId` | UUID | Врач |
| `scheduledTime` | datetime | Дата и время приёма |
| `appointmentType` | enum | `Consultation / Diagnosis / Procedure` |

**Семантика**: Создана запись на приём. Подписчики: Patient Management (уведомление пациента), Billing (резервирование средств).

### `Scheduling.Appointment.AppointmentCompleted`

**Семантика**: Приём завершён. Подписчики: Clinical Records (создание записи), Billing (списание средств).

### `Scheduling.Appointment.AppointmentCancelled`

**Семантика**: Приём отменён. Подписчики: Billing (отмена платежа, возврат).

---

## Clinical Records

### `Clinical.MedicalRecord.DiagnosisRecorded`

| Поле | Тип | Описание |
|---|---|---|
| `eventId` | UUID | Идентификатор события |
| `eventVersion` | int | Версия схемы (1) |
| `occurredAt` | datetime | Время наступления |
| `recordId` | UUID | Идентификатор записи |
| `patientId` | UUID | Пациент |
| `doctorId` | UUID | Врач |
| `diagnosisCode` | string | Код диагноза (ICD-10) |
| `diagnosisDescription` | string | Описание диагноза |

**Семантика**: Врач зафиксировал диагноз. Подписчик: AI Diagnostics (для сопоставления с результатами ИИ).

### `Clinical.MedicalRecord.TreatmentPrescribed`

| Поле | Тип | Описание |
|---|---|---|
| `eventId` | UUID | Идентификатор события |
| `eventVersion` | int | Версия схемы (1) |
| `occurredAt` | datetime | Время наступления |
| `recordId` | UUID | Идентификатор записи |
| `patientId` | UUID | Пациент |
| `medications` | [Medication] | Список назначенных препаратов |
| `procedures` | [Procedure] | Список назначенных процедур |

**Семантика**: Назначено лечение. Подписчики: Pharma Supply Chain (резервирование препаратов), Billing (расчёт стоимости).

---

## AI Diagnostics

### `AI.AIDiagnosticRequest.DiagnosticRequested`

| Поле | Тип | Описание |
|---|---|---|
| `eventId` | UUID | Идентификатор события |
| `eventVersion` | int | Версия схемы (1) |
| `occurredAt` | datetime | Время наступления |
| `requestId` | UUID | Идентификатор запроса |
| `patientId` | UUID | Пациент |
| `imageRef` | string | Ссылка на изображение / данные |
| `modelId` | string | Идентификатор модели ИИ |

**Семантика**: Отправлен запрос на ИИ-диагностику. Source: Appointment Scheduling или Clinical Records.

### `AI.AIDiagnosticRequest.DiagnosticCompleted`

| Поле | Тип | Описание |
|---|---|---|
| `eventId` | UUID | Идентификатор события |
| `eventVersion` | int | Версия схемы (1) |
| `occurredAt` | datetime | Время наступления |
| `requestId` | UUID | Идентификатор запроса |
| `result` | string | Результат диагностики |
| `confidenceScore` | float | Уверенность модели (0–1) |

**Семантика**: ИИ-модель завершила анализ. Подписчик: Clinical Records (сохранение результата).

---

## Billing & Payments

### `Billing.Payment.PaymentCompleted`

| Поле | Тип | Описание |
|---|---|---|
| `eventId` | UUID | Идентификатор события |
| `eventVersion` | int | Версия схемы (1) |
| `occurredAt` | datetime | Время наступления |
| `paymentId` | UUID | Идентификатор платежа |
| `amount` | decimal | Сумма |
| `currency` | string | Валюта (ISO 4217) |
| `referenceType` | enum | `Appointment / Loan / Order` |
| `referenceId` | UUID | Ссылка на связанную сущность |

**Семантика**: Платёж успешно проведён. Подписчик: Lending (обновление графика платежей по кредиту).

### `Billing.Payment.PaymentFailed`

**Семантика**: Платёж отклонён (недостаточно средств, ошибка шлюза). Подписчики: Appointment Scheduling (уведомление), Lending (пеня).

---

## Lending

### `Lending.LoanAgreement.LoanApproved`

| Поле | Тип | Описание |
|---|---|---|
| `eventId` | UUID | Идентификатор события |
| `eventVersion` | int | Версия схемы (1) |
| `occurredAt` | datetime | Время наступления |
| `loanId` | UUID | Идентификатор договора |
| `customerId` | UUID | Заёмщик |
| `approvedAmount` | decimal | Одобренная сумма |
| `interestRate` | float | Процентная ставка |

**Семантика**: Кредит одобрен. Подписчики: Account Management (зачисление), Billing (формирование графика).

### `Lending.LoanAgreement.LoanDisbursed`

**Семантика**: Средства переведены заёмщику. Подписчик: Account Management (зачисление на счёт).

---

## Pharma Supply Chain

### `Pharma.PharmaOrder.InventoryLow`

| Поле | Тип | Описание |
|---|---|---|
| `eventId` | UUID | Идентификатор события |
| `eventVersion` | int | Версия схемы (1) |
| `occurredAt` | datetime | Время наступления |
| `sku` | string | Артикул товара |
| `currentStock` | int | Текущий остаток |
| `reorderPoint` | int | Порог заказа |

**Семантика**: Уровень запасов ниже порогового значения. Подписчики: Equipment Manufacturing (остановка производства), Clinical Records (предупреждение).

---

## Data Marketplace

### `DataMarketplace.DataProduct.DataProductPublished`

| Поле | Тип | Описание |
|---|---|---|
| `eventId` | UUID | Идентификатор события |
| `eventVersion` | int | Версия схемы (1) |
| `occurredAt` | datetime | Время наступления |
| `productId` | UUID | Идентификатор Data Product |
| `ownerDomain` | string | Домен-владелец |
| `schemaRef` | string | Ссылка на схему в Schema Registry |
| `accessPolicy` | string | Политика доступа (RBAC role) |

**Семантика**: Опубликован новый Data Product. Подписчики: все домены (обновление каталога).

---

## Identity & Access

### `IAM.User.RoleAssigned`

| Поле | Тип | Описание |
|---|---|---|
| `eventId` | UUID | Идентификатор события |
| `eventVersion` | int | Версия схемы (1) |
| `occurredAt` | datetime | Время наступления |
| `userId` | UUID | Пользователь |
| `role` | string | Назначенная роль |
| `domain` | string | Домен, к которому предоставлен доступ |

**Семантика**: Пользователю назначена роль в контексте домена. Подписчики: Data Marketplace (обновление прав доступа), все защищённые контексты.
