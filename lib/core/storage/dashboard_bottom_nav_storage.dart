import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardBottomNavStorage {
  static const int maxPinnedActions = 4;
  static const List<String> defaultPinnedActionIds = [
    'sales_orders',
    'payment_made',
    'expenses',
    'employees',
  ];

  static final ValueNotifier<int> changeToken = ValueNotifier<int>(0);

  static String _keyForCompany(int companyId) =>
      'dashboard_bottom_nav_actions_$companyId';

  static Future<List<String>> loadPinnedActionIds(int companyId) async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_keyForCompany(companyId));
    if (values == null || values.isEmpty) {
      return List<String>.from(defaultPinnedActionIds);
    }
    return _sanitize(values);
  }

  static Future<void> savePinnedActionIds(
    int companyId,
    List<String> actionIds,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _sanitize(actionIds);
    await prefs.setStringList(_keyForCompany(companyId), payload);
    changeToken.value++;
  }

  static List<String> _sanitize(List<String> ids) {
    final seen = <String>{};
    final out = <String>[];
    for (final raw in ids) {
      final id = raw.trim();
      if (id.isEmpty || seen.contains(id)) continue;
      seen.add(id);
      out.add(id);
      if (out.length >= maxPinnedActions) break;
    }
    return out;
  }
}
