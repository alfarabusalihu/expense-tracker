import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../theme/app_colors.dart';

/// Category selection widget supporting smooth horizontal scrolling
/// (with mouse wheel, drag, touch, and scroll arrows) and grid wraps.
class CategorySelector extends StatefulWidget {
  final String selectedCategory;
  final ValueChanged<String?> onCategorySelected;
  final bool showAllOption;
  final bool isHorizontal;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.showAllOption = false,
    this.isHorizontal = true,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollIndicators);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollIndicators());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicators);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollIndicators() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final canLeft = currentScroll > 5;
    final canRight = currentScroll < (maxScroll - 5);

    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  void _scrollBy(double offset) {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset + offset).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'movie':
        return Icons.movie;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      default:
        return Icons.category;
    }
  }

  Widget _buildAllChip(BuildContext context) {
    final isSelected = widget.selectedCategory.isEmpty;
    return ChoiceChip(
      avatar: Icon(
        Icons.apps,
        size: 16,
        color: isSelected ? AppColors.primary : Theme.of(context).iconTheme.color,
      ),
      label: const Text('All Categories'),
      selected: isSelected,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      backgroundColor: Theme.of(context).cardColor,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.lightCardBorder,
      ),
      onSelected: (bool selected) {
        if (selected) {
          widget.onCategorySelected(null);
        }
      },
    );
  }

  Widget _buildChip(BuildContext context, Map<String, String> cat) {
    final categoryId = cat['id']!;
    final categoryLabel = cat['label']!;
    final iconData = _getCategoryIcon(cat['icon']);
    final isSelected = widget.selectedCategory.toLowerCase() == categoryId.toLowerCase();

    return ChoiceChip(
      avatar: Icon(
        iconData,
        size: 16,
        color: isSelected ? AppColors.primary : Theme.of(context).iconTheme.color,
      ),
      label: Text(categoryLabel),
      selected: isSelected,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      backgroundColor: Theme.of(context).cardColor,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.lightCardBorder,
      ),
      onSelected: (bool selected) {
        if (selected) {
          widget.onCategorySelected(categoryId);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> chips = [];

    if (widget.showAllOption) {
      chips.add(Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: _buildAllChip(context),
      ));
    }

    chips.addAll(AppConstants.categories.map((cat) {
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: _buildChip(context, cat),
      );
    }));

    if (!widget.isHorizontal) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (widget.showAllOption) _buildAllChip(context),
          ...AppConstants.categories.map((cat) => _buildChip(context, cat)),
        ],
      );
    }

    return Row(
      children: [
        if (_canScrollLeft)
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _scrollBy(-140.0),
            child: const Padding(
              padding: EdgeInsets.only(right: 4.0),
              child: Icon(Icons.chevron_left, size: 22, color: AppColors.primary),
            ),
          ),
        Expanded(
          child: Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                final delta = pointerSignal.scrollDelta.dy != 0
                    ? pointerSignal.scrollDelta.dy
                    : pointerSignal.scrollDelta.dx;
                if (delta != 0 && _scrollController.hasClients) {
                  final target = (_scrollController.offset + delta).clamp(
                    0.0,
                    _scrollController.position.maxScrollExtent,
                  );
                  _scrollController.jumpTo(target);
                }
              }
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: chips,
              ),
            ),
          ),
        ),
        if (_canScrollRight)
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _scrollBy(140.0),
            child: const Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: Icon(Icons.chevron_right, size: 22, color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}
