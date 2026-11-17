/// Recognize the supply module only when explicitly assigned by the backend.
bool hasSupplyModuleAssignment(List<dynamic> modules) => modules.any((item) {
      if (item is! Map) return false;
      final type = (item['type'] ?? '').toString().trim().toLowerCase();
      final topLevel = type == 'module' ||
          (item['parent_module_id'] == null && type != 'submodule');
      final name = (item['name'] ?? '')
          .toString()
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), '');
      final id = (item['id'] ?? '').toString().trim();
      // Backend module 52 is the Raw Material Inventory entry for this flow.
      return topLevel &&
          (id == '52' ||
              const {
                'statusofsupply',
                'statusofsupplies',
                'rawmaterialinventory',
              }.contains(name));
    });
