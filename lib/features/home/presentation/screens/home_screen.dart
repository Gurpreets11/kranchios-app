import 'package:core_package/core_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';

/// The home screen — the first screen shown after login, and the
/// app's effective navigation root (back here exits the app rather
/// than popping further — see [AppExitGuard] below).
///
/// Demonstrates [AppSearchField], [AppDropdownTrigger] (paired with
/// [AppDialogs.showActionSheet] for a "Sort by" control), and
/// [AppPaginatedListView] wired together against a small in-memory
/// dataset, standing in for a real paginated API-backed list (e.g.
/// leads, orders). New apps built from this template replace
/// `_allItems` and the artificial delay in [_loadMore] with a real
/// repository call.
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _pageSize = 10;
  static final _allItems = List.generate(
    42,
        (index) => 'Activity item ${index + 1}',
  );

  late final PaginationController _paginationController;
  String _query = '';
  int _visibleCount = _pageSize;
  bool _sortNewestFirst = true;

  @override
  void initState() {
    super.initState();
    _paginationController = PaginationController(onLoadMore: _loadMore);
  }

  @override
  void dispose() {
    _paginationController.dispose();
    super.dispose();
  }

  List<String> get _filteredItems {
    final matches = _query.isBlank
        ? _allItems
        : _allItems.where((item) {
      return item.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    // "Newest" here just means the generated order vs. reversed — in a
    // real app this would be a `sortBy` parameter on the repository call.
    return _sortNewestFirst ? matches : matches.reversed.toList();
  }

  Future<void> _showSortSheet(BuildContext context) async {
    final selection = await AppDialogs.showActionSheet<bool>(
      context,
      title: 'Sort by',
      items: [
        AppActionSheetItem(label: 'Newest first', value: true),
        AppActionSheetItem(label: 'Oldest first', value: false),
      ],
    );

    if (selection != null && selection != _sortNewestFirst) {
      setState(() {
        _sortNewestFirst = selection;
        _visibleCount = _pageSize;
      });
      _paginationController.reset();
    }
  }

  Future<void> _loadMore() async {
    // Simulates network latency for the next "page" — replace with a
    // real repository call in an app built from this template.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      _visibleCount = (_visibleCount + _pageSize).clamp(
        0,
        _filteredItems.length,
      );
    });
    _paginationController.setHasMore(_visibleCount < _filteredItems.length);
  }

  void _onSearchChanged(String query) {
    setState(() {
      _query = query;
      _visibleCount = _pageSize;
    });
    _paginationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final config = AppThemeScope.of(context);
    final authState = ref.watch(authControllerProvider);
    final visibleItems = _filteredItems.take(_visibleCount).toList();

    return AppExitGuard(
      behavior: AppExitBehavior.confirmDialog,
      child: Padding(
        padding: EdgeInsets.all(config.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${authState.user?.name ?? ''}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: config.spacing.md),
            Row(
              children: [
                Expanded(
                  child: AppSearchField(
                    hintText: 'Search activity',
                    onChanged: _onSearchChanged,
                  ),
                ),
                SizedBox(width: config.spacing.sm),
                AppDropdownTrigger(
                  label: _sortNewestFirst ? 'Newest' : 'Oldest',
                  onTap: () => _showSortSheet(context),
                ),
              ],
            ),
            SizedBox(height: config.spacing.md),
            Expanded(
              child: AppPaginatedListView<String>(
                items: visibleItems,
                controller: _paginationController,
                emptyState: const AppEmptyState(
                  title: 'No matching activity',
                  message: 'Try a different search term.',
                ),
                itemBuilder: (context, item) => Padding(
                  padding: EdgeInsets.only(bottom: config.spacing.sm),
                  child: AppCard(
                    child: Row(
                      children: [
                        Icon(Icons.history, color: config.primary),
                        SizedBox(width: config.spacing.sm),
                        Expanded(child: Text(item)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}