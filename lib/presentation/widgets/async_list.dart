import 'dart:async';

import 'package:flutter/material.dart';

import 'state_views.dart';

enum _Status { loading, success, error }

/// Listens to a live stream of items and handles every state for you:
/// skeleton loading, error + retry, empty, and the list itself.
/// Used by News, Events and Plans, so the UX is identical everywhere.
class AsyncList<T> extends StatefulWidget {
  const AsyncList({
    super.key,
    required this.stream,
    required this.itemBuilder,
    required this.emptyMessage,
  });

  final Stream<List<T>> Function() stream;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String emptyMessage;

  @override
  State<AsyncList<T>> createState() => _AsyncListState<T>();
}

class _AsyncListState<T> extends State<AsyncList<T>> {
  StreamSubscription<List<T>>? _subscription;
  _Status _status = _Status.loading;
  List<T> _items = [];

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _subscribe() {
    _subscription?.cancel();
    _subscription = widget.stream().listen(
      (data) {
        if (!mounted) return;
        setState(() {
          _items = data;
          _status = _Status.success;
        });
      },
      onError: (Object _) {
        if (!mounted) return;
        setState(() => _status = _Status.error);
      },
    );
  }

  void _retry() {
    setState(() => _status = _Status.loading);
    _subscribe();
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;
    switch (_status) {
      case _Status.loading:
        child = const LoadingList(key: ValueKey('loading'));
      case _Status.error:
        child = ErrorView(key: const ValueKey('error'), onRetry: _retry);
      case _Status.success:
        child = _items.isEmpty
            ? EmptyView(
                key: const ValueKey('empty'),
                message: widget.emptyMessage,
              )
            : ListView.separated(
                key: const ValueKey('list'),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) =>
                    widget.itemBuilder(context, _items[i]),
              );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: child,
    );
  }
}
