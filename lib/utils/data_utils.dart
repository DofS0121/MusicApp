/// ---------------------------------------------------------
/// Helper đọc JSON linh hoạt cho cả PascalCase & camelCase.
/// Dùng cho API .NET / Node / PHP đều ổn
/// ---------------------------------------------------------

// ==============================
// STRING
// ==============================
String getStr(Map? m, List<String> keys, {String def = ''}) {
  if (m == null) return def;

  for (final key in keys) {
    if (m.containsKey(key) && m[key] != null) {
      return m[key].toString();
    }
  }
  return def;
}

// ==============================
// INT
// ==============================
int? getInt(Map? m, List<String> keys, {int? def}) {
  if (m == null) return def;

  for (final key in keys) {
    if (m.containsKey(key) && m[key] != null) {
      final v = m[key];
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v);
    }
  }
  return def;
}

// ==============================
// DOUBLE
// ==============================
double? getDouble(Map? m, List<String> keys, {double? def}) {
  if (m == null) return def;

  for (final key in keys) {
    if (m.containsKey(key) && m[key] != null) {
      final v = m[key];
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v);
    }
  }
  return def;
}

// ==============================
// BOOL
// ==============================
bool getBool(Map? m, List<String> keys, {bool def = false}) {
  if (m == null) return def;

  for (final key in keys) {
    if (m.containsKey(key) && m[key] != null) {
      final v = m[key];
      if (v is bool) return v;
      if (v is int) return v == 1;
      if (v is String) {
        return v.toLowerCase() == "true" || v == "1";
      }
    }
  }
  return def;
}

// ==============================
// LIST<Map<String, dynamic>>
// ==============================
List<Map<String, dynamic>> getListMap(Map? json, String key) {
  if (json == null) return [];
  if (!json.containsKey(key)) return [];

  final value = json[key];
  if (value is List) {
    return value.whereType<Map<String, dynamic>>().toList();
  }
  return [];
}

// ==============================
// LIST<dynamic>
// ==============================
List<dynamic> getList(Map? json, String key) {
  if (json == null) return [];
  final v = json[key];
  return v is List ? v : [];
}
