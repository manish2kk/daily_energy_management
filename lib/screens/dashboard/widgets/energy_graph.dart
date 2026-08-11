import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../utils/date_utils.dart';

class EnergyGraph extends StatefulWidget {
  final List<Map<String, Object?>> rows;

  const EnergyGraph({super.key, required this.rows});

  @override
  State<EnergyGraph> createState() => _EnergyGraphState();
}

class _EnergyGraphState extends State<EnergyGraph> {
  static const _weeks = 53;
  static const _cell = 14.0;
  static const _gap = 2.0;
  static const _colWidth = _cell + _gap;

  static const _c4PlusDark = Color(0xFF57D364);
  static const _c3Dark = Color(0xFF2DA044);
  static const _c2Dark = Color(0xFF186C2D);
  static const _c1Dark = Color(0xFF023A16);
  static const _c0Dark = Color(0xFF151B23);

  static const _c4PlusLight = Color(0xFF065C24);
  static const _c3Light = Color(0xFF2F8A46);
  static const _c2Light = Color(0xFF48B55E);
  static const _c1Light = Color(0xFF7FD488);
  static const _c0Light = Color(0xFFFAFAFA);
  static const _graphBgLight = Color(0xFFE8EAED);

  final _scroll = ScrollController();
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentWeek());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToCurrentWeek() {
    if (!_scroll.hasClients) return;
    _scroll.jumpTo(_scroll.position.maxScrollExtent);
  }

  bool _dischargeOn(DateTime d) => widget.rows.any(
        (r) =>
            r['category'] == 'discharge' &&
            sameDay(DateTime.parse(r['date'] as String), d),
      );

  int _chargingOn(DateTime d) => widget.rows
      .where(
        (r) =>
            r['category'] != 'discharge' &&
            sameDay(DateTime.parse(r['date'] as String), d),
      )
      .length;

  int _totalOn(DateTime d) => widget.rows
      .where((r) => sameDay(DateTime.parse(r['date'] as String), d))
      .length;

  bool get _isLight => Theme.of(context).brightness == Brightness.light;

  Color _emptyColor() => _isLight ? _c0Light : _c0Dark;

  Color _levelColor(int count) {
    if (_isLight) {
      if (count >= 4) return _c4PlusLight;
      if (count == 3) return _c3Light;
      if (count == 2) return _c2Light;
      if (count == 1) return _c1Light;
      return _c0Light;
    }
    if (count >= 4) return _c4PlusDark;
    if (count == 3) return _c3Dark;
    if (count == 2) return _c2Dark;
    if (count == 1) return _c1Dark;
    return _c0Dark;
  }

  Color _cellColor(DateTime d, {required bool isFuture}) {
    if (isFuture) {
      return _isLight
          ? Colors.white.withValues(alpha: .55)
          : Theme.of(context).dividerColor.withValues(alpha: .08);
    }
    if (_dischargeOn(d)) return Colors.red;
    return _levelColor(_chargingOn(d));
  }

  /// Month for a week column: if the week spans two months, use the newer one.
  DateTime _weekMonth(DateTime weekSunday) {
    final weekEnd = weekSunday.add(const Duration(days: 6));
    return DateTime(weekEnd.year, weekEnd.month);
  }

  String _tooltipText(DateTime d) {
    final date = DateFormat('d MMMM y').format(d);
    final total = _totalOn(d);
    final unit = total == 1 ? 'completion' : 'completions';
    if (_dischargeOn(d)) {
      return '$date · $total $unit (includes discharge)';
    }
    return '$date · $total $unit';
  }

  void _selectDay(DateTime d, {required bool isFuture}) {
    if (isFuture) return;
    setState(() {
      final day = dateOnly(d);
      _selected = _selected != null && sameDay(_selected!, day) ? null : day;
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final thisWeekSunday = startOfWeekSunday(today);
    final monthFmt = DateFormat('MMM');

    final weekSundays = List.generate(_weeks, (w) {
      final weeksAgo = _weeks - 1 - w;
      return thisWeekSunday.subtract(Duration(days: weeksAgo * 7));
    });

    final monthLabels = <String?>[];
    DateTime? prevMonth;
    for (final sunday in weekSundays) {
      final month = _weekMonth(sunday);
      if (prevMonth != null &&
          prevMonth.year == month.year &&
          prevMonth.month == month.month) {
        monthLabels.add(null);
      } else {
        monthLabels.add(monthFmt.format(month));
        prevMonth = month;
      }
    }

    return Column(
      children: [
        Card(
          color: Theme.of(context).brightness == Brightness.light
              ? _graphBgLight
              : null,
          clipBehavior: Clip.none,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: SingleChildScrollView(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(_weeks, (w) {
                  final weekSunday = weekSundays[w];
                  final label = monthLabels[w];

                  return SizedBox(
                    width: _colWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 16,
                          child: label == null
                              ? null
                              : OverflowBox(
                                  alignment: Alignment.centerLeft,
                                  minWidth: 0,
                                  maxWidth: 36,
                                  child: Text(
                                    label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 4),
                        ...List.generate(7, (dayIndex) {
                          final d = weekSunday.add(Duration(days: dayIndex));
                          final isFuture = d.isAfter(today);
                          final selected =
                              _selected != null && sameDay(_selected!, d);

                          final cell = GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapDown: isFuture
                                ? null
                                : (_) => _selectDay(d, isFuture: false),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: _gap),
                              child: Container(
                                width: _cell,
                                height: _cell,
                                decoration: BoxDecoration(
                                  color: _cellColor(
                                    d,
                                    isFuture: isFuture,
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                    color: selected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .dividerColor
                                            .withValues(alpha: .15),
                                    width: selected ? 1.5 : 1,
                                  ),
                                ),
                              ),
                            ),
                          );

                          if (isFuture) return cell;
                          return Tooltip(
                            message: _tooltipText(d),
                            waitDuration: const Duration(milliseconds: 400),
                            child: cell,
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        if (_selected != null) ...[
          const SizedBox(height: 10),
          Text(
            _tooltipText(_selected!),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 8,
          children: [
            _LegendSwatch(color: _emptyColor(), label: '0'),
            _LegendSwatch(color: _levelColor(1), label: '1'),
            _LegendSwatch(color: _levelColor(2), label: '2'),
            _LegendSwatch(color: _levelColor(3), label: '3'),
            _LegendSwatch(color: _levelColor(4), label: '4+'),
            const _LegendSwatch(color: Colors.red, label: 'Discharge'),
          ],
        ),
      ],
    );
  }
}

class _LegendSwatch extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendSwatch({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: .15),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
