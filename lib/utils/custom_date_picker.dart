import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// A TextInputFormatter that auto-inserts `/` after DD and MM
/// so the user only types digits and gets dd/mm/yyyy format.
class DateAutoSlashFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    final oldText = oldValue.text;

    // If deleting, let it go through normally
    if (newText.length < oldText.length) {
      return newValue;
    }

    // Strip non-digits
    final digitsOnly = newText.replaceAll(RegExp(r'[^\d]'), '');

    // Build formatted string
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length && i < 8; i++) {
      if (i == 2 || i == 4) {
        buffer.write('/');
      }
      buffer.write(digitsOnly[i]);
    }

    final formatted = buffer.toString();
    // Cap at 10 chars: dd/mm/yyyy
    final result =
        formatted.length > 10 ? formatted.substring(0, 10) : formatted;

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

/// Shows a custom date picker dialog with dd/mm/yyyy auto-slash input
/// and a calendar button to switch to the standard calendar picker.
Future<DateTime?> showAutoFormatDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  return showDialog<DateTime>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _AutoFormatDatePickerDialog(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    ),
  );
}

class _AutoFormatDatePickerDialog extends StatefulWidget {
  const _AutoFormatDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_AutoFormatDatePickerDialog> createState() =>
      _AutoFormatDatePickerDialogState();
}

class _AutoFormatDatePickerDialogState
    extends State<_AutoFormatDatePickerDialog> {
  late TextEditingController _controller;
  String? _errorText;
  bool _showCalendar = true; // Start with calendar view

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(widget.initialDate),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DateTime? _parseDate(String text) {
    try {
      if (text.length != 10) return null;
      final parts = text.split('/');
      if (parts.length != 3) return null;
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day == null || month == null || year == null) return null;
      if (month < 1 || month > 12 || day < 1 || day > 31) return null;
      final date = DateTime(year, month, day);
      // Verify the date is valid (e.g., not 31/02)
      if (date.day != day || date.month != month || date.year != year) {
        return null;
      }
      return date;
    } catch (_) {
      return null;
    }
  }

  void _validateAndReturn() {
    final date = _parseDate(_controller.text);
    if (date == null) {
      setState(() => _errorText = 'Enter a valid date (dd/mm/yyyy)');
      return;
    }
    if (date.isBefore(widget.firstDate) || date.isAfter(widget.lastDate)) {
      setState(() => _errorText =
          'Date must be between ${DateFormat('dd/MM/yyyy').format(widget.firstDate)} and ${DateFormat('dd/MM/yyyy').format(widget.lastDate)}');
      return;
    }
    Navigator.of(context).pop(date);
  }

  void _switchToCalendar() async {
    // Parse current input as initial date for calendar
    DateTime initDate = widget.initialDate;
    final parsed = _parseDate(_controller.text);
    if (parsed != null &&
        !parsed.isBefore(widget.firstDate) &&
        !parsed.isAfter(widget.lastDate)) {
      initDate = parsed;
    }

    setState(() {
      _showCalendar = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showCalendar) {
      return _buildCalendarView();
    }
    return _buildInputView();
  }

  Widget _buildCalendarView() {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 360,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 8, 0),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SELECT DATE',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat('EEE, dd MMM yyyy')
                              .format(widget.initialDate),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black54),
                        tooltip: 'Switch to input',
                        onPressed: () {
                          setState(() => _showCalendar = false);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            // Calendar
            SizedBox(
              height: 320,
              child: Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: widget.initialDate,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  onDateChanged: (date) {
                    _controller.text = DateFormat('dd/MM/yyyy').format(date);
                  },
                ),
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('CANCEL',
                        style: TextStyle(color: Colors.black54)),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      final date = _parseDate(_controller.text);
                      if (date != null) {
                        Navigator.of(context).pop(date);
                      } else {
                        Navigator.of(context).pop(widget.initialDate);
                      }
                    },
                    child:
                        const Text('OK', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputView() {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 360,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 8, 0),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SELECT DATE',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _controller.text.isNotEmpty
                              ? _controller.text
                              : 'dd/mm/yyyy',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today,
                            color: Colors.black54),
                        tooltip: 'Switch to calendar',
                        onPressed: _switchToCalendar,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            // Input field
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                inputFormatters: [
                  DateAutoSlashFormatter(),
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  labelText: 'Date',
                  labelStyle: const TextStyle(color: Colors.black54),
                  hintText: 'dd/mm/yyyy',
                  hintStyle: const TextStyle(color: Colors.black26),
                  errorText: _errorText,
                  errorStyle: const TextStyle(color: Colors.redAccent),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black38),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent),
                  ),
                ),
                onChanged: (_) {
                  if (_errorText != null) {
                    setState(() => _errorText = null);
                  }
                },
                onSubmitted: (_) => _validateAndReturn(),
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('CANCEL',
                        style: TextStyle(color: Colors.black54)),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _validateAndReturn,
                    child:
                        const Text('OK', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
