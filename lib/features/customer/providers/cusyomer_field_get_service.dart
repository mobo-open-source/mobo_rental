
/// Service to filter Odoo fields and remove problematic ones
/// that can cause singleton errors or computation issues
class OdooFieldsFilterService {
  /// Get detailed field information for debugging
  /// This fetches ALL attributes to compare fields
  static void logFieldDetails(
    Map<dynamic, dynamic> fieldsMap,
    String fieldName,
  ) {
    if (fieldsMap.containsKey(fieldName)) {
      final fieldData = fieldsMap[fieldName];
      if (fieldData is Map) {
        fieldData.forEach((key, value) {
        });
      }
    } else {
    }
  }

  /// Compare two fields side by side
  static void compareFields(
    Map<dynamic, dynamic> fieldsMap,
    String field1,
    String field2,
  ) {

    final f1Data = fieldsMap[field1] as Map?;
    final f2Data = fieldsMap[field2] as Map?;

    if (f1Data == null || f2Data == null) {
      return;
    }

    // Get all unique keys from both fields
    final allKeys = <String>{
      ...f1Data.keys.map((k) => k.toString()),
      ...f2Data.keys.map((k) => k.toString()),
    };


    for (final key in allKeys.toList()..sort()) {
      final val1 = f1Data[key]?.toString() ?? 'NOT SET';
      final val2 = f2Data[key]?.toString() ?? 'NOT SET';

      final marker = val1 != val2 ? '⚠️ ' : '  ';
    }

  }

  /// Filters fields from fields_get result to return only safe fields
  ///
  /// Removes:
  /// - Computed fields (store: false)
  /// - Binary fields (can be large)
  /// - Certain relational fields that might cause issues
  ///
  /// [fieldsMap] - The result from fields_get API call
  /// [includeBinary] - Whether to include binary fields (default: false)
  /// [includeRelational] - Whether to include one2many/many2many (default: true)
  static List<String> getSafeFields(
    Map<dynamic, dynamic> fieldsMap, {
    bool includeBinary = false,
    bool includeRelational = true,
  }) {
    final List<String> safeFields = [];

    fieldsMap.forEach((key, value) {
      if (value is! Map) return;

      final String fieldName = key.toString();
      final bool isStored = value['store'] == true;
      final String? fieldType = value['type']?.toString();
      final bool isSearchable = value['searchable'] == true;
      final String? relation = value['relation']?.toString();

      if (!includeBinary && fieldType == 'binary') return;

      if (!includeRelational &&
          (fieldType == 'one2many' || fieldType == 'many2many')) {
        return;
      }

      if (isStored) {
        safeFields.add(fieldName);
        return;
      }

      if (fieldType == 'many2one' && relation != null && isSearchable) {
        safeFields.add(fieldName);
        return;
      }
    });

    return safeFields;
  }


  /// Get only basic fields (char, text, integer, float, boolean, date, datetime, selection, many2one)
  static List<String> getBasicFields(Map<dynamic, dynamic> fieldsMap) {
    const basicTypes = {
      'char',
      'text',
      'integer',
      'float',
      'boolean',
      'date',
      'datetime',
      'selection',
      'many2one',
      'monetary',
    };

    final List<String> basicFields = [];

    fieldsMap.forEach((key, value) {
      if (value is! Map) return;

      final String fieldName = key.toString();
      final bool isStored = value['store'] == true;
      final String? fieldType = value['type']?.toString();

      if (isStored && fieldType != null && basicTypes.contains(fieldType)) {
        basicFields.add(fieldName);
      }
    });

    return basicFields;
  }

  /// Get problematic fields that were filtered out (for debugging)
  static List<String> getProblematicFields(Map<dynamic, dynamic> fieldsMap) {
    final List<String> problematicFields = [];

    fieldsMap.forEach((key, value) {
      if (value is! Map) return;

      final String fieldName = key.toString();
      final bool isStored = value['store'] == true;
      final String? fieldType = value['type']?.toString();

      // Non-stored computed fields
      if (!isStored) {
        problematicFields.add('$fieldName (computed: $fieldType)');
        return;
      }

      // Binary fields
      if (fieldType == 'binary') {
        problematicFields.add('$fieldName (binary)');
        return;
      }
    });

    return problematicFields;
  }

  /// Get fallback fields if fields_get fails
  static List<String> getFallbackFields() {
    return [
      'id',
      'name',
      'display_name',
      'active',
      'create_date',
      'write_date',
    ];
  }
}
