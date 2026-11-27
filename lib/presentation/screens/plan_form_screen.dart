import 'package:flutter/material.dart';

import '../../data/models/plan_item.dart';
import '../../data/repositories/school_repository.dart';
import '../widgets/form_shell.dart';

class PlanFormScreen extends StatefulWidget {
  const PlanFormScreen({super.key, required this.repository, this.existing});

  final SchoolRepository repository;
  final PlanItem? existing;

  @override
  State<PlanFormScreen> createState() => _PlanFormScreenState();
}

class _PlanFormScreenState extends State<PlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title);
  late final TextEditingController _period =
      TextEditingController(text: widget.existing?.period);
  late final TextEditingController _description =
      TextEditingController(text: widget.existing?.description);

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _period.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repository.savePlan(
        PlanItem(
          id: widget.existing?.id ?? '',
          title: _title.text.trim(),
          period: _period.text.trim(),
          description: _description.text.trim(),
          createdAt: widget.existing?.createdAt ?? DateTime.now(),
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = "Couldn't save the plan. Check your connection and try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormShell(
      title: widget.existing == null ? 'Add plan' : 'Edit plan',
      formKey: _formKey,
      saving: _saving,
      error: _error,
      onSave: _save,
      children: [
        TextFormField(
          controller: _title,
          textCapitalization: TextCapitalization.sentences,
          decoration: fieldDecoration('Title', icon: Icons.flag_outlined),
          validator: notEmpty('Enter a title', min: 3),
        ),
        TextFormField(
          controller: _period,
          decoration: fieldDecoration(
            'Period (optional)',
            icon: Icons.date_range_outlined,
            hint: 'e.g. Semester 1 or Spring 2027',
          ),
        ),
        TextFormField(
          controller: _description,
          minLines: 5,
          maxLines: 12,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          decoration: fieldDecoration('Description'),
          validator: notEmpty('Add a description (at least 10 characters)', min: 10),
        ),
      ],
    );
  }
}
