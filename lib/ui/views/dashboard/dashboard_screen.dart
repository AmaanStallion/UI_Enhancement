import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stallion/ui/views/dashboard/projectlist_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({Key? key, this.callback}) : super(key: key);

  final Function? callback;

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  Widget build(BuildContext context) {
    // return Scaffold(body: ProjectListScreenView(callback: widget.callback));
    return ProjectListScreenView(callback: widget.callback);
  }
}
