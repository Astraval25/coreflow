# Draft State Preservation Technique

## Goal
Keep a user's in-progress draft (sales/purchase order) intact while navigating to another screen (e.g., create customer/vendor item) and back.

## Core Technique
- Keep draft state in a `ChangeNotifier` ViewModel provided at the page level (`ChangeNotifierProvider`).
- Navigate using `Navigator.push(...)` to the create/mapping page.
- Return to the draft page with `Navigator.pop(context, true)` when creation succeeds.
- On return, refresh only the item list (do not recreate the draft ViewModel).

Because the draft page stays on the navigation stack, its widget tree and provider instance remain alive, so the draft state is preserved.

## Pattern Summary
1. Draft page is opened with a `ChangeNotifierProvider`:
   - Example: `CreateSalesOrderPage` creates `CreateSalesOrderViewModel`.
2. When the item picker is empty, we:
   - Close the sheet with `Navigator.pop(...)`.
   - Push a "create item" flow using `Navigator.of(hostContext).push(...)`.
3. After creation:
   - Return `true` from the create flow.
   - Reload available items in the draft ViewModel.
   - Keep all other draft data untouched.

## Key Code Shape (Pseudo)
```dart
final created = await Navigator.of(hostContext).push<bool>(
  MaterialPageRoute(builder: (_) => CreateItemFlow(...)),
);

if (created == true) {
  await vm.reloadItems(); // refresh available items only
  // Draft stays intact because vm was not disposed
}
```

## Where Implemented
- Sales draft:
  - `CreateSalesOrderViewModel.reloadSellableItems()`
  - Item picker in `create_sales_order_page.dart`
  - Item picker in `update_sales_order_page.dart`
- Purchase draft:
  - `CreatePurchaseOrderViewModel.reloadPurchasableItems()`
  - Item picker in `create_purchase_order_page.dart`
  - Item picker in `update_purchase_order_page.dart`

## Notes for Reuse
- Always pass a `hostContext` from the draft page (not the bottom sheet context) for navigation.
- Avoid rebuilding the draft page on return.
- Refresh only the dependent list(s), not the entire draft.

