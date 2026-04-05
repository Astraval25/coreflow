# ProcessLoadingScreen Widget

## Overview
`ProcessLoadingScreen` is a generic, reusable widget for displaying multi-step process loading states. It provides visual feedback to users during operations that involve multiple sequential steps such as creating, updating, deleting, or bulk operations.

## Location
```
lib/core/widgets/process_loading_screen.dart
```

## Features
- ✅ Visual step-by-step progress indicator
- ✅ Completed steps shown with green checkmarks
- ✅ Current step highlighted with primary color
- ✅ Pending steps shown in muted color
- ✅ Optional title for context
- ✅ Optional circular progress indicator
- ✅ Responsive and centered layout
- ✅ Flexible text wrapping for long step descriptions

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `steps` | `List<String>` | Yes | - | List of step descriptions to display |
| `currentStep` | `int` | Yes | - | Index of the current step (0-based) |
| `title` | `String?` | No | `null` | Optional title displayed above steps |
| `showProgress` | `bool` | No | `true` | Whether to show circular progress indicator |

## Usage

### Basic Usage

```dart
ProcessLoadingScreen(
  steps: const ['Step 1', 'Step 2', 'Step 3'],
  currentStep: 1,
)
```

### With Title

```dart
ProcessLoadingScreen(
  steps: const ['Creating customer', 'Creating customer items', 'Done'],
  currentStep: currentStep,
  title: 'Creating Customer',
)
```

### Without Progress Indicator

```dart
ProcessLoadingScreen(
  steps: const ['Validating', 'Processing', 'Complete'],
  currentStep: 0,
  showProgress: false,
)
```

## Implementation Pattern

### 1. State Management

Add state variables to track the process:

```dart
class _MyPageState extends State<MyPage> {
  int _currentStep = 0;
  bool _isProcessing = false;
  
  // ... other state variables
}
```

### 2. Process Execution

Implement your multi-step process with step updates:

```dart
Future<void> _executeProcess() async {
  setState(() {
    _isProcessing = true;
    _currentStep = 0;
  });

  // Step 1
  await _performStep1();
  setState(() => _currentStep = 1);

  // Step 2
  await _performStep2();
  setState(() => _currentStep = 2);

  // Step 3 (Done)
  await _performStep3();
  setState(() => _currentStep = 3);

  // Show completion for 800ms before closing
  await Future.delayed(Duration(milliseconds: 800));

  setState(() => _isProcessing = false);
  
  // Navigate or show success message
}
```

### 3. UI Integration

Show the loading screen conditionally:

```dart
@override
Widget build(BuildContext context) {
  if (_isProcessing) {
    return ProcessLoadingScreen(
      steps: const ['Step 1', 'Step 2', 'Step 3', 'Done'],
      currentStep: _currentStep,
      title: 'Processing',
    );
  }

  return Scaffold(
    // ... your normal UI
  );
}
```

## Real-World Examples

### Customer Creation with Items

```dart
Future<void> _createCustomer() async {
  setState(() {
    _isProcessing = true;
    _currentStep = 0;
  });

  // Step 0: Create customer
  final customerId = await _createCustomerAPI();
  setState(() => _currentStep = 1);

  // Step 1: Create customer items
  await _createCustomerItems(customerId);
  setState(() => _currentStep = 2);

  // Step 2: Done - show completion
  await Future.delayed(Duration(milliseconds: 800));

  setState(() => _isProcessing = false);
  Navigator.pop(context, true);
}

// In build method
if (_isProcessing) {
  return ProcessLoadingScreen(
    steps: const ['Creating customer', 'Creating customer items', 'Done'],
    currentStep: _currentStep,
    title: 'Creating Customer',
  );
}
```

### Vendor Creation

```dart
ProcessLoadingScreen(
  steps: const [
    'Creating vendor',
    'Setting up payment terms',
    'Configuring tax settings',
    'Done'
  ],
  currentStep: currentStep,
  title: 'Creating Vendor',
)
```

### Order Processing

```dart
ProcessLoadingScreen(
  steps: const [
    'Validating order',
    'Creating order',
    'Updating inventory',
    'Sending notifications',
    'Done'
  ],
  currentStep: currentStep,
  title: 'Processing Order',
)
```

### Bulk Delete Operation

```dart
ProcessLoadingScreen(
  steps: const [
    'Validating items',
    'Deleting records',
    'Updating references',
    'Cleaning up',
    'Done'
  ],
  currentStep: currentStep,
  title: 'Bulk Delete',
)
```

### Account Deletion

```dart
ProcessLoadingScreen(
  steps: const [
    'Backing up data',
    'Removing account',
    'Cleaning up resources',
    'Done'
  ],
  currentStep: currentStep,
  title: 'Deleting Account',
)
```

### Data Import

```dart
ProcessLoadingScreen(
  steps: const [
    'Uploading file',
    'Validating data',
    'Importing records',
    'Generating report',
    'Done'
  ],
  currentStep: currentStep,
  title: 'Importing Data',
)
```

### Bulk Update

```dart
ProcessLoadingScreen(
  steps: const [
    'Fetching records',
    'Applying updates',
    'Validating changes',
    'Done'
  ],
  currentStep: currentStep,
  title: 'Updating Records',
)
```

## Best Practices

### 1. Always Include "Done" Step
Always add a "Done" step as the final step to provide clear completion feedback:

```dart
steps: const ['Step 1', 'Step 2', 'Done']  // ✅ Good
steps: const ['Step 1', 'Step 2']          // ❌ Avoid
```

### 2. Add Completion Delay
Add a delay after the final step to let users see the completion:

```dart
// After final step
setState(() => _currentStep = steps.length - 1);
await Future.delayed(Duration(milliseconds: 800));  // Show "Done" with checkmark
setState(() => _isProcessing = false);
```

### 3. Use Descriptive Step Names
Use clear, action-oriented step descriptions:

```dart
// ✅ Good
steps: const ['Creating customer', 'Adding items', 'Done']

// ❌ Avoid
steps: const ['Step 1', 'Step 2', 'Done']
```

### 4. Handle Errors Gracefully
Close the loading screen immediately on errors:

```dart
try {
  // ... process steps
} catch (e) {
  setState(() => _isProcessing = false);  // Close immediately
  // Show error message
}
```

### 5. Keep Step Count Reasonable
Limit steps to 3-5 for better UX:

```dart
// ✅ Good - 4 steps
steps: const ['Validate', 'Process', 'Update', 'Done']

// ❌ Too many - 8 steps
steps: const ['Step1', 'Step2', 'Step3', 'Step4', 'Step5', 'Step6', 'Step7', 'Done']
```

### 6. Use Meaningful Titles
Provide context with descriptive titles:

```dart
// ✅ Good
title: 'Creating Customer'
title: 'Processing Order'
title: 'Deleting Account'

// ❌ Avoid
title: 'Loading'
title: 'Please Wait'
```

## ViewModel Integration

For complex operations, integrate with ViewModels:

```dart
// In ViewModel
class MyViewModel extends ChangeNotifier {
  int _currentStep = 0;
  Function(int)? onStepChanged;

  int get currentStep => _currentStep;

  Future<void> executeProcess() async {
    _currentStep = 0;
    if (onStepChanged != null) onStepChanged!(0);
    notifyListeners();

    // Step 1
    await _step1();
    _currentStep = 1;
    if (onStepChanged != null) onStepChanged!(1);
    notifyListeners();

    // Step 2
    await _step2();
    _currentStep = 2;
    if (onStepChanged != null) onStepChanged!(2);
    notifyListeners();
  }
}

// In Widget
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final viewModel = Provider.of<MyViewModel>(context, listen: false);
    viewModel.onStepChanged = (step) {
      if (mounted) {
        setState(() {
          _currentStep = step;
        });
      }
    };
  });
}
```

## Styling

The widget uses the app's theme colors:
- **Background**: `LoginColors.background`
- **Surface**: `LoginColors.surface`
- **Border**: `LoginColors.borderLight`
- **Primary**: `LoginColors.primary`
- **Success**: `Colors.green`
- **Text**: `LoginColors.textPrimary` / `LoginColors.textSecondary`

## Accessibility

The widget is accessible by default:
- Clear visual indicators for each step state
- Color-coded icons (green for complete, primary for current, gray for pending)
- Readable text with appropriate font weights
- Flexible text wrapping for long descriptions

## Testing

Example test case:

```dart
testWidgets('ProcessLoadingScreen displays steps correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ProcessLoadingScreen(
        steps: const ['Step 1', 'Step 2', 'Done'],
        currentStep: 1,
        title: 'Test Process',
      ),
    ),
  );

  expect(find.text('Test Process'), findsOneWidget);
  expect(find.text('Step 1'), findsOneWidget);
  expect(find.text('Step 2'), findsOneWidget);
  expect(find.text('Done'), findsOneWidget);
});
```

## Related Widgets

- `CircularProgressIndicator` - For simple loading states
- `LinearProgressIndicator` - For progress bars
- `SnackBar` - For completion messages

## Migration from CustomerCreationLoading

If you're migrating from the old `CustomerCreationLoading` widget:

```dart
// Old
CustomerCreationLoading(
  steps: const ['Creating customer', 'Creating customer items', 'Done'],
  currentStep: currentStep,
)

// New
ProcessLoadingScreen(
  steps: const ['Creating customer', 'Creating customer items', 'Done'],
  currentStep: currentStep,
  title: 'Creating Customer',  // Optional but recommended
)
```

## Support

For issues or questions, refer to the main project documentation or contact the development team.
