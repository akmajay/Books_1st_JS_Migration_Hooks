import 'package:flutter/material.dart';
import '../../../widgets/forms/app_text_field.dart';
import '../../../widgets/forms/app_dropdown_field.dart';
import '../../../utils/validators.dart';
import '../../../services/school_service.dart';
import '../../../models/school_model.dart';

class AcademicProfileStep extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onSaved;
  final VoidCallback onSkip;

  const AcademicProfileStep({
    super.key,
    required this.initialData,
    required this.onSaved,
    required this.onSkip,
  });

  @override
  State<AcademicProfileStep> createState() => _AcademicProfileStepState();
}

class _AcademicProfileStepState extends State<AcademicProfileStep> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, dynamic> _data;
  List<SchoolModel> _schools = [];
  bool _isLoadingSchools = true;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.initialData);
    _loadSchools();
  }

  Future<void> _loadSchools() async {
    final schools = await SchoolService().getActiveSchools();
    if (mounted) {
      setState(() {
        _schools = schools;
        _isLoadingSchools = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.initialData['user_type'] ?? 'school_student';

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Academic Profile', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Help us show you relevant books.'),
          const SizedBox(height: 32),
          
          if (_isLoadingSchools)
            const Center(child: CircularProgressIndicator())
          else ...[
            AppDropdownField<String>(
              label: 'School / College / Institute',
              value: _data['school']?.toString(),
              items: _schools.map((s) => s.id).toList(),
              itemLabels: _schools.map((s) => s.name).toList(),
              onChanged: (v) => setState(() => _data['school'] = v),
              onSaved: (v) => _data['school'] = v,
              validator: (v) => AppValidators.required(v, 'Please select your institution'),
            ),
            const SizedBox(height: 16),
          ],
          if (type == 'school_student') ...[
            const SizedBox(height: 16),
            AppDropdownField<String>(
              label: 'Board',
              value: _data['board']?.toString(),
              items: const ['CBSE', 'ICSE', 'State Board', 'IB', 'Other'],
              onChanged: (v) => setState(() => _data['board'] = v),
              onSaved: (v) => _data['board'] = v,
            ),
            const SizedBox(height: 16),
            AppDropdownField<String>(
              label: 'Class',
              value: _data['class_year']?.toString(),
              items: const ['Class 8', 'Class 9', 'Class 10', 'Class 11', 'Class 12'],
              onChanged: (v) => setState(() => _data['class_year'] = v),
              onSaved: (v) => _data['class_year'] = v,
            ),
          ] else if (type == 'college_student') ...[
            AppTextField(
              label: 'Branch/Stream',
              initialValue: _data['college_branch']?.toString(),
              onSaved: (v) => _data['college_branch'] = v,
            ),
            const SizedBox(height: 16),
            AppDropdownField<String>(
              label: 'Semester',
              value: _data['college_semester']?.toString(),
              items: const ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4', 'Sem 5', 'Sem 6', 'Sem 7', 'Sem 8'],
              onChanged: (v) => setState(() => _data['college_semester'] = v),
              onSaved: (v) => _data['college_semester'] = v,
            ),
          ] else if (type == 'exam_aspirant') ...[
            AppDropdownField<String>(
              label: 'Preparing For',
              value: _data['exam_type']?.toString(),
              items: const ['JEE', 'NEET', 'UPSC', 'SSC', 'GATE', 'CAT', 'Bank PO', 'Other'],
              onChanged: (v) => setState(() => _data['exam_type'] = v),
              onSaved: (v) => _data['exam_type'] = v,
            ),
          ],

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                widget.onSaved(_data);
              }
            },
            child: const Text('Continue'),
          ),
          TextButton(onPressed: widget.onSkip, child: const Text('Skip for now')),
        ],
      ),
    );
  }
}
