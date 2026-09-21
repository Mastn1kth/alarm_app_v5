import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_app/domain/services/alarm_scheduler_service.dart';

void main() {
  group('AlarmStateMachine', () {
    late AlarmStateMachine machine;

    setUp(() {
      machine = AlarmStateMachine();
    });

    test('initial state should be scheduled', () {
      expect(machine.getState('alarm-1'), AlarmState.scheduled);
    });

    test('should transition from scheduled to ringing', () {
      final result = machine.transition('alarm-1', AlarmState.ringing);
      expect(result, true);
      expect(machine.getState('alarm-1'), AlarmState.ringing);
    });

    test('should transition from ringing to completed', () {
      machine.transition('alarm-1', AlarmState.ringing);
      final result = machine.transition('alarm-1', AlarmState.completed);
      expect(result, true);
      expect(machine.getState('alarm-1'), AlarmState.completed);
    });

    test('should reject invalid transitions', () {
      // Cannot go from scheduled to completed directly
      final result = machine.transition('alarm-1', AlarmState.completed);
      expect(result, false);
      expect(machine.getState('alarm-1'), AlarmState.scheduled);
    });

    test('should allow snooze from ringing', () {
      machine.transition('alarm-1', AlarmState.ringing);
      final result = machine.transition('alarm-1', AlarmState.snoozed);
      expect(result, true);
    });

    test('should allow re-ringing from snoozed', () {
      machine.transition('alarm-1', AlarmState.ringing);
      machine.transition('alarm-1', AlarmState.snoozed);
      final result = machine.transition('alarm-1', AlarmState.ringing);
      expect(result, true);
    });

    test('should cancel from scheduled', () {
      final result = machine.transition('alarm-1', AlarmState.cancelled);
      expect(result, true);
      expect(machine.getState('alarm-1'), AlarmState.cancelled);
    });

    test('should reschedule from cancelled', () {
      machine.transition('alarm-1', AlarmState.cancelled);
      final result = machine.transition('alarm-1', AlarmState.scheduled);
      expect(result, true);
    });

    test('should track history', () {
      machine.transition('alarm-1', AlarmState.ringing);
      machine.transition('alarm-1', AlarmState.completed);

      final history = machine.getHistory('alarm-1');
      expect(history.length, 2);
      expect(history[0].toState, AlarmState.ringing);
      expect(history[1].toState, AlarmState.completed);
    });

    test('should get active alarms', () {
      machine.transition('alarm-1', AlarmState.scheduled);
      machine.transition('alarm-2', AlarmState.ringing);
      machine.transition('alarm-3', AlarmState.completed);

      final activeIds = machine.getActiveAlarmIds();
      expect(activeIds, contains('alarm-1'));
      expect(activeIds, contains('alarm-2'));
      expect(activeIds, isNot(contains('alarm-3')));
    });

    test('should get ringing alarms', () {
      machine.transition('alarm-1', AlarmState.ringing);
      machine.transition('alarm-2', AlarmState.scheduled);

      final ringingIds = machine.getRingingAlarmIds();
      expect(ringingIds, contains('alarm-1'));
      expect(ringingIds, isNot(contains('alarm-2')));
    });

    test('should reset state for repeating alarms', () {
      machine.transition('alarm-1', AlarmState.ringing);
      machine.transition('alarm-1', AlarmState.completed);
      machine.reset('alarm-1');

      expect(machine.getState('alarm-1'), AlarmState.scheduled);
      // History should be preserved
      expect(machine.getHistory('alarm-1'), isNotEmpty);
    });
  });
}
