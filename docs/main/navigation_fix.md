# Navigation Fix - Customer/Vendor Detail Pages

## Issue
When clicking "Create Sale" or "Receive Payment" buttons on customer detail page, or "Create Purchase" or "Make Payment" buttons on vendor detail page, users were being taken to the listing pages instead of the create pages.

## Solution Implemented

### 1. Added Create Page Routes
Updated `lib/routing/app_routinf.dart` to include routes for all create pages:
- `/sales/:companyId/create` → CreateSalesOrderPage
- `/purchase/:companyId/create` → CreatePurchaseOrderPage
- `/payment/:companyId/create` → CreatePaymentSentPage
- `/pay-received/:companyId/create` → CreateReceivePaymentPage

### 2. Updated Customer Detail Page Navigation
Modified `lib/features/customers/widget/detail/customer_detail_body.dart`:
- "Create Sale" button now navigates to `/sales/${companyId}/create`
- "Receive Payment" button now navigates to `/pay-received/${companyId}/create`

### 3. Updated Vendor Detail Page Navigation
Modified `lib/features/vendor/widget/detail/vendor_detail_body.dart`:
- "Create Purchase" button now navigates to `/purchase/${companyId}/create`
- "Make Payment" button now navigates to `/payment/${companyId}/create`

## Result
✅ Clicking quick action buttons now correctly navigates to create pages instead of listing pages
✅ CompanyId is properly passed to create pages via route parameters

## Future Enhancement: Auto-Selection
To automatically select the customer/vendor when opening create pages from detail pages, you would need to:

1. Pass customer/vendor data via route `extra` parameter
2. Modify create page constructors to accept optional pre-selected entity
3. Update view models to check for pre-selected data on initialization
4. Auto-populate the selector if pre-selected data exists

Example implementation pattern:
```dart
// In detail page
context.push(
  '/sales/${vm.companyId}/create',
  extra: {
    'preSelectedCustomer': {
      'customerId': customer.customerId,
      'displayName': customer.displayName,
      'customerCompanyName': customer.customerCompanyName,
      'email': customer.email,
      'isActive': customer.isActive,
    }
  }
);

// In create page
final extra = GoRouterState.of(context).extra as Map?;
final preSelected = extra?['preSelectedCustomer'];
if (preSelected != null) {
  vm.setCustomer(Customer.fromMap(preSelected));
}
```
