import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../global_widgets/section_header.dart';
import '../providers/stats_provider.dart';
import '../widgets/stat_card.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  static const routeName = 'stats';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);

    return SafeArea(
      child: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          const SectionHeader(
            title: 'Analisis Tagihan',
            subtitle: 'Ringkasan dan insight keuangan Anda',
          ),
          const SizedBox(height: AppSpacing.md),
          stats.when(
            data: (data) => _InsightBanner(
              summary:
                  'Total pengeluaran bulan ini: ${MoneyFormatter.format(data.totalAll)}. '
                  'Anda telah membayar ${data.paidPercent}% dari total tagihan.',
            ),
            error: (error, _) => Text(error.toString()),
            loading: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.lg),
          stats.when(
            data: (data) => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.15,
              children: [
                StatCard(
                  title: 'Sudah Dibayar',
                  value: data.totalPaid,
                  subtitle: '${data.paidPercent}% dari total',
                  accentColor: AppColors.accentGreen,
                ),
                StatCard(
                  title: 'Belum Dibayar',
                  value: data.totalUnpaid,
                  subtitle: '${data.unpaidPercent}% dari total',
                  accentColor: AppColors.accentYellow,
                ),
                StatCard(
                  title: 'Terlambat',
                  value: data.totalOverdue,
                  subtitle: '${data.overdueCount} tagihan terlambat',
                  accentColor: AppColors.accentRed,
                ),
                StatCard(
                  title: 'Rata-rata Tagihan',
                  value: data.average,
                  subtitle: 'Per tagihan',
                  accentColor: AppColors.primary,
                ),
              ],
            ),
            error: (error, _) => Text(error.toString()),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ChartSection(),
        ],
      ),
    );
  }
}

class _InsightBanner extends StatelessWidget {
  const _InsightBanner({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.trending_up, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              summary,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chart = ref.watch(statsChartProvider);
    final months = ref.watch(statsPeriodProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Pengeluaran',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DropdownButton<int>(
                value: months,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('1 bulan')),
                  DropdownMenuItem(value: 3, child: Text('3 bulan')),
                  DropdownMenuItem(value: 6, child: Text('6 bulan')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(statsPeriodProvider.notifier).state = value;
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 160,
            child: chart.when(
              data: (points) => BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => AppColors.primary,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final value = rod.toY.toInt();
                        return BarTooltipItem(
                          MoneyFormatter.format(value),
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= points.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              points[index].label,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(points.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: points[index].value,
                          width: 18,
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.primary,
                        ),
                      ],
                    );
                  }),
                ),
              ),
              error: (error, _) => Text(error.toString()),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
