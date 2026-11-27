import 'package:flutter/material.dart';

import '../../data/models/app_user.dart';
import '../../data/models/plan_item.dart';
import '../../data/repositories/school_repository.dart';
import '../widgets/async_list.dart';
import '../widgets/dialogs.dart';
import '../widgets/plan_card.dart';
import 'plan_form_screen.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({
    super.key,
    required this.repository,
    required this.user,
  });

  final SchoolRepository repository;
  final AppUser user;

  Future<void> _edit(BuildContext context, PlanItem item) async {
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => PlanFormScreen(repository: repository, existing: item),
      ),
    );
  }

  Future<void> _delete(BuildContext context, PlanItem item) async {
    final ok = await confirmDelete(context, title: 'Delete this plan?');
    if (!ok) return;
    try {
      await repository.deletePlan(item.id);
    } catch (_) {
      if (context.mounted) {
        showMessage(context, "Couldn't delete the plan. Try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AsyncList<PlanItem>(
      stream: repository.watchPlans,
      emptyMessage: user.isAdmin
          ? 'No plans yet.\nTap "Add plan" to create the first one.'
          : 'No plans published yet.\nCheck back soon.',
      itemBuilder: (context, item) => PlanCard(
        item: item,
        onEdit: user.isAdmin ? () => _edit(context, item) : null,
        onDelete: user.isAdmin ? () => _delete(context, item) : null,
      ),
    );
  }
}
