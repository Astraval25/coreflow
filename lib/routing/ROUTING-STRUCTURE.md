change the entire route system to 
## App
cf/legal/privacy-policy
cf/legal/terms-of-service

## Auth
cf/auth/login
cf/auth/register
cf/auth/verify
cf/auth/resend-otp

## Dashboard 
cf/company/:companyId/dashboard

## Notification 
cf/company/:companyId/notifications

## Company
cf/company/list
cf/company/create
cf/company/:companyId/detail
cf/company/:companyId/update

## User
cf/user/:userId/profile/
cf/user/:userId/settings/

## customers
cf/company/:companyId/customers
cf/company/:companyId/customers/create
cf/company/:companyId/customers/:customerId/update
cf/company/:companyId/customers/:customerId/detail

## vendors
cf/company/:companyId/vendors
cf/company/:companyId/vendors/create
cf/company/:companyId/vendors/:vendorId/update
cf/company/:companyId/vendors/:vendorId/detail

## Items
cf/company/:companyId/items
cf/company/:companyId/items/create
cf/company/:companyId/items/:itemId/update
cf/company/:companyId/items/:itemId/detail

## Sales 
cf/company/:companyId/sales
cf/company/:companyId/sales/create
cf/company/:companyId/sales/:salesId/update
cf/company/:companyId/sales/:salesId/detail

## Purchase 
cf/company/:companyId/purchase/list
cf/company/:companyId/purchase/create
cf/company/:companyId/purchase/:purchaseId/update
cf/company/:companyId/purchase/:purchaseId/detail

## Payment received
cf/company/:companyId/payment-received/list
cf/company/:companyId/payment-received/create
cf/company/:companyId/payment-received/:paymentReceivedId/update
cf/company/:companyId/payment-received/:paymentReceivedId/detail

## Payment made
cf/company/:companyId/payment-made/list
cf/company/:companyId/payment-made/create
cf/company/:companyId/payment-made/:paymentMadeId/update
cf/company/:companyId/payment-made/:paymentMadeId/detail

## Report
cf/company/:companyId/report/customers
cf/company/:companyId/report/vendors
cf/company/:companyId/report/items
cf/company/:companyId/report/sales
cf/company/:companyId/report/purchase
cf/company/:companyId/report/payment-received
cf/company/:companyId/report/payment-made
