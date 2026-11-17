import 'package:flutter_test/flutter_test.dart';
import 'package:stallion/ui/views/workprogess/supply_module_assignment.dart';

void main() {
  test('recognizes assigned supply module name variants', () {
    for (final name in ['Status of Supply', 'Status of Supplies', 'status_of_supply']) {
      expect(hasSupplyModuleAssignment([{'name': name, 'type': 'module'}]), isTrue);
    }
  });

  test('does not grant access from accounts, PO or unassigned modules', () {
    expect(hasSupplyModuleAssignment([]), isFalse);
    expect(hasSupplyModuleAssignment([
      {'name': 'Account Management', 'type': 'module'},
      {'name': 'Request Purchase Order', 'type': 'module'},
      {'name': 'Status of Supply', 'type': 'submodule', 'parent_module_id': 50},
    ]), isFalse);
  });

  test('maps assigned Raw Material Inventory to the supply flow', () {
    expect(hasSupplyModuleAssignment([
      {'id': 52, 'name': 'Raw Material Inventory', 'type': 'module'},
    ]), isTrue);
    expect(hasSupplyModuleAssignment([
      {'id': '52', 'name': 'Inventory', 'type': 'module'},
    ]), isTrue);
    expect(hasSupplyModuleAssignment([
      {'name': 'Raw Material Inventory', 'type': 'module'},
    ]), isTrue);
    expect(hasSupplyModuleAssignment([
      {'id': '52', 'name': 'Raw Material Inventory', 'type': 'submodule', 'parent_module_id': '50'},
    ]), isFalse);
  });
}
