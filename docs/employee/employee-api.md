# Employee Portal APIs (Self-Service)

Base prefix: `/api/emp`
Auth: **Requires ROLE_EMP JWT** (from employee login)
All endpoints automatically scope to the logged-in employee — no `companyId` or `employeeId` in the URL.

### 18. Create Work Log
- API: `POST /api/companies/{companyId}/modemp/work-logs`
- Request example:

```http
POST /api/companies/1/modemp/work-logs
Content-Type: application/json
```

```json
{
  "employeeId": 101,
  "workDefId": 201,
  "logDate": "2026-04-03",
  "quantity": 125.5,
  "employeeRemarks": "Completed morning shift"
}
```

- Response example:

```json
{
  "responseStatus": true,
  "responseCode": 201,
  "responseMessage": "Work log created successfully",
  "responseData": {
    "logId": 701
  }
}
```

- Validation rules:
  - Work log creation is blocked if salary is already calculated for that employee on `logDate`.
  - This applies to both admin and employee initiated create requests.
  - Use admin salary-adjustment API (with reason) to make post-salary corrections.

- Locked-date error example:

```json
{
  "responseStatus": false,
  "responseCode": 406,
  "responseMessage": "Cannot create work log for 2026-04-03 because salary is already calculated for this date. Please Contact the admin to adjustment  salary .",
  "responseData": null
}
```
### 23. Create Leave Log
- API: `POST /api/companies/{companyId}/modemp/leave-logs`
- Request example:

```http
POST /api/companies/1/modemp/leave-logs
Content-Type: application/json
```

```json
{
  "employeeId": 101,
  "leaveDate": "2026-04-07",
  "leaveType": "FULL_DAY",
  "leaveCategory": "SICK",
  "reason": "Fever"
}
```

- Response example:

```json
{
  "responseStatus": true,
  "responseCode": 201,
  "responseMessage": "Leave log created successfully",
  "responseData": {
    "leaveId": 801
  }
}
```

- Validation rules:
  - Leave log creation is blocked if salary is already calculated for that employee on `leaveDate`.
  - This applies to both admin and employee initiated create requests.
  - Use admin salary-adjustment API (with reason) to make post-salary corrections.

- Locked-date error example:

```json
{
  "responseStatus": false,
  "responseCode": 406,
  "responseMessage": "Cannot create leave log for 2026-04-07 because salary is already calculated for this date. Please Contact the admin to adjustment  salary .",
  "responseData": null
}
```

### 22a. Update Work Log (employee self-service)
- API: `PUT /api/companies/{companyId}/modemp/work-logs/employee`
- Auth: **Requires ROLE_EMP JWT**
- Allowed only when the existing work log status is **not** `APPROVED`.
- Identifies the row by `(employeeId, workDefId, logDate)`.
- The `employeeId` in the body must match the logged-in employee.
- Request example:

```http
PUT /api/companies/1/modemp/work-logs/employee
Authorization: Bearer <employee-jwt>
Content-Type: application/json
```

```json
{
  "employeeId": 3,
  "workDefId": 1,
  "logDate": "2026-04-14",
  "quantity": 60.0,
  "employeeRemarks": "Completed morning shift"
}
```

- Response example:

```json
{
  "responseStatus": true,
  "responseCode": 203,
  "responseMessage": "Work log updated successfully",
  "responseData": null
}
```

- Rejection example (already approved):

```json
{
  "responseStatus": false,
  "responseCode": 406,
  "responseMessage": "Cannot update an APPROVED work log",
  "responseData": null
}
```
### 27a. Update Leave Log (employee self-service)
- API: `PUT /api/companies/{companyId}/modemp/leave-logs/employee`
- Auth: **Requires ROLE_EMP JWT**
- Allowed only when the existing leave log status is **not** `APPROVED`.
- Identifies the row by `(employeeId, leaveDate)`.
- The `employeeId` in the body must match the logged-in employee.
- Request example:

```http
PUT /api/companies/1/modemp/leave-logs/employee
Authorization: Bearer <employee-jwt>
Content-Type: application/json
```

```json
{
  "employeeId": 3,
  "leaveDate": "2026-04-21",
  "leaveType": "FULL_DAY",
  "leaveCategory": "SICK",
  "reason": "Fever"
}
```

- Response example:

```json
{
  "responseStatus": true,
  "responseCode": 203,
  "responseMessage": "Leave log updated successfully",
  "responseData": null
}
```

- Rejection example (already approved):

```json
{
  "responseStatus": false,
  "responseCode": 406,
  "responseMessage": "Cannot update an APPROVED leave log",
  "responseData": null
}
```

### 37. Get My Profile
- API: `GET /api/emp/me`
- Request example:

```http
GET /api/emp/me
Authorization: Bearer <employee-jwt>
```

- Response example:

```json
{
  "responseStatus": true,
  "responseCode": 202,
  "responseMessage": "Profile retrieved successfully",
  "responseData": {
    "employeeId": 101,
    "employeeCode": "EMP-001",
    "employeeName": "Ravi Kumar",
    "phone": "9876543210",
    "email": "ravi@company.com",
    "designation": "Machine Operator",
    "joinedDt": "2026-01-10",
    "isActive": true,
    "currentSalaryType": "MONTHLY",
    "currentMonthlyAmount": 28000,
    "salaryConfigHistory": [ "..." ]
  }
}
```

### 38. Get My Salary Periods
- API: `GET /api/emp/salary/periods?from={YYYY-MM-DD}&to={YYYY-MM-DD}`
- Either `from`/`to` (preferred) or legacy `period={YYYYMM}` is accepted.
- Request example:

```http
GET /api/emp/salary/periods?from=2026-04-01&to=2026-04-30
Authorization: Bearer <employee-jwt>
```

- Response example: same shape as API #29, filtered to the logged-in employee only.

### 39. Get My Salary Detail
- API: `GET /api/emp/salary/periods/{salaryPeriodId}`
- Request example:

```http
GET /api/emp/salary/periods/901
Authorization: Bearer <employee-jwt>
```

- Response example: same shape as API #30.
- Returns `403` if the salary period does not belong to the logged-in employee.

### 40. Download My Salary Slip (PDF)
- API: `GET /api/emp/salary/periods/{salaryPeriodId}/slip`
- Request example:

```http
GET /api/emp/salary/periods/901/slip
Authorization: Bearer <employee-jwt>
```

- Response: Binary PDF file. Returns `403` if the salary period does not belong to the logged-in employee.

### 41. Get My Work Logs
- API: `GET /api/emp/work-logs?from={YYYY-MM-DD}&to={YYYY-MM-DD}`
- Request example:

```http
GET /api/emp/work-logs?from=2026-04-01&to=2026-04-30
Authorization: Bearer <employee-jwt>
```

- Response example: same `WorkLogDto[]` shape as API #19, filtered to the logged-in employee.

### 42. Get My Leave Logs
- API: `GET /api/emp/leave-logs?from={YYYY-MM-DD}&to={YYYY-MM-DD}`
- Request example:

```http
GET /api/emp/leave-logs?from=2026-04-01&to=2026-04-30
Authorization: Bearer <employee-jwt>
```

- Response example: same `LeaveLogDto[]` shape as API #24, filtered to the logged-in employee.
