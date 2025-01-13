import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class AppointmentReviewScreen extends StatefulWidget {
  const AppointmentReviewScreen({super.key});

  @override
  State<AppointmentReviewScreen> createState() =>
      _AppointmentReviewScreenState();
}

class _AppointmentReviewScreenState extends State<AppointmentReviewScreen> {
  String defaultImagePath = '.dart_tool/assets/logo.png';
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  TextEditingController _commentController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
        title: "Review",
        child: Container(
            child: SingleChildScrollView(
                child: Column(children: [
          SizedBox(
            width: 600,
            child: Image.asset(defaultImagePath),
          ),
          TextField(
            decoration: InputDecoration(labelText: "Comment"),
            controller: _commentController,
          ),
          _formBuild()
        ]))));
  }

  FormBuilder _formBuild() {
    return FormBuilder(
        key: _formKey,
        initialValue: _initialValue,
        child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(20),
            child: Row()));
  }
}
