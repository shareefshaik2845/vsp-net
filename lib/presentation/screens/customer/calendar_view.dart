import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/state_provider.dart';
import '../../../core/theme.dart';
import '../../../domain/entities.dart';

class ValleyCalendarView extends ConsumerStatefulWidget {
  const ValleyCalendarView({super.key});

  @override
  ConsumerState<ValleyCalendarView> createState() => _ValleyCalendarViewState();
}

class _ValleyCalendarViewState extends ConsumerState<ValleyCalendarView> {
  Map<String, dynamic>? _calendarData;
  late final int _year;
  late final int _month1;
  late final int _month2;

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month1 = now.month;
    _month2 = now.month < 12 ? now.month + 1 : 1;
    _loadCalendar();
  }

  Future<void> _loadCalendar() async {
    try {
      final repo = ref.read(customerRepositoryProvider);
      final m1 = await repo.fetchMonthlyCalendar('1', _month1, _year);
      final y2 = _month2 > _month1 ? _year : _year + 1;
      final m2 = await repo.fetchMonthlyCalendar('1', _month2, y2);
      setState(() => _calendarData = {_month1.toString(): m1, _month2.toString(): m2});
    } catch (_) {
      setState(() => _calendarData = {});
    }
  }

  void _lastError(WidgetRef ref, BuildContext context, dynamic notifier) {
    try {
      final error = notifier.lastError as String?;
      if (error != null && error.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red.shade700, behavior: SnackBarBehavior.floating));
        notifier.lastError = null;
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(bookingsProvider, (_, __) => _lastError(ref, context, ref.read(bookingsProvider.notifier)));
    final bookings = ref.watch(bookingsProvider);
    final blocks = ref.watch(calendarBlocksProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadCalendar,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Valley Reservation Matrix', style: ResortTheme.lightTheme.textTheme.displayMedium),
              const SizedBox(height: 6),
              Text(
                'Verify dates immediately. Double-click or tap cells to inspect scheduled bookings.',
                style: ResortTheme.lightTheme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              _buildLegend(context),
              const SizedBox(height: 32),

              LayoutBuilder(
                builder: (context, constraints) {
                  final name1 = '${_monthNames[_month1 - 1]} $_year';
                  final name2 = '${_monthNames[_month2 - 1]} ${_month2 > _month1 ? _year : _year + 1}';
                  final days1 = DateTime(_year, _month1 + 1, 0).day;
                  final days2 = DateTime(_month2 > _month1 ? _year : _year + 1, _month2 + 1, 0).day;
                  final pad1 = DateTime(_year, _month1, 1).weekday % 7;
                  final pad2 = DateTime(_month2 > _month1 ? _year : _year + 1, _month2, 1).weekday % 7;

                  if (constraints.maxWidth > 750) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildMonthCard(context, name1, pad1, days1, bookings, blocks, _month1)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildMonthCard(context, name2, pad2, days2, bookings, blocks, _month2)),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildMonthCard(context, name1, pad1, days1, bookings, blocks, _month1),
                        const SizedBox(height: 24),
                        _buildMonthCard(context, name2, pad2, days2, bookings, blocks, _month2),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ResortTheme.stoneBg.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ResortTheme.lightBone),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 10,
        children: [
          _legendItem('Available Night', Colors.white, border: const BorderSide(color: ResortTheme.lightBone)),
          _legendItem('Booked Direct', ResortTheme.mossGreen),
          _legendItem('OTA Sync (Airbnb)', const Color(0xFF7A8B7B)),
          _legendItem('Pending Payment', ResortTheme.goldAccent),
          _legendItem('Blocked / Maint', const Color(0xFF706B5C)),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, {BorderSide? border}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: border != null ? Border.all(color: border.color, width: border.width) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: ResortTheme.charcoal)),
      ],
    );
  }

  Widget _buildMonthCard(
    BuildContext context, 
    String monthName, 
    int padDays, 
    int totalDays, 
    List<Booking> bookings, 
    List<CalendarBlock> blocks,
    int monthNum,
  ) {
    final monthKey = monthNum.toString();
    final monthData = _calendarData?[monthKey] as Map<String, dynamic>?;
    final apiAvailable = (monthData?['availableDates'] as List<dynamic>?)?.cast<String>() ?? [];
    final apiBlocked = (monthData?['blockedDates'] as List<dynamic>?)?.cast<String>() ?? [];
    final apiBooked = (monthData?['bookedDates'] as List<dynamic>?)?.cast<String>() ?? [];
    final minStay = monthData?['minStay'] as int?;
    final maxStay = monthData?['maxStay'] as int?;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(monthName, style: ResortTheme.lightTheme.textTheme.titleLarge),
                if (minStay != null || maxStay != null)
                  Text(
                    'Min ${minStay ?? '-'} / Max ${maxStay ?? '-'} nights',
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: ResortTheme.lightBone),
            const SizedBox(height: 12),
            
            GridRow(
              children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                  .map((e) => Expanded(
                        child: Center(
                          child: Text(
                            e,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: ResortTheme.charcoal.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemCount: padDays + totalDays,
              itemBuilder: (context, idx) {
                if (idx < padDays) {
                  return Container();
                }

                final dayNum = idx - padDays + 1;
                final dateStr = '${DateTime.now().year}-${monthNum.toString().padLeft(2, '0')}-${dayNum.toString().padLeft(2, '0')}';
                
                // Use API data when available, fall back to local
                bool isBlocked = false;
                bool isBooked = false;
                Booking? matchingBooking;
                CalendarBlock? matchingBlock;

                if (_calendarData != null && apiAvailable.isNotEmpty) {
                  isBlocked = apiBlocked.contains(dateStr);
                  isBooked = apiBooked.contains(dateStr);
                } else {
                  final status = _getDayStatus(dateStr, bookings, blocks);
                  isBlocked = status == CalendarDayStatus.blocked;
                  isBooked = status == CalendarDayStatus.booked || status == CalendarDayStatus.ota || status == CalendarDayStatus.pending;
                }

                for (final bl in blocks) {
                  if (dateStr.compareTo(bl.startDate) >= 0 && dateStr.compareTo(bl.endDate) < 0) {
                    matchingBlock = bl;
                    break;
                  }
                }
                if (matchingBlock == null) {
                  for (final b in bookings) {
                    if (dateStr.compareTo(b.startDate) >= 0 && dateStr.compareTo(b.endDate) < 0 && b.status != BookingStatus.cancelled) {
                      matchingBooking = b;
                      break;
                    }
                  }
                }

                final info = _buildDayInfo(dateStr, matchingBooking, matchingBlock);
                CalendarDayStatus status = isBlocked ? CalendarDayStatus.blocked : (isBooked ? CalendarDayStatus.booked : CalendarDayStatus.available);

                Color cellColor = Colors.white;
                Color textColor = ResortTheme.charcoal;
                Border? border = Border.all(color: ResortTheme.lightBone.withValues(alpha: 0.5));
                
                switch (status) {
                  case CalendarDayStatus.booked:
                    cellColor = ResortTheme.mossGreen;
                    textColor = Colors.white;
                    border = null;
                    break;
                  case CalendarDayStatus.pending:
                    cellColor = ResortTheme.goldAccent;
                    textColor = ResortTheme.mossGreen;
                    border = null;
                    break;
                  case CalendarDayStatus.ota:
                    cellColor = const Color(0xFF7A8B7B);
                    textColor = Colors.white;
                    border = null;
                    break;
                  case CalendarDayStatus.blocked:
                    cellColor = const Color(0xFF706B5C);
                    textColor = const Color(0xFFF4F1EA);
                    border = null;
                    break;
                  default:
                    break;
                }

                return Tooltip(
                  message: info,
                  child: InkWell(
                    onTap: () => _showDayDialog(context, dateStr, info),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(10),
                        border: border,
                        boxShadow: status != CalendarDayStatus.available
                            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$dayNum',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  CalendarDayStatus _getDayStatus(String dateStr, List<Booking> bookings, List<CalendarBlock> blocks) {
    for (final bl in blocks) {
      if (dateStr.compareTo(bl.startDate) >= 0 && dateStr.compareTo(bl.endDate) < 0) {
        return CalendarDayStatus.blocked;
      }
    }
    for (final b in bookings) {
      if (dateStr.compareTo(b.startDate) >= 0 && dateStr.compareTo(b.endDate) < 0) {
        if (b.status == BookingStatus.cancelled) continue;
        if (b.status == BookingStatus.pendingPayment) return CalendarDayStatus.pending;
        return b.source == BookingSource.direct ? CalendarDayStatus.booked : CalendarDayStatus.ota;
      }
    }
    return CalendarDayStatus.available;
  }

  String _buildDayInfo(String dateStr, Booking? booking, CalendarBlock? block) {
    if (block != null) {
      return 'Blocked for: ${block.reason.toUpperCase()}\nNotes: ${block.notes ?? "None"}\nBy: ${block.blockedBy}';
    }
    if (booking != null) {
      return 'Booked: ${booking.guestName}\nStatus: ${booking.status.name.toUpperCase()}\nSource: ${booking.source.name.toUpperCase()}\nStay: ${booking.startDate} to ${booking.endDate}';
    }
    return 'Available Night';
  }

  void _showDayDialog(BuildContext context, String dateStr, String info) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(dateStr, style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: ResortTheme.mossGreen)),
          content: Text(info, style: GoogleFonts.inter(fontSize: 13, height: 1.5)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: ResortTheme.mossGreen)),
            ),
          ],
        );
      },
    );
  }
}

class GridRow extends StatelessWidget {
  final List<Widget> children;
  const GridRow({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(children: children);
  }
}
