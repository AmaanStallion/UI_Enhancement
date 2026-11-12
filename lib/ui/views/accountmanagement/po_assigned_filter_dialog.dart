import 'package:flutter/material.dart';
import 'package:stallion/models/sales_lead_filter.dart';

/// Presentation only: the caller owns selections and filter actions.
class PoAssignedFilterDialog extends StatefulWidget {
  const PoAssignedFilterDialog(
      {super.key,
      required this.groups,
      required this.onReset,
      required this.onApply,
      this.isPreview = false});
  final List<FilterList> groups;
  final VoidCallback onReset;
  final VoidCallback onApply;
  final bool isPreview;

  @override
  State<PoAssignedFilterDialog> createState() => _PoAssignedFilterDialogState();
}

class _PoAssignedFilterDialogState extends State<PoAssignedFilterDialog> {
  int selected = 0;
  String query = '';
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final groups = widget.groups;
    final options = groups.isEmpty
        ? <Detail>[]
        : (groups[selected].details ?? <Detail>[])
            .where((item) =>
                (item.name ?? '').toLowerCase().contains(query.toLowerCase()))
            .toList();
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      actionsPadding: const EdgeInsets.all(12),
      title: Container(
          color: Colors.black,
          padding: const EdgeInsets.all(16),
          child: const Text('FILTER',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600))),
      content: SizedBox(
          width: 640,
          height: (size.height * .52).clamp(180.0, 420.0),
          child: Column(children: [
            if (widget.isPreview)
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('Sample options · UI preview',
                      style: TextStyle(fontSize: 11, color: Colors.black54))),
            Expanded(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  Expanded(
                      flex: 2,
                      child: ColoredBox(
                          color: const Color(0xFFF2F2F2),
                          child: ListView.builder(
                              itemCount: groups.length,
                              itemBuilder: (_, index) {
                                final group = groups[index];
                                return InkWell(
                                    onTap: () => setState(() {
                                          selected = index;
                                          query = '';
                                          search.clear();
                                        }),
                                    child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 16),
                                        decoration: BoxDecoration(
                                            color: selected == index
                                                ? Colors.white
                                                : Colors.transparent,
                                            border: Border(
                                                left: BorderSide(
                                                    width: 3,
                                                    color: selected == index
                                                        ? Colors.black
                                                        : Colors.transparent))),
                                        child: Text(
                                            '${group.name ?? ''}${group.ct > 0 ? ' (${group.ct})' : ''}',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: selected == index
                                                    ? FontWeight.w600
                                                    : FontWeight.w400))));
                              }))),
                  Expanded(
                      flex: 3,
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(children: [
                            TextField(
                                controller: search,
                                onChanged: (value) =>
                                    setState(() => query = value),
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                    hintText: 'Search',
                                    filled: true,
                                    fillColor: Colors.white,
                                    isDense: true,
                                    prefixIcon:
                                        const Icon(Icons.search, size: 20),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)))),
                            const SizedBox(height: 8),
                            Expanded(
                                child: options.isEmpty
                                    ? const Center(
                                        child: Text('No options found',
                                            style: TextStyle(fontSize: 13)))
                                    : ListView.separated(
                                        itemCount: options.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 6),
                                        itemBuilder: (_, index) {
                                          final option = options[index];
                                          return Material(
                                              color: const Color(0xFFF2F2F2),
                                              borderRadius:
                                                  BorderRadius.circular(9),
                                              child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(9),
                                                  onTap: () => setState(() {
                                                        option.isSelected =
                                                            option.isSelected !=
                                                                true;
                                                        groups[selected]
                                                            .ct = (groups[
                                                                        selected]
                                                                    .details ??
                                                                <Detail>[])
                                                            .where((item) =>
                                                                item.isSelected ==
                                                                true)
                                                            .length;
                                                      }),
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Row(children: [
                                                        Expanded(
                                                            child: Text(
                                                                option.name ??
                                                                    '',
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        13))),
                                                        const SizedBox(
                                                            width: 6),
                                                        Icon(
                                                            option.isSelected ==
                                                                    true
                                                                ? Icons
                                                                    .check_box_rounded
                                                                : Icons
                                                                    .check_box_outline_blank,
                                                            color: Colors.black,
                                                            size: 20),
                                                      ]))));
                                        })),
                          ]))),
                ])),
          ])),
      actions: [
        Row(children: [
          Expanded(
              child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black),
                      shape: const StadiumBorder()),
                  onPressed: () {
                    setState(() {
                      query = '';
                      search.clear();
                    });
                    widget.onReset();
                  },
                  child: const Text('RESET'))),
          const SizedBox(width: 10),
          Expanded(
              child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder()),
                  onPressed: widget.onApply,
                  child: const Text('APPLY FILTER'))),
        ])
      ],
    );
  }
}
