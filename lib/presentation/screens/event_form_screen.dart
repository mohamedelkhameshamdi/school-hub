import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../data/models/event_item.dart';
import '../../data/repositories/school_repository.dart';
import '../widgets/form_shell.dart';

String _hhmm(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key, required this.repository, this.existing});

  final SchoolRepository repository;
  final EventItem? existing;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title);
  late final TextEditingController _description =
      TextEditingController(text: widget.existing?.description);
  late final TextEditingController _location =
      TextEditingController(text: widget.existing?.location);

  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final base = e?.start ?? DateTime.now().add(const Duration(days: 1));
    _date = DateTime(base.year, base.month, base.day);
    _startTime = e != null
        ? TimeOfDay.fromDateTime(e.start)
        : const TimeOfDay(hour: 10, minute: 0);
    _endTime = e != null
        ? TimeOfDay.fromDateTime(e.end)
        : const TimeOfDay(hour: 12, minute: 0);
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  DateTime _combine(TimeOfDay t) =>
      DateTime(_date.year, _date.month, _date.day, t.hour, t.minute);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime({required bool start}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start ? _startTime : _endTime,
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final start = _combine(_startTime);
    final end = _combine(_endTime);
    if (!end.isAfter(start)) {
      setState(() => _error = 'The end time must be after the start time.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repository.saveEvent(
        EventItem(
          id: widget.existing?.id ?? '',
          title: _title.text.trim(),
          description: _description.text.trim(),
          location: _location.text.trim(),
          start: start,
          end: end,
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = "Couldn't save the event. Check your connection and try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormShell(
      title: widget.existing == null ? 'New event' : 'Edit event',
      saveLabel: widget.existing == null ? 'Create event' : 'Save changes',
      formKey: _formKey,
      saving: _saving,
      error: _error,
      onSave: _save,
      children: [
        TextFormField(
          controller: _title,
          textCapitalization: TextCapitalization.sentences,
          decoration: fieldDecoration('Event title', icon: Icons.event_outlined),
          validator: notEmpty('Enter a title', min: 3),
        ),
        TextFormField(
          controller: _description,
          minLines: 4,
          maxLines: 10,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          decoration: fieldDecoration(
            'Description',
            hint: 'What is it about? Who is it for?',
          ),
          validator: notEmpty('Add a description (at least 10 characters)', min: 10),
        ),
        TextFormField(
          controller: _location,
          textCapitalization: TextCapitalization.words,
          decoration: fieldDecoration('Location', icon: Icons.place_outlined),
          validator: notEmpty('Enter a location', min: 2),
        ),
        _PickerField(
          label: 'Date',
          value: fullDate(_date),
          icon: Icons.calendar_today_outlined,
          onTap: _pickDate,
        ),
        Row(
          children: [
            Expanded(
              child: _PickerField(
                label: 'Starts',
                value: _hhmm(_startTime),
                icon: Icons.schedule,
                onTap: () => _pickTime(start: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PickerField(
                label: 'Ends',
                value: _hhmm(_endTime),
                icon: Icons.schedule,
                onTap: () => _pickTime(start: false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: fieldDecoration(label, icon: icon),
        child: Text(value),
      ),
    );
  }
}
