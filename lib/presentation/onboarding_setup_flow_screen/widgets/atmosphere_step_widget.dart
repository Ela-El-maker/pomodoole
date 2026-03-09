import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodorofocus/data/models/catalog_item.dart';
import 'package:pomodorofocus/state/app/data_providers.dart';
import 'package:sizer/sizer.dart';

class AtmosphereStepWidget extends ConsumerWidget {
  const AtmosphereStepWidget({
    super.key,
    required this.selectedAtmosphere,
    required this.onAtmosphereSelected,
  });

  final String selectedAtmosphere;
  final ValueChanged<String> onAtmosphereSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atmospheres = ref.watch(catalogItemsProvider(CatalogType.atmosphere));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 3 of 4',
          style: GoogleFonts.dmSans(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFA8C3A0),
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Choose your\natmosphere',
          style: GoogleFonts.dmSans(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2F2F2F),
            height: 1.3,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Set the mood for your focus sessions.',
          style: GoogleFonts.dmSans(
            fontSize: 11.sp,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF6F6F6F),
          ),
        ),
        SizedBox(height: 4.h),
        atmospheres.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Text(
            'Failed to load atmospheres',
            style: GoogleFonts.dmSans(color: const Color(0xFF6F6F6F)),
          ),
          data: (items) => Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: _AtmosphereCard(
                      item: item,
                      isSelected: selectedAtmosphere == item.value,
                      onTap: () => onAtmosphereSelected(item.value),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _AtmosphereCard extends StatelessWidget {
  const _AtmosphereCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final CatalogItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFA8C3A0).withValues(alpha: 0.12)
              : const Color(0xFFF0EFEA),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected ? const Color(0xFFA8C3A0) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 11.w,
              height: 5.5.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFA8C3A0).withValues(alpha: 0.2)
                    : const Color(0xFFE8E6E0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Text(
                  item.emoji ?? '🌿',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2F2F2F),
                    ),
                  ),
                  Text(
                    item.description ?? '',
                    style: GoogleFonts.dmSans(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF6F6F6F),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 6.w,
                height: 3.h,
                decoration: const BoxDecoration(
                  color: Color(0xFFA8C3A0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }
}
