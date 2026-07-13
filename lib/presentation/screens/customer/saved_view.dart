import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../providers/state_provider.dart';

class SavedView extends ConsumerWidget {
  const SavedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedResorts = ref.watch(savedPropertiesProvider);

    return Container(
      color: AppColors.stoneBg,
      child: savedResorts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: AppColors.mossGreen.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No Saved Resorts Yet',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mossGreen,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Tap the heart icon on a resort\nto save it to your wishlist.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.charcoal.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Saved Sanctuaries',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mossGreen,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Quickly access and book your favorite private reserves.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.charcoal.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: savedResorts.length,
                    itemBuilder: (context, index) {
                      final resort = savedResorts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadius.xxlBr,
                          border: Border.all(color: AppColors.lightBone, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: AppRadius.xxlBr,
                          child: InkWell(
                            onTap: () {
                              ref.read(propertyProvider.notifier).updateProperty(resort);
                              ref.read(activeTabProvider.notifier).state = 'explore';
                            },
                            child: Row(
                              children: [
                                Image.network(
                                  resort.image,
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          resort.city.toUpperCase(),
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                            color: AppColors.goldAccent,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          resort.name,
                                          style: AppTextStyles.titleSm.copyWith(color: AppColors.mossGreen),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '₹${resort.basePriceWeekday.toStringAsFixed(0)} / night',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.charcoal.withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    ref.read(savedPropertiesProvider.notifier).toggleSave(resort);
                                  },
                                ),
                                const SizedBox(width: 12),
                              ],
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
}
