## Dashboard KPI
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/dashboard/kpi?startDate=2025-10-31&endDate=2026-10-31
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Dashboard KPI retrieved",
  "responseData": {
    "totalRevenue": 211791.0,
    "totalExpense": 169141.0,
    "netProfit": 42650.0,
    "totalSalesOrders": 17,
    "totalPurchaseOrders": 15,
    "totalPaymentsReceived": 6,
    "totalPaymentsMade": 9,
    "avgOrderValue": 11904.125,
    "outstandingReceivables": 9267.0,
    "outstandingPayables": 162476.0
  }
}
```
## Cash flow
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/dashboard/cash-flow?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Cash flow retrieved",
  "responseData": [
    {
      "month": "2026-01",
      "openingBalance": -29239.0,
      "incoming": 0.0,
      "outgoing": 0.0,
      "closingBalance": -29239.0
    },
    {
      "month": "2026-02",
      "openingBalance": -29239.0,
      "incoming": 18000.0,
      "outgoing": 1500.0,
      "closingBalance": -12739.0
    },
    {
      "month": "2026-03",
      "openingBalance": -12739.0,
      "incoming": 211574.0,
      "outgoing": 72580.0,
      "closingBalance": 126255.0
    }
  ]
}
```

## Revenue vs expense
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/dashboard/revenue-expense?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Revenue vs expense retrieved",
  "responseData": [
    {
      "month": "2026-01",
      "revenue": 0.0,
      "expense": 0.0,
      "netProfit": 0.0,
      "runningRevenue": 0.0,
      "runningExpense": 0.0,
      "runningNetProfit": 0.0
    },
    {
      "month": "2026-02",
      "revenue": 205242.0,
      "expense": 148039.0,
      "netProfit": 57203.0,
      "runningRevenue": 205242.0,
      "runningExpense": 148039.0,
      "runningNetProfit": 57203.0
    },
    {
      "month": "2026-03",
      "revenue": 6549.0,
      "expense": 21102.0,
      "netProfit": -14553.0,
      "runningRevenue": 211791.0,
      "runningExpense": 169141.0,
      "runningNetProfit": 42650.0
    }
  ]
}
```

## Sales summary
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/sales/summary?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Sales summary retrieved",
  "responseData": {
    "totalOrders": 17,
    "totalAmount": 211791.0,
    "totalPaid": 202524.0,
    "totalDue": 9267.0,
    "avgOrderValue": 12458.29411764706
  }
}
```

## Purchase summary
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/purchase/summary?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Purchase summary retrieved",
  "responseData": {
    "totalOrders": 15,
    "totalAmount": 169141.0,
    "totalPaid": 6665.0,
    "totalDue": 162476.0,
    "avgOrderValue": 11276.066666666668
  }
}
```

## Sales order frequency
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/sales/order-frequency?startDate=2026-01-01&endDate=2026-03-29
```json

{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Sales order frequency retrieved",
  "responseData": [
    {
      "month": "2026-02",
      "orderCount": 4
    },
    {
      "month": "2026-03",
      "orderCount": 13
    }
  ]
}
```

## Purchase order frequency
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/purchase/order-frequency?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Purchase order frequency retrieved",
  "responseData": [
    {
      "month": "2026-02",
      "orderCount": 11
    },
    {
      "month": "2026-03",
      "orderCount": 4
    }
  ]
}
```

## Sales payment frequency
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/sales/payment-frequency?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Sales payment frequency retrieved",
  "responseData": [
    {
      "month": "2026-02",
      "paymentCount": 1
    },
    {
      "month": "2026-03",
      "paymentCount": 5
    }
  ]
}
```

## Purchase payment frequency
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/purchase/payment-frequency?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Purchase payment frequency retrieved",
  "responseData": [
    {
      "month": "2026-02",
      "paymentCount": 1
    },
    {
      "month": "2026-03",
      "paymentCount": 8
    }
  ]
}
```

## Sales item frequency
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/sales/item-frequency?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Sales item frequency retrieved",
  "responseData": [
    {
      "itemId": 7,
      "itemName": "24 Gauge GI Wire",
      "totalQuantity": 39.0,
      "orderCount": 8
    },
    {
      "itemId": 5,
      "itemName": "Coconut Fibre 4 Ply",
      "totalQuantity": 8.0,
      "orderCount": 3
    }
  ]
}
```

## Purchase item frequency
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/purchase/item-frequency?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Purchase item frequency retrieved",
  "responseData": [
    {
      "itemId": 31,
      "itemName": "app",
      "totalQuantity": 15.0,
      "orderCount": 2
    },
    {
      "itemId": 27,
      "itemName": "AM",
      "totalQuantity": 10.0,
      "orderCount": 2
    }
  ]
}
```

## Sales running order amount
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/sales/running-order-amount?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Sales running order amount retrieved",
  "responseData": [
    {
      "month": "2026-02",
      "cumulativeAmount": 205242.0
    },
    {
      "month": "2026-03",
      "cumulativeAmount": 211791.0
    }
  ]
}
```

## Purchase running order amount
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/purchase/running-order-amount?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Purchase running order amount retrieved",
  "responseData": [
    {
      "month": "2026-02",
      "cumulativeAmount": 148039.0
    },
    {
      "month": "2026-03",
      "cumulativeAmount": 169141.0
    }
  ]
}
```

## Sales running payment amount
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/sales/running-payment-amount?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Sales running payment amount retrieved",
  "responseData": [
    {
      "month": "2026-02",
      "cumulativeAmount": 18000.0
    },
    {
      "month": "2026-03",
      "cumulativeAmount": 229574.0
    }
  ]
}
```

## Purchase running payment amount
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/purchase/running-payment-amount?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Purchase running payment amount retrieved",
  "responseData": [
    {
      "month": "2026-02",
      "cumulativeAmount": 1500.0
    },
    {
      "month": "2026-03",
      "cumulativeAmount": 74080.0
    }
  ]
}
```

## Sales by customer
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/sales/by-customer?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Sales by customer retrieved",
  "responseData": [
    {
      "partyId": 112,
      "partyName": "Vino",
      "totalOrders": 5,
      "totalAmount": 203207.0,
      "paidAmount": 201850.0,
      "dueAmount": 1357.0
    },
    {
      "partyId": 122,
      "partyName": "Rahul",
      "totalOrders": 4,
      "totalAmount": 5173.0,
      "paidAmount": 0.0,
      "dueAmount": 5173.0
    }
  ]
}
```

## Purchase by vendor
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/purchase/by-vendor?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Purchase by vendor retrieved",
  "responseData": [
    {
      "partyId": 47,
      "partyName": "Rahul R (V)",
      "totalOrders": 6,
      "totalAmount": 144229.0,
      "paidAmount": 3305.0,
      "dueAmount": 140924.0
    },
    {
      "partyId": 49,
      "partyName": "Vino (V)",
      "totalOrders": 5,
      "totalAmount": 21992.0,
      "paidAmount": 960.0,
      "dueAmount": 21032.0
    }
  ]
}
```

## Sales by item
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/sales/by-item?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Sales by item retrieved",
  "responseData": [
    {
      "itemId": 11,
      "itemName": "Mobile",
      "totalQuantity": 1.0,
      "totalAmount": 200000.0
    },
    {
      "itemId": 6,
      "itemName": "Coconut Fibre 8 Ply",
      "totalQuantity": 8.0,
      "totalAmount": 3600.0
    }
  ]
}
```

## Purchase by item
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/purchase/by-item?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Purchase by item retrieved",
  "responseData": [
    {
      "itemId": 35,
      "itemName": "jsns",
      "totalQuantity": 6.0,
      "totalAmount": 27876.0
    },
    {
      "itemId": 11,
      "itemName": "Mobile",
      "totalQuantity": 1.0,
      "totalAmount": 20000.0
    }
  ]
}
```

## Profit by item
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/profit/by-item?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Profit by item retrieved",
  "responseData": [
    {
      "itemId": 11,
      "itemName": "Mobile",
      "totalSalesAmount": 200000.0,
      "totalPurchaseAmount": 20000.0,
      "profit": 180000.0,
      "profitMargin": 90.0
    },
    {
      "itemId": 6,
      "itemName": "Coconut Fibre 8 Ply",
      "totalSalesAmount": 3600.0,
      "totalPurchaseAmount": 500.0,
      "profit": 3100.0,
      "profitMargin": 86.11111111111111
    }
  ]
}
```

## Top selling items
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/dashboard/top-selling-items?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Top selling items retrieved",
  "responseData": [
    {
      "itemId": 7,
      "itemName": "24 Gauge GI Wire",
      "totalAmount": 2804.0,
      "totalQuantity": 39.0
    },
    {
      "itemId": 6,
      "itemName": "Coconut Fibre 8 Ply",
      "totalAmount": 3600.0,
      "totalQuantity": 8.0
    }
  ]
}
```

## Top profitable items 
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/dashboard/top-profitable-items?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Top profitable items retrieved",
  "responseData": [
    {
      "itemId": 11,
      "itemName": "Mobile",
      "totalAmount": 200000.0,
      "totalQuantity": 1.0
    },
    {
      "itemId": 6,
      "itemName": "Coconut Fibre 8 Ply",
      "totalAmount": 3600.0,
      "totalQuantity": 8.0
    }
  ]
}
```

## Payment mode distribution
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/dashboard/payment-mode-distribution?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Payment mode distribution retrieved",
  "responseData": [
    {
      "mode": "BANK_TRANSFER",
      "totalAmount": 280154.0,
      "transactionCount": 12,
      "percentage": 92.2609285568443
    },
    {
      "mode": "CASH",
      "totalAmount": 19500.0,
      "transactionCount": 2,
      "percentage": 6.421782686873876
    },
    {
      "mode": "UPI",
      "totalAmount": 4000.0,
      "transactionCount": 1,
      "percentage": 1.3172887562818207
    }
  ]
}
```

## Monthly trend retrieved
API: {{astraval.com}}/api/companies/{{companyId}}/analytics/dashboard/monthly-trend?startDate=2026-01-01&endDate=2026-03-29
```json
{
  "responseStatus": true,
  "responseCode": 200,
  "responseMessage": "Monthly trend retrieved",
  "responseData": [
    {
      "month": "2026-01",
      "salesAmount": 0.0,
      "purchaseAmount": 0.0,
      "paymentReceived": 0.0,
      "paymentMade": 0.0
    },
    {
      "month": "2026-02",
      "salesAmount": 205242.0,
      "purchaseAmount": 148039.0,
      "paymentReceived": 18000.0,
      "paymentMade": 1500.0
    },
    {
      "month": "2026-03",
      "salesAmount": 6549.0,
      "purchaseAmount": 21102.0,
      "paymentReceived": 211574.0,
      "paymentMade": 72580.0
    }
  ]
}
```
