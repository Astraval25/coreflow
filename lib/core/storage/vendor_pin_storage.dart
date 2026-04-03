import 'package:shared_preferences/shared_preferences.dart';

class VendorPinStorage {
  static String _keyForCompany(int companyId) => 'pinned_vendors_$companyId';

  static Future<Set<int>> loadPinnedVendorIds(int companyId) async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_keyForCompany(companyId)) ?? <String>[];
    return values.map(int.tryParse).whereType<int>().toSet();
  }

  static Future<void> savePinnedVendorIds(
    int companyId,
    Set<int> vendorIds,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = vendorIds.map((id) => id.toString()).toList();
    await prefs.setStringList(_keyForCompany(companyId), payload);
  }
}
