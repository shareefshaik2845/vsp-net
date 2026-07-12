import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities.dart';
import '../../providers/state_provider.dart';
import '../../../core/theme.dart';
import '../../../core/snackbar_helper.dart';

class CustomerDashboardView extends ConsumerStatefulWidget {
  const CustomerDashboardView({super.key});

  @override
  ConsumerState<CustomerDashboardView> createState() => _CustomerDashboardViewState();
}

class _CustomerDashboardViewState extends ConsumerState<CustomerDashboardView> {
  String _activeTab = 'upcoming'; // upcoming, past
  Booking? _selectedInvoice;
  Map<String, dynamic>? _invoiceData;

  
  // Cancellation form states
  final _cancelReasonController = TextEditingController();

  @override
  void dispose() {
    _cancelReasonController.dispose();
    super.dispose();
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

  void _openCancellationSheet(Booking booking) {
    setState(() {
      _cancelReasonController.clear();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final double paid = booking.advancePaidAmount;
            final double refundEst = paid; // 100% refund estimate by policy

            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: ResortTheme.lightBone,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Request Cancellation',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ResortTheme.mossGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reservation ID: ${booking.id}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: ResortTheme.charcoal.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: ResortTheme.lightBone),
                    const SizedBox(height: 16),
                    
                    // Refund Policy info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.red.shade700, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Cancellation & Refund Policy',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cancel before 48 hours of check-in for a full 100% refund of your advance deposit. Inside 48 hours, a 30% retention fee applies.',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.red.shade900.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Refund estimates
                    _refundDetailRow('Deposit Paid:', '₹${_formatIndianCurrency(paid)} INR'),
                    _refundDetailRow('Refund rate eligibility:', '100% Full Refund', isHighlight: true),
                    _refundDetailRow('Estimated refund credit:', '₹${_formatIndianCurrency(refundEst)} INR', isBold: true),
                    
                    const SizedBox(height: 20),
                    Text(
                      'REASON FOR CANCELLATION',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: ResortTheme.charcoal.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _cancelReasonController,
                      maxLines: 3,
                      style: GoogleFonts.inter(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Please share your reason for cancellation...',
                        filled: true,
                        fillColor: ResortTheme.stoneBg.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: ResortTheme.lightBone.withValues(alpha: 0.8)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: ResortTheme.lightBone.withValues(alpha: 0.8)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: ResortTheme.mossGreen),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: ResortTheme.lightBone),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Go Back',
                              style: GoogleFonts.inter(
                                color: ResortTheme.mossGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_cancelReasonController.text.trim().isEmpty) {
                                SnackbarHelper.warning(context, 'Please share a reason for cancellation.');
                                return;
                              }
                              
                              ref.read(bookingsProvider.notifier).cancelBooking(
                                booking.id,
                                _cancelReasonController.text.trim(),
                                100.0, // 100% refund
                              );

                              ref.read(notificationsProvider.notifier).addNotification(
                                'Cancellation Requested',
                                '${booking.guestName} initiated cancellation for stay ID: ${booking.id}.',
                                'booking',
                              );

                              Navigator.pop(context);
                              SnackbarHelper.success(context, 'Cancellation request filed for ${booking.id}.');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC62828),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Request Cancel',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
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
      },
    );
  }

  Widget _refundDetailRow(String label, String value, {bool isHighlight = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: ResortTheme.charcoal.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isBold || isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isHighlight
                  ? ResortTheme.mossGreen
                  : (isBold ? const Color(0xFFC62828) : ResortTheme.charcoal),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(bookingsProvider, (_, __) => _lastError(ref, context, ref.read(bookingsProvider.notifier)));
    final bookings = ref.watch(bookingsProvider);
    final profileAsync = ref.watch(customerProfileProvider);
    final profile = profileAsync.valueOrNull ?? {};
    final email = (profile['email'] as String?) ?? '';

    // Filter bookings matching the logged-in email
    final myBookings = bookings.where((b) {
      return b.guestEmail.toLowerCase().trim() == email.toLowerCase().trim();
    }).toList();

    final upcomingBookings = myBookings
        .where((b) => b.status != BookingStatus.cancelled && b.status != BookingStatus.checkedOut)
        .toList();

    final pastBookings = myBookings
        .where((b) => b.status == BookingStatus.cancelled || b.status == BookingStatus.checkedOut)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFFE6E2D3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Trips',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ResortTheme.mossGreen,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Track active check-ins, upcoming stays, download statements, and cancel reservations.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: ResortTheme.charcoal.withValues(alpha: 0.6),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Tab switchers
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _tabButton('upcoming', Icons.hotel_outlined, 'Upcoming Stays (${upcomingBookings.length})'),
                          _tabButton('past', Icons.history, 'Past History (${pastBookings.length})'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
        
                // Content List
                _activeTab == 'upcoming'
                    ? _buildBookingsList(upcomingBookings, isUpcoming: true)
                    : _buildBookingsList(pastBookings, isUpcoming: false),
              ],
            ),
          ),
          // Render Invoice Modal Overlay
          if (_selectedInvoice != null) _buildInvoiceModal(_selectedInvoice!),
        ],
      ),
    );
  }

  Widget _tabButton(String tab, IconData icon, String label) {
    final isActive = _activeTab == tab;
    return InkWell(
      onTap: () => setState(() => _activeTab = tab),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? ResortTheme.mossGreen : ResortTheme.stoneBg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? Colors.transparent : ResortTheme.lightBone,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : ResortTheme.charcoal.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : ResortTheme.charcoal.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> list, {required bool isUpcoming}) {
    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFE6E2D3)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isUpcoming ? Icons.calendar_today_outlined : Icons.folder_open_outlined,
                size: 40,
                color: ResortTheme.charcoal.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                isUpcoming
                    ? 'No upcoming stays found in your trips.'
                    : 'No past or cancelled stays registered.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ResortTheme.charcoal.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final b = list[index];
        final statusLabel = b.status.name.toUpperCase();
        
        // Match status colors
        Color statusBg = const Color(0xFFFFF8E1);
        Color statusTxt = const Color(0xFFF57F17);
        if (b.status == BookingStatus.confirmed || b.status == BookingStatus.checkedIn) {
          statusBg = const Color(0xFFE8F5E9);
          statusTxt = const Color(0xFF2E7D32);
        } else if (b.status == BookingStatus.cancelled) {
          statusBg = const Color(0xFFFFEBEE);
          statusTxt = const Color(0xFFC62828);
        } else if (b.status == BookingStatus.checkedOut) {
          statusBg = const Color(0xFFE8EAF6);
          statusTxt = const Color(0xFF3F51B5);
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFE6E2D3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: statusTxt,
                      ),
                    ),
                  ),
                  Text(
                    b.id,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: ResortTheme.goldAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Resort Title and Details
              Text(
                'Whispering Valleys Sanctuary', // Standard default resort label
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ResortTheme.mossGreen,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.date_range_outlined, size: 14, color: ResortTheme.mossGreen),
                  const SizedBox(width: 6),
                  Text(
                    '${b.startDate} to ${b.endDate} (${b.nightsCount} Nights)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: ResortTheme.charcoal.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.people_outline, size: 14, color: ResortTheme.mossGreen),
                  const SizedBox(width: 6),
                  Text(
                    '${b.guestsCount} Guest(s) checked in',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: ResortTheme.charcoal.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(color: ResortTheme.lightBone),
              const SizedBox(height: 16),
              
              // Pricing summary
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL AMOUNT PAID',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: ResortTheme.charcoal.withValues(alpha: 0.4),
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${_formatIndianCurrency(b.advancePaidAmount)} INR',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ResortTheme.mossGreen,
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () async {
                            setState(() => _selectedInvoice = b);
                            try {
                              final repo = ref.read(customerRepositoryProvider);
                              final invoices = await repo.fetchInvoices();
                              final match = invoices.cast<Map<String, dynamic>?>().firstWhere(
                                (inv) => inv?['bookingId'] == b.id || inv?['bookingId'] == b.id.replaceAll('BKG-', ''),
                                orElse: () => null,
                              );
                              setState(() => _invoiceData = match);
                            } catch (_) {
                              setState(() => _invoiceData = null);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: ResortTheme.lightBone),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: Text(
                            'View Invoice',
                            style: GoogleFonts.inter(
                              color: ResortTheme.charcoal,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        if (isUpcoming && b.status != BookingStatus.cancelled)
                          ElevatedButton(
                            onPressed: () => _openCancellationSheet(b),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC62828),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            child: Text(
                              'Cancel Stay',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInvoiceModal(Booking booking) {
    final inv = _invoiceData;
    final double subtotal = (inv?['subtotal'] as num?)?.toDouble() ?? booking.baseAmount;
    final double tax = (inv?['taxAmount'] as num?)?.toDouble() ?? booking.taxAmount;
    final double discount = (inv?['discountAmount'] as num?)?.toDouble() ?? booking.discountAmount;
    final double total = (inv?['totalAmount'] as num?)?.toDouble() ?? booking.totalAmount;
    final String invoiceNumber = inv?['invoiceNumber'] as String? ?? booking.id;
    final String invStatus = inv?['status'] as String? ?? '';
    final String dueDate = inv?['dueDate'] as String? ?? '';
    final String paidAt = inv?['paidAt'] as String? ?? '';

    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
            ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VSP Nest Billing Statement',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ResortTheme.mossGreen,
                          ),
                        ),
                        Text(
                          'Invoice #$invoiceNumber • ${booking.id}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: ResortTheme.charcoal.withValues(alpha: 0.5),
                          ),
                        ),
                        if (invStatus.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: invStatus == 'PAID' ? Colors.green.shade50 : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              invStatus,
                              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: invStatus == 'PAID' ? Colors.green.shade800 : Colors.orange.shade800),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _selectedInvoice = null;
                      _invoiceData = null;
                    }),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: ResortTheme.lightBone),
              const SizedBox(height: 12),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _invoiceDetailsRow('Direct client:', booking.guestName),
                      _invoiceDetailsRow('Telephone:', booking.guestPhone),
                      _invoiceDetailsRow('Check-in Period:', '${booking.startDate} to ${booking.endDate} (${booking.nightsCount} Nights)'),
                      if (dueDate.isNotEmpty) _invoiceDetailsRow('Due Date:', dueDate.split('T').first),
                      if (paidAt.isNotEmpty) _invoiceDetailsRow('Paid At:', paidAt.split('T').first),
                      const SizedBox(height: 16),
                      
                      // Breakdown
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ResortTheme.stoneBg.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ResortTheme.lightBone),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'CHARGES DESCRIPTION',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: ResortTheme.charcoal.withValues(alpha: 0.4),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Text(
                                  'AMOUNT',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: ResortTheme.charcoal.withValues(alpha: 0.4),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(color: ResortTheme.lightBone),
                            const SizedBox(height: 10),
                            _invoiceBreakdownItem('Luxury Accommodation Stays (${booking.nightsCount} Nights)', subtotal),
                            if (booking.extraGuestAmount > 0) _invoiceBreakdownItem('Extra Guest Capacity Surcharges', booking.extraGuestAmount),
                            _invoiceBreakdownItem('Sanitization & Cleaning Fees', booking.cleaningAmount),
                            if (discount > 0) _invoiceBreakdownItem('Coupon Applied (${booking.couponApplied ?? 'Promo'})', -discount, isDiscount: true),
                            _invoiceBreakdownItem('Luxury GST (18.00%)', tax),
                            const SizedBox(height: 10),
                            const Divider(color: ResortTheme.lightBone),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Grand Total:',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: ResortTheme.mossGreen,
                                  ),
                                ),
                                Text(
                                  '₹${_formatIndianCurrency(total)} INR',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: ResortTheme.mossGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Payment Summary
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ResortTheme.goldAccent.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Advance Paid Amount:',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: ResortTheme.mossGreen,
                              ),
                            ),
                            Text(
                              '₹${_formatIndianCurrency(booking.advancePaidAmount)} INR',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: ResortTheme.mossGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() {
                        _selectedInvoice = null;
                        _invoiceData = null;
                      }),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: ResortTheme.lightBone),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Close',
                        style: GoogleFonts.inter(
                          color: ResortTheme.charcoal,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        SnackbarHelper.info(context, 'Direct printing initialized.');
                      },
                      icon: const Icon(Icons.print, size: 14, color: Colors.white),
                      label: Text(
                        'Print Statement',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ResortTheme.mossGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _invoiceDetailsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: ResortTheme.charcoal.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: ResortTheme.charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _invoiceBreakdownItem(String label, double value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isDiscount ? ResortTheme.mossGreen : ResortTheme.charcoal.withValues(alpha: 0.8),
                fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            isDiscount
                ? '-₹${_formatIndianCurrency(value.abs())}'
                : '₹${_formatIndianCurrency(value)}',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isDiscount ? ResortTheme.mossGreen : ResortTheme.charcoal.withValues(alpha: 0.8),
              fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
