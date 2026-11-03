import 'package:stallion/models/get_all_members_by_project.dart';
import 'package:stallion/models/get_meeting_id.dart';
import 'package:stallion/models/get_user_task_by_id.dart';
import 'package:stallion/models/task_count_modal.dart';
import 'package:stallion/models/task_extend_details.dart';

class TaskManagerMockData {
  /// Global toggle flag for offline visual UI testing with mock data.
  static const bool useMockData = false;

  /// Returns mock list of user tasks for TaskManagerScreen & TaskCountScreen
  static List<UserTask> getMockUserTasks() {
    return [
      UserTask(
        taskId: "101",
        taskTitle: "Review Architectural Drawings & Structural Load Specifications",
        taskDeadline: "15-08-2026",
        assignTo: "Ramesh Sharma (Project Lead)",
        assignBy: "Anil Patel (Site Eng.)",
        taskCreateAt: "01-08-2026",
        taskCompleteStatus: "0", // Pending
        taskRemark: "Awaiting final approval from senior structural engineer.",
        projectIdFk: "1",
      ),
      UserTask(
        taskId: "102",
        taskTitle: "Inspect Concrete Pouring on 12th Floor Slab",
        taskDeadline: "10-08-2026",
        assignTo: "Priya Verma (QC Specialist)",
        assignBy: "Ramesh Sharma (Project Lead)",
        taskCreateAt: "02-08-2026",
        taskCompleteStatus: "1", // Completed
        taskRemark: "Concrete cube test results verified successfully.",
        projectIdFk: "1",
      ),
      UserTask(
        taskId: "103",
        taskTitle: "Submit Electrical Wiring & Piping Compliance Report",
        taskDeadline: "18-08-2026",
        assignTo: "Suresh Gupta (MEP Engineer)",
        assignBy: "Anil Patel (Site Eng.)",
        taskCreateAt: "03-08-2026",
        taskCompleteStatus: "0", // Pending
        taskRemark: "Drafting report with sub-contractor feedback.",
        projectIdFk: "1",
      ),
      UserTask(
        taskId: "104",
        taskTitle: "Safety Barrier & Scaffolding Pre-Monsoon Audit",
        taskDeadline: "05-08-2026",
        assignTo: "Vikram Singh (Safety Officer)",
        assignBy: "Ramesh Sharma (Project Lead)",
        taskCreateAt: "25-07-2026",
        taskCompleteStatus: "0", // Extended
        taskRemark: "Rain delay requested extension by 10 days.",
        projectIdFk: "1",
      ),
    ];
  }

  /// Returns mock list of project meetings
  static List<MettingDatum> getMockMeetings() {
    return [
      MettingDatum(
        mettingId: "201",
        mettingTitle: "Weekly Site Coordination & Progress Sync",
        mettingCreate: "08-08-2026",
        totalTaskAssign: "4",
        totalTaskCompleted: "2",
        taskDetails: getMockUserTasks(),
      ),
      MettingDatum(
        mettingId: "202",
        mettingTitle: "MEP & Electrical Contractor Review",
        mettingCreate: "12-08-2026",
        totalTaskAssign: "3",
        totalTaskCompleted: "1",
        taskDetails: getMockUserTasks().sublist(0, 2),
      ),
      MettingDatum(
        mettingId: "203",
        mettingTitle: "Quality Control & Safety Inspection Meeting test test test",
        mettingCreate: "16-08-2026",
        totalTaskAssign: "2",
        totalTaskCompleted: "0",
        taskDetails: getMockUserTasks().sublist(2, 4),
      ),
    ];
  }

  /// Returns detailed mock UserTask for TaskDetailsScreen
  static UserTask getMockTaskDetails(String? taskId) {
    List<UserTask> tasks = getMockUserTasks();
    return tasks.firstWhere(
      (t) => t.taskId == taskId,
      orElse: () => tasks.first,
    );
  }

  /// Returns detailed mock MettingDatum for MeetingDetailsScreen
  static MettingDatum getMockMeetingDetails(String? meetingId) {
    List<MettingDatum> meetings = getMockMeetings();
    return meetings.firstWhere(
      (m) => m.mettingId == meetingId,
      orElse: () => meetings.first,
    );
  }

  /// Returns mock member details list for project assignments
  static List<MemberDetail> getMockMembers() {
    return [
      MemberDetail(
        memberName: "Ramesh Sharma",
        contactNubmer: "+91 9876543210",
        memberId: "E001",
        designation: "Project Lead",
      ),
      MemberDetail(
        memberName: "Priya Verma",
        contactNubmer: "+91 9876543211",
        memberId: "E002",
        designation: "QC Specialist",
      ),
      MemberDetail(
        memberName: "Suresh Gupta",
        contactNubmer: "+91 9876543212",
        memberId: "E003",
        designation: "MEP Engineer",
      ),
      MemberDetail(
        memberName: "Vikram Singh",
        contactNubmer: "+91 9876543213",
        memberId: "E004",
        designation: "Safety Officer",
      ),
      MemberDetail(
        memberName: "Anil Patel",
        contactNubmer: "+91 9876543214",
        memberId: "E005",
        designation: "Site Manager",
      ),
    ];
  }

  /// Returns mock extension history and remarks for TaskRemarks & timeline graph
  static List<ExtendTaskDetail> getMockTaskRemarks(String? taskId) {
    return [
      ExtendTaskDetail(
        taskExtendDate: "6th Feb 2024",
        taskExtendRemak: "Original project deadline assigned.",
        createdDate: "05-02-2024",
        extendedBy: "Rishab Pawar",
        documents: [
          Document(documentName: "Initial_Scope.pdf"),
        ],
      ),
      ExtendTaskDetail(
        taskExtendDate: "7th Feb 2024",
        taskExtendRemak: "Extended due to architectural revisions.",
        createdDate: "06-02-2024",
        extendedBy: "Rishab Pawar",
        documents: [],
      ),
      ExtendTaskDetail(
        taskExtendDate: "29th Mar 2024",
        taskExtendRemak: "Final extension granted for client approval.",
        createdDate: "07-02-2024",
        extendedBy: "Rishab Pawar",
        documents: [
          Document(documentName: "Revised_Timeline.pdf"),
        ],
      ),
    ];
  }

  /// Returns mock share details for MeetingDetailsScreen
  static List<ShareDetail> getMockShareDetails(String? meetingId) {
    return [
      ShareDetail(
        memberName: "Ramesh Sharma",
        memberId: "E001",
      ),
      ShareDetail(
        memberName: "Priya Verma",
        memberId: "E002",
      ),
    ];
  }

  /// Returns mock TaskArr array for TaskCountScreen
  static List<TaskArr> getMockTaskCountArray() {
    return [
      TaskArr(
        id: "1",
        name: "All Tasks",
        details: Details(
          totalMyTask: "12",
          compMyTask: "5",
          pendMyTask: "5",
          extendedTask: "2",
        ),
      ),
      TaskArr(
        id: "2",
        name: "Meetings",
        details: Details(
          totalMyTask: "4",
          compMyTask: "2",
          pendMyTask: "2",
          extendedTask: "0",
        ),
      ),
    ];
  }
}
