import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../providers/module_provider.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen_header.dart';

class ModulesScreen extends StatefulWidget {
  final bool showBackButton;
  const ModulesScreen({super.key, this.showBackButton = false});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ModuleProvider>().fetchModules();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ModuleProvider>();
    final filteredModules = provider.modules.where((module) {
      final query = _searchQuery.toLowerCase();
      return module.title.toLowerCase().contains(query) ||
          module.moduleCode.toLowerCase().contains(query);
    }).toList();

    final totalCredits = provider.modules.fold(0.0, (sum, m) => sum + m.creditHours);
    final totalHours = provider.modules.fold(0.0, (sum, m) => sum + m.weeklyHours);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchModules(),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ScreenHeader(
              title: 'My Modules',
              subtitle: 'Manage your courses',
              showNotification: false,
              showBackButton: widget.showBackButton,
              action: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.addModule),
              ),
              stats: [
                HeaderStatCard(
                  label: 'Modules',
                  value: '${provider.modules.length}',
                  icon: Icons.book_outlined,
                ),
                HeaderStatCard(
                  label: 'Credits',
                  value: '${totalCredits.toInt()}',
                  icon: Icons.credit_card_outlined,
                ),
                HeaderStatCard(
                  label: 'Weekly Load',
                  value: '${totalHours.toInt()}h',
                  icon: Icons.timer_outlined,
                ),
                HeaderStatCard(
                  label: 'Avg Credits',
                  value: (totalCredits / (provider.modules.isEmpty ? 1 : provider.modules.length)).toStringAsFixed(1),
                  icon: Icons.assessment_outlined,
                ),
              ],
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search modules...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  prefixIcon: const Icon(Icons.search, size: 20, color: Colors.white70),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20, color: Colors.white70),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            _buildBody(provider, filteredModules),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_module_fab',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addModule),
        label: const Text('New Module'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(ModuleProvider provider, List<dynamic> filteredModules) {
    if (provider.isLoading && provider.modules.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: ShimmerList(itemHeight: 120),
      );
    }

    if (provider.error != null && provider.modules.isEmpty) {
      return ErrorState(message: provider.error!, onRetry: () => provider.fetchModules());
    }

    if (provider.modules.isEmpty) {
      return EmptyState(
        icon: Icons.auto_stories_outlined,
        title: 'No Modules Added',
        subtitle: 'Add your courses or modules to calculate your workload.',
        actionLabel: 'Add First Module',
        onAction: () => Navigator.pushNamed(context, AppRoutes.addModule),
      );
    }

    if (filteredModules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_outlined, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('No modules match your search', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisExtent: 140,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredModules.length,
      itemBuilder: (context, index) {
        final module = filteredModules[index];
        return _buildModuleCard(module);
      },
    );
  }

  Widget _buildModuleCard(module) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, AppRoutes.moduleDetail, arguments: module),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      module.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildDifficultyChip(module.difficulty),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  _buildInfoItem(Icons.credit_card_outlined, '${module.creditHours} Credits'),
                  const SizedBox(width: 20),
                  _buildInfoItem(Icons.timer_outlined, '${module.weeklyHours}h/week'),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: module.weeklyHours / 40, // Arbitrary max 40h
                backgroundColor: AppColors.border,
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String diff) {
    Color color = AppColors.success;
    if (diff.toLowerCase() == 'medium') color = AppColors.warning;
    if (diff.toLowerCase() == 'hard') color = AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        diff,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
