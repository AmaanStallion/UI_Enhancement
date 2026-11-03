import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_all_members_by_project.dart';
import 'package:stallion/models/tenant_payment_list.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/task_manager/assign_meeting.dart';
import 'package:stallion/ui/views/task_manager/task_manager_mock_data.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';

class CreateNewMeeting extends StatefulWidget {
  const CreateNewMeeting({
    super.key,
    this.towarId,
    this.projectId,
    this.projectName,
    this.towarName,
  });
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  @override
  State<CreateNewMeeting> createState() => _CreateNewMeetingState();
}

class _CreateNewMeetingState extends State<CreateNewMeeting> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<MemberDetail>? memberDetailsRes = [];
  List<MemberDetail>? selectedMember = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _participantsController = TextEditingController();
  TextEditingController _titleController = TextEditingController();

  String participantsNumberSelected = '';
  Future<List<TenantPaymentListElement>?> getMembersByProject() async {
    if (TaskManagerMockData.useMockData) {
      setState(() {
        memberDetailsRes = TaskManagerMockData.getMockMembers();
      });
      return null;
    }

    try {
      if (AppUrl.useNewBackend && widget.projectId != null && widget.projectId!.isNotEmpty) {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
        var response = await apiNetworkHandler.get(
          AppUrl.getProjectUsers(widget.projectId!),
        );
        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic> && decoded['success'] == true) {
            final List users = decoded['data'] as List? ?? [];
            List<MemberDetail> parsed = users.map((u) {
              return MemberDetail(
                memberId: u['id']?.toString(),
                memberName: u['name']?.toString(),
                isSelected: false,
              );
            }).toList();
            setState(() {
              memberDetailsRes = parsed;
            });
            return null;
          }
        }
      }

      final SharedPreferences prefs = await _prefs;
      String? userId = prefs.getString('mobileNo');

      Map<String, String> data = {
        "user_id": userId ?? '',
        "project_id": widget.projectId ?? '',
        "towar_id": widget.towarId ?? '',
      };

      if (kDebugMode) {
        print(data);
      }

      var response =
          await apiNetworkHandler.post(AppUrl.getMemberByProject, data);

      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = getAllMembersByProjectFromJson(response.body);

        if (kDebugMode) {
          print(dataModel.response?.errorCode);
        }

        if (dataModel.response?.errorCode == "0") {
          setState(() {
            memberDetailsRes = dataModel.response?.memberDetails;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('CreateNewMeeting: Error fetching project members: $e');
      }
    }
    return null;
  }

  @override
  void initState() {
    getMembersByProject();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return Scaffold(
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 24, vertical: 8),
        child: InkWell(
          onTap: () {
            if (_formKey.currentState!.validate()) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return AssignMeeting(
                      isFromCreateNewMeeting: true,
                      memberDetailsRes: selectedMember,
                      projectId: widget.projectId,
                      towarId: widget.towarId!,
                      projectName: widget.projectName,
                      towarName: widget.towarName!,
                      mettingTilte: _titleController.text,
                    );
                  },
                ),
              );
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(25),
            ),
            width: double.maxFinite,
            child: Text(
              "ADD TASK",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            widget.towarName!.isNotEmpty
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                : widget.projectName!.toUpperCase(),
            style: TextStyle(
                fontStyle: FontStyle.normal,
                fontSize: isMobile ? 14.0 : 17.0)),
      ),
      body: _buildBodyContent(isMobile),
    );
  }

  Widget _buildBodyContent(bool isMobile) {
    final labelWidth = isMobile ? 75.0 : 130.0;
    final fontSize = isMobile ? 13.0 : 15.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          SizedBox(
            width: double.maxFinite,
            child: AppText(
              title: "CREATE MEETING",
              fontSize: isMobile ? 15 : 17,
              fontWeight: FontWeight.w700,
              titleTextAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 24, vertical: 6),
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16, vertical: isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Of Creation Row
                  Row(
                    children: [
                      SizedBox(
                        width: labelWidth,
                        child: Text(
                          'Date Of Creation',
                          style: TextStyle(fontSize: fontSize, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Center(child: Icon(Icons.remove, size: isMobile ? 12 : 16, color: Colors.black54)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          DateFormat('dd MMM yyyy').format(DateTime.now()).toString(),
                          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title Row
                  Row(
                    children: [
                      SizedBox(
                        width: labelWidth,
                        child: Text(
                          'Title',
                          style: TextStyle(fontSize: fontSize, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Center(child: Icon(Icons.remove, size: isMobile ? 12 : 16, color: Colors.black54)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "(Title Cannot be Empty)";
                            }
                            return null;
                          },
                          controller: _titleController,
                          style: TextStyle(color: Colors.black, fontSize: fontSize),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.black54),
                            ),
                            hintText: 'Enter Title',
                            hintStyle: TextStyle(fontSize: fontSize, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Participants Row
                  Row(
                    children: [
                      SizedBox(
                        width: labelWidth,
                        child: Text(
                          'Participants',
                          style: TextStyle(fontSize: fontSize, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Center(child: Icon(Icons.remove, size: isMobile ? 12 : 16, color: Colors.black54)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            customShowUpdateDialog();
                          },
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "(Please Select Participants)";
                              }
                              return null;
                            },
                            enabled: false,
                            readOnly: true,
                            controller: _participantsController,
                            style: TextStyle(color: Colors.black, fontSize: fontSize),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.black54),
                              ),
                              hintText: 'Select Participants',
                              hintStyle: TextStyle(fontSize: fontSize, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  customShowUpdateDialog() {
    TextEditingController searchController = TextEditingController();
    List<MemberDetail> filteredMembers = List.from(memberDetailsRes ?? []);

    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState1) {
            void filterSearch(String query) {
              setState1(() {
                if (query.trim().isEmpty) {
                  filteredMembers = List.from(memberDetailsRes ?? []);
                } else {
                  filteredMembers = (memberDetailsRes ?? [])
                      .where((member) =>
                          member.memberName
                              ?.toLowerCase()
                              .contains(query.toLowerCase()) ??
                          false)
                      .toList();
                }
              });
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                width: double.infinity,
                child: const Text(
                  "Select Participants",
                  style: TextStyle(
                    fontFamily: 'HelveticaNeue',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: SizedBox(
                height: 340,
                width: 400,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: TextField(
                        onChanged: filterSearch,
                        style: const TextStyle(fontSize: 13),
                        controller: searchController,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            labelText: "Search by Name",
                            hintText: "Search by Name",
                            prefixIcon: Icon(Icons.search, size: 18),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)))),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredMembers.length,
                        itemBuilder: (context, i) {
                          final item = filteredMembers[i];
                          final bool isSelected = item.isSelected == true;
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.withValues(alpha: 0.15),
                                ),
                              ),
                            ),
                            margin: const EdgeInsets.only(bottom: 4),
                            child: InkWell(
                              onTap: () {
                                setState1(() {
                                  item.isSelected = !isSelected;
                                });
                                final indexInOriginal = (memberDetailsRes ?? [])
                                    .indexWhere((m) => m.memberId == item.memberId);
                                if (indexInOriginal != -1) {
                                  memberDetailsRes![indexInOriginal].isSelected = item.isSelected;
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xfff8f9fa)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.memberName ?? '',
                                      style: TextStyle(
                                        fontFamily: 'HelveticaNeue',
                                        fontSize: 15,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.black87,
                                      ),
                                    ),
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_outline_rounded
                                          : Icons.circle_outlined,
                                      color: isSelected ? Colors.green : Colors.grey,
                                      size: 20,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black54),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Close',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _participantsController.clear();
                            setState1(() {
                              participantsNumberSelected = '';
                              selectedMember?.clear();
                            });
                            for (int i = 0; i < (memberDetailsRes?.length ?? 0); i++) {
                              if (memberDetailsRes?[i].isSelected == true) {
                                setState1(() {
                                  participantsNumberSelected =
                                      participantsNumberSelected.trim() == ''
                                          ? '${memberDetailsRes?[i].memberId}'
                                          : "$participantsNumberSelected,${memberDetailsRes?[i].memberId ?? ''}";
                                  selectedMember?.add(memberDetailsRes![i]);
                                });
                                _participantsController.text =
                                    _participantsController.text.trim() == ''
                                        ? '${memberDetailsRes?[i].memberName}'
                                        : "${_participantsController.text},${memberDetailsRes?[i].memberName ?? ''}";
                              }
                            }
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20)),
                            child: const Text(
                              "OK",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
