import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';

import '../../../models/get_team_list.dart';
import '../../../utils/api_network_call.dart';
import '../../../utils/app_url.dart';

class TeamListView extends StatefulWidget {
  const TeamListView(
      {Key? key,
      this.projectId,
      this.towarId,
      this.projectName,
      this.towarName})
      : super(key: key);
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  @override
  State<TeamListView> createState() => _TeamListViewState();
}

class _TeamListViewState extends State<TeamListView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final NetworkHandler apiNetworkHandler = NetworkHandler();

  // full list from API
  List<TemaDetail?> _allTemaDetails = [];

  // filtered list for UI
  List<TemaDetail?> _filteredTemaDetails = [];

  bool _loadedOnce = false;
  bool _noRecord = false;

  // search (in body)
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchGetTeamList();
    _searchCtrl.addListener(() => _applyFilter(_searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _applyFilter(String raw) {
    final q = raw.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        _filteredTemaDetails = List<TemaDetail?>.from(_allTemaDetails);
        _noRecord = _filteredTemaDetails.isEmpty;
      });
      return;
    }

    bool hit(String? s) => (s ?? '').toLowerCase().contains(q);

    final filtered = _allTemaDetails.where((t) {
      if (t == null) return false;
      final companyHit = hit(t.compayName);
      final typeHit = hit(t.typeName);
      final memberHit = (t.memberDetails ?? []).any((m) {
        if (m == null) return false;
        return hit(m.memberName) || hit(m.designation) || hit(m.contactNubmer);
      });
      return companyHit || typeHit || memberHit;
    }).toList();

    setState(() {
      _filteredTemaDetails = filtered;
      _noRecord = filtered.isEmpty;
    });
  }

  Future<void> fetchGetTeamList() async {
    try {
      final prefs = await _prefs;
      final userId = prefs.getString('mobileNo');
      if (userId == null || widget.projectId == null) {
        setState(() {
          _loadedOnce = true;
          _noRecord = true;
        });
        return;
      }

      final data = {"user_id": userId, "project_id": widget.projectId!};
      if (kDebugMode) print(data);

      final response =
          await apiNetworkHandler.post(AppUrl.webgetTeamList, data);
      if (kDebugMode) print(response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = getTeamListFromJson(response.body);
        if (dataModel?.response?.errorCode == "0") {
          final list = dataModel?.response?.temaDetails ?? [];
          setState(() {
            _allTemaDetails = list;
            _filteredTemaDetails = List<TemaDetail?>.from(list);
            _loadedOnce = true;
            _noRecord = list.isEmpty;
          });
        } else {
          setState(() {
            _loadedOnce = true;
            _noRecord = true;
          });
        }
      } else {
        if (kDebugMode) print(response.body);
        setState(() {
          _loadedOnce = true;
          _noRecord = true;
        });
      }
    } catch (e) {
      if (kDebugMode) print(e);
      setState(() {
        _loadedOnce = true;
        _noRecord = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasTower = (widget.towarName != null) && widget.towarName!.isNotEmpty;
    final temaDetails = _filteredTemaDetails;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          hasTower
              ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
              : widget.projectName!.toUpperCase(),
          style: const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: !_loadedOnce
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // SEARCH BAR IN BODY
                  Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child:
                          // TextField(
                          //   controller: _searchCtrl,
                          //   focusNode: _searchFocus,
                          //   decoration: InputDecoration(
                          //     hintText: 'Search company, type, or member',
                          //     prefixIcon: const Icon(Icons.search),
                          //     suffixIcon: (_searchCtrl.text.isEmpty)
                          //         ? null
                          //         : IconButton(
                          //             tooltip: 'Clear',
                          //             icon: const Icon(Icons.close),
                          //             onPressed: () {
                          //               // safe clear: no AppBar swap here, so focus churn is fine
                          //               _searchCtrl
                          //                   .clear(); // triggers listener -> _applyFilter('')
                          //             },
                          //           ),
                          //     border: const OutlineInputBorder(),
                          //     isDense: true,
                          //   ),
                          //   textInputAction: TextInputAction.search,
                          // ),
                          // in initState: remove _searchCtrl.addListener(...)
// keep _applyFilter(String) as-is

// TextField:
                          TextField(
                        controller: _searchCtrl,
                        focusNode: _searchFocus,
                        decoration: InputDecoration(
                          hintText: 'Search company, type, or member',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: (_searchCtrl.text.isEmpty)
                              ? null
                              : IconButton(
                                  tooltip: 'Clear',
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _applyFilter(
                                        ''); // since onChanged won't fire on programmatic clear
                                    setState(
                                        () {}); // refresh suffixIcon visibility
                                  },
                                ),
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        textInputAction: TextInputAction.search,
                        onChanged: (value) {
                          _applyFilter(value);
                          setState(
                              () {}); // ensures suffixIcon + list refresh on each keystroke/backspace
                        },
                      )),

                  if (_noRecord)
                    const Expanded(
                      child: Center(child: Text('No records found')),
                    )
                  else
                    // LIST
                    Expanded(
                      child: ExpandedTileList.builder(
                        // key: ValueKey(
                        //     _filteredTemaDetails.length), // <-- add this
                        key: ValueKey(temaDetails
                            .map((e) => e?.companyId ?? '')
                            .join('|')),

                        itemCount: temaDetails.length,
                        reverse: false,
                        shrinkWrap: true,
                        itemBuilder: (context, index, controller) {
                          final item = temaDetails[index];
                          if (item == null) const SizedBox.shrink();

                          // choose a stable unique identifier if you have it (e.g., teamId)
                          final tileKey = ValueKey(
                              '${item?.compayName ?? ''}-${item?.typeName ?? ''}');

                          final members =
                              item?.memberDetails ?? const <MemberDetail?>[];
                          final memberCount = members.length;
                          final double itemHeight =
                              (memberCount * 82).toDouble();

                          return ExpandedTile(
                            key: tileKey,
                            theme: const ExpandedTileThemeData(
                              headerColor: Colors.white,
                              //headerRadius: 0.0,
                              headerPadding: EdgeInsets.only(
                                  left: 24.0, right: 24.0, top: 5, bottom: 5),
                              headerSplashColor: Colors.white,
                              contentBackgroundColor: Colors.white,
                              //contentRadius: 0.0,
                            ),
                            controller: controller,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12.0),
                                Text(
                                  (item?.compayName ?? '').toString(),
                                  style: const TextStyle(
                                      fontSize: 17, color: Colors.black),
                                ),
                                const SizedBox(height: 5.0),
                                Text(
                                  (item?.typeName ?? '')
                                      .toString()
                                      .capitalize(),
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black38),
                                ),
                                const SizedBox(height: 12.0),
                                const Divider(
                                    height: 1,
                                    thickness: 0.5,
                                    color: Colors.black),
                              ],
                            ),
                            content: SizedBox(
                              width: double.infinity,
                              height: itemHeight,
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: memberCount,
                                itemBuilder: (context, i) {
                                  final m = members[i];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxHeight: 80,
                                                maxWidth: 80,
                                              ),
                                              child: Image.asset(
                                                  'images/profile-icon.png'),
                                            ),
                                            const SizedBox(width: 30.0),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    (m?.memberName ?? '')
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 17,
                                                        color: Colors.black)),
                                                Text(
                                                    (m?.designation ?? '')
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey)),
                                                Text(
                                                    (m?.contactNubmer ?? '')
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.blue)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const Divider(
                                            height: 1,
                                            thickness: 0.5,
                                            color: Colors.black),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
