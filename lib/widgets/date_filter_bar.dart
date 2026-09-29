import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum DateQuickFilter {
  allTime,
  today,
  yesterday,
  thisWeek,
  thisMonth,
  lastMonth,
  thisYear,
}

/// Horizontally scrollable date filter bar with scroll arrows, mouse wheel support, and touch gestures.
class DateFilterBar extends StatefulWidget {
  final DateQuickFilter selectedFilter;
  final ValueChanged<DateQuickFilter> onFilterSelected;

  const DateFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  State<DateFilterBar> createState() => _DateFilterBarState();
}

class _DateFilterBarState extends State<DateFilterBar> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  static const List<Map<String, dynamic>> _filterOptions = [
    {'filter': DateQuickFilter.allTime, 'label': 'All Time'},
    {'filter': DateQuickFilter.today, 'label': 'Today'},
    {'filter': DateQuickFilter.yesterday, 'label': 'Yesterday'},
    {'filter': DateQuickFilter.thisWeek, 'label': 'This Week'},
    {'filter': DateQuickFilter.thisMonth, 'label': 'This Month'},
    {'filter': DateQuickFilter.lastMonth, 'label': 'Last Month'},
    {'filter': DateQuickFilter.thisYear, 'label': 'This Year'},
  ];

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

  Widget _buildChip(BuildContext context, Map<String, dynamic> opt) {
    final filter = opt['filter'] as DateQuickFilter;
    final label = opt['label'] as String;
    final isSelected = widget.selectedFilter == filter;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      backgroundColor: Theme.of(context).cardColor,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.lightCardBorder,
      ),
      onSelected: (bool selected) {
        if (selected) {
          widget.onFilterSelected(filter);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (_canScrollLeft)
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _scrollBy(-120.0),
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
                children: _filterOptions.map((opt) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: _buildChip(context, opt),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        if (_canScrollRight)
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _scrollBy(120.0),
            child: const Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: Icon(Icons.chevron_right, size: 22, color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}
