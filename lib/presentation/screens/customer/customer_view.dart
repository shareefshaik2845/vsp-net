import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities.dart';
import '../../providers/state_provider.dart';
import '../../../core/theme.dart';
import '../../../core/snackbar_helper.dart';

class CustomerView extends ConsumerStatefulWidget {
  const CustomerView({super.key});

  @override
  ConsumerState<CustomerView> createState() => _CustomerViewState();
}

class _CustomerViewState extends ConsumerState<CustomerView> {
  PropertyDetails _selectedResort = PropertyDetails(
      id: '',
      name: '',
      tagline: '',
      description: '',
      location: '',
      basePriceWeekday: 0,
      basePriceWeekend: 0,
      extraGuestCharge: 0,
      cleaningFee: 0,
      state: '',
      city: '',
      image: '',
      gallery: [],
      amenities: [],
      rules: []);
  Map<String, dynamic>? _propertyDetail;
  bool _isLoadingDetail = false;
  String _searchQuery = '';
  String _selectedState = 'All Indian States';
  String _selectedCity = 'All Cities';
  String _selectedCategory = 'All';
  bool _showDetails = false;
  final ScrollController _scrollController = ScrollController();

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }
  }

  List<PropertyDetails> _getFilteredResorts(List<PropertyDetails> resorts) {
    return resorts.where((resort) {
      final matchesSearch = _searchQuery.isEmpty ||
          resort.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          resort.tagline.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          resort.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          resort.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          resort.state.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesState = _selectedState == 'All Indian States' ||
          resort.state.toLowerCase() == _selectedState.toLowerCase();

      final matchesCity = _selectedCity == 'All Cities' ||
          resort.city.toLowerCase() == _selectedCity.toLowerCase();

      bool matchesCategory = true;
      if (_selectedCategory == 'Beach') {
        matchesCategory = resort.location.toLowerCase().contains('goa') ||
            resort.location.toLowerCase().contains('beach') ||
            resort.tagline.toLowerCase().contains('ocean');
      } else if (_selectedCategory == 'Mountain') {
        matchesCategory = resort.location.toLowerCase().contains('hill') ||
            resort.location.toLowerCase().contains('mountain') ||
            resort.tagline.toLowerCase().contains('mountain');
      } else if (_selectedCategory == 'Luxury') {
        matchesCategory = resort.basePriceWeekday >= 15000;
      }

      return matchesSearch && matchesState && matchesCity && matchesCategory;
    }).toList();
  }

  Future<void> _loadPropertyDetail(String id) async {
    setState(() => _isLoadingDetail = true);
    try {
      final repo = ref.read(customerRepositoryProvider);
      final detail = await repo.fetchPropertyDetail(id);
      if (mounted) setState(() => _propertyDetail = detail);
    } catch (_) {
      if (mounted) setState(() => _propertyDetail = null);
    } finally {
      if (mounted) setState(() => _isLoadingDetail = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final activeProp = ref.read(propertyProvider).valueOrNull;
        if (activeProp != null) {
          setState(() {
            _selectedResort = activeProp;
          });
          _loadPropertyDetail(activeProp.id);
        }
        final profileAsync = ref.read(customerProfileProvider);
        final profile = profileAsync.valueOrNull ?? {};
        _nameController.text = profile['name'] ?? '';
        _emailController.text = profile['email'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
      }
    });
    final resorts = ref.read(resortsListProvider);
    if (resorts.isNotEmpty) {
      _selectedResort = resorts.first;
    }
  }

  // State variables for form
  late String _selectedStartDate =
      DateTime.now().toIso8601String().split('T').first;
  late String _selectedEndDate = DateTime.now()
      .add(const Duration(days: 2))
      .toIso8601String()
      .split('T')
      .first;
  int _guestsCount = 2;
  String _couponCode = '';
  String _couponError = '';
  String _couponSuccess = '';
  double _couponDiscount = 0.0;

  // Guest Checkout Form
  String _checkoutStep = 'details'; // details, payment, confirmed
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hkNotesController = TextEditingController();

  Booking? _createdBooking;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _hkNotesController.dispose();
    _scrollController.dispose();
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

  QuoteDetails _calculateQuote(
      PropertyDetails property, List<PricingSeasonRule> rules,
      {int taxRate = 18, int depositRate = 30}) {
    DateTime start;
    DateTime end;
    try {
      start = DateTime.parse(_selectedStartDate);
      end = DateTime.parse(_selectedEndDate);
    } catch (e) {
      return const QuoteDetails(
          nightsCount: 0,
          weekdayNights: 0,
          weekendNights: 0,
          baseAmount: 0,
          extraGuestAmount: 0,
          cleaningAmount: 0,
          discountAmount: 0,
          taxAmount: 0,
          totalAmount: 0,
          requiredAdvance: 0);
    }
    int nights = end.difference(start).inDays;

    if (nights <= 0) {
      return const QuoteDetails(
          nightsCount: 0,
          weekdayNights: 0,
          weekendNights: 0,
          baseAmount: 0,
          extraGuestAmount: 0,
          cleaningAmount: 0,
          discountAmount: 0,
          taxAmount: 0,
          totalAmount: 0,
          requiredAdvance: 0);
    }

    int weekdayNights = 0;
    int weekendNights = 0;
    double baseAccAmount = 0.0;

    double multiplier = 1.0;
    String? ruleName;

    if (start.month == 6 && start.day >= 15) {
      final monsoon = rules.firstWhere((r) => r.id == 'PR-RULE-1',
          orElse: () => const PricingSeasonRule(
              id: '',
              name: '',
              startDate: '',
              endDate: '',
              weekdayPrice: 0,
              weekendPrice: 0,
              multiplier: 1.0,
              isActive: false));
      if (monsoon.isActive) {
        multiplier = monsoon.multiplier;
        ruleName = monsoon.name;
      }
    }

    for (int i = 0; i < nights; i++) {
      DateTime current = start.add(Duration(days: i));
      if (current.weekday == DateTime.friday ||
          current.weekday == DateTime.saturday) {
        weekendNights++;
        baseAccAmount += property.basePriceWeekend * multiplier;
      } else {
        weekdayNights++;
        baseAccAmount += property.basePriceWeekday * multiplier;
      }
    }

    double extraGuests = _guestsCount > 2
        ? (_guestsCount - 2) * property.extraGuestCharge * nights
        : 0.0;
    double cleaning = property.cleaningFee;

    double disc = _couponDiscount;

    double taxableAmount = (baseAccAmount + extraGuests + cleaning) - disc;
    double tax = taxableAmount * (taxRate / 100.0);
    double total = taxableAmount + tax;

    return QuoteDetails(
      nightsCount: nights,
      weekdayNights: weekdayNights,
      weekendNights: weekendNights,
      baseAmount: baseAccAmount,
      extraGuestAmount: extraGuests,
      cleaningAmount: cleaning,
      discountAmount: disc,
      taxAmount: tax,
      totalAmount: total,
      requiredAdvance: total * (depositRate / 100.0),
      seasonApplied: ruleName,
    );
  }

  Future<void> _applyPromo(QuoteDetails quote) async {
    if (_couponCode.isEmpty) {
      setState(() {
        _couponError = 'Please key in a coupon code first.';
        _couponSuccess = '';
        _couponDiscount = 0.0;
      });
      return;
    }
    try {
      final repo = ref.read(customerRepositoryProvider);
      final result = await repo.validateCoupon(
        _couponCode,
        quote.baseAmount + quote.extraGuestAmount,
        _selectedResort.id,
      );
      final isValid = result['isValid'] as bool? ?? false;
      if (!mounted) return;
      if (isValid) {
        final discount = (result['discountAmount'] as num?)?.toDouble() ?? 0;
        setState(() {
          _couponDiscount = discount;
          _couponSuccess =
              result['description'] as String? ?? 'Coupon applied!';
          _couponError = '';
        });
      } else {
        setState(() {
          _couponDiscount = 0.0;
          _couponError = result['error'] as String? ?? 'Invalid coupon code.';
          _couponSuccess = '';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _couponDiscount = 0.0;
        _couponError = 'Failed to validate coupon. Please try again.';
        _couponSuccess = '';
      });
    }
  }

  void _handleInitiatePayment(QuoteDetails quote) {
    setState(() {
      if (_nameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _phoneController.text.isEmpty) {
        SnackbarHelper.warning(
            context, 'Please complete all contact details fields.');
        return;
      }
      if (quote.nightsCount <= 0) {
        SnackbarHelper.warning(context, 'Date selection is unavailable.');
        return;
      }
      _checkoutStep = 'payment';
    });
  }

  Future<void> _handleCompletePayment(QuoteDetails quote) async {
    final localId = 'BKG-${DateTime.now().millisecondsSinceEpoch}';
    final freshBooking = Booking(
      id: localId,
      resortName: _selectedResort.name,
      guestName: _nameController.text,
      guestEmail: _emailController.text,
      guestPhone: _phoneController.text,
      startDate: _selectedStartDate,
      endDate: _selectedEndDate,
      guestsCount: _guestsCount,
      nightsCount: quote.nightsCount,
      source: BookingSource.direct,
      status: BookingStatus.pendingPayment,
      paymentStatus: PaymentStatus.pending,
      baseAmount: quote.baseAmount,
      extraGuestAmount: quote.extraGuestAmount,
      cleaningAmount: quote.cleaningAmount,
      discountAmount: quote.discountAmount,
      taxAmount: quote.taxAmount,
      totalAmount: quote.totalAmount,
      advancePaidAmount: 0,
      balanceAmount: quote.totalAmount,
      couponApplied:
          _couponSuccess.isNotEmpty ? _couponCode.toUpperCase() : null,
      createdAt: DateTime.now().toIso8601String(),
      housekeepingNotes: _hkNotesController.text,
      propertyId: _selectedResort.id,
    );

    try {
      final result =
          await ref.read(bookingsProvider.notifier).addBooking(freshBooking);
      final realId = (result['id'] ?? localId).toString();

      await ref.read(customerRepositoryProvider).initiatePayment({
        'bookingId': realId,
        'paymentMethod': 'credit_card',
      });

      await ref.read(notificationsProvider.notifier).addNotification(
            'New Direct Booking: $realId',
            '${_nameController.text} confirmed a luxury stay for ${quote.nightsCount} nights.',
            'booking',
          );

      setState(() {
        _createdBooking = freshBooking.copyWith(
          id: realId,
          status: BookingStatus.confirmed,
          paymentStatus: PaymentStatus.paid,
          advancePaidAmount: quote.totalAmount,
          balanceAmount: 0,
        );
        _checkoutStep = 'confirmed';
      });
    } catch (e) {
      if (mounted) {
        SnackbarHelper.error(context, 'Payment failed: $e');
      }
    }
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final notifs = ref.watch(customerNotificationsProvider);
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Notifications',
                          style: AppTextStyles.titleMd
                              .copyWith(color: AppColors.mossGreen)),
                      IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close)),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: notifs.isEmpty
                        ? const Center(
                            child: Text('No notifications yet.',
                                style: TextStyle(color: Colors.grey)))
                        : ListView.separated(
                            itemCount: notifs.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final n = notifs[i];
                              return ListTile(
                                leading: Icon(
                                  n.type == 'booking'
                                      ? Icons.shopping_bag
                                      : n.type == 'payment'
                                          ? Icons.payment
                                          : Icons.info_outline,
                                  size: 20,
                                  color: n.read
                                      ? Colors.grey
                                      : AppColors.mossGreen,
                                ),
                                title: Text(n.title,
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: n.read
                                            ? FontWeight.normal
                                            : FontWeight.bold)),
                                subtitle: Text(n.message,
                                    style: GoogleFonts.inter(
                                        fontSize: 11, color: Colors.grey)),
                                trailing: Text(_formatNotifTime(n.timestamp),
                                    style: GoogleFonts.inter(
                                        fontSize: 9, color: Colors.grey)),
                                onTap: () {
                                  if (!n.read) {
                                    ref
                                        .read(customerNotificationsProvider
                                            .notifier)
                                        .markAsRead(n.id);
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatNotifTime(String ts) {
    try {
      final dt = DateTime.parse(ts);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      return '${diff.inDays}d';
    } catch (_) {
      return ts;
    }
  }

  Widget _buildExplorerHeader(List<PropertyDetails> allResorts) {
    final states = [
      'All Indian States',
      ...allResorts.map((r) => r.state).toSet()
    ];
    final citiesForState = _selectedState == 'All Indian States'
        ? allResorts.map((r) => r.city).toSet()
        : allResorts
            .where((r) => r.state.toLowerCase() == _selectedState.toLowerCase())
            .map((r) => r.city)
            .toSet();
    final cities = ['All Cities', ...citiesForState];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stack to overlay the search console on the hero banner
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 35),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: AppColors.mossGreen.withValues(alpha: 0.5),
              ),
              child: Stack(
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1200&q=80',
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                        const SizedBox.shrink(),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.mossGreen.withValues(alpha: 0.95),
                          AppColors.mossGreen.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                    ),
                    padding: const EdgeInsets.only(
                        left: 40, right: 40, top: 48, bottom: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Notification Bell
                        Align(
                          alignment: Alignment.topRight,
                          child: Consumer(
                            builder: (context, ref, _) {
                              final notifs =
                                  ref.watch(customerNotificationsProvider);
                              final unread =
                                  notifs.where((n) => !n.read).length;
                              return Stack(
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        _showNotifications(context),
                                    icon: const Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.white,
                                        size: 24),
                                  ),
                                  if (unread > 0)
                                    Positioned(
                                      right: 6,
                                      top: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '$unread',
                                          style: GoogleFonts.inter(
                                              fontSize: 8,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.goldAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.goldAccent
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '✧ PRIVATE RESERVES & SANCTUARIES ✧',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: AppColors.goldAccent,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Find your next sanctuary',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Explore a curated collection of ultra-premium estates across elite destinations.',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Floating Console positioned at the bottom center
            Positioned(
              bottom: 0,
              left: 24,
              right: 24,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.xxlBr,
                  border: Border.all(color: AppColors.lightBone, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: LayoutBuilder(
                  builder: (context, boxConstraints) {
                    final isNarrow = boxConstraints.maxWidth < 750;
                    if (isNarrow) {
                      return Column(
                        children: [
                          _buildSearchInputField(),
                          const Divider(color: AppColors.lightBone, height: 16),
                          _buildStateDropdown(states),
                          const Divider(color: AppColors.lightBone, height: 16),
                          _buildCityDropdown(cities),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: _buildSearchInputField(),
                        ),
                        Container(
                          height: 32,
                          width: 1,
                          color: AppColors.lightBone,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        Expanded(
                          flex: 3,
                          child: _buildStateDropdown(states),
                        ),
                        Container(
                          height: 32,
                          width: 1,
                          color: AppColors.lightBone,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        Expanded(
                          flex: 3,
                          child: _buildCityDropdown(cities),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildCategorySelector(),
      ],
    );
  }

  Widget _buildSearchInputField() {
    return TextField(
      onChanged: (v) => setState(() => _searchQuery = v),
      decoration: InputDecoration(
        hintText: 'Search sanctuaries...',
        hintStyle: GoogleFonts.inter(
            fontSize: 14, color: AppColors.charcoal.withValues(alpha: 0.4)),
        prefixIcon:
            const Icon(Icons.search, color: AppColors.mossGreen, size: 20),
        filled: true,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.charcoal),
    );
  }

  Widget _buildStateDropdown(List<String> states) {
    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField<String>(
        initialValue: _selectedState,
        decoration: InputDecoration(
          labelText: 'STATE',
          labelStyle: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: AppColors.mossGreen.withValues(alpha: 0.6),
          ),
          prefixIcon: const Icon(Icons.map_outlined,
              color: AppColors.goldAccent, size: 18),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        icon: const Icon(Icons.keyboard_arrow_down,
            color: AppColors.mossGreen, size: 18),
        style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.charcoal,
            fontWeight: FontWeight.w600),
        items: states.map((state) {
          return DropdownMenuItem<String>(
            value: state,
            child: Text(state),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) {
            setState(() {
              _selectedState = val;
              _selectedCity = 'All Cities';
            });
          }
        },
      ),
    );
  }

  Widget _buildCityDropdown(List<String> cities) {
    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField<String>(
        initialValue: _selectedCity,
        decoration: InputDecoration(
          labelText: 'CITY',
          labelStyle: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: AppColors.mossGreen.withValues(alpha: 0.6),
          ),
          prefixIcon: const Icon(Icons.location_city_outlined,
              color: AppColors.goldAccent, size: 18),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        icon: const Icon(Icons.keyboard_arrow_down,
            color: AppColors.mossGreen, size: 18),
        style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.charcoal,
            fontWeight: FontWeight.w600),
        items: cities.map((city) {
          return DropdownMenuItem<String>(
            value: city,
            child: Text(city),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) {
            setState(() {
              _selectedCity = val;
            });
          }
        },
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = ['All', 'Beach', 'Mountain', 'Luxury'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            'EXPLORE BY CATEGORY',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppColors.mossGreen.withValues(alpha: 0.6),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.mossGreen : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.mossGreen
                            : AppColors.lightBone,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.mossGreen.withValues(alpha: 0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          const Icon(Icons.star,
                              color: AppColors.goldAccent, size: 14),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          cat.toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color:
                                isSelected ? Colors.white : AppColors.charcoal,
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
  }

  IconData _getAmenityIcon(String iconName) {
    switch (iconName) {
      case 'Waves':
        return Icons.pool;
      case 'Mountain':
        return Icons.filter_hdr;
      case 'ChefHat':
        return Icons.restaurant_menu;
      case 'Wifi':
        return Icons.wifi;
      case 'Flame':
        return Icons.local_fire_department;
      case 'Tv':
        return Icons.tv;
      case 'Flower2':
        return Icons.spa;
      case 'TreePine':
        return Icons.forest;
      case 'Compass':
        return Icons.explore;
      default:
        return Icons.star;
    }
  }

  Widget _buildResortCardsList() {
    final allResorts = ref.watch(resortsListProvider);
    final resorts = _getFilteredResorts(allResorts);
    if (resorts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.lightBone),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off,
                  size: 48, color: AppColors.goldAccent),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No sanctuaries match your criteria.',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  color: AppColors.mossGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Try adjusting your search queries or category filters.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.charcoal.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: resorts.map((resort) {
        final isSelected = _selectedResort.name == resort.name;

        return Container(
          margin: const EdgeInsets.only(bottom: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.xxlBr,
            border: Border.all(color: AppColors.lightBone, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AppRadius.xxlBr,
            child: InkWell(
              onTap: () {
                _scrollToTop();
                ref.read(propertyProvider.notifier).updateProperty(resort);
                setState(() {
                  _selectedResort = resort;
                  _showDetails = true;
                  _checkoutStep = 'details';
                });
                _loadPropertyDetail(resort.id);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.network(
                        resort.image,
                        height: 280,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          height: 280,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.5),
                                Colors.transparent
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        left: 20,
                        right: 76,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                      color: AppColors.goldAccent
                                          .withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star,
                                        color: AppColors.goldAccent, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      resort.basePriceWeekday >= 15000
                                          ? 'ELITE RESERVE'
                                          : 'EXECUTIVE RETREAT',
                                      style: GoogleFonts.spaceGrotesk(
                                        color: AppColors.mossGreen,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.mossGreen.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                '${resort.city}, ${resort.state}',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 14,
                        right: 20,
                        child: Consumer(
                          builder: (context, ref, child) {
                            final isSaved = ref
                                .watch(savedPropertiesProvider)
                                .any((p) => p.name == resort.name);
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  isSaved
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isSaved
                                      ? Colors.red.shade600
                                      : AppColors.mossGreen,
                                  size: 20,
                                ),
                                onPressed: () {
                                  ref
                                      .read(savedPropertiesProvider.notifier)
                                      .toggleSave(resort);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.goldAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'CURRENT SELECTION',
                              style: GoogleFonts.spaceGrotesk(
                                color: AppColors.mossGreen,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resort.location.toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: AppColors.goldAccent,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          resort.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mossGreen,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          resort.tagline,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.charcoal.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: resort.amenities.take(3).map((am) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.stoneBg.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.lightBone
                                        .withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_getAmenityIcon(am.icon),
                                      size: 12, color: AppColors.goldAccent),
                                  const SizedBox(width: 6),
                                  Text(
                                    am.label,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.charcoal
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: AppColors.lightBone),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'EXPERIENCE STARTS AT',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                    color: AppColors.charcoal
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '₹${resort.basePriceWeekday.toStringAsFixed(0)}',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.mossGreen,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '/ night (weekday)',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.charcoal
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _scrollToTop();
                                ref
                                    .read(propertyProvider.notifier)
                                    .updateProperty(resort);
                                setState(() {
                                  _selectedResort = resort;
                                  _showDetails = true;
                                  _checkoutStep = 'details';
                                });
                                _loadPropertyDetail(resort.id);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mossGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'VIEW SANCTUARY',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_ios,
                                      size: 12, color: AppColors.goldAccent),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConciergeSection() {
    return Consumer(
      builder: (context, ref, _) {
        final conciergeAsync = ref.watch(customerConciergeProvider);
        final requests = conciergeAsync.valueOrNull ?? [];
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFE6E2D3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.room_service,
                          color: AppColors.goldAccent, size: 20),
                      const SizedBox(width: 10),
                      Text('Concierge Services',
                          style: AppTextStyles.titleLg
                              .copyWith(color: AppColors.mossGreen)),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => _showConciergeForm(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text('New Request',
                        style: GoogleFonts.inter(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (requests.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.stoneBg.withValues(alpha: 0.3),
                    borderRadius: AppRadius.lgBr,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.spa_outlined,
                          color: AppColors.goldAccent, size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'No concierge requests yet. Tap "New Request" to arrange airport transfers, spa bookings, or special experiences.',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.charcoal.withValues(alpha: 0.6)),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...requests.take(3).map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.stoneBg.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r['requestType'] as String? ?? '',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: AppColors.charcoal),
                                  ),
                                  Text(
                                    r['description'] as String? ?? '',
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppColors.charcoal
                                            .withValues(alpha: 0.6)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (r['status'] as String? ?? '') ==
                                        'COMPLETED'
                                    ? Colors.green.shade50
                                    : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                r['status'] as String? ?? 'PENDING',
                                style: GoogleFonts.inter(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: (r['status'] as String? ?? '') ==
                                            'COMPLETED'
                                        ? Colors.green.shade800
                                        : Colors.orange.shade800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              if (requests.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${requests.length - 3} more requests',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showConciergeForm(BuildContext context) {
    final descController = TextEditingController();
    String selectedType = 'TRANSPORT';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: Text('New Concierge Request',
                  style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.bold, color: AppColors.mossGreen)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration:
                        const InputDecoration(labelText: 'Request Type'),
                    items: ['TRANSPORT', 'SPA', 'DINING', 'EXPERIENCE', 'OTHER']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => selectedType = v);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe your request...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      descController.dispose();
                      Navigator.pop(ctx);
                    },
                    child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (descController.text.trim().isEmpty) return;
                    await ref
                        .read(customerConciergeProvider.notifier)
                        .createRequest(
                            selectedType, descController.text.trim());
                    if (ctx.mounted) Navigator.pop(ctx);
                    descController.dispose();
                    SnackbarHelper.success(
                        context, 'Concierge request submitted!');
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mossGreen),
                  child: const Text('Submit',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDetailHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6E2D3)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Circular Back Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _scrollToTop();
                setState(() {
                  _showDetails = false;
                });
              },
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.stoneBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 14, color: AppColors.mossGreen),
              ),
            ),
          ),

          // Resort Name (Title)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _selectedResort.name,
                style:
                    AppTextStyles.titleSm.copyWith(color: AppColors.mossGreen),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Right Side Actions (City Tag)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.stoneBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _selectedResort.city,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.mossGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
        customerBookingsProvider,
        (_, __) => _lastError(
            ref, context, ref.read(customerBookingsProvider.notifier)));
    ref.listen(
        customerPropertiesProvider,
        (_, __) => _lastError(
            ref, context, ref.read(customerPropertiesProvider.notifier)));
    ref.listen(
        customerCouponsProvider,
        (_, __) => _lastError(
            ref, context, ref.read(customerCouponsProvider.notifier)));
    ref.listen(
        customerFavoritesProvider,
        (_, __) => _lastError(
            ref, context, ref.read(customerFavoritesProvider.notifier)));
    ref.listen(
        customerProfileProvider,
        (_, __) => _lastError(
            ref, context, ref.read(customerProfileProvider.notifier)));
    ref.listen(
        customerPricingProvider,
        (_, __) => _lastError(
            ref, context, ref.read(customerPricingProvider.notifier)));
    ref.listen(
        customerStatsProvider,
        (_, __) =>
            _lastError(ref, context, ref.read(customerStatsProvider.notifier)));
    ref.listen(
        customerNotificationsProvider,
        (_, __) => _lastError(
            ref, context, ref.read(customerNotificationsProvider.notifier)));
    ref.listen(
        customerInvoicesProvider,
        (_, __) => _lastError(
            ref, context, ref.read(customerInvoicesProvider.notifier)));
    ref.listen(
        customerConciergeProvider,
        (_, __) => _lastError(
            ref, context, ref.read(customerConciergeProvider.notifier)));
    final propertyAsync = ref.watch(propertyProvider);
    final rules = ref.watch(pricingRulesProvider);
    final allResorts = ref.watch(resortsListProvider);
    final taxRate = ref.watch(taxRateProvider);
    final depositRate = ref.watch(depositRateProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: propertyAsync.when(
        data: (property) {
          final quote = _calculateQuote(_selectedResort, rules,
              taxRate: taxRate, depositRate: depositRate);
          if (_showDetails) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0),
                  child: _buildDetailHeader(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                        left: 24.0, right: 24.0, bottom: 24.0),
                    child: _buildContent(_selectedResort, quote),
                  ),
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              key: const ValueKey('explorer_scroll'),
              controller: _scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExplorerHeader(allResorts),
                  const SizedBox(height: 24),
                  _buildResortCardsList(),
                  const SizedBox(height: 24),
                  _buildConciergeSection(),
                ],
              ),
            );
          }
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.mossGreen)),
        error: (err, stack) =>
            Center(child: Text('Sandbox initialisation failure: $err')),
      ),
    );
  }

  Widget _buildContent(PropertyDetails property, QuoteDetails quote) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: _buildResortShowcase(property)),
              const SizedBox(width: 32),
              Expanded(flex: 5, child: _buildCheckoutFlow(property, quote)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildResortShowcase(property),
              const SizedBox(height: 32),
              _buildCheckoutFlow(property, quote),
            ],
          );
        }
      },
    );
  }

  Widget _buildResortShowcase(PropertyDetails property) {
    final images = property.gallery;
    final heroImageUrl = images.isNotEmpty ? images[0] : property.image;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Image
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.lightBone),
                image: DecorationImage(
                    image: NetworkImage(heroImageUrl), fit: BoxFit.cover),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.black.withValues(alpha: 0.2),
                      Colors.transparent
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.mossGreen.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.goldAccent.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'FEATURED SANCTUARY',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: AppColors.goldAccent),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      property.name,
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: AppColors.goldAccent, size: 18),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.location,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Consumer(
                builder: (context, ref, child) {
                  final isSaved = ref
                      .watch(savedPropertiesProvider)
                      .any((p) => p.name == property.name);
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color:
                            isSaved ? Colors.red.shade600 : AppColors.mossGreen,
                        size: 20,
                      ),
                      onPressed: () {
                        ref
                            .read(savedPropertiesProvider.notifier)
                            .toggleSave(property);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        // Gallery row
        if (images.isNotEmpty)
          Row(
            children: [
              for (final url in images.take(3))
                Expanded(
                  child: Container(
                    height: 100,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.lgBr,
                      border: Border.all(
                          color: AppColors.lightBone.withValues(alpha: 0.4)),
                      image: DecorationImage(
                          image: NetworkImage(url), fit: BoxFit.cover),
                    ),
                  ),
                ),
            ],
          )
        else
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: AppRadius.lgBr,
              border:
                  Border.all(color: AppColors.lightBone.withValues(alpha: 0.4)),
              image: DecorationImage(
                  image: NetworkImage(property.image), fit: BoxFit.cover),
            ),
          ),
        const SizedBox(height: 24),
        // Details Box
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFE6E2D3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property.tagline,
                style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mossGreen,
                    height: 1.3),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                property.description,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.charcoal.withValues(alpha: 0.8),
                    height: 1.6),
              ),
              const SizedBox(height: 24),
              // Pricing Grid
              const Divider(color: Color(0xFFE6E2D3)),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, gridConstraints) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _priceBox(
                          'STANDARD WEEKDAY',
                          '₹${property.basePriceWeekday.toStringAsFixed(0)}',
                          '/ night'),
                      _priceBox(
                          'STANDARD WEEKEND',
                          '₹${property.basePriceWeekend.toStringAsFixed(0)}',
                          '/ night'),
                      _priceBox(
                          'EXTRA GUESTS CAPACITY',
                          '₹${property.extraGuestCharge.toStringAsFixed(0)}',
                          'per head / night',
                          isWide: true),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              // Amenities
              Text('ELITE AMENITIES INCLUDED:',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mossGreen)),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: property.amenities
                    .map((am) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppRadius.lgBr,
                            border: Border.all(
                                color:
                                    AppColors.lightBone.withValues(alpha: 0.6)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('✦',
                                  style: TextStyle(
                                      color: AppColors.goldAccent,
                                      fontSize: 14)),
                              const SizedBox(width: 8),
                              Text(am.label,
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.charcoal)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              if (_isLoadingDetail)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.mossGreen)),
                ),
              // Rules
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.mossGreen,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROPERTY & CONSERVATION RULES:',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldAccent,
                            letterSpacing: 1)),
                    const SizedBox(height: AppSpacing.lg),
                    ...property.rules.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ',
                                  style: TextStyle(
                                      color: AppColors.stoneBg, fontSize: 16)),
                              Expanded(
                                  child: Text(r,
                                      style: GoogleFonts.inter(
                                          color: AppColors.stoneBg
                                              .withValues(alpha: 0.95),
                                          fontSize: 13,
                                          height: 1.5))),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              if (_propertyDetail != null) ...[
                const SizedBox(height: 24),
                _buildDetailInfoRow(_propertyDetail!),
                if ((_propertyDetail!['reviews'] as List<dynamic>?)
                        ?.isNotEmpty ==
                    true) ...[
                  const SizedBox(height: 24),
                  _buildReviewsSection(
                      _propertyDetail!['reviews'] as List<dynamic>),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailInfoRow(Map<String, dynamic> detail) {
    final bedrooms = detail['bedrooms'] as int?;
    final bathrooms = detail['bathrooms'] as int?;
    final checkIn = detail['checkInTime'] as String?;
    final checkOut = detail['checkOutTime'] as String?;
    final houseRules = _normalizeHouseRules(detail['houseRules']);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE6E2D3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DETAILS & POLICIES',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mossGreen,
                  letterSpacing: 1)),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              if (bedrooms != null)
                _statChip(Icons.bed_outlined,
                    '$bedrooms Bedroom${bedrooms > 1 ? 's' : ''}'),
              if (bathrooms != null)
                _statChip(Icons.bathtub_outlined,
                    '$bathrooms Bathroom${bathrooms > 1 ? 's' : ''}'),
              if (checkIn != null) _statChip(Icons.login, 'Check-in: $checkIn'),
              if (checkOut != null)
                _statChip(Icons.logout, 'Check-out: $checkOut'),
            ],
          ),
          if (houseRules.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(color: Color(0xFFE6E2D3)),
            const SizedBox(height: AppSpacing.lg),
            Text('HOUSE RULES:',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mossGreen)),
            const SizedBox(height: AppSpacing.md),
            ...houseRules.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(
                              color: AppColors.goldAccent, fontSize: 14)),
                      Expanded(
                          child: Text('$r',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.charcoal
                                      .withValues(alpha: 0.8)))),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  List<String> _normalizeHouseRules(dynamic rawRules) {
    if (rawRules == null) return [];
    if (rawRules is Iterable) {
      return rawRules
          .whereType<String>()
          .map((rule) => rule.trim())
          .where((rule) => rule.isNotEmpty)
          .toList();
    }
    if (rawRules is String) {
      return rawRules
          .split(RegExp(r'\r?\n'))
          .map((rule) => rule.trim())
          .where((rule) => rule.isNotEmpty)
          .toList();
    }
    return [];
  }

  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.stoneBg.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBone.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.mossGreen),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal)),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(List<dynamic> reviews) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE6E2D3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('GUEST REVIEWS',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mossGreen,
                      letterSpacing: 1)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.mossGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${reviews.length} reviews',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...reviews.take(5).map((r) {
            final review = r as Map<String, dynamic>;
            final authorRaw = review['author'];
            final author = authorRaw != null ? authorRaw.toString().trim() : '';
            final authorInitial =
                author.isNotEmpty ? author[0].toUpperCase() : 'G';
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.stoneBg,
                    child: Text(
                      authorInitial,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mossGreen),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(review['author'] as String? ?? '',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.charcoal)),
                            if (review['rating'] != null)
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 14, color: AppColors.goldAccent),
                                  const SizedBox(width: 4),
                                  Text('${review['rating']}',
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.charcoal)),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(review['comment'] as String? ?? '',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color:
                                    AppColors.charcoal.withValues(alpha: 0.7),
                                height: 1.4)),
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

  Widget _priceBox(String label, String value, String suffix,
      {bool isWide = false}) {
    return Container(
      width: isWide ? double.infinity : 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBone.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A4A35).withValues(alpha: 0.6))),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4A3F2D))),
              const SizedBox(width: 4),
              Text(suffix,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF4A4A35).withValues(alpha: 0.6))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutFlow(PropertyDetails property, QuoteDetails quote) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE6E2D3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Book Property',
                  style: AppTextStyles.titleLg
                      .copyWith(color: AppColors.mossGreen)),
              Row(
                children: [
                  _stepDot(_checkoutStep == 'details'),
                  const SizedBox(width: 6),
                  _stepDot(_checkoutStep == 'payment'),
                  const SizedBox(width: 6),
                  _stepDot(_checkoutStep == 'confirmed', isGold: true),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: Color(0xFFE6E2D3)),
          const SizedBox(height: AppSpacing.lg),
          if (_checkoutStep == 'details') _buildStepDetails(quote),
          if (_checkoutStep == 'payment') _buildStepPayment(quote),
          if (_checkoutStep == 'confirmed') _buildStepConfirmed(quote),
        ],
      ),
    );
  }

  Widget _stepDot(bool active, {bool isGold = false}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? (isGold ? AppColors.goldAccent : AppColors.mossGreen)
            : AppColors.lightBone,
        borderRadius: BorderRadius.circular(4),
        border: active
            ? Border.all(
                color: (isGold ? AppColors.goldAccent : AppColors.mossGreen)
                    .withValues(alpha: 0.25),
                width: 2)
            : null,
      ),
    );
  }

  Widget _buildStepDetails(QuoteDetails quote) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: _dateInput('CHECK-IN NIGHT', _selectedStartDate,
                    (v) => setState(() => _selectedStartDate = v))),
            const SizedBox(width: 12),
            Expanded(
                child: _dateInput('CHECK-OUT DAY', _selectedEndDate,
                    (v) => setState(() => _selectedEndDate = v))),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: AppSpacing.allLg,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppColors.lightBone.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Occupancy Limit',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4A4A35))),
                  Text('Guests exceeding 2 are\ncharged extra',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.charcoal.withValues(alpha: 0.65))),
                ],
              ),
              Row(
                children: [
                  _counterBtn(
                      Icons.remove,
                      () => setState(() => _guestsCount =
                          _guestsCount > 1 ? _guestsCount - 1 : 1)),
                  SizedBox(
                      width: 32,
                      child: Center(
                          child: Text('$_guestsCount',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.charcoal)))),
                  _counterBtn(
                      Icons.add,
                      () => setState(() => _guestsCount =
                          _guestsCount < 8 ? _guestsCount + 1 : 8)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (quote.nightsCount > 0) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5F0),
              borderRadius: AppRadius.xxlBr,
              border: Border.all(color: AppColors.lightBone),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Stay\nDuration:',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.charcoal.withValues(alpha: 0.7))),
                    Text(
                        '${quote.nightsCount} Nights (${quote.weekdayNights} Wkdy, ${quote.weekendNights}\nWknd)',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mossGreen),
                        textAlign: TextAlign.right),
                  ],
                ),
                if (quote.seasonApplied != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Seasonal\nMultiplier:',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mossGreen)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4B483).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFFD4B483)
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Text(quote.seasonApplied!,
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.goldAccent)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                const Divider(color: Color(0xFFE6E2D3)),
                const SizedBox(height: AppSpacing.lg),
                _calcRow('Base accommodation:',
                    '₹${quote.baseAmount.toStringAsFixed(0)}'),
                if (quote.extraGuestAmount > 0)
                  _calcRow('Extra Guest Surcharge:',
                      '₹${quote.extraGuestAmount.toStringAsFixed(0)}'),
                _calcRow('Sanitization & Cleaning:',
                    '₹${quote.cleaningAmount.toStringAsFixed(0)}'),
                if (quote.discountAmount > 0)
                  _calcRow('Promo Discount:',
                      '-₹${quote.discountAmount.toStringAsFixed(0)}',
                      isDiscount: true),
                _calcRow('Luxury GST (${ref.watch(taxRateProvider)}.00%):',
                    '₹${quote.taxAmount.toStringAsFixed(0)}'),
                const SizedBox(height: AppSpacing.sm),
                const Divider(color: Color(0xFFE6E2D3)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total stay price:',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mossGreen)),
                    Text('₹${quote.totalAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mossGreen)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4B483).withValues(alpha: 0.25),
                    borderRadius: AppRadius.lgBr,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          '${ref.watch(depositRateProvider)}% Advance Deposit:',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mossGreen)),
                      Text('₹${quote.requiredAdvance.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mossGreen)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('APPLY COUPON CODE',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: const Color(0xFF4A4A35).withValues(alpha: 0.6))),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => _couponCode = v.toUpperCase(),
                  decoration: InputDecoration(
                    hintText: 'e.g. WELCOMEFIXED',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.lightBone.withValues(alpha: 0.8))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.lightBone.withValues(alpha: 0.8))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.mossGreen)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _applyPromo(quote),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mossGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: Text('Apply',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (_couponError.isNotEmpty)
            Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text('⚠ $_couponError',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.red.shade600))),
          if (_couponSuccess.isNotEmpty)
            Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text('✓ $_couponSuccess',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mossGreen))),
          const SizedBox(height: AppSpacing.md),
          Consumer(
            builder: (context, ref, _) {
              final couponsAsync = ref.watch(customerCouponsProvider);
              final coupons = couponsAsync.valueOrNull ?? [];
              if (coupons.isEmpty) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.stoneBg.withValues(alpha: 0.5),
                  borderRadius: AppRadius.lgBr,
                  border: Border.all(
                      color: AppColors.lightBone.withValues(alpha: 0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_offer,
                            color: AppColors.goldAccent, size: 14),
                        const SizedBox(width: 6),
                        Text('Available Coupons',
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color:
                                    AppColors.charcoal.withValues(alpha: 0.6))),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...coupons.take(3).map((c) {
                      final code = c['code'] as String? ?? '';
                      final desc = c['description'] as String? ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: InkWell(
                          onTap: () {
                            setState(() => _couponCode = code);
                          },
                          child: Text(
                            '$code - $desc',
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.mossGreen,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ] else ...[
          Container(
            padding: AppSpacing.allLg,
            decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: AppRadius.lgBr,
                border: Border.all(color: Colors.red.shade200)),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.red.shade700, size: 16),
                const SizedBox(width: 8),
                Text('Date selection is unavailable.',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.red.shade700)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        const Divider(color: Color(0xFFE6E2D3)),
        const SizedBox(height: AppSpacing.lg),
        Text('GUEST CONTACT INFORMATION',
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: const Color(0xFF4A4A35))),
        const SizedBox(height: AppSpacing.md),
        _textField('Guest Full Name', _nameController),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: _textField('Email Address', _emailController)),
            const SizedBox(width: 12),
            Expanded(child: _textField('Phone Number', _phoneController)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _textField(
            'Any special preparation requests? (Bonfire arrangement, mild spices, late arrivals notes)',
            _hkNotesController,
            maxLines: 2),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: quote.nightsCount > 0
                ? () => _handleInitiatePayment(quote)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mossGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              disabledBackgroundColor:
                  AppColors.mossGreen.withValues(alpha: 0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Verify Booking & Proceed',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepPayment(QuoteDetails quote) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: AppSpacing.allLg,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.lgBr,
            border:
                Border.all(color: AppColors.lightBone.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reservation Summary',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mossGreen)),
              const SizedBox(height: AppSpacing.sm),
              _summaryRow('Name:', _nameController.text),
              _summaryRow(
                  'Stay Period:', '$_selectedStartDate to $_selectedEndDate'),
              _summaryRow('Guests:', '$_guestsCount Adults'),
              const SizedBox(height: AppSpacing.sm),
              const Divider(color: AppColors.lightBone),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text('Amount Due: ',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.charcoal.withValues(alpha: 0.7))),
                  Text('₹${quote.totalAmount.toStringAsFixed(0)} INR',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mossGreen)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: AppSpacing.allLg,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F5F0),
            borderRadius: AppRadius.xxlBr,
            border: Border.all(color: AppColors.lightBone),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2.0),
                child: Icon(Icons.credit_card,
                    color: AppColors.goldAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment Authorization',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mossGreen)),
                    const SizedBox(height: 4),
                    Text(
                        'Your booking will be confirmed after payment authorization. The full amount will be charged to complete the reservation.',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.charcoal.withValues(alpha: 0.85),
                            height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: double.infinity,
          padding: AppSpacing.allLg,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4EE),
            borderRadius: AppRadius.lgBr,
          ),
          child: Row(
            children: [
              Icon(Icons.verified_user, color: AppColors.mossGreen, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Secure payment via encrypted gateway. Your card will be charged ₹${quote.totalAmount.toStringAsFixed(0)} INR.',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.charcoal.withValues(alpha: 0.8)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _handleCompletePayment(quote),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('Pay ₹${quote.totalAmount.toStringAsFixed(0)} INR',
                style: GoogleFonts.inter(
                    color: AppColors.mossGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: OutlinedButton(
            onPressed: () => setState(() => _checkoutStep = 'details'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.lightBone),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('Back to reservation details',
                style: GoogleFonts.inter(
                    color: AppColors.mossGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildStepConfirmed(QuoteDetails quote) {
    if (_createdBooking == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
              color: AppColors.goldAccent.withValues(alpha: 0.2),
              shape: BoxShape.circle),
          child: const Center(
              child: Text('✓',
                  style: TextStyle(
                      fontSize: 30,
                      color: AppColors.mossGreen,
                      fontFamily: 'serif'))),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Stay Confirmed!',
            style: AppTextStyles.titleLg.copyWith(color: AppColors.mossGreen)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Booking Reference ID: ',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.charcoal.withValues(alpha: 0.5))),
            Text(_createdBooking!.id,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldAccent)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
            'Excellent choice. An exclusive private villa reservation is secured. We have locked dates ${_createdBooking!.startDate} to ${_createdBooking!.endDate} immediately.',
            style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF4A4A35).withValues(alpha: 0.8),
                height: 1.5),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.stoneBg.withValues(alpha: 0.25),
            borderRadius: AppRadius.xxlBr,
            border:
                Border.all(color: AppColors.lightBone.withValues(alpha: 0.8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Invoice details:',
                      style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mossGreen)),
                  Text(_createdBooking!.id,
                      style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mossGreen)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(color: AppColors.lightBone),
              const SizedBox(height: AppSpacing.sm),
              _invoiceRow('Guest:', _createdBooking!.guestName),
              _invoiceRow('Phone:', _createdBooking!.guestPhone),
              _invoiceRow('Accommodation:',
                  '₹${_createdBooking!.baseAmount.toStringAsFixed(0)}'),
              _invoiceRow('Services & Clean:',
                  '₹${_createdBooking!.cleaningAmount.toStringAsFixed(0)}'),
              if (_createdBooking!.discountAmount > 0)
                _invoiceRow('Coupon Applied:',
                    '-₹${_createdBooking!.discountAmount.toStringAsFixed(0)}',
                    isDiscount: true),
              _invoiceRow('Tax Amount:',
                  '₹${_createdBooking!.taxAmount.toStringAsFixed(0)}'),
              const SizedBox(height: AppSpacing.sm),
              const Divider(color: AppColors.lightBone),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Paid Advance:',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mossGreen)),
                  Text(
                      '₹${_createdBooking!.advancePaidAmount.toStringAsFixed(0)} INR',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mossGreen)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.print, size: 16, color: AppColors.stoneBg),
            label: Text('Print Copy',
                style: GoogleFonts.inter(
                    color: AppColors.stoneBg,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mossGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: () {
            setState(() {
              _checkoutStep = 'details';
              _nameController.clear();
              _emailController.clear();
              _phoneController.clear();
              _hkNotesController.clear();
              _createdBooking = null;
            });
          },
          child: Text('Book Another Luxury Stay',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldAccent)),
        ),
      ],
    );
  }

  Widget _invoiceRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: AppColors.charcoal.withValues(alpha: 0.9))),
          const SizedBox(width: 4),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color:
                      isDiscount ? AppColors.mossGreen : AppColors.charcoal)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.charcoal.withValues(alpha: 0.7))),
          const SizedBox(width: 4),
          Expanded(
              child: Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal))),
        ],
      ),
    );
  }

  Widget _textField(String hint, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppColors.lightBone.withValues(alpha: 0.8))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppColors.lightBone.withValues(alpha: 0.8))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.mossGreen)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      style: GoogleFonts.inter(fontSize: 12),
    );
  }

  Widget _calcRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDiscount
                      ? AppColors.mossGreen
                      : AppColors.charcoal.withValues(alpha: 0.8),
                  fontWeight:
                      isDiscount ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDiscount
                      ? AppColors.mossGreen
                      : AppColors.charcoal.withValues(alpha: 0.8),
                  fontWeight:
                      isDiscount ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _dateInput(String label, String value, Function(String) onChanged) {
    // Format YYYY-MM-DD to DD-MM-YYYY for display
    String displayValue = value;
    try {
      final parts = value.split('-');
      if (parts.length == 3) {
        displayValue = '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    } catch (_) {}

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: const Color(0xFF4A4A35).withValues(alpha: 0.6))),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppColors.lightBone.withValues(alpha: 0.8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(displayValue,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal)),
              const Icon(Icons.calendar_today,
                  size: 14, color: AppColors.charcoal),
            ],
          ),
        ),
      ],
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.lightBone),
        ),
        child: Icon(icon, size: 14, color: AppColors.charcoal),
      ),
    );
  }
}
