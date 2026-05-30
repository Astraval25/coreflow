const List<String> kBackendUnitOptions = <String>[
  'PCS',
  'KG',
  'GRAM',
  'LITER',
  'MILLILITER',
  'METER',
  'INCH',
];

String? normalizeItemUnit(String? raw) {
  if (raw == null) return null;
  final value = raw.trim().toUpperCase();
  if (value.isEmpty) return null;

  switch (value) {
    case 'UNIT':
    case 'PCE':
    case 'PC':
    case 'PIECE':
    case 'PIECES':
      return 'PCS';
    case 'ML':
    case 'MILLI_LITER':
    case 'MILLI-LITER':
      return 'MILLILITER';
    case 'L':
    case 'LTR':
      return 'LITER';
    case 'G':
    case 'GM':
      return 'GRAM';
    case 'M':
    case 'MTR':
      return 'METER';
    case 'IN':
      return 'INCH';
    default:
      return kBackendUnitOptions.contains(value) ? value : null;
  }
}
