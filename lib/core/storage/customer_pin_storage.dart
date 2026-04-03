import 'package:shared_preferences/shared_preferences.dart';

class CustomerPinStorage {
  static String _keyForCompany(int companyId) => 'pinned_customers_$companyId';

  static Future<Set<int>> loadPinnedCustomerIds(int companyId) async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_keyForCompany(companyId)) ?? <String>[];
    return values.map(int.tryParse).whereType<int>().toSet();
  }

  static Future<void> savePinnedCustomerIds(
    int companyId,
    Set<int> customerIds,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = customerIds.map((id) => id.toString()).toList();
    await prefs.setStringList(_keyForCompany(companyId), payload);
  }
}
