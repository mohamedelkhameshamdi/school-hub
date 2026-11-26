import 'package:flutter/material.dart';

import 'state_views.dart';

enum _Status { loading, success, error }

/// Loads a list asynchronously and handles every state for you:
/// skeleton loading, error + retry, empty, content with pull-to-refresh.
/// Used by both the News and Events screens, so the UX is identical.
class AsyncList<T> extends StatefulWidget {
  const AsyncList({
    super.key,
    required this.load,
    required this.itemBuilder,
    required this.emptyMessage,
  });

  final Future<List<T>> Function() load;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String emptyMessage;

  @override
  State<AsyncList<T>> createState() => _AsyncListState<T>();
}

class _AsyncListState<T> extends State<AsyncList<T>> {
  _Status _status = _Status.loading;
  List<T> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && _status != _Status.loading) {
      setState(() => _status = _Status.loading);
    }
    try {
      final data = await widget.load();
      if (!mounted) return;
      setState(() {
        _items = data;
        _status = _Status.success;
      });
    } catch (_) {
      if (!mounted) return;
      if (silent && _items.isNotEmpty) {
        // Pull-to-refresh failed: keep what the user already sees.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't refresh. Showing the last update."),
          ),
        );
      } else {
        setState(() => _status = _Status.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;
    switch (_status) {
      case _Status.loading:
        child = const LoadingList(key: ValueKey('loading'));
      case _Status.error:
        child = ErrorView(
          key: const ValueKey('error'),
          onRetry: () => _load(),
        );
      case _Status.success:
        child = _items.isEmpty
            ? EmptyView(
                key: const ValueKey('empty'),
                message: widget.emptyMessage,
              )
            : RefreshIndicator(
                key: const ValueKey('list'),
                onRefresh: () => _load(silent: true),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) =>
                      widget.itemBuilder(context, _items[i]),
                ),
              );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: child,
    );
  }
}
