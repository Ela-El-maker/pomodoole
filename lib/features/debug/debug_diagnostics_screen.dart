import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodorofocus/state/session/session_providers.dart';

class DebugDiagnosticsScreen extends ConsumerWidget {
  const DebugDiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionControllerProvider);
    final appTheme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Debug Diagnostics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Session State', style: appTheme.textTheme.titleLarge),
          const SizedBox(height: 8),
          _InfoTile(label: 'Phase', value: sessionState.phase.name),
          _InfoTile(label: 'Time', value: sessionState.formattedRemainingTime),
          _InfoTile(label: 'Session Label', value: sessionState.sessionLabel),
          _InfoTile(
            label: 'Cycle Index',
            value: '${sessionState.sessionInCycle}',
          ),
          _InfoTile(
            label: 'Completed Sessions',
            value: '${sessionState.completedSessions}',
          ),
          _InfoTile(
            label: 'Current Task',
            value: sessionState.currentTask.isEmpty
                ? '(none)'
                : sessionState.currentTask,
          ),
          _InfoTile(
            label: 'Interrupted Snapshot',
            value: sessionState.interruptedSnapshot == null
                ? 'None'
                : sessionState.interruptedSnapshot.toString(),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
