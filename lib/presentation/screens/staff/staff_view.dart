import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/state_provider.dart';
import '../../../core/snackbar_helper.dart';
import '../../../core/theme.dart';
import '../../../domain/entities.dart';

class StaffView extends ConsumerStatefulWidget {
  final bool isEmbedded;
  const StaffView({super.key, this.isEmbedded = false});

  @override
  ConsumerState<StaffView> createState() => _StaffViewState();
}

class _StaffViewState extends ConsumerState<StaffView> {
  String _activeGroup = 'roster'; // roster, housekeeping

  // Dialog edit states
  String _editStatus = 'clean';
  final _notesController = TextEditingController();
  final _staffController = TextEditingController();

  String get _todayStr => DateTime.now().toIso8601String().split('T').first;

  @override
  void dispose() {
    _notesController.dispose();
    _staffController.dispose();
    super.dispose();
  }

  void _lastError(WidgetRef ref, BuildContext context, dynamic notifier) {
    try {
      final error = notifier.lastError as String?;
      if (error != null && error.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
              content: Text(error),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating));
        notifier.lastError = null;
      }
    } catch (_) {}
  }

  String _formatTime(String isoStr) {
    try {
      final dt = DateTime.parse(isoStr);
      final hr = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final min = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${hr.toString().padLeft(2, '0')}:$min $ampm';
    } catch (e) {
      return '12:00 PM';
    }
  }

  void _openEditDialog(RoomStatus room) {
    setState(() {
      _editStatus = room.status.name;
      _notesController.text = room.notes ?? '';
      _staffController.text = room.assignedStaff ?? '';
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: AppRadius.xxlBr),
              title: Text(
                'Housekeeping Audit: ${room.name}',
                style: AppTextStyles.titleMd,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SUITE STATUS CODE',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal.withValues(alpha: 0.5),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ['clean', 'cleaning', 'dirty'].map((st) {
                        final isSelected = _editStatus == st;
                        Color btnColor = isSelected
                            ? AppColors.mossGreen
                            : AppColors.stoneBg;
                        Color txtColor =
                            isSelected ? Colors.white : AppColors.charcoal;
                        return Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  _editStatus = st;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 36,
                                decoration: BoxDecoration(
                                  color: btnColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : AppColors.lightBone,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  st.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: txtColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'ALLOCATED STAFF',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal.withValues(alpha: 0.5),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _staffController,
                      style: AppTextStyles.bodySm,
                      decoration: const InputDecoration(
                        hintText: 'Staff Member Name',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'PREPARATION LOGS & NOTES',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal.withValues(alpha: 0.5),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _notesController,
                      style: AppTextStyles.bodySm,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText:
                            'Towels laid, aromatherapy diffuser lit, private spa oils replenished...',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Back',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    HousekeepingStatus hks;
                    if (_editStatus == 'cleaning') {
                      hks = HousekeepingStatus.cleaning;
                    } else if (_editStatus == 'dirty') {
                      hks = HousekeepingStatus.dirty;
                    } else {
                      hks = HousekeepingStatus.clean;
                    }

                    ref.read(staffRoomsProvider.notifier).updateStatus(
                          room.id,
                          _editStatus,
                          assignedStaff: _staffController.text.trim().isEmpty
                              ? null
                              : _staffController.text,
                          notes: _notesController.text.trim().isEmpty
                              ? null
                              : _notesController.text,
                        );

                    if (hks == HousekeepingStatus.clean) {
                      ref.read(notificationsProvider.notifier).addNotification(
                            'Room Verified Clean',
                            '${room.name} marked completely sanitary and ready for immediate check-ins.',
                            'staff',
                          );
                    }

                    Navigator.pop(context);
                    SnackbarHelper.success(
                        context, 'Updated condition logs for ${room.name}.');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mossGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Commit Changes',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
        bookingsProvider,
        (_, __) =>
            _lastError(ref, context, ref.read(bookingsProvider.notifier)));
    final staffRoomsAsync = ref.watch(staffRoomsProvider);
    final bookings = ref.watch(bookingsProvider);
    final propertyAsync = ref.watch(propertyProvider);
    final activeResort = propertyAsync.valueOrNull;

    // Trigger staff room load when property changes
    ref.listen(propertyProvider, (prev, next) {
      final resort = next.valueOrNull;
      if (resort != null) {
        ref.read(staffRoomsProvider.notifier).loadRooms(resort.id);
      }
    });

    final rooms = staffRoomsAsync.valueOrNull ?? [];

    final arrivalsToday = bookings
        .where((b) =>
            b.startDate == _todayStr && b.status != BookingStatus.cancelled)
        .toList();
    final departuresToday = bookings
        .where((b) =>
            b.endDate == _todayStr && b.status != BookingStatus.cancelled)
        .toList();
    final activeLodgers = bookings.where((b) {
      if (b.status == BookingStatus.cancelled) return false;
      try {
        final start = DateTime.parse(b.startDate);
        final end = DateTime.parse(b.endDate);
        final checkpoint = DateTime.parse(_todayStr);
        return (checkpoint.isAtSameMomentAs(start) ||
                checkpoint.isAfter(start)) &&
            checkpoint.isBefore(end);
      } catch (e) {
        return false;
      }
    }).toList();

    final pendingCount =
        rooms.where((r) => r.status != HousekeepingStatus.clean).length;

    if (widget.isEmbedded) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 750;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isMobile
                  ? Row(
                      children: [
                        Expanded(
                          child: _buildGroupToggleButton('roster',
                              Icons.people_outline, 'Guest Transit manifest',
                              isMobile: true),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildGroupToggleButton(
                              'housekeeping',
                              Icons.assignment_outlined,
                              'Housekeeping status board ($pendingCount Pending)',
                              isMobile: true),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _buildGroupToggleButton('roster',
                              Icons.people_outline, 'Guest Transit manifest',
                              isMobile: false),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildGroupToggleButton(
                              'housekeeping',
                              Icons.assignment_outlined,
                              'Housekeeping status board ($pendingCount Pending)',
                              isMobile: false),
                        ),
                      ],
                    ),
              const SizedBox(height: 24),
              _activeGroup == 'roster'
                  ? _buildRosterView(
                      arrivalsToday, departuresToday, activeLodgers, isMobile)
                  : _buildHousekeepingView(rooms, isMobile),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.stoneBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 750;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderRibbon(isMobile, pendingCount, activeResort),
                const SizedBox(height: 24),
                _activeGroup == 'roster'
                    ? _buildRosterView(
                        arrivalsToday, departuresToday, activeLodgers, isMobile)
                    : _buildHousekeepingView(rooms, isMobile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderRibbon(
      bool isMobile, int pendingCount, PropertyDetails? activeResort) {
    final resortName =
        activeResort != null ? activeResort.name : 'Resort Villa';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(color: AppColors.lightBone, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$resortName Concierge Desk',
                      style: AppTextStyles.displayMedium.copyWith(
                        fontSize: isMobile ? 20 : 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Coordinate same-day guest transits, housekeeping quality, and physical villa preps.',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.charcoal.withValues(alpha: 0.6),
                        fontSize: isMobile ? 11 : 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMobile && activeResort != null) ...[
                const SizedBox(width: 16),
                _buildPropertySelector(activeResort, isMobile),
              ],
            ],
          ),
          if (isMobile && activeResort != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildPropertySelector(activeResort, isMobile),
          ],
          const SizedBox(height: 20),
          isMobile
              ? Row(
                  children: [
                    Expanded(
                      child: _buildGroupToggleButton('roster',
                          Icons.people_outline, 'Guest Transit manifest',
                          isMobile: true),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildGroupToggleButton(
                          'housekeeping',
                          Icons.assignment_outlined,
                          'Housekeeping status board ($pendingCount Pending)',
                          isMobile: true),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildGroupToggleButton('roster',
                          Icons.people_outline, 'Guest Transit manifest',
                          isMobile: false),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildGroupToggleButton(
                          'housekeeping',
                          Icons.assignment_outlined,
                          'Housekeeping status board ($pendingCount Pending)',
                          isMobile: false),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildGroupToggleButton(String group, IconData icon, String label,
      {required bool isMobile}) {
    final isActive = _activeGroup == group;
    return InkWell(
      onTap: () {
        setState(() {
          _activeGroup = group;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isMobile ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3B2314) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : AppColors.lightBone,
            width: 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: const Color(0xFF3B2314).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? Colors.white
                  : AppColors.charcoal.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isActive
                      ? Colors.white
                      : AppColors.charcoal.withValues(alpha: 0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertySelector(
      PropertyDetails currentProperty, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : null,
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mossGreen.withValues(alpha: 0.1),
        borderRadius: AppRadius.mdBr,
        border: Border.all(color: AppColors.mossGreen.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PropertyDetails>(
          isExpanded: isMobile,
          value: currentProperty,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.mossGreen),
          dropdownColor: Colors.white,
          borderRadius: AppRadius.lgBr,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppColors.mossGreen,
            fontSize: 13,
          ),
          onChanged: (PropertyDetails? newProperty) {
            if (newProperty != null) {
              ref.read(propertyProvider.notifier).updateProperty(newProperty);
              ref.read(notificationsProvider.notifier).addNotification(
                    'Context Switched',
                    'Now managing ${newProperty.name}.',
                    'system',
                  );
            }
          },
          items: ref.watch(resortsListProvider).map((PropertyDetails resort) {
            return DropdownMenuItem<PropertyDetails>(
              value: resort,
              child: Text(resort.name),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRosterView(
    List<Booking> arrivals,
    List<Booking> departures,
    List<Booking> activeLodgers,
    bool isMobile,
  ) {
    if (isMobile) {
      return Column(
        children: [
          _buildArrivalsColumn(arrivals),
          const SizedBox(height: 20),
          _buildDeparturesColumn(departures),
          const SizedBox(height: 20),
          _buildActiveLodgersColumn(activeLodgers),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildArrivalsColumn(arrivals)),
          const SizedBox(width: 20),
          Expanded(child: _buildDeparturesColumn(departures)),
          const SizedBox(width: 20),
          Expanded(child: _buildActiveLodgersColumn(activeLodgers)),
        ],
      );
    }
  }

  Widget _buildArrivalsColumn(List<Booking> list) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(color: AppColors.lightBone),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.south_west,
                    size: 14, color: Colors.green.shade800),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Today's Guest Arrivals (${list.length})",
                  style: AppTextStyles.titleLg.copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.lightBone, height: 1),
          const SizedBox(height: AppSpacing.lg),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: Text(
                  "No guest arrivals scheduled on $_todayStr.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final b = list[index];
                return Container(
                  padding: AppSpacing.allLg,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50.withValues(alpha: 0.2),
                    border: Border.all(
                        color: Colors.green.shade100.withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              b.guestName,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.charcoal,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.charcoal,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              b.id,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Phone: ${b.guestPhone} • guestsCount: ${b.guestsCount}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.charcoal.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stays till: ${b.endDate} (${b.nightsCount} Nights)',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.charcoal.withValues(alpha: 0.6),
                        ),
                      ),
                      if (b.housekeepingNotes != null &&
                          b.housekeepingNotes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.green.shade100
                                    .withValues(alpha: 0.6)),
                            borderRadius: AppRadius.mdBr,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('📣 ', style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(
                                  'Prep notes: ${b.housekeepingNotes}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.green.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDeparturesColumn(List<Booking> list) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(color: AppColors.lightBone),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.north_east,
                    size: 14, color: Colors.blue.shade800),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Today's Key Departures (${list.length})",
                  style: AppTextStyles.titleLg.copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.lightBone, height: 1),
          const SizedBox(height: AppSpacing.lg),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: Text(
                  "No guest departures scheduled on $_todayStr.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final b = list[index];
                return Container(
                  padding: AppSpacing.allLg,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50.withValues(alpha: 0.2),
                    border: Border.all(
                        color: Colors.blue.shade100.withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              b.guestName,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.charcoal,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade900,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              b.id,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Accounted total: ₹${b.totalAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.charcoal.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Checked-in period: ${b.startDate} to ${b.endDate}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.charcoal.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: AppRadius.mdBr,
                        ),
                        child: Text(
                          'Status: Verified cleaning protocols triggered.',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActiveLodgersColumn(List<Booking> list) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: AppRadius.xxlBr,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('👑 ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  "Active In-house Guests (${list.length})",
                  style: AppTextStyles.titleSm.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: AppSpacing.lg),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: Text(
                  "No active lodgers currently on $_todayStr.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.white12, height: 24),
              itemBuilder: (context, index) {
                final b = list[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            b.guestName,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          b.id,
                          style: AppTextStyles.labelSm
                              .copyWith(color: AppColors.goldAccent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Channel Source: ${b.source.name.toUpperCase()} • ${b.guestsCount} lodgers',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Accommodated stay: ${b.startDate} to ${b.endDate}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHousekeepingView(List<RoomStatus> rooms, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(color: AppColors.lightBone, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'In-Ground Suite Cleanings Board',
            style: AppTextStyles.titleLg,
          ),
          const SizedBox(height: 8),
          Text(
            'Mark housekeeping schedules, logs, and staff tasks to synchronize with checks.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.charcoal.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final int crossAxisCount =
                  width > 1100 ? 4 : (width > 600 ? 2 : 1);

              if (crossAxisCount == 1) {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rooms.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (context, index) =>
                      _buildRoomCard(rooms[index], isList: true),
                );
              } else {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) =>
                      _buildRoomCard(rooms[index], isList: false),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(RoomStatus room, {bool isList = false}) {
    Color statusBg = Colors.white;
    Color statusText = AppColors.charcoal;
    switch (room.status) {
      case HousekeepingStatus.clean:
        statusBg = const Color(0xFFD1FAE5); // Emerald 100
        statusText = const Color(0xFF065F46); // Emerald 800
        break;
      case HousekeepingStatus.cleaning:
        statusBg = const Color(0xFFFEF3C7); // Amber 100
        statusText = const Color(0xFF92400E); // Amber 800
        break;
      case HousekeepingStatus.dirty:
        statusBg = const Color(0xFFFEE2E2); // Red 100
        statusText = const Color(0xFF991B1B); // Red 800
        break;
    }

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                room.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.charcoal,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: AppRadius.mdBr,
              ),
              child: Text(
                room.status.name.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: statusText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          room.notes ??
              'No custom preparation notes set yet. Click Adjust status to allocate.',
          maxLines: isList ? 5 : 3,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.charcoal.withValues(alpha: 0.55),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Staff: ${room.assignedStaff ?? "Unassigned"}',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal.withValues(alpha: 0.5),
          ),
        ),
      ],
    );

    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: AppColors.stoneBg.withValues(alpha: 0.3),
        borderRadius: AppRadius.lgBr,
        border: Border.all(color: AppColors.lightBone),
      ),
      child: isList
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                content,
                const SizedBox(height: 12),
                const Divider(color: AppColors.lightBone, height: 1),
                const SizedBox(height: 12),
                _buildRoomCardFooter(room),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                content,
                const Spacer(),
                const Divider(color: AppColors.lightBone, height: 1),
                const SizedBox(height: 8),
                _buildRoomCardFooter(room),
              ],
            ),
    );
  }

  Widget _buildRoomCardFooter(RoomStatus room) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Updated: ${_formatTime(room.lastUpdated)}',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 9,
            color: AppColors.charcoal.withValues(alpha: 0.4),
          ),
        ),
        InkWell(
          onTap: () => _openEditDialog(room),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.lightBone),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                )
              ],
            ),
            child: Text(
              'Adjust status',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
