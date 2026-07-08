import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/incident_provider.dart';
import '../../utils/category_utils.dart';

/// Dashboard de reportes para el panel de administración.
/// Muestra el total de incidentes, cuántos se registraron hoy,
/// un desglose por categoría y la tendencia de los últimos 7 días.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    // El admin debe ver TODOS los incidentes, sin filtro por userId.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentProvider>().clearFilters();
      context.read<IncidentProvider>().loadIncidents();
    });
  }

  Future<void> _refresh() async {
    await context.read<IncidentProvider>().loadIncidents();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final incidents = provider.incidents;
    final now = DateTime.now();

    final total = incidents.length;
    final today =
        incidents.where((i) => _isSameDay(i.createdAt, now)).length;

    final weekStart = now.subtract(const Duration(days: 6));
    final thisWeek = incidents
        .where((i) => i.createdAt.isAfter(
            DateTime(weekStart.year, weekStart.month, weekStart.day)))
        .length;

    // Desglose por categoría, de mayor a menor.
    final Map<String, int> byCategory = {};
    for (final i in incidents) {
      byCategory[i.category] = (byCategory[i.category] ?? 0) + 1;
    }
    final sortedCategories = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategory =
        sortedCategories.isNotEmpty ? sortedCategories.first.key : '—';

    // Incidentes por día en los últimos 7 días (para la mini gráfica).
    final last7Days = List.generate(
      7,
      (index) => DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - index)),
    );
    final Map<DateTime, int> byDay = {
      for (final d in last7Days)
        d: incidents.where((i) => _isSameDay(i.createdAt, d)).length,
    };
    final maxDayCount =
        byDay.values.isEmpty ? 0 : byDay.values.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: provider.isLoading && incidents.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: AppColors.alertRed),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.list_alt,
                              label: 'Total de incidentes',
                              value: '$total',
                              color: AppColors.darkBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.today,
                              label: 'Hoy',
                              value: '$today',
                              color: AppColors.alertRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.calendar_view_week,
                              label: 'Últimos 7 días',
                              value: '$thisWeek',
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.category,
                              label: 'Categoría top',
                              value: topCategory,
                              color: CategoryUtils.colorOf(topCategory),
                              isTextValue: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Incidentes por categoría',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (sortedCategories.isEmpty)
                        const Text(
                          'No hay incidentes reportados todavía.',
                          style: TextStyle(color: AppColors.gray),
                        )
                      else
                        ...sortedCategories.map(
                          (entry) => _CategoryBar(
                            category: entry.key,
                            count: entry.value,
                            total: total,
                          ),
                        ),
                      const SizedBox(height: 24),
                      const Text(
                        'Últimos 7 días',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: byDay.entries.map((entry) {
                            final heightFactor = maxDayCount == 0
                                ? 0.0
                                : entry.value / maxDayCount;
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${entry.value}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: 70 * heightFactor
                                          .clamp(0.05, 1.0),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _weekdayLabel(entry.key.weekday),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.gray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return labels[weekday - 1];
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isTextValue = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isTextValue;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isTextValue ? 16 : 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: AppColors.gray, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.category,
    required this.count,
    required this.total,
  });

  final String category;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;
    final color = CategoryUtils.colorOf(category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CategoryUtils.iconOf(category), size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(category, style: const TextStyle(fontSize: 13)),
              ),
              Text(
                '$count',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: AppColors.lightGray,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}