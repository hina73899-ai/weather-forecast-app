import 'package:flutter/material.dart';
class PageIndicatorSection extends StatelessWidget {
  final int activeIndex;
  final int totalPages;
  final ValueChanged<int> onDotTap;

  const PageIndicatorSection({
    required this.activeIndex,
    required this.totalPages,
    required this.onDotTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalPages, (index) {
          final isSelected = index == activeIndex;
          return GestureDetector(
            onTap: () => onDotTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isSelected ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: isSelected ? null : Border.all(color: Colors.white54, width: 1.5),
              ),
            ),
          );
        }),
      ),
    );
  }
}


