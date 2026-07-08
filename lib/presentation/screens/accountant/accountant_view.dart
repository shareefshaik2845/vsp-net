import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/state_provider.dart';
import '../../../core/theme.dart';
import '../../../core/snackbar_helper.dart';
import '../../../domain/entities.dart';

class AccountantView extends ConsumerStatefulWidget {
  const AccountantView({super.key});

  @override
  ConsumerState<AccountantView> createState() => _AccountantViewState();
}

class _AccountantViewState extends ConsumerState<AccountantView> {
  final _searchController = TextEditingController();
  String _filterPayment = 'all'; // all, paid, partially_paid, pending, refunded
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatIndianCurrency(double value) {
    final String s = value.toStringAsFixed(0);
    if (s.length <= 3) return s;
    final String lastThree = s.substring(s.length - 3);
    String remaining = s.substring(0, s.length - 3);
    final List<String> groups = [];
    while (remaining.length > 2) {
      groups.insert(0, remaining.substring(remaining.length - 2));
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) {
      groups.insert(0, remaining);
    }
    return '${groups.join(',')},$lastThree';
  }

  String _getPaymentStatusLabel(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return 'PAID';
      case PaymentStatus.partiallyPaid:
        return 'PARTIALLY PAID';
      case PaymentStatus.pending:
        return 'PENDING';
      case PaymentStatus.refunded:
        return 'REFUNDED';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(bookingsProvider);
    final propertyAsync = ref.watch(propertyProvider);
    final activeResort = propertyAsync.valueOrNull;

    // Filtered list of invoices
    final filteredInvoices = bookings.where((b) {
      final matchSearch = b.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.guestName.toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchPayment = true;
      if (_filterPayment != 'all') {
        if (_filterPayment == 'paid') {
          matchPayment = b.paymentStatus == PaymentStatus.paid;
        } else if (_filterPayment == 'partially_paid') {
          matchPayment = b.paymentStatus == PaymentStatus.partiallyPaid;
        } else if (_filterPayment == 'pending') {
          matchPayment = b.paymentStatus == PaymentStatus.pending;
        } else if (_filterPayment == 'refunded') {
          matchPayment = b.paymentStatus == PaymentStatus.refunded;
        }
      }
      
      return matchSearch && matchPayment;
    }).toList();

    // Summary calculations
    final double totalInvoicedSum = bookings.fold(0.0, (sum, b) => sum + b.totalAmount);
    final double totalCollectedSum = bookings.fold(0.0, (sum, b) => sum + b.advancePaidAmount);
    final double totalBalanceSells = bookings.fold(0.0, (sum, b) => sum + b.balanceAmount);
    
    // Refunds queue
    final refundQueue = bookings
        .where((b) => b.status == BookingStatus.cancelled && b.paymentStatus != PaymentStatus.refunded)
        .toList();

    return Scaffold(
      backgroundColor: ResortTheme.stoneBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 750;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderRibbon(isMobile, activeResort),
                const SizedBox(height: 24),
                _buildKpiGrid(
                  isMobile,
                  totalInvoicedSum,
                  totalCollectedSum,
                  totalBalanceSells,
                  refundQueue.length,
                ),
                const SizedBox(height: 24),
                _buildMainContentSplit(isMobile, refundQueue, filteredInvoices),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderRibbon(bool isMobile, PropertyDetails? activeResort) {
    final resortName = activeResort != null 
        ? activeResort.name
        : 'Resort';

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: ResortTheme.lightBone, width: 1.0),
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
                      '$resortName Ledger Office',
                      style: ResortTheme.lightTheme.textTheme.displayMedium?.copyWith(
                        fontSize: isMobile ? 20 : 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track incoming invoices, process refund streams, and balance corporate assets cash flow.',
                      style: ResortTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: ResortTheme.charcoal.withValues(alpha: 0.6),
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
            const SizedBox(height: 16),
            _buildPropertySelector(activeResort, isMobile),
          ],
          const SizedBox(height: 20),
          isMobile
              ? Row(
                  children: [
                    Expanded(
                      child: _buildExportButton(
                        'pdf',
                        Icons.download,
                        'Export PDF\nLedger',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildExportButton(
                        'excel',
                        Icons.trending_up,
                        'Export\nExcel',
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    _buildExportButton(
                      'pdf',
                      Icons.download,
                      'Export PDF Ledger',
                    ),
                    const SizedBox(width: 8),
                    _buildExportButton(
                      'excel',
                      Icons.trending_up,
                      'Export Excel',
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildPropertySelector(PropertyDetails currentProperty, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: ResortTheme.mossGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ResortTheme.mossGreen.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PropertyDetails>(
          isExpanded: isMobile,
          value: currentProperty,
          icon: const Icon(Icons.arrow_drop_down, color: ResortTheme.mossGreen),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: ResortTheme.mossGreen,
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

  Widget _buildExportButton(String format, IconData icon, String label) {
    return InkWell(
      onTap: () {
        ref.read(notificationsProvider.notifier).addNotification(
          'Export Initiated',
          'Successfully generated financial ledger stream in ${format.toUpperCase()} format. Download started.',
          'system',
        );
        SnackbarHelper.success(context, 'Ledger exported in ${format.toUpperCase()} format.');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ResortTheme.lightBone, width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: ResortTheme.charcoal),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: ResortTheme.charcoal,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiGrid(
    bool isMobile,
    double invoiced,
    double collected,
    double balance,
    int pendingRefunds,
  ) {
    if (isMobile) {
      return Column(
        children: [
          _buildKpiCard(
            'Total Booked Gross',
            '₹${_formatIndianCurrency(invoiced)} INR',
            'Ledger Total',
            const Color(0xFFE0E7FF), // indigo 100 bg
            const Color(0xFF4338CA), // indigo 700 text
            '₹',
            isDark: false,
          ),
          const SizedBox(height: 12),
          _buildKpiCard(
            'Total Cash Collected',
            '₹${_formatIndianCurrency(collected)} INR',
            'Deposited / Settled',
            const Color(0xFFD1FAE5), // emerald 100 bg
            const Color(0xFF065F46), // emerald 800 text
            null,
            iconData: Icons.check_circle_outline,
            isDark: false,
          ),
          const SizedBox(height: 12),
          _buildKpiCard(
            'Balance Account Receivable',
            '₹${_formatIndianCurrency(balance)} INR',
            'On Arrival Settle',
            const Color(0xFFFEF3C7), // amber 100 bg
            const Color(0xFF92400E), // amber 800 text
            null,
            iconData: Icons.credit_card,
            isDark: false,
          ),
          const SizedBox(height: 12),
          _buildKpiCard(
            'Refunds Queue',
            '$pendingRefunds Pending',
            'requires clearing action',
            const Color(0xFF1E293B), // slate 800 bg
            const Color(0xFFF1F5F9), // slate 100 text
            null,
            iconData: Icons.refresh,
            isDark: true,
          ),
        ],
      );
    } else {
      return LayoutBuilder(
        builder: (context, c) {
          final width = (c.maxWidth - 48) / 4;
          return Row(
            children: [
              _buildKpiCard(
                'Total Booked Gross',
                '₹${_formatIndianCurrency(invoiced)} INR',
                'Ledger Total',
                const Color(0xFFE0E7FF),
                const Color(0xFF4338CA),
                '₹',
                isDark: false,
                width: width,
              ),
              const SizedBox(width: 16),
              _buildKpiCard(
                'Total Cash Collected',
                '₹${_formatIndianCurrency(collected)} INR',
                'Deposited / Settled',
                const Color(0xFFD1FAE5),
                const Color(0xFF065F46),
                null,
                iconData: Icons.check_circle_outline,
                isDark: false,
                width: width,
              ),
              const SizedBox(width: 16),
              _buildKpiCard(
                'Balance Account Receivable',
                '₹${_formatIndianCurrency(balance)} INR',
                'On Arrival Settle',
                const Color(0xFFFEF3C7),
                const Color(0xFF92400E),
                null,
                iconData: Icons.credit_card,
                isDark: false,
                width: width,
              ),
              const SizedBox(width: 16),
              _buildKpiCard(
                'Refunds Queue',
                '$pendingRefunds Pending',
                'requires clearing action',
                const Color(0xFF1E293B),
                const Color(0xFFF1F5F9),
                null,
                iconData: Icons.refresh,
                isDark: true,
                width: width,
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildKpiCard(
    String label,
    String value,
    String badgeText,
    Color accentBg,
    Color accentText,
    String? symbol, {
    IconData? iconData,
    required bool isDark,
    double? width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? null : Border.all(color: ResortTheme.lightBone),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey.shade400 : ResortTheme.charcoal.withValues(alpha: 0.4),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : ResortTheme.charcoal,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : accentBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.inter(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey.shade300 : accentText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : accentBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: symbol != null
                ? Text(
                    symbol,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: accentText,
                    ),
                  )
                : Icon(
                    iconData,
                    size: 16,
                    color: isDark ? Colors.grey.shade400 : accentText,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContentSplit(
    bool isMobile,
    List<Booking> refundQueue,
    List<Booking> invoices,
  ) {
    if (isMobile) {
      return Column(
        children: [
          _buildRefundQueueBlock(refundQueue),
          const SizedBox(height: 24),
          _buildInvoicesBlock(context, invoices, isMobile: true),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: _buildRefundQueueBlock(refundQueue),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 8,
            child: _buildInvoicesBlock(context, invoices, isMobile: false),
          ),
        ],
      );
    }
  }

  Widget _buildRefundQueueBlock(List<Booking> list) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ResortTheme.lightBone),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card, size: 16, color: ResortTheme.charcoal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pending Refunds Queue (${list.length})',
                  style: ResortTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: ResortTheme.lightBone, height: 1),
          const SizedBox(height: 16),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: Text(
                  'No pending refunds require bookkeeping clears.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade400),
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
                final refundVal = b.refundAmount ?? b.advancePaidAmount;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.red.shade100.withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(16),
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
                                fontSize: 12,
                                color: ResortTheme.charcoal,
                              ),
                            ),
                          ),
                          Text(
                            b.id,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF991B1B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Stays period: ${b.startDate} to ${b.endDate}',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: ResortTheme.charcoal.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: ResortTheme.charcoal.withValues(alpha: 0.6),
                          ),
                          children: [
                            const TextSpan(text: 'Refund Obligation: '),
                            TextSpan(
                              text: '₹${_formatIndianCurrency(refundVal)} INR',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB91C1C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Reason: ${b.cancellationReason ?? "Admin cancellation"}',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          color: ResortTheme.charcoal.withValues(alpha: 0.45),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(bookingsProvider.notifier).processRefund(b.id);
                            ref.read(notificationsProvider.notifier).addNotification(
                              'Refund Settled',
                              'Accountant processed full refund transaction for reference ${b.id}.',
                              'payment',
                            );
                            SnackbarHelper.success(context, 'Processed refund obligation for ${b.id}.');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB91C1C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'Clear & Process Refund',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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

  Widget _buildInvoicesBlock(BuildContext context, List<Booking> list, {required bool isMobile}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ResortTheme.lightBone),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Corporate Invoices Ledger',
                      style: ResortTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Review all generated customer transaction papers.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: ResortTheme.charcoal.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Search & Filter controls
          isMobile
              ? Column(
                  children: [
                    _buildPaymentFilterDropdown(),
                    const SizedBox(height: 8),
                    _buildSearchTextField(),
                  ],
                )
              : Row(
                  children: [
                    SizedBox(
                      width: 140,
                      child: _buildPaymentFilterDropdown(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSearchTextField(),
                    ),
                  ],
                ),
          const SizedBox(height: 20),

          // Invoice list/table container
          isMobile
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildInvoiceCard(context, list[index]);
                  },
                )
              : _buildDesktopTable(context, list),
        ],
      ),
    );
  }

  Widget _buildPaymentFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ResortTheme.lightBone),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filterPayment,
          isExpanded: true,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            color: ResortTheme.charcoal,
          ),
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All States')),
            DropdownMenuItem(value: 'paid', child: Text('Paid')),
            DropdownMenuItem(value: 'partially_paid', child: Text('Partially Paid')),
            DropdownMenuItem(value: 'pending', child: Text('Pending')),
            DropdownMenuItem(value: 'refunded', child: Text('Refunded')),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _filterPayment = val;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ResortTheme.lightBone),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.inter(fontSize: 11.5),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          hintText: 'search by name or invoice...',
          hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 11.5),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          fillColor: Colors.transparent,
          filled: false,
          prefixIcon: Icon(Icons.search, size: 14, color: Colors.grey.shade400),
          prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, Booking invoice) {
    Color stateBg = Colors.white;
    Color stateText = ResortTheme.charcoal;
    switch (invoice.paymentStatus) {
      case PaymentStatus.paid:
        stateBg = const Color(0xFFD1FAE5);
        stateText = const Color(0xFF065F46);
        break;
      case PaymentStatus.partiallyPaid:
        stateBg = const Color(0xFFFEF3C7);
        stateText = const Color(0xFF92400E);
        break;
      case PaymentStatus.pending:
        stateBg = const Color(0xFFE2E8F0);
        stateText = const Color(0xFF475569);
        break;
      case PaymentStatus.refunded:
        stateBg = const Color(0xFFFEE2E2);
        stateText = const Color(0xFF991B1B);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ResortTheme.stoneBg.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ResortTheme.lightBone),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                invoice.id,
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: const Color(0xFF78350F),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: stateBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getPaymentStatusLabel(invoice.paymentStatus),
                  style: GoogleFonts.inter(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: stateText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: ResortTheme.lightBone, height: 1),
          const SizedBox(height: 10),
          Text(
            invoice.guestName,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: ResortTheme.charcoal,
            ),
          ),
          Text(
            invoice.guestEmail,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: ResortTheme.charcoal.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FULFILLMENT AMOUNT',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: ResortTheme.charcoal.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${_formatIndianCurrency(invoice.totalAmount)}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: ResortTheme.charcoal,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'CASH INFLOWS',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: ResortTheme.charcoal.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${_formatIndianCurrency(invoice.advancePaidAmount)}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.green.shade800,
                    ),
                  ),
                  Text(
                    'Balance: ₹${_formatIndianCurrency(invoice.balanceAmount)}',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: ResortTheme.charcoal.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: ResortTheme.lightBone, height: 1),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showInvoiceDialog(context, invoice),
              icon: const Icon(Icons.receipt, size: 13, color: Colors.white),
              label: Text(
                'View paper',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ResortTheme.charcoal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<Booking> invoices) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ResortTheme.lightBone),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text('INVOICE CODE', style: _tableHeaderStyle)),
                  Expanded(flex: 3, child: Text('CUSTOMER ACCOUNT', style: _tableHeaderStyle)),
                  Expanded(flex: 2, child: Text('FULFILLMENT AMOUNT', style: _tableHeaderStyle)),
                  Expanded(flex: 3, child: Text('CASH INFLOWS', style: _tableHeaderStyle)),
                  Expanded(flex: 2, child: Text('STATE', style: _tableHeaderStyle)),
                  Expanded(flex: 2, child: Text('INVOICE DETAILS', style: _tableHeaderStyle)),
                ],
              ),
            ),
            const Divider(color: ResortTheme.lightBone, height: 1),
            if (invoices.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    'No matching records found.',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: invoices.length,
                separatorBuilder: (context, index) => const Divider(color: ResortTheme.lightBone, height: 1),
                itemBuilder: (context, index) {
                  final invoice = invoices[index];
                  Color stateBg = Colors.white;
                  Color stateText = ResortTheme.charcoal;
                  switch (invoice.paymentStatus) {
                    case PaymentStatus.paid:
                      stateBg = const Color(0xFFD1FAE5);
                      stateText = const Color(0xFF065F46);
                      break;
                    case PaymentStatus.partiallyPaid:
                      stateBg = const Color(0xFFFEF3C7);
                      stateText = const Color(0xFF92400E);
                      break;
                    case PaymentStatus.pending:
                      stateBg = const Color(0xFFE2E8F0);
                      stateText = const Color(0xFF475569);
                      break;
                    case PaymentStatus.refunded:
                      stateBg = const Color(0xFFFEE2E2);
                      stateText = const Color(0xFF991B1B);
                      break;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            invoice.id,
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: const Color(0xFF78350F),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invoice.guestName,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: ResortTheme.charcoal,
                                ),
                              ),
                              Text(
                                invoice.guestEmail,
                                style: GoogleFonts.inter(
                                  fontSize: 9.5,
                                  color: ResortTheme.charcoal.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '₹${_formatIndianCurrency(invoice.totalAmount)}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: ResortTheme.charcoal,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${_formatIndianCurrency(invoice.advancePaidAmount)}',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: ResortTheme.charcoal,
                                ),
                              ),
                              Text(
                                'Balance: ₹${_formatIndianCurrency(invoice.balanceAmount)}',
                                style: GoogleFonts.inter(
                                  fontSize: 9.5,
                                  color: ResortTheme.charcoal.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: UnconstrainedBox(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: stateBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getPaymentStatusLabel(invoice.paymentStatus),
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: stateText,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: UnconstrainedBox(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              onTap: () => _showInvoiceDialog(context, invoice),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: ResortTheme.charcoal,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.receipt, size: 10, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      'View paper',
                                      style: GoogleFonts.inter(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
      ),
    );
  }

  TextStyle get _tableHeaderStyle => GoogleFonts.spaceGrotesk(
        fontSize: 9,
        fontWeight: FontWeight.bold,
        color: ResortTheme.charcoal.withValues(alpha: 0.4),
      );

  void _showInvoiceDialog(BuildContext context, Booking invoice) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VSP Nest Billing Statement',
                      style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF451A03),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Settled Reservation Reference • ${invoice.id}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
                        color: ResortTheme.charcoal.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: ResortTheme.lightBone, height: 1),
                const SizedBox(height: 16),
                _dialogInvoiceRow('Direct client:', invoice.guestName),
                _dialogInvoiceRow('Telephone:', invoice.guestPhone),
                _dialogInvoiceRow(
                  'Check-in period:',
                  '${invoice.startDate} to ${invoice.endDate} (${invoice.nightsCount} Nights)',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ResortTheme.stoneBg.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ResortTheme.lightBone),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Item charge description',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: ResortTheme.charcoal.withValues(alpha: 0.4),
                            ),
                          ),
                          Text(
                            'Amount',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: ResortTheme.charcoal.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: ResortTheme.lightBone, height: 1),
                      const SizedBox(height: 8),
                      _itemBreakdownRow(
                        'Luxury Accommodation Nights (${invoice.nightsCount} nights)',
                        invoice.baseAmount,
                      ),
                      if (invoice.extraGuestAmount > 0)
                        _itemBreakdownRow(
                          'Additional Guest Capacity rates',
                          invoice.extraGuestAmount,
                        ),
                      _itemBreakdownRow(
                        'Sanitization Service Fee',
                        invoice.cleaningAmount,
                      ),
                      if (invoice.discountAmount > 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'CouponApplied: ${invoice.couponApplied ?? "Promo"}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFF065F46),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '-₹${_formatIndianCurrency(invoice.discountAmount)}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF065F46),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Divider(color: ResortTheme.lightBone, height: 12),
                      _itemBreakdownRow(
                        'Luxury Tax (18% GST)',
                        invoice.taxAmount,
                      ),
                      const Divider(color: ResortTheme.lightBone, height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Balanced Total Settle:',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ResortTheme.charcoal,
                            ),
                          ),
                          Text(
                            '₹${_formatIndianCurrency(invoice.totalAmount)} INR',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ResortTheme.charcoal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    border: Border.all(color: const Color(0xFFFEF3C7)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF92400E),
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Cash flows split: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: 'Transacted Advance Collected: '),
                        TextSpan(
                          text: '₹${_formatIndianCurrency(invoice.advancePaidAmount)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: '. Ledger Accounts Receivable: '),
                        TextSpan(
                          text: '₹${_formatIndianCurrency(invoice.balanceAmount)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: '. State: '),
                        TextSpan(
                          text: _getPaymentStatusLabel(invoice.paymentStatus),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          SnackbarHelper.info(context, 'Direct Print Out stream initiated.');
                        },
                        icon: const Icon(Icons.print, size: 14, color: Colors.white),
                        label: Text(
                          'Direct Print Out',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ResortTheme.charcoal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: ResortTheme.lightBone),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Back to registers',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: ResortTheme.charcoal.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dialogInvoiceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: ResortTheme.charcoal.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: ResortTheme.charcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemBreakdownRow(String label, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: ResortTheme.charcoal.withValues(alpha: 0.8),
              ),
            ),
          ),
          Text(
            '₹${_formatIndianCurrency(val)}',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: ResortTheme.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}
