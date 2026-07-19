# Event Storming — событийная архитектура «Будущее 2.0»

## Условные обозначения

- 🟦 **Command** — команда, инициирующая действие
- 🟩 **Event** — доменное событие, факт, произошедший в системе
- 🟧 **Aggregate** — агрегат, в рамках которого происходит событие
- 🟥 **External System** — внешняя система (легаси)

## Поток событий

```mermaid
flowchart LR
    subgraph "Patient Management"
        PR[("Patient<br/>Aggregate")]
        PC1[/"RegisterPatient"\]
        PE1>"PatientRegistered"]
    end

    subgraph "Appointment Scheduling"
        AP[("Appointment<br/>Aggregate")]
        AC1[/"ScheduleAppointment"\]
        AC2[/"CompleteAppointment"\]
        AE1>"AppointmentScheduled"]
        AE2>"AppointmentCompleted"]
        AE3>"AppointmentCancelled"]
    end

    subgraph "Clinical Records"
        CR[("MedicalRecord<br/>Aggregate")]
        CC1[/"RecordDiagnosis"\]
        CE1>"DiagnosisRecorded"]
        CE2>"TreatmentPrescribed"]
    end

    subgraph "Billing & Payments"
        BP[("Payment<br/>Aggregate")]
        BC1[/"ProcessPayment"\]
        BE1>"PaymentInitiated"]
        BE2>"PaymentCompleted"]
        BE3>"PaymentFailed"]
    end

    subgraph "AI Diagnostics"
        AD[("AIDiagnosticRequest<br/>Aggregate")]
        AC3[/"RequestDiagnostic"\]
        AE4>"DiagnosticRequested"]
        AE5>"DiagnosticCompleted"]
    end

    subgraph "Lending"
        LN[("LoanAgreement<br/>Aggregate")]
        LC1[/"ApplyForLoan"\]
        LC2[/"ApproveLoan"\]
        LE1>"LoanApplicationSubmitted"]
        LE2>"LoanApproved"]
        LE3>"LoanDisbursed"]
    end

    subgraph "Pharma Supply Chain"
        PS[("PharmaOrder<br/>Aggregate")]
        PC2[/"PlaceOrder"\]
        PE2>"OrderPlaced"]
        PE3>"OrderShipped"]
        PE4>"InventoryLow"]
    end

    subgraph "Data Marketplace"
        DM[("DataProduct<br/>Aggregate")]
        DC1[/"PublishDataProduct"\]
        DE1>"DataProductPublished"]
        DE2>"DataProductDeprecated"]
    end

    PC1 --> PE1
    PE1 -.->|Event Bus| AP
    PE1 -.->|Event Bus| BP
    PE1 -.->|Event Bus| CR

    AC2 --> AE2
    AE2 -.->|Event Bus| CR
    AE2 -.->|Event Bus| BP

    CC1 --> CE1
    CE1 -.->|Event Bus| AD

    CC1 --> CE2
    CE2 -.->|Event Bus| PS

    AC3 --> AE4
    AE4 -.->|Event Bus| AD

    AE5 -.->|Event Bus| CR

    BC1 --> BE2
    BE2 -.->|Event Bus| LN

    LC2 --> LE2
    LE2 -.->|Event Bus| BP

    PC2 --> PE2
    PE2 -.->|Event Bus| BP

    DC1 --> DE1
    DE1 -.->|Event Bus| PC
    DE1 -.->|Event Bus| BP
    DE1 -.->|Event Bus| LN
```

## Таблица событий

| Событие | Контекст-источник | Команда-триггер | Подписчики |
|---|---|---|---|
| PatientRegistered | Patient Management | RegisterPatient | Appointment Scheduling, Billing & Payments, Clinical Records |
| AppointmentScheduled | Appointment Scheduling | ScheduleAppointment | Patient Management (уведомление) |
| AppointmentCompleted | Appointment Scheduling | CompleteAppointment | Clinical Records, Billing & Payments |
| AppointmentCancelled | Appointment Scheduling | CancelAppointment | Billing & Payments |
| DiagnosisRecorded | Clinical Records | RecordDiagnosis | AI Diagnostics |
| TreatmentPrescribed | Clinical Records | PrescribeTreatment | Pharma Supply, Billing & Payments |
| PaymentInitiated | Billing & Payments | InitiatePayment | — (внутреннее) |
| PaymentCompleted | Billing & Payments | ProcessPayment | Lending |
| PaymentFailed | Billing & Payments | ProcessPayment | Lending, Appointment Scheduling |
| DiagnosticRequested | Appointment Scheduling | RequestDiagnostic | AI Diagnostics |
| DiagnosticCompleted | AI Diagnostics | CompleteDiagnostic | Clinical Records |
| LoanApplicationSubmitted | Lending | ApplyForLoan | — (внутреннее) |
| LoanApproved | Lending | ApproveLoan | Account Management, Billing & Payments |
| LoanDisbursed | Lending | DisburseLoan | Account Management |
| OrderPlaced | Pharma Supply Chain | PlaceOrder | Billing & Payments |
| OrderShipped | Pharma Supply Chain | ShipOrder | Equipment Manufacturing |
| InventoryLow | Pharma Supply Chain | — (автоматическое) | Equipment Manufacturing, Clinical Records |
| DataProductPublished | Data Marketplace | PublishDataProduct | Все домены (уведомление) |
| DataProductDeprecated | Data Marketplace | DeprecateDataProduct | Все домены (уведомление) |
| UserLoggedIn | Identity & Access | Authenticate | Data Marketplace (аудит) |
| RoleAssigned | Identity & Access | AssignRole | Все защищённые контексты |
