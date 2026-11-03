import 'package:flutter/foundation.dart';

/// Temporary local UI preview. Set to false to restore backend data and access.
/// Release builds always use the backend.
const bool useAccountManagementTestData = kDebugMode;

const Map<String, String> accountManagementTestData = {
  'poRequested': '12',
  'poAssigned': '8',
  'poIssued': '24',
  'woRequested': '6',
  'woAssigned': '4',
  'woIssued': '18',
  'paymentRequested': '9',
  'paymentApproved': '15',
  'paymentDue': '1250000',
  'paymentOverdue': '275000',
};
