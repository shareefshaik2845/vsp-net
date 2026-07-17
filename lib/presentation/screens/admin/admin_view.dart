import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../../providers/state_provider.dart';
import '../../../core/theme.dart';
import '../../../core/snackbar_helper.dart';
import '../../../domain/entities.dart';
import '../staff/staff_view.dart';

class AdminView extends ConsumerStatefulWidget {
  const AdminView({super.key});

  @override
  ConsumerState<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends ConsumerState<AdminView> {
  String _activeTab = 'kpis'; // kpis, blocks, orders, tariffs, coupons, ota

  // Calendar Blocking states
  String _blockStart = '';
  String _blockEnd = '';
  final _blockNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _blockStart =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final end = now.add(const Duration(days: 2));
    _blockEnd =
        '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
  }

  String _blockReason = 'maintenance';
  String? _blockError;
  String? _blockSuccess;
  String? _selectedPropertyId;

  // Coupon Form states
  final _couponCodeController = TextEditingController();
  final _couponDescController = TextEditingController();
  String _couponType = 'percentage'; // percentage, fixed
  double _couponValue = 10;
  String _couponExpiry = DateTime.now()
      .add(const Duration(days: 90))
      .toIso8601String()
      .split('T')
      .first;
  int _couponLimit = 50;
  double _couponMinSub = 25000;
  String? _couponFormError;

  // Bookings filter states
  String _filterSource =
      'all'; // all, direct, airbnb, bookingCom, agoda, makemytrip, goibibo
  String _filterStatus = 'all'; // all, confirmed, pendingPayment, cancelled
  String _filterQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _blockNotesController.dispose();
    _couponCodeController.dispose();
    _couponDescController.dispose();
    _searchController.dispose();
    _seasonNameController.dispose();
    _seasonWeekdayController.dispose();
    _seasonWeekendController.dispose();
    _seasonMultiplierController.dispose();
    super.dispose();
  }

  void _lastError(WidgetRef ref, BuildContext context, dynamic notifier) {
    try {
      final error = notifier.lastError as String?;
      if (error != null && error.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        notifier.lastError = null;
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
        bookingsProvider,
        (_, __) =>
            _lastError(ref, context, ref.read(bookingsProvider.notifier)));
    ref.listen(
        calendarBlocksProvider,
        (_, __) => _lastError(
            ref, context, ref.read(calendarBlocksProvider.notifier)));
    ref.listen(
        couponsProvider,
        (_, __) =>
            _lastError(ref, context, ref.read(couponsProvider.notifier)));
    ref.listen(
        pricingRulesProvider,
        (_, __) =>
            _lastError(ref, context, ref.read(pricingRulesProvider.notifier)));
    ref.listen(
        otaSyncProvider,
        (_, __) =>
            _lastError(ref, context, ref.read(otaSyncProvider.notifier)));
    final bookings = ref.watch(bookingsProvider);
    final blocks = ref.watch(calendarBlocksProvider);
    final coupons = ref.watch(couponsProvider);
    final pricingRules = ref.watch(pricingRulesProvider);
    final otaSyncs = ref.watch(otaSyncProvider);
    final propertyAsync = ref.watch(propertyProvider);
    final dashboardAsync = ref.watch(adminDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.stoneBg,
      body: propertyAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.mossGreen)),
        error: (err, stack) =>
            Center(child: Text('Error loading property: $err')),
        data: (property) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderRibbon(property),
                const SizedBox(height: 24),
                _buildActiveTabContent(
                  property: property,
                  bookings: bookings,
                  blocks: blocks,
                  coupons: coupons,
                  pricingRules: pricingRules,
                  otaSyncs: otaSyncs,
                  dashboardAsync: dashboardAsync,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- HEADER & NAVIGATION RIBBON ---
  Widget _buildHeaderRibbon(PropertyDetails property) {
    final tabs = [
      {'id': 'kpis', 'label': 'Analytics Board', 'icon': Icons.trending_up},
      {
        'id': 'blocks',
        'label': 'Calendar Blocking',
        'icon': Icons.calendar_month
      },
      {'id': 'orders', 'label': 'Booking Matrix', 'icon': Icons.shopping_bag},
      {'id': 'tariffs', 'label': 'Tariffs / Seasonality', 'icon': Icons.tune},
      {'id': 'coupons', 'label': 'Coupons Editor', 'icon': Icons.local_offer},
      {'id': 'ota', 'label': 'OTA Synergy', 'icon': Icons.sync},
      {
        'id': 'staff_ops',
        'label': 'Resort Operations',
        'icon': Icons.cleaning_services_outlined
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(
            color: AppColors.goldAccent.withValues(alpha: 0.15), width: 1.2),
        boxShadow: AppShadows.card,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 750;
          return Column(
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
                          '${property.name} Core Console',
                          style: AppTextStyles.displayMedium.copyWith(
                            fontSize: isMobile ? 20 : 24,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Live property scheduling, tariffs optimization, and sales intelligence.',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.charcoal.withValues(alpha: 0.6),
                            fontSize: isMobile ? 11 : 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 16),
                    _buildPropertySelector(property, isMobile),
                  ],
                ],
              ),
              if (isMobile) ...[
                const SizedBox(height: AppSpacing.lg),
                _buildPropertySelector(property, isMobile),
              ],
              const SizedBox(height: 20),
              isMobile
                  ? Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tabs.map((tab) {
                        final isSelected = _activeTab == tab['id'];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _activeTab = tab['id'] as String;
                            });
                          },
                          borderRadius: AppRadius.mdBr,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: isSelected ? AppGradients.gold : null,
                              color: isSelected
                                  ? null
                                  : AppColors.stoneBg.withValues(alpha: 0.5),
                              borderRadius: AppRadius.mdBr,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.goldAccent
                                            .withValues(alpha: 0.15),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  tab['icon'] as IconData,
                                  size: 14,
                                  color: isSelected
                                      ? const Color(0xFF2C3627)
                                      : AppColors.charcoal
                                          .withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  tab['label'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? const Color(0xFF2C3627)
                                        : AppColors.charcoal
                                            .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: tabs.map((tab) {
                          final isSelected = _activeTab == tab['id'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _activeTab = tab['id'] as String;
                                });
                              },
                              borderRadius: AppRadius.mdBr,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient:
                                      isSelected ? AppGradients.gold : null,
                                  color: isSelected
                                      ? null
                                      : AppColors.stoneBg
                                          .withValues(alpha: 0.5),
                                  borderRadius: AppRadius.mdBr,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.goldAccent
                                                .withValues(alpha: 0.15),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      tab['icon'] as IconData,
                                      size: 16,
                                      color: isSelected
                                          ? const Color(0xFF2C3627)
                                          : AppColors.charcoal
                                              .withValues(alpha: 0.6),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      tab['label'] as String,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? const Color(0xFF2C3627)
                                            : AppColors.charcoal
                                                .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPropertySelector(
      PropertyDetails currentProperty, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

  // --- VIEW SELECTOR ---
  Widget _buildActiveTabContent({
    required PropertyDetails property,
    required List<Booking> bookings,
    required List<CalendarBlock> blocks,
    required List<Coupon> coupons,
    required List<PricingSeasonRule> pricingRules,
    required List<OtaSyncStatus> otaSyncs,
    required AsyncValue<AdminDashboardState> dashboardAsync,
  }) {
    switch (_activeTab) {
      case 'kpis':
        return _buildAnalyticsBoard(
          bookings,
          blocks,
          otaSyncs,
          coupons,
          dashboardAsync,
        );
      case 'blocks':
        return _buildCalendarBlocking(blocks);
      case 'orders':
        return _buildBookingMatrix(bookings);
      case 'tariffs':
        return _buildTariffsView(property, pricingRules);
      case 'coupons':
        return _buildCouponsEditor(coupons);
      case 'ota':
        return _buildOtaSynergy(otaSyncs);
      case 'staff_ops':
        return const StaffView(isEmbedded: true);
      default:
        return const SizedBox.shrink();
    }
  }

  // --- 1. ANALYTICS BOARD ---
  List<double> _computeWeeklyRevenue(List<Booking> bookings, {int weeks = 6}) {
    final now = DateTime.now();
    final weekStarts = List.generate(weeks, (i) {
      final day =
          now.subtract(Duration(days: now.weekday - 1 + (weeks - 1 - i) * 7));
      return DateTime(day.year, day.month, day.day);
    });

    final weeklyRevenue = List<double>.filled(weeks, 0);
    for (final b in bookings) {
      try {
        final start = DateTime.parse(b.startDate);
        for (int i = 0; i < weeks; i++) {
          final wStart = weekStarts[i];
          final wEnd = wStart.add(const Duration(days: 7));
          if (!start.isBefore(wStart) && start.isBefore(wEnd)) {
            weeklyRevenue[i] += b.totalAmount;
            break;
          }
        }
      } catch (e) {
        debugPrint('Error parsing booking date $e');
      }
    }

    final maxRev = weeklyRevenue.reduce((a, b) => a > b ? a : b);
    if (maxRev == 0) return [0, 0, 0, 0, 0, 0];
    return weeklyRevenue.map((r) => r / maxRev).toList();
  }

  Widget _buildAnalyticsBoard(
    List<Booking> bookings,
    List<CalendarBlock> blocks,
    List<OtaSyncStatus> otaChannels,
    List<Coupon> coupons,
    AsyncValue<AdminDashboardState> dashboardAsync,
  ) {
    final activeBookings =
        bookings.where((b) => b.status != BookingStatus.cancelled).toList();
    final activeBookingsCount = activeBookings.length;
    final cancelledBookingsCount =
        bookings.where((b) => b.status == BookingStatus.cancelled).length;

    const int totalDaysInScope = 61;
    final int totalBookedDaysSum =
        activeBookings.fold(0, (sum, b) => sum + b.nightsCount);
    final int totalCouponCountUsed =
        coupons.fold(0, (sum, c) => sum + c.usageCount);

    return dashboardAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.mossGreen)),
      error: (err, stack) {
        final fallbackRevenue =
            activeBookings.fold(0.0, (sum, b) => sum + b.totalAmount);
        final fallbackAdvance =
            activeBookings.fold(0.0, (sum, b) => sum + b.advancePaidAmount);
        final fallbackOccupancy =
            min(100, ((totalBookedDaysSum / totalDaysInScope) * 100).round());
        return _buildDashboardGrid(
          width: MediaQuery.of(context).size.width,
          bookings: bookings,
          totalBookedRevenue: fallbackRevenue,
          totalAdvanceCollected: fallbackAdvance,
          calculatedOccupancy: fallbackOccupancy,
          activeBookingsCount: activeBookingsCount,
          cancelledBookingsCount: cancelledBookingsCount,
          blocks: blocks,
          otaChannels: otaChannels,
          totalCouponCountUsed: totalCouponCountUsed,
          totalBookedDaysSum: totalBookedDaysSum,
          upcomingEvents: const [],
          recentActivity: const [],
          averageRating: 0,
          reviewsCount: 0,
          revenueThisMonth: fallbackRevenue,
        );
      },
      data: (dash) {
        return _buildDashboardGrid(
          width: MediaQuery.of(context).size.width,
          bookings: bookings,
          totalBookedRevenue: dash.revenueThisMonth,
          totalAdvanceCollected: dash.revenueToday,
          calculatedOccupancy: (dash.occupancyRate * 100).round(),
          activeBookingsCount: dash.activeBookings,
          cancelledBookingsCount: dash.totalBookings - dash.activeBookings,
          blocks: blocks,
          otaChannels: otaChannels,
          totalCouponCountUsed: totalCouponCountUsed,
          totalBookedDaysSum: totalBookedDaysSum,
          upcomingEvents: dash.upcomingEvents,
          recentActivity: dash.recentActivity,
          averageRating: dash.averageRating,
          reviewsCount: dash.reviewsCount,
          revenueThisMonth: dash.revenueThisMonth,
        );
      },
    );
  }

  Widget _buildDashboardGrid({
    required double width,
    required List<Booking> bookings,
    required double totalBookedRevenue,
    required double totalAdvanceCollected,
    required int calculatedOccupancy,
    required int activeBookingsCount,
    required int cancelledBookingsCount,
    required List<CalendarBlock> blocks,
    required List<OtaSyncStatus> otaChannels,
    required int totalCouponCountUsed,
    required int totalBookedDaysSum,
    required List<Map<String, dynamic>> upcomingEvents,
    required List<Map<String, dynamic>> recentActivity,
    required double averageRating,
    required int reviewsCount,
    required double revenueThisMonth,
  }) {
    final int kpiCrossAxisCount = width > 1100 ? 4 : (width > 600 ? 2 : 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: kpiCrossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.8,
          children: [
            _buildKpiCard(
              title: 'MONTH REVENUE',
              value: '₹${totalBookedRevenue.toStringAsFixed(0)}',
              badgeText: 'Revenue This Month',
              badgeBg: const Color(0xFFE8EAF6),
              badgeTextColor: const Color(0xFF3F51B5),
              icon: const Text('₹',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F51B5))),
              iconBg: const Color(0xFFE8EAF6),
            ),
            _buildKpiCard(
              title: 'TODAY REVENUE',
              value: '₹${totalAdvanceCollected.toStringAsFixed(0)}',
              badgeText: 'Today\'s Collection',
              badgeBg: const Color(0xFFE8F5E9),
              badgeTextColor: const Color(0xFF2E7D32),
              icon: const Icon(Icons.monetization_on, color: Color(0xFF2E7D32)),
              iconBg: const Color(0xFFE8F5E9),
            ),
            _buildKpiCard(
              title: 'OCCUPANCY RATE',
              value: '$calculatedOccupancy%',
              badgeText: '$totalBookedDaysSum / 61 Nights Booked',
              badgeBg: const Color(0xFFFFF8E1),
              badgeTextColor: const Color(0xFFF57F17),
              icon: const Icon(Icons.trending_up, color: Color(0xFFF57F17)),
              iconBg: const Color(0xFFFFF8E1),
            ),
            _buildKpiCard(
              title: 'ACTIVE STAYS',
              value: '$activeBookingsCount',
              badgeText: '$cancelledBookingsCount Cancelled',
              badgeBg: const Color(0xFFFFEBEE),
              badgeTextColor: const Color(0xFFC62828),
              icon: const Icon(Icons.people, color: Color(0xFFC62828)),
              iconBg: const Color(0xFFFFEBEE),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (width > 900)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 8,
                child: Column(
                  children: [
                    _buildSalesPerformanceChart(bookings, width < 600),
                    const SizedBox(height: 20),
                    _buildUpcomingEvents(upcomingEvents),
                    const SizedBox(height: 20),
                    _buildRecentActivity(recentActivity),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildMetricInsightsPanel(
                      calculatedOccupancy: calculatedOccupancy,
                      totalCouponCountUsed: totalCouponCountUsed,
                      blocksCount: blocks.length,
                      otaChannels: otaChannels,
                    ),
                    const SizedBox(height: 20),
                    _buildRatingCard(averageRating, reviewsCount),
                  ],
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildSalesPerformanceChart(bookings, width < 600),
              const SizedBox(height: 20),
              _buildUpcomingEvents(upcomingEvents),
              const SizedBox(height: 20),
              _buildRecentActivity(recentActivity),
              const SizedBox(height: 20),
              _buildMetricInsightsPanel(
                calculatedOccupancy: calculatedOccupancy,
                totalCouponCountUsed: totalCouponCountUsed,
                blocksCount: blocks.length,
                otaChannels: otaChannels,
              ),
              const SizedBox(height: 20),
              _buildRatingCard(averageRating, reviewsCount),
            ],
          ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String badgeText,
    required Color badgeBg,
    required Color badgeTextColor,
    required Widget icon,
    required Color iconBg,
  }) {
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(
            color: AppColors.goldAccent.withValues(alpha: 0.15), width: 1.2),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.charcoal.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: AppRadius.lgBr,
            ),
            child: Center(child: icon),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesPerformanceChart(List<Booking> bookings, bool isMobile) {
    final points = _computeWeeklyRevenue(bookings);
    final peakRev = bookings.fold(0.0, (sum, b) => sum + b.totalAmount);
    final peakValue = points.reduce((a, b) => a > b ? a : b);
    final peakIndex = points.indexOf(peakValue);
    final peakWeekLabel = [
      'Wk 1 (Jun)',
      'Wk 2 (Jun)',
      'Wk 3 (Jun)',
      'Wk 4 (Jun)',
      'Wk 1 (Jul)',
      'Wk 2 (Jul)'
    ];
    final peakLabel =
        peakIndex < peakWeekLabel.length ? peakWeekLabel[peakIndex] : 'Peak';
    return Container(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(
            color: AppColors.goldAccent.withValues(alpha: 0.15), width: 1.2),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Sales Performance',
                      style: AppTextStyles.titleLg.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Real-time transaction tracking',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.charcoal.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.stoneBg,
                        borderRadius: AppRadius.smBr,
                      ),
                      child: Text(
                        'Live data',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.charcoal.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weekly Sales Performance',
                            style: AppTextStyles.titleLg,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Real-time transaction tracking',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.charcoal.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.stoneBg,
                        borderRadius: AppRadius.smBr,
                      ),
                      child: Text(
                        'Live data',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.charcoal.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: SalesChartPainter(
                    points: points,
                  ),
                ),
                Positioned(
                  top: 40,
                  left: isMobile ? 80 : 140,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.charcoal,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: Text(
                      '$peakLabel: ₹${(peakRev * peakValue).toStringAsFixed(0)} INR',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isMobile ? 'W1 (Jun)' : 'Wk 1 (June)',
              isMobile ? 'W2 (Jun)' : 'Wk 2 (June)',
              isMobile ? 'W3 (Jun)' : 'Wk 3 (June)',
              isMobile ? 'W4 (Jun)' : 'Wk 4 (June)',
              isMobile ? 'W1 (Jul)' : 'Wk 1 (July)',
              isMobile ? 'W2 (Jul)' : 'Wk 2 (July)',
            ].map((label) {
              return Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 8 : 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal.withValues(alpha: 0.4),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricInsightsPanel({
    required int calculatedOccupancy,
    required int totalCouponCountUsed,
    required int blocksCount,
    required List<OtaSyncStatus> otaChannels,
  }) {
    final activeOtaCount =
        otaChannels.where((c) => c.status == 'success').length;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(
            color: AppColors.goldAccent.withValues(alpha: 0.25), width: 1.2),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SYNC LOGS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Metrics Insights',
            style: AppTextStyles.titleMd.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'VSP Nest current booking distribution tracks occupancy at a healthy $calculatedOccupancy% ratio across our 2-month prototype period.',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: AppSpacing.md),
          _buildInsightRow('Coupons Redeemed:', '$totalCouponCountUsed usages'),
          const SizedBox(height: AppSpacing.md),
          _buildInsightRow('Blocked Dates ranges:', '$blocksCount active'),
          const SizedBox(height: AppSpacing.md),
          _buildInsightRow('OTA Integrations:',
              '$activeOtaCount/${otaChannels.length} Synced',
              isGreen: true),
        ],
      ),
    );
  }

  Widget _buildInsightRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: isGreen ? Colors.greenAccent : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingEvents(List<Map<String, dynamic>> events) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(
            color: AppColors.goldAccent.withValues(alpha: 0.15), width: 1.2),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming Events',
              style: AppTextStyles.titleLg.copyWith(fontSize: 16)),
          const SizedBox(height: AppSpacing.md),
          if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('No upcoming events scheduled.',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            )
          else
            ...events.map((e) {
              final guestName = e['guestName'] as String? ?? '—';
              final propertyName = e['propertyName'] as String? ?? '—';
              final checkIn = e['checkIn'] as String? ?? '';
              final checkOut = e['checkOut'] as String? ?? '';
              final status = e['status'] as String? ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: status == 'CHECKED_IN'
                            ? Colors.green
                            : Colors.amber,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(guestName,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(propertyName,
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: Colors.grey)),
                          if (checkIn.isNotEmpty)
                            Text('$checkIn → $checkOut',
                                style: GoogleFonts.inter(
                                    fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == 'CHECKED_IN'
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: AppRadius.smBr,
                      ),
                      child: Text(
                        status.replaceAll('_', ' '),
                        style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: status == 'CHECKED_IN'
                                ? Colors.green.shade800
                                : Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(List<Map<String, dynamic>> activities) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(
            color: AppColors.goldAccent.withValues(alpha: 0.15), width: 1.2),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity',
              style: AppTextStyles.titleLg.copyWith(fontSize: 16)),
          const SizedBox(height: AppSpacing.md),
          if (activities.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('No recent activity recorded.',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            )
          else
            ...activities.map((a) {
              final action = a['action'] as String? ?? '';
              final description = a['description'] as String? ?? '';
              final timestamp = a['timestamp'] as String? ?? '';
              final type = a['type'] as String? ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      type == 'booking'
                          ? Icons.shopping_bag
                          : type == 'payment'
                              ? Icons.payment
                              : Icons.info_outline,
                      size: 16,
                      color: type == 'booking'
                          ? Colors.blue
                          : type == 'payment'
                              ? Colors.green
                              : Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(description,
                              style: GoogleFonts.inter(fontSize: 12)),
                          Text('$action • ${_formatTimestamp(timestamp)}',
                              style: GoogleFonts.inter(
                                  fontSize: 9, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _formatTimestamp(String ts) {
    try {
      final dt = DateTime.parse(ts);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return ts;
    }
  }

  Widget _buildRatingCard(double averageRating, int reviewsCount) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(
            color: AppColors.goldAccent.withValues(alpha: 0.15), width: 1.2),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Guest Satisfaction',
              style: AppTextStyles.titleLg.copyWith(fontSize: 16)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < averageRating.round()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$reviewsCount',
                    style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal),
                  ),
                  Text('Reviews',
                      style:
                          GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 2. CALENDAR BLOCKING ---
  Widget _buildCalendarBlocking(List<CalendarBlock> blocks) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isVertical = constraints.maxWidth < 900;
        final formCard = _buildBlockFormCard();
        final listCard = _buildActiveBlocksCard(blocks);

        if (isVertical) {
          return Column(
            children: [
              formCard,
              const SizedBox(height: 20),
              listCard,
            ],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: formCard),
              const SizedBox(width: 20),
              Expanded(flex: 7, child: listCard),
            ],
          );
        }
      },
    );
  }

  Widget _buildBlockFormCard() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(color: AppColors.lightBone, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Block Operational Calendar', style: AppTextStyles.titleLg),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Isolating dates prevents customers and OTAs from completing bookings. Overlapping reservations logic will block execution.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.charcoal.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDatePickerField('Block Start Date', _blockStart,
                    (val) {
                  setState(() => _blockStart = val);
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    _buildDatePickerField('Block End Date', _blockEnd, (val) {
                  setState(() => _blockEnd = val);
                }),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Select Property',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppColors.charcoal.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Consumer(
            builder: (context, ref, _) {
              final properties = ref.watch(resortsListProvider);
              if (properties.isEmpty) return const Text('No properties available');
              return DropdownButtonFormField<String>(
                value: _selectedPropertyId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.lightBone,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                hint: Text('Select a property', style: TextStyle(color: AppColors.charcoal.withValues(alpha: 0.5))),
                items: properties.map((p) {
                  return DropdownMenuItem<String>(
                    value: p.id,
                    child: Text(p.name, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedPropertyId = val);
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Reason category',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppColors.charcoal.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildReasonRadioGrid(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Administrative Notes',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppColors.charcoal.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _blockNotesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText:
                  'Write specific reasons (e.g. Filter cleaning, VIP personal retreat)',
            ),
            style: GoogleFonts.inter(fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_blockError != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: AppRadius.mdBr,
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber,
                      color: Colors.red.shade800, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _blockError!,
                      style: GoogleFonts.inter(
                          color: Colors.red.shade800, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          if (_blockSuccess != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: AppRadius.mdBr,
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                _blockSuccess!,
                style: GoogleFonts.inter(
                    color: Colors.green.shade800, fontSize: 12),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          ElevatedButton.icon(
            onPressed: _handleCreateBlock,
            icon: const Icon(Icons.lock, size: 16, color: Colors.white),
            label: Text(
              'Commit Date Isolation',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mossGreen,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBr),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(
      String label, String currentDate, Function(String) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppColors.charcoal.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            DateTime? initialDate = DateTime.tryParse(currentDate);
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initialDate ?? DateTime.now(),
              firstDate: DateTime(2026, 1, 1),
              lastDate: DateTime(2026, 12, 31),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.mossGreen,
                      onPrimary: Colors.white,
                      onSurface: AppColors.charcoal,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              final formatted =
                  '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
              onDateSelected(formatted);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.stoneBg.withValues(alpha: 0.3),
              borderRadius: AppRadius.mdBr,
              border: Border.all(color: AppColors.lightBone),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentDate,
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.calendar_today,
                    size: 14, color: AppColors.mossGreen),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonRadioGrid() {
    final reasons = ['maintenance', 'owner_stay', 'private_event', 'holiday'];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 3.5,
      children: reasons.map((r) {
        final isSelected = _blockReason == r;
        return InkWell(
          onTap: () {
            setState(() {
              _blockReason = r;
            });
          },
          borderRadius: AppRadius.mdBr,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF4F1EA) : Colors.white,
              borderRadius: AppRadius.mdBr,
              border: Border.all(
                color: isSelected ? AppColors.mossGreen : AppColors.lightBone,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 14,
                  color: isSelected
                      ? AppColors.mossGreen
                      : AppColors.charcoal.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r.replaceAll('_', ' ').toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected ? AppColors.mossGreen : AppColors.charcoal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _handleCreateBlock() async {
    setState(() {
      _blockError = null;
      _blockSuccess = null;
    });

    if (_selectedPropertyId == null) {
      setState(() {
        _blockError = 'Please select a property.';
      });
      return;
    }

    if (_blockNotesController.text.trim().isEmpty) {
      setState(() {
        _blockError = 'Administrative Notes are required.';
      });
      return;
    }

    final blocks = ref.read(calendarBlocksProvider);
    final bookings = ref.read(bookingsProvider);

    final start = DateTime.parse(_blockStart);
    final end = DateTime.parse(_blockEnd);

    if (end.isBefore(start)) {
      setState(() {
        _blockError = 'End date cannot be before start date.';
      });
      return;
    }

    for (final b in bookings) {
      if (b.status == BookingStatus.cancelled) continue;
      final bStart = DateTime.parse(b.startDate);
      final bEnd = DateTime.parse(b.endDate);
      if (!(end.isBefore(bStart) || start.isAfter(bEnd))) {
        setState(() {
          _blockError =
              'Overlap Alert: Booking ${b.id} (${b.guestName}) is already scheduled on these dates.';
        });
        return;
      }
    }

    for (final bl in blocks) {
      final blStart = DateTime.parse(bl.startDate);
      final blEnd = DateTime.parse(bl.endDate);
      if (!(end.isBefore(blStart) || start.isAfter(blEnd))) {
        setState(() {
          _blockError =
              'Overlap Alert: Another calendar block is already placed in this range.';
        });
        return;
      }
    }

    final newBlock = CalendarBlock(
      id: 'BLOCK-${DateTime.now().millisecondsSinceEpoch}',
      startDate: _blockStart,
      endDate: _blockEnd,
      reason: _blockReason,
      notes: _blockNotesController.text,
      blockedBy: 'Admin Console',
      propertyId: _selectedPropertyId,
    );

    try {
      await ref.read(calendarBlocksProvider.notifier).addBlock(newBlock);
      ref.read(notificationsProvider.notifier).addNotification(
            'Calendar Dates Isolated',
            'Blocked dates $_blockStart to $_blockEnd due to $_blockReason.',
            'system',
          );
      setState(() {
        _blockNotesController.clear();
        _blockSuccess =
            'Calendar date block placed successfully! Dynamic availability locked.';
      });
    } catch (e) {
      setState(() {
        _blockError = 'Failed to create block: $e';
      });
    }
  }

  Widget _buildActiveBlocksCard(List<CalendarBlock> blocks) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(color: AppColors.lightBone, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active Isolated Calendar Blocks', style: AppTextStyles.titleLg),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Any deletion of active schedules opens checked dates back to availability.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.charcoal.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (blocks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: Text(
                  'No active isolated blocks exist currently.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: blocks.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: AppColors.lightBone, height: 24),
              itemBuilder: (context, index) {
                final block = blocks[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '${block.startDate} to ${block.endDate}',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.charcoal,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: AppRadius.mdBr,
                                ),
                                child: Text(
                                  block.reason
                                      .toUpperCase()
                                      .replaceAll('_', ' '),
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            block.notes ?? '',
                            style: GoogleFonts.inter(
                              color: AppColors.charcoal.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Blocked by: ${block.blockedBy}',
                            style: GoogleFonts.inter(
                              color: AppColors.charcoal.withValues(alpha: 0.4),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ref
                            .read(calendarBlocksProvider.notifier)
                            .removeBlock(block.id);
                        ref
                            .read(notificationsProvider.notifier)
                            .addNotification(
                              'Exclusion Restored',
                              'Inventory unlocked from ${block.startDate} to ${block.endDate}.',
                              'system',
                            );
                      },
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.charcoal),
                      hoverColor: Colors.red.shade50,
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // --- 3. BOOKING MATRIX ---
  Widget _buildBookingMatrix(List<Booking> bookings) {
    final filteredBookings = bookings.where((b) {
      final sourceStr = b.source.toJson().toLowerCase();
      final matchSource = _filterSource == 'all' ||
          (_filterSource == 'bookingCom' && sourceStr == 'bookingcom') ||
          (sourceStr == _filterSource.toLowerCase());

      final statusStr = b.status.name.toLowerCase();
      final matchStatus = _filterStatus == 'all' ||
          (statusStr == _filterStatus.toLowerCase()) ||
          (_filterStatus == 'pendingPayment' && statusStr == 'pendingpayment');

      final matchQuery =
          b.guestName.toLowerCase().contains(_filterQuery.toLowerCase()) ||
              b.id.toLowerCase().contains(_filterQuery.toLowerCase()) ||
              b.guestEmail.toLowerCase().contains(_filterQuery.toLowerCase());

      return matchSource && matchStatus && matchQuery;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(color: AppColors.lightBone, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Central Bookings Management Desk',
              style: AppTextStyles.titleLg),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Track and filter incoming reservations from all channels dynamically.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.charcoal.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          _buildFilterBar(),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                return _buildBookingMobileList(filteredBookings);
              } else {
                return _buildBookingDesktopTable(filteredBookings);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: AppColors.stoneBg.withValues(alpha: 0.5),
        borderRadius: AppRadius.lgBr,
        border: Border.all(color: AppColors.lightBone),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile) ...[
                _buildDropdownFilter(
                    'Source Filter',
                    _filterSource,
                    {
                      'all': 'All Sources',
                      'direct': 'Direct Web',
                      'airbnb': 'Airbnb.com',
                      'bookingCom': 'Booking.com',
                      'agoda': 'Agoda',
                      'makemytrip': 'MakeMyTrip',
                      'goibibo': 'Goibibo',
                    },
                    (val) => setState(() => _filterSource = val)),
                const SizedBox(height: AppSpacing.md),
                _buildDropdownFilter(
                    'Status Filter',
                    _filterStatus,
                    {
                      'all': 'All Statuses',
                      'confirmed': 'Confirmed',
                      'pendingPayment': 'Pending Payment',
                      'cancelled': 'Cancelled',
                    },
                    (val) => setState(() => _filterStatus = val)),
                const SizedBox(height: AppSpacing.md),
                _buildSearchField(),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownFilter(
                          'Source Filter',
                          _filterSource,
                          {
                            'all': 'All Sources',
                            'direct': 'Direct Web',
                            'airbnb': 'Airbnb.com',
                            'bookingCom': 'Booking.com',
                            'agoda': 'Agoda',
                            'makemytrip': 'MakeMyTrip',
                            'goibibo': 'Goibibo',
                          },
                          (val) => setState(() => _filterSource = val)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdownFilter(
                          'Status Filter',
                          _filterStatus,
                          {
                            'all': 'All Statuses',
                            'confirmed': 'Confirmed',
                            'pendingPayment': 'Pending Payment',
                            'cancelled': 'Cancelled',
                          },
                          (val) => setState(() => _filterStatus = val)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _buildSearchField(),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDropdownFilter(String label, String value,
      Map<String, String> options, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSm
              .copyWith(color: AppColors.charcoal.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 6),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.lightBone),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w500),
              icon: const Icon(Icons.arrow_drop_down, size: 18),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
              items: options.entries.map((e) {
                return DropdownMenuItem(value: e.key, child: Text(e.value));
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SEARCH RESERVATION',
          style: AppTextStyles.labelSm
              .copyWith(color: AppColors.charcoal.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _filterQuery = val),
            style: GoogleFonts.inter(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Search by guest name, reference ID...',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search, size: 16),
              suffixIcon: _filterQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 14),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _filterQuery = '');
                      },
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingDesktopTable(List<Booking> list) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightBone),
        borderRadius: AppRadius.lgBr,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lgBr,
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.2), // Reference ID
            1: FlexColumnWidth(2.2), // Guest Info
            2: FlexColumnWidth(2.0), // Dates
            3: FlexColumnWidth(1.2), // Channel
            4: FlexColumnWidth(1.8), // Payment
            5: FlexColumnWidth(1.5), // Overall Status
            6: FlexColumnWidth(2.0), // Actions
          },
          border: const TableBorder.symmetric(
              inside: BorderSide(color: AppColors.lightBone, width: 0.5)),
          children: [
            TableRow(
              decoration: BoxDecoration(
                  color: AppColors.stoneBg.withValues(alpha: 0.3)),
              children: [
                _buildTableHeader('Reference ID'),
                _buildTableHeader('Guest Information'),
                _buildTableHeader('Dates / Nights'),
                _buildTableHeader('Channel'),
                _buildTableHeader('Payment'),
                _buildTableHeader('Overall Status'),
                _buildTableHeader('Actions'),
              ],
            ),
            if (list.isEmpty)
              TableRow(
                children: [
                  for (int i = 0; i < 7; i++)
                    i == 3
                        ? const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text('No matching records found.',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          )
                        : const SizedBox.shrink()
                ],
              )
            else
              ...list.map((b) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 14),
                      child: Text(
                        b.id,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: AppColors.mossGreen,
                            fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.guestName,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.charcoal)),
                          const SizedBox(height: 2),
                          Text('${b.guestPhone} • ${b.guestEmail}',
                              style: GoogleFonts.inter(
                                  fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${b.startDate} to ${b.endDate}',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600, fontSize: 11)),
                          Text(
                              '${b.nightsCount} Nights ({b.guestsCount} guests)',
                              style: GoogleFonts.inter(
                                  fontSize: 9, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: b.source == BookingSource.direct
                              ? Colors.amber.shade50
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          b.source.toJson().toUpperCase(),
                          style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: b.source == BookingSource.direct
                                  ? Colors.amber.shade900
                                  : Colors.blue.shade800),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('₹${b.totalAmount.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(
                              'Paid: ₹${b.advancePaidAmount.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                  fontSize: 9, color: Colors.grey)),
                          Text(
                            b.paymentStatus.name.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: b.paymentStatus == PaymentStatus.paid
                                  ? Colors.green
                                  : b.paymentStatus == PaymentStatus.refunded
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: b.status == BookingStatus.confirmed
                              ? Colors.green.shade50
                              : b.status == BookingStatus.cancelled
                                  ? Colors.red.shade50
                                  : Colors.orange.shade50,
                          borderRadius: AppRadius.mdBr,
                        ),
                        child: Text(
                          b.status.name.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: b.status == BookingStatus.confirmed
                                ? Colors.green.shade800
                                : b.status == BookingStatus.cancelled
                                    ? Colors.red.shade800
                                    : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 10),
                      child: _buildBookingActions(b),
                    ),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal.withValues(alpha: 0.5)),
      ),
    );
  }

  Widget _buildBookingActions(Booking b) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (b.status == BookingStatus.pendingPayment)
          InkWell(
            onTap: () {
              ref.read(bookingsProvider.notifier).confirmPayment(b.id);
              ref.read(notificationsProvider.notifier).addNotification(
                    'Payment Authorized',
                    'Authorized check-in payment of ₹${b.totalAmount.toStringAsFixed(0)} for ${b.guestName}.',
                    'payment',
                  );
              SnackbarHelper.success(
                  context, 'Payment authorized successfully.');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.shade200)),
              child: Text('Authorize Pay',
                  style: GoogleFonts.inter(
                      fontSize: 9,
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        if (b.status != BookingStatus.cancelled)
          InkWell(
            onTap: () {
              ref
                  .read(bookingsProvider.notifier)
                  .cancelBooking(b.id, 'Cancelled via Admin Console', 100);
              ref.read(notificationsProvider.notifier).addNotification(
                    'Reservation Revoked',
                    'Cancelled booking ${b.id} and scheduled full refund.',
                    'system',
                  );
              SnackbarHelper.success(
                  context, 'Reservation revoked and refund scheduled.');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.shade200)),
              child: Text('Revoke',
                  style: GoogleFonts.inter(
                      fontSize: 9,
                      color: Colors.red.shade900,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Housekeeping & Guest Notes',
                      style: AppTextStyles.titleLg),
                  content: Text(b.housekeepingNotes ??
                      'No custom housekeeping details uploaded.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close')),
                  ],
                );
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text('Notes',
                style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.blue.shade700,
                    decoration: TextDecoration.underline)),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingMobileList(List<Booking> list) {
    if (list.isEmpty) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('No matching records found.')));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (c, idx) =>
          const Divider(color: AppColors.lightBone, height: 24),
      itemBuilder: (context, idx) {
        final b = list[idx];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(b.id,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: AppColors.mossGreen,
                        fontSize: 13)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: b.source == BookingSource.direct
                        ? Colors.amber.shade50
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    b.source.toJson().toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: b.source == BookingSource.direct
                            ? Colors.amber.shade900
                            : Colors.blue.shade800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(b.guestName,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            Text('${b.guestPhone} • ${b.guestEmail}',
                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DATES / NIGHTS',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 9, color: Colors.grey)),
                      Text('${b.startDate} to ${b.endDate}',
                          style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w600)),
                      Text('${b.nightsCount} Nights',
                          style: GoogleFonts.inter(
                              fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('TOTAL AMOUNT',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 9, color: Colors.grey)),
                      Text('₹${b.totalAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Status: ${b.status == BookingStatus.pendingPayment ? "PENDING PAY" : b.status.name.toUpperCase()}',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: b.status == BookingStatus.confirmed
                                ? Colors.green.shade800
                                : b.status == BookingStatus.cancelled
                                    ? Colors.red.shade800
                                    : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildBookingActions(b),
          ],
        );
      },
    );
  }

  // --- 4. TARIFFS & SEASONALITY ---
  Widget _buildTariffsView(
      PropertyDetails property, List<PricingSeasonRule> pricingRules) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isVertical = constraints.maxWidth < 900;
        final baseRateCard = _buildBaseRatesCard(property);
        final seasonalCard = _buildSeasonalRulesCard(pricingRules);

        if (isVertical) {
          return Column(
            children: [
              baseRateCard,
              const SizedBox(height: 20),
              seasonalCard,
            ],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: baseRateCard),
              const SizedBox(width: 20),
              Expanded(flex: 7, child: seasonalCard),
            ],
          );
        }
      },
    );
  }

  Widget _buildBaseRatesCard(PropertyDetails property) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(color: AppColors.lightBone, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Optimize Base Tariffs', style: AppTextStyles.titleLg),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Optimize flat system defaults immediately. Adjusting these recalculates all incoming live checkout quotes.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.charcoal.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          _buildNumberInputField(
            'Weekday Night Base (INR)',
            property.basePriceWeekday,
            (val) {
              ref.read(propertyProvider.notifier).updateProperty(
                    property.copyWith(basePriceWeekday: val),
                  );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildNumberInputField(
            'Weekend Night Base (INR)',
            property.basePriceWeekend,
            (val) {
              ref.read(propertyProvider.notifier).updateProperty(
                    property.copyWith(basePriceWeekend: val),
                  );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildNumberInputField(
            'Extra Guest Fee / Night',
            property.extraGuestCharge,
            (val) {
              ref.read(propertyProvider.notifier).updateProperty(
                    property.copyWith(extraGuestCharge: val),
                  );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildNumberInputField(
            'Standard cleaning fee',
            property.cleaningFee,
            (val) {
              ref.read(propertyProvider.notifier).updateProperty(
                    property.copyWith(cleaningFee: val),
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInputField(
      String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppColors.charcoal.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 44,
          child: TextFormField(
            initialValue: value.toStringAsFixed(0),
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (val) {
              final parsed = double.tryParse(val) ?? 0.0;
              onChanged(parsed);
            },
          ),
        ),
      ],
    );
  }

  final _seasonNameController = TextEditingController();
  final _seasonWeekdayController = TextEditingController();
  final _seasonWeekendController = TextEditingController();
  final _seasonMultiplierController = TextEditingController();
  String _seasonStartDate = '';
  String _seasonEndDate = '';
  String? _seasonFormError;

  Future<void> _pickSeasonDate(bool isStart, [void Function()? onUpdate]) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 6, 1),
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2026, 12, 31),
      helpText: isStart ? 'Select Start Month & Day' : 'Select End Month & Day',
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.mossGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.charcoal,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && context.mounted) {
      final formatted =
          '${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) {
          _seasonStartDate = formatted;
        } else {
          _seasonEndDate = formatted;
        }
      });
      onUpdate?.call();
    }
  }

  void _showAddSeasonRuleDialog() {
    _seasonNameController.clear();
    _seasonStartDate = '';
    _seasonEndDate = '';
    _seasonWeekdayController.clear();
    _seasonWeekendController.clear();
    _seasonMultiplierController.clear();
    _seasonFormError = null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.tune, size: 20, color: AppColors.mossGreen),
              const SizedBox(width: 8),
              Text('Add Seasonal Rule', style: AppTextStyles.titleLg),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SEASON NAME',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 6),
                TextField(
                  controller: _seasonNameController,
                  style: GoogleFonts.inter(fontSize: 12),
                  decoration: const InputDecoration(
                      hintText: 'e.g. Monsoon Discount, Peak Season'),
                ),
                const SizedBox(height: 16),
                Text('PROPERTY',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 6),
                Consumer(
                  builder: (context, ref, _) {
                    final properties = ref.watch(resortsListProvider);
                    if (properties.isEmpty) return const Text('No properties available');
                    return DropdownButtonFormField<String>(
                      value: _selectedPropertyId,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.stoneBg.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.lightBone),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      hint: Text('Select a property', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      items: properties.map((p) {
                        return DropdownMenuItem<String>(
                          value: p.id,
                          child: Text(p.name, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedPropertyId = val);
                        setDialogState(() {});
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSeasonDateField(
                        'START DATE',
                        _seasonStartDate,
                        () => _pickSeasonDate(true, () => setDialogState(() {})),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSeasonDateField(
                        'END DATE',
                        _seasonEndDate,
                        () => _pickSeasonDate(false, () => setDialogState(() {})),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSeasonNumberField(
                        'WEEKDAY PRICE (₹)',
                        _seasonWeekdayController,
                        'e.g. 9600',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSeasonNumberField(
                        'WEEKEND PRICE (₹)',
                        _seasonWeekendController,
                        'e.g. 12000',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSeasonNumberField(
                  'MULTIPLIER',
                  _seasonMultiplierController,
                  'e.g. 0.8 for discount, 1.5 for peak',
                ),
                if (_seasonFormError != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(_seasonFormError!,
                        style: TextStyle(
                            color: Colors.red.shade800, fontSize: 11)),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _seasonNameController.text.trim();
                final start = _seasonStartDate;
                final end = _seasonEndDate;
                final weekday =
                    double.tryParse(_seasonWeekdayController.text.trim());
                final weekend =
                    double.tryParse(_seasonWeekendController.text.trim());
                final multiplier =
                    double.tryParse(_seasonMultiplierController.text.trim());

                if (_selectedPropertyId == null) {
                  setDialogState(() {
                    _seasonFormError = 'Please select a property.';
                  });
                  return;
                }

                if (name.isEmpty || start.isEmpty || end.isEmpty) {
                  setDialogState(() {
                    _seasonFormError = 'Name, start date, and end date are required.';
                  });
                  return;
                }

                if (weekday == null || weekend == null) {
                  setDialogState(() {
                    _seasonFormError = 'Weekday and weekend prices are required.';
                  });
                  return;
                }

                final rule = PricingSeasonRule(
                  id: 'SR-${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  startDate: start,
                  endDate: end,
                  weekdayPrice: weekday,
                  weekendPrice: weekend,
                  multiplier: multiplier ?? 1.0,
                  isActive: true,
                  propertyId: _selectedPropertyId,
                );

                try {
                  await ref.read(pricingRulesProvider.notifier).addRule(rule);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    if (context.mounted) {
                      SnackbarHelper.success(context, 'Seasonal rule "$name" added.');
                    }
                  }
                } catch (e) {
                  setDialogState(() {
                    _seasonFormError = 'Failed to add rule: $e';
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mossGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Rule'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonDateField(String label, String value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.stoneBg.withValues(alpha: 0.3),
              borderRadius: AppRadius.mdBr,
              border: Border.all(color: AppColors.lightBone),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? 'Pick date' : value,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: value.isEmpty
                          ? Colors.grey
                          : AppColors.charcoal,
                      fontWeight:
                          value.isEmpty ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today,
                    size: 14, color: AppColors.mossGreen),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonNumberField(
      String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(fontSize: 12),
            decoration: InputDecoration(hintText: hint),
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonalRulesCard(List<PricingSeasonRule> pricingRules) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(color: AppColors.lightBone, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Seasonal Rule Modifiers', style: AppTextStyles.titleLg),
          const SizedBox(height: AppSpacing.sm),
          ElevatedButton.icon(
            onPressed: _showAddSeasonRuleDialog,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Rule',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mossGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdBr),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Toggle or customize seasonal multipliers on target date limits.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.charcoal.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          if (pricingRules.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('No seasonal rules defined yet. Tap "Add Rule" to create one.',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            )
          else
            ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pricingRules.length,
            separatorBuilder: (c, idx) =>
                const Divider(color: AppColors.lightBone, height: 20),
            itemBuilder: (context, idx) {
              final rule = pricingRules[idx];
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 500;
                  final info = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rule.name,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(
                        'Applies Month Limits: check-ins between ${rule.startDate} and ${rule.endDate}',
                        style:
                            GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Text('Multiplier: ${rule.multiplier}x',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.mossGreen)),
                          Text(
                              'Weekday: ₹${rule.weekdayPrice.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(fontSize: 11)),
                          Text(
                              'Weekend: ₹${rule.weekendPrice.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(fontSize: 11)),
                        ],
                      ),
                    ],
                  );

                  final button = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Rule'),
                              content: Text('Delete "${rule.name}"?'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(pricingRulesProvider.notifier)
                                        .deleteRule(rule.id);
                                    Navigator.pop(ctx);
                                    SnackbarHelper.success(
                                        context, '${rule.name} deleted.');
                                  },
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.delete_outline,
                              size: 18, color: Colors.red.shade300),
                        ),
                      ),
                      Switch(
                        value: rule.isActive,
                        activeColor: AppColors.mossGreen,
                        onChanged: (val) {
                          ref
                              .read(pricingRulesProvider.notifier)
                              .toggleRuleActive(rule.id);
                        },
                      ),
                    ],
                  );

                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(rule.name,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            button,
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Applies Month Limits: check-ins between ${rule.startDate} and ${rule.endDate}',
                          style: GoogleFonts.inter(
                              fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            Text('Multiplier: ${rule.multiplier}x',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mossGreen)),
                            Text(
                                'Weekday: ₹${rule.weekdayPrice.toStringAsFixed(0)}',
                                style: GoogleFonts.inter(fontSize: 11)),
                            Text(
                                'Weekend: ₹${rule.weekendPrice.toStringAsFixed(0)}',
                                style: GoogleFonts.inter(fontSize: 11)),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: info),
                        button,
                      ],
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 5. DISCOUNT COUPONS EDITOR ---
  Widget _buildCouponsEditor(List<Coupon> coupons) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isVertical = constraints.maxWidth < 900;
        final formCard = _buildCouponFormCard();
        final listCard = _buildCouponListCard(coupons);

        if (isVertical) {
          return Column(
            children: [
              formCard,
              const SizedBox(height: 20),
              listCard,
            ],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: formCard),
              const SizedBox(width: 20),
              Expanded(flex: 7, child: listCard),
            ],
          );
        }
      },
    );
  }

  Widget _buildCouponFormCard() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(color: AppColors.lightBone, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add System Coupon', style: AppTextStyles.titleLg),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create custom promo codes that guests can immediately enter and check out with.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.charcoal.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COUPON CODE',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _couponCodeController,
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 12, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: 'e.g. MONSOON20',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COUPON SCHEMA',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(height: 6),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.stoneBg.withValues(alpha: 0.3),
                        borderRadius: AppRadius.lgBr,
                        border: Border.all(color: AppColors.lightBone),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _couponType,
                          isExpanded: true,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.charcoal,
                              fontWeight: FontWeight.w500),
                          onChanged: (val) {
                            if (val != null) setState(() => _couponType = val);
                          },
                          items: const [
                            DropdownMenuItem(
                                value: 'percentage',
                                child: Text('Percentage Discount')),
                            DropdownMenuItem(
                                value: 'fixed',
                                child: Text('Fixed INR Deduction')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('VALUE AMOUNT',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 40,
                      child: TextFormField(
                        initialValue: _couponValue.toStringAsFixed(0),
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(fontSize: 12),
                        decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10)),
                        onChanged: (val) => setState(
                            () => _couponValue = double.tryParse(val) ?? 0.0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDatePickerField('Expiry Date', _couponExpiry,
                    (val) => setState(() => _couponExpiry = val)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('USAGE LIMIT CAP',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 40,
                      child: TextFormField(
                        initialValue: _couponLimit.toString(),
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(fontSize: 12),
                        decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10)),
                        onChanged: (val) => setState(
                            () => _couponLimit = int.tryParse(val) ?? 0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MIN BOOKING CAP',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 40,
                      child: TextFormField(
                        initialValue: _couponMinSub.toStringAsFixed(0),
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(fontSize: 12),
                        decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10)),
                        onChanged: (val) => setState(
                            () => _couponMinSub = double.tryParse(val) ?? 0.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('COUPON DESCRIPTION',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 6),
          SizedBox(
            height: 40,
            child: TextField(
              controller: _couponDescController,
              style: GoogleFonts.inter(fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Brief label shown to guests',
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_couponFormError != null)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                  color: Colors.red.shade50, borderRadius: AppRadius.smBr),
              child: Text(_couponFormError!,
                  style: TextStyle(color: Colors.red.shade800, fontSize: 11)),
            ),
          ElevatedButton(
            onPressed: _handleCreateCoupon,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mossGreen,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBr),
            ),
            child: Text('Add Coupon to Registry',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateCoupon() async {
    setState(() {
      _couponFormError = null;
    });

    final code = _couponCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() {
        _couponFormError = 'Coupon code is required.';
      });
      return;
    }

    final newCoupon = Coupon(
      id: 'C-${DateTime.now().millisecondsSinceEpoch}',
      code: code,
      type: _couponType,
      value: _couponValue,
      expiryDate: _couponExpiry,
      usageLimit: _couponLimit,
      usageCount: 0,
      minBookingValue: _couponMinSub,
      description: _couponDescController.text.trim().isNotEmpty
          ? _couponDescController.text.trim()
          : (_couponType == 'percentage'
              ? '${_couponValue.toStringAsFixed(0)}% off on bookings above ₹${_couponMinSub.toStringAsFixed(0)}'
              : '₹${_couponValue.toStringAsFixed(0)} off on bookings above ₹${_couponMinSub.toStringAsFixed(0)}'),
      isActive: true,
    );

    try {
      await ref.read(couponsProvider.notifier).addCoupon(newCoupon);
      ref.read(notificationsProvider.notifier).addNotification(
            'New Promotion Added',
            'Created code $code offering dynamic savings on checkout.',
            'system',
          );
      setState(() {
        _couponCodeController.clear();
        _couponDescController.clear();
        _couponValue = 10;
        _couponMinSub = 25000;
      });
      if (!context.mounted) return;
      SnackbarHelper.success(context, 'Coupon added to registry successfully!');
    } catch (e) {
      setState(() {
        _couponFormError = 'Failed to create coupon: $e';
      });
    }
  }

  Widget _buildCouponListCard(List<Coupon> coupons) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(color: AppColors.lightBone, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active Registered Coupons', style: AppTextStyles.titleLg),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Manage rules or revoke access immediately.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.charcoal.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: coupons.length,
            separatorBuilder: (c, idx) =>
                const Divider(color: AppColors.lightBone, height: 20),
            itemBuilder: (context, idx) {
              final cp = coupons[idx];
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(cp.code,
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.charcoal)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: cp.isActive
                                    ? Colors.green.shade50
                                    : AppColors.stoneBg,
                                borderRadius: AppRadius.smBr,
                              ),
                              child: Text(
                                cp.isActive ? 'ACTIVE' : 'INACTIVE',
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: cp.isActive
                                      ? Colors.green.shade800
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(cp.description,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color:
                                    AppColors.charcoal.withValues(alpha: 0.6))),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Usage: ${cp.usageCount} / ${cp.usageLimit} • Min Booking Value: ₹${cp.minBookingValue.toStringAsFixed(0)} • Expires: ${cp.expiryDate}',
                          style: GoogleFonts.inter(
                              fontSize: 9, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Coupon'),
                          content: Text('Delete coupon "${cp.code}"?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel')),
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(couponsProvider.notifier)
                                    .deleteCoupon(cp.id);
                                Navigator.pop(ctx);
                                SnackbarHelper.success(
                                    context, 'Coupon ${cp.code} deleted.');
                              },
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.delete_outline,
                          size: 18, color: Colors.red.shade300),
                    ),
                  ),
                  Switch(
                    value: cp.isActive,
                    activeThumbColor: AppColors.mossGreen,
                    onChanged: (val) {
                      ref
                          .read(couponsProvider.notifier)
                          .toggleCouponActive(cp.id);
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 6. OTA SYNERGY HUB ---
  Widget _buildOtaSynergy(List<OtaSyncStatus> otaChannels) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xxlBr,
        border: Border.all(color: AppColors.lightBone, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('OTA Channel Synchronizer', style: AppTextStyles.titleLg),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Manage real-time connections with global travel networks.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.charcoal.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final int crossAxisCount =
                  width > 1000 ? 3 : (width > 600 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: otaChannels.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (context, index) {
                  final ch = otaChannels[index];
                  final isConflict = ch.status == 'conflict';
                  final isError = ch.status == 'error';

                  return Container(
                    padding: AppSpacing.allLg,
                    decoration: BoxDecoration(
                      color: isConflict
                          ? const Color(0xFFFFF8E1).withValues(alpha: 0.3)
                          : (isError
                              ? const Color(0xFFFFEBEE).withValues(alpha: 0.3)
                              : AppColors.stoneBg.withValues(alpha: 0.3)),
                      borderRadius: AppRadius.lgBr,
                      border: Border.all(
                        color: isConflict
                            ? Colors.amber.shade300
                            : (isError
                                ? Colors.red.shade200
                                : AppColors.lightBone),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '🏕  ${ch.channelName}',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: ch.status == 'success'
                                        ? Colors.green.shade50
                                        : (isConflict
                                            ? Colors.amber.shade50
                                            : Colors.red.shade50),
                                    borderRadius: AppRadius.smBr,
                                  ),
                                  child: Text(
                                    ch.status.toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: ch.status == 'success'
                                          ? Colors.green.shade800
                                          : (isConflict
                                              ? Colors.amber.shade800
                                              : Colors.red.shade800),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Last synchronisation checklist:',
                              style: GoogleFonts.inter(
                                  fontSize: 10, color: Colors.grey),
                            ),
                            Text(
                              ch.lastSyncTime.contains('T')
                                  ? '${ch.lastSyncTime.split('T')[0]} ${ch.lastSyncTime.split('T')[1].substring(0, 5)}'
                                  : ch.lastSyncTime,
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.charcoal
                                      .withValues(alpha: 0.7)),
                            ),
                            if (ch.conflictsCount > 0) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(4)),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning,
                                        size: 10, color: Colors.amber.shade800),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${ch.conflictsCount} overlap conflict flagged.',
                                        style: TextStyle(
                                            color: Colors.amber.shade900,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                ref
                                    .read(otaSyncProvider.notifier)
                                    .toggleSync(ch.id);
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    ch.syncEnabled
                                        ? Icons.toggle_on
                                        : Icons.toggle_off,
                                    color: ch.syncEnabled
                                        ? Colors.green
                                        : Colors.grey,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    ch.syncEnabled
                                        ? 'Sync Enabled'
                                        : 'Disabled',
                                    style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: ch.syncEnabled
                                  ? () {
                                      ref
                                          .read(otaSyncProvider.notifier)
                                          .triggerSyncSuccess(ch.id);
                                      SnackbarHelper.success(context,
                                          'Synchronized ${ch.channelName} feeds.');
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                surfaceTintColor: Colors.white,
                                foregroundColor: AppColors.charcoal,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.smBr,
                                    side: const BorderSide(
                                        color: AppColors.lightBone)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.refresh, size: 12),
                                  const SizedBox(width: 4),
                                  Text('Sync Now',
                                      style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- SalesChartPainter ---
class SalesChartPainter extends CustomPainter {
  final List<double> points;
  SalesChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.mossGreen
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.mossGreen.withValues(alpha: 0.12),
          AppColors.mossGreen.withValues(alpha: 0.01),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final double stepX = size.width / (points.length - 1);

    path.moveTo(0, size.height - (points[0] * size.height));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height - (points[0] * size.height));

    for (int i = 1; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height - (points[i] * size.height);

      final prevX = (i - 1) * stepX;
      final prevY = size.height - (points[i - 1] * size.height);
      final controlX1 = prevX + stepX / 2;
      final controlY1 = prevY;
      final controlX2 = prevX + stepX / 2;
      final controlY2 = y;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = AppColors.lightBone.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw dots at key locations
    final dotPaint = Paint()
      ..color = AppColors.mossGreen
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height - (points[i] * size.height);
      canvas.drawCircle(Offset(x, y), 4.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SalesChartPainter oldDelegate) =>
      oldDelegate.points != points;
}
