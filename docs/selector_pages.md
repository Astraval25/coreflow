# Selector Pages Documentation

## Overview
Selector pages are full-screen, searchable selection interfaces for choosing entities like customers, vendors, and items. They provide a consistent user experience across the application with search functionality, pull-to-refresh, error handling, and empty states.

## Available Selector Pages

### 1. CustomerSelectorPage
### 2. VendorSelectorPage  
### 3. ItemSelectorPage

## Location
```
lib/core/widgets/customer_selector_page.dart
lib/core/widgets/vendor_selector_page.dart
lib/core/widgets/item_selector_page.dart
```

---

## Common Features

All selector pages share these features:

- ✅ **Search Functionality** - Real-time search with clear button
- ✅ **Pull-to-Refresh** - Swipe down to reload data
- ✅ **Loading States** - Circular progress indicator during data fetch
- ✅ **Error Handling** - Error display with retry button
- ✅ **Empty States** - Contextual messages when no data found
- ✅ **Active Filtering** - Only shows active/sellable entities
- ✅ **Avatar Display** - First letter avatar for visual identification
- ✅ **Responsive Cards** - Touch-friendly card-based layout
- ✅ **Navigation Return** - Returns selected entity on tap

---

## CustomerSelectorPage

### Purpose
Select a customer from a searchable list of active customers.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `companyId` | `int` | Yes | The company ID to fetch customers for |

### Returns
`Customer` object when a customer is selected, or `null` if cancelled.

### Usage

```dart
// Navigate to customer selector
final selectedCustomer = await Navigator.push<Customer>(
  context,
  MaterialPageRoute(
    builder: (context) => CustomerSelectorPage(
      companyId: companyId,
    ),
  ),
);

// Handle selection
if (selectedCustomer != null) {
  print('Selected: ${selectedCustomer.displayName}');
  // Use the selected customer
}
```

### Search Fields
- Display name
- Company name
- Email address

### Display Information
- **Primary**: Display name
- **Secondary**: Company name (if available)
- **Avatar**: First letter of display name or company name

### Example Integration

```dart
class OrderCreatePage extends StatefulWidget {
  final int companyId;
  
  @override
  State<OrderCreatePage> createState() => _OrderCreatePageState();
}

class _OrderCreatePageState extends State<OrderCreatePage> {
  Customer? _selectedCustomer;

  Future<void> _selectCustomer() async {
    final customer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerSelectorPage(
          companyId: widget.companyId,
        ),
      ),
    );

    if (customer != null) {
      setState(() {
        _selectedCustomer = customer;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ListTile(
            title: Text(_selectedCustomer?.displayName ?? 'Select Customer'),
            trailing: Icon(Icons.chevron_right),
            onTap: _selectCustomer,
          ),
          // ... rest of the form
        ],
      ),
    );
  }
}
```

---

## VendorSelectorPage

### Purpose
Select a vendor from a searchable list of active vendors.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `companyId` | `int` | Yes | The company ID to fetch vendors for |

### Returns
`Vendor` object when a vendor is selected, or `null` if cancelled.

### Usage

```dart
// Navigate to vendor selector
final selectedVendor = await Navigator.push<Vendor>(
  context,
  MaterialPageRoute(
    builder: (context) => VendorSelectorPage(
      companyId: companyId,
    ),
  ),
);

// Handle selection
if (selectedVendor != null) {
  print('Selected: ${selectedVendor.displayName}');
  // Use the selected vendor
}
```

### Search Fields
- Display name
- Company name
- Email address

### Display Information
- **Primary**: Display name
- **Secondary**: Company name (if available)
- **Avatar**: First letter of display name or company name

### Example Integration

```dart
class PurchaseOrderPage extends StatefulWidget {
  final int companyId;
  
  @override
  State<PurchaseOrderPage> createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPage> {
  Vendor? _selectedVendor;

  Future<void> _selectVendor() async {
    final vendor = await Navigator.push<Vendor>(
      context,
      MaterialPageRoute(
        builder: (context) => VendorSelectorPage(
          companyId: widget.companyId,
        ),
      ),
    );

    if (vendor != null) {
      setState(() {
        _selectedVendor = vendor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ListTile(
            title: Text(_selectedVendor?.displayName ?? 'Select Vendor'),
            trailing: Icon(Icons.chevron_right),
            onTap: _selectVendor,
          ),
          // ... rest of the form
        ],
      ),
    );
  }
}
```

---

## ItemSelectorPage

### Purpose
Select an item from a searchable list of active, sellable items with optional exclusion of already selected items.

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `companyId` | `int` | Yes | - | The company ID to fetch items for |
| `excludeItemIds` | `List<int>` | No | `[]` | List of item IDs to exclude from selection |

### Returns
`Item` object when an item is selected, or `null` if cancelled.

### Usage

#### Basic Usage

```dart
// Navigate to item selector
final selectedItem = await Navigator.push<Item>(
  context,
  MaterialPageRoute(
    builder: (context) => ItemSelectorPage(
      companyId: companyId,
    ),
  ),
);

// Handle selection
if (selectedItem != null) {
  print('Selected: ${selectedItem.itemName}');
  print('Price: ${selectedItem.baseSalesPrice}');
  // Use the selected item
}
```

#### With Exclusions (Prevent Duplicates)

```dart
// Exclude already selected items
final selectedItemIds = _selectedItems.map((e) => e['itemId'] as int).toList();

final selectedItem = await Navigator.push<Item>(
  context,
  MaterialPageRoute(
    builder: (context) => ItemSelectorPage(
      companyId: companyId,
      excludeItemIds: selectedItemIds,  // Prevent duplicate selection
    ),
  ),
);

if (selectedItem != null) {
  setState(() {
    _selectedItems.add({
      'itemId': selectedItem.itemId,
      'itemName': selectedItem.itemName,
      'salesPrice': selectedItem.baseSalesPrice,
      'salesDescription': selectedItem.salesDescription,
    });
  });
}
```

### Search Fields
- Item name
- Item type
- HSN code

### Display Information
- **Primary**: Item name
- **Secondary**: Item type • Base sales price (₹)
- **Avatar**: First letter of item name

### Filtering
- Only shows **active** items
- Only shows **sellable** items
- Excludes items in `excludeItemIds` list

### Example Integration

```dart
class CustomerCreatePage extends StatefulWidget {
  final int companyId;
  
  @override
  State<CustomerCreatePage> createState() => _CustomerCreatePageState();
}

class _CustomerCreatePageState extends State<CustomerCreatePage> {
  List<Map<String, dynamic>> _selectedItems = [];

  Future<void> _addCustomerItem() async {
    // Get list of already selected item IDs
    final excludeIds = _selectedItems.map((e) => e['itemId'] as int).toList();

    // Navigate to item selector with exclusions
    final selectedItem = await Navigator.push<Item>(
      context,
      MaterialPageRoute(
        builder: (context) => ItemSelectorPage(
          companyId: widget.companyId,
          excludeItemIds: excludeIds,  // Prevent duplicates
        ),
      ),
    );

    // Add selected item
    if (selectedItem != null) {
      setState(() {
        _selectedItems.add({
          'itemId': selectedItem.itemId,
          'itemName': selectedItem.itemName,
          'salesPrice': selectedItem.baseSalesPrice,
          'salesDescription': selectedItem.salesDescription,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FilledButton.icon(
            onPressed: _addCustomerItem,
            icon: Icon(Icons.add),
            label: Text('Add Item'),
          ),
          // Display selected items
          ListView.builder(
            shrinkWrap: true,
            itemCount: _selectedItems.length,
            itemBuilder: (context, index) {
              final item = _selectedItems[index];
              return ListTile(
                title: Text(item['itemName']),
                subtitle: Text('₹${item['salesPrice']}'),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

---

## Common Implementation Patterns

### Pattern 1: Simple Selection

```dart
Future<void> _selectEntity() async {
  final selected = await Navigator.push<EntityType>(
    context,
    MaterialPageRoute(
      builder: (context) => EntitySelectorPage(
        companyId: companyId,
      ),
    ),
  );

  if (selected != null) {
    setState(() {
      _selectedEntity = selected;
    });
  }
}
```

### Pattern 2: Selection with Validation

```dart
Future<void> _selectCustomer() async {
  final customer = await Navigator.push<Customer>(
    context,
    MaterialPageRoute(
      builder: (context) => CustomerSelectorPage(
        companyId: companyId,
      ),
    ),
  );

  if (customer != null) {
    // Validate selection
    if (customer.dueAmount > 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Customer has high due amount')),
      );
    }
    
    setState(() {
      _selectedCustomer = customer;
    });
  }
}
```

### Pattern 3: Selection with Callback

```dart
class MyWidget extends StatelessWidget {
  final Function(Customer) onCustomerSelected;

  Future<void> _selectCustomer(BuildContext context) async {
    final customer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerSelectorPage(
          companyId: companyId,
        ),
      ),
    );

    if (customer != null) {
      onCustomerSelected(customer);
    }
  }
}
```

### Pattern 4: Multiple Selections (Items with Exclusions)

```dart
class ItemSelectionWidget extends StatefulWidget {
  @override
  State<ItemSelectionWidget> createState() => _ItemSelectionWidgetState();
}

class _ItemSelectionWidgetState extends State<ItemSelectionWidget> {
  List<Item> _selectedItems = [];

  Future<void> _addItem() async {
    // Exclude already selected items
    final excludeIds = _selectedItems.map((e) => e.itemId).toList();

    final item = await Navigator.push<Item>(
      context,
      MaterialPageRoute(
        builder: (context) => ItemSelectorPage(
          companyId: companyId,
          excludeItemIds: excludeIds,
        ),
      ),
    );

    if (item != null) {
      setState(() {
        _selectedItems.add(item);
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _selectedItems.removeAt(index);
    });
  }
}
```

---

## UI Components

### Search Bar
All selector pages include a search bar with:
- Placeholder text (e.g., "Search customers...")
- Search icon prefix
- Clear button suffix (when text is entered)
- Real-time filtering

### List Items
Each item in the list displays:
- **Avatar**: Circular avatar with first letter
- **Primary Text**: Main identifier (name)
- **Secondary Text**: Additional info (company name, price, etc.)
- **Chevron Icon**: Right arrow indicating selection

### States

#### Loading State
```
┌─────────────────────┐
│                     │
│   ⟳ Loading...      │
│                     │
└─────────────────────┘
```

#### Error State
```
┌─────────────────────┐
│        ⚠️           │
│  Failed to load     │
│   [Retry Button]    │
└─────────────────────┘
```

#### Empty State
```
┌─────────────────────┐
│        🔍           │
│  No items found     │
│                     │
└─────────────────────┘
```

#### Success State
```
┌─────────────────────┐
│  [Search Bar]       │
├─────────────────────┤
│  ○ Item 1      →    │
│  ○ Item 2      →    │
│  ○ Item 3      →    │
└─────────────────────┘
```

---

## Best Practices

### 1. Always Check for Null
```dart
final selected = await Navigator.push<Customer>(...);

if (selected != null) {  // ✅ Always check
  // Use selected entity
}
```

### 2. Use Exclusions for Multiple Selections
```dart
// ✅ Good - Prevents duplicates
ItemSelectorPage(
  companyId: companyId,
  excludeItemIds: alreadySelectedIds,
)

// ❌ Avoid - Allows duplicates
ItemSelectorPage(
  companyId: companyId,
)
```

### 3. Provide User Feedback
```dart
if (selected != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('${selected.name} selected')),
  );
}
```

### 4. Handle Navigation Properly
```dart
// ✅ Good - Async/await
final result = await Navigator.push<Customer>(...);

// ❌ Avoid - No await
Navigator.push<Customer>(...);
```

### 5. Type Safety
```dart
// ✅ Good - Specify return type
final customer = await Navigator.push<Customer>(...);

// ❌ Avoid - No type
final customer = await Navigator.push(...);
```

---

## Styling

All selector pages use consistent theming:

### Colors
- **Background**: `LoginColors.background`
- **Surface**: `LoginColors.surface`
- **Border**: `LoginColors.borderLight`
- **Primary**: `LoginColors.primary`
- **Text Primary**: `LoginColors.textPrimary`
- **Text Secondary**: `LoginColors.textSecondary`
- **Text Tertiary**: `LoginColors.textTertiary`

### Typography
- **Title**: 15px, FontWeight.w600
- **Subtitle**: 12.5px, Regular
- **Search**: 15px, Regular
- **Hint**: 14px, Regular

### Spacing
- Card margin: 5px vertical
- Card padding: 14px horizontal, 12px vertical
- Avatar radius: 22px
- Border radius: 14px (cards), 12px (search)

---

## Accessibility

All selector pages are accessible:
- ✅ Semantic labels for screen readers
- ✅ Touch targets meet minimum size (48x48)
- ✅ Clear visual hierarchy
- ✅ Keyboard navigation support
- ✅ High contrast text
- ✅ Clear error messages

---

## Performance Considerations

### Data Loading
- Data is loaded once on page open
- Pull-to-refresh for manual updates
- Local filtering for search (no API calls)

### Search Optimization
- Case-insensitive search
- Trim whitespace
- Multiple field search
- Real-time filtering

### Memory Management
- Controllers disposed properly
- State cleaned up on dispose
- No memory leaks

---

## Error Handling

All selector pages handle errors gracefully:

```dart
try {
  final data = await repository.getData(companyId);
  setState(() {
    _allData = data;
    _filtered = data;
    _isLoading = false;
  });
} catch (e) {
  setState(() {
    _error = 'Failed to load data';
    _isLoading = false;
  });
}
```

Users can retry failed operations with the retry button.

---

## Testing

### Unit Test Example

```dart
testWidgets('CustomerSelectorPage displays customers', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CustomerSelectorPage(companyId: 1),
    ),
  );

  // Wait for loading
  await tester.pump();
  
  // Verify search bar
  expect(find.byType(TextField), findsOneWidget);
  
  // Verify title
  expect(find.text('Select Customer'), findsOneWidget);
});
```

### Integration Test Example

```dart
testWidgets('Can select customer and return', (tester) async {
  Customer? selectedCustomer;

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            selectedCustomer = await Navigator.push<Customer>(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerSelectorPage(companyId: 1),
              ),
            );
          },
          child: Text('Select'),
        ),
      ),
    ),
  );

  // Tap select button
  await tester.tap(find.text('Select'));
  await tester.pumpAndSettle();

  // Tap first customer
  await tester.tap(find.byType(Card).first);
  await tester.pumpAndSettle();

  // Verify customer was selected
  expect(selectedCustomer, isNotNull);
});
```

---

## Comparison Table

| Feature | CustomerSelectorPage | VendorSelectorPage | ItemSelectorPage |
|---------|---------------------|-------------------|------------------|
| **Search Fields** | Name, Company, Email | Name, Company, Email | Name, Type, HSN |
| **Filtering** | Active only | Active only | Active + Sellable |
| **Exclusions** | ❌ No | ❌ No | ✅ Yes |
| **Display Info** | Name, Company | Name, Company | Name, Type, Price |
| **Use Case** | Sales, Orders | Purchases | Order Items, Customer Items |
| **Return Type** | `Customer` | `Vendor` | `Item` |

---

## Migration Guide

If you're using dropdown-based selection, migrate to selector pages:

### Before (Dropdown)
```dart
DropdownButtonFormField<Customer>(
  items: customers.map((c) => DropdownMenuItem(
    value: c,
    child: Text(c.displayName),
  )).toList(),
  onChanged: (customer) {
    setState(() => _selectedCustomer = customer);
  },
)
```

### After (Selector Page)
```dart
ListTile(
  title: Text(_selectedCustomer?.displayName ?? 'Select Customer'),
  trailing: Icon(Icons.chevron_right),
  onTap: () async {
    final customer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerSelectorPage(
          companyId: companyId,
        ),
      ),
    );
    if (customer != null) {
      setState(() => _selectedCustomer = customer);
    }
  },
)
```

### Benefits of Migration
- ✅ Better UX with full-screen selection
- ✅ Search functionality
- ✅ Better performance with large lists
- ✅ Consistent UI across app
- ✅ Pull-to-refresh support
- ✅ Better error handling

---

## Related Widgets

- `ProcessLoadingScreen` - For multi-step operations
- `ItemSectionCard` - For displaying selected items
- `AppDrawer` - For navigation

---

## Support

For issues or questions, refer to the main project documentation or contact the development team.
