import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/incident_provider.dart';
import '/widgets/incident_card.dart';
import '../../utils/category_utils.dart';
import '../../config/theme.dart';

class IncidentListScreen extends StatefulWidget {
  final String? userId;
  final String title;
  const IncidentListScreen({super.key,this.userId, this.title = 'Incidentes reportados'});

  @override
  State<IncidentListScreen> createState() => _IncidentListScreenState();
}

class _IncidentListScreenState extends State<IncidentListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentProvider>().loadIncidents(userId: widget.userId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por categoría o descripción...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.search('', userId: widget.userId);
                        },
                      )
                    : null,
              ),
              onSubmitted: (v) => provider.search(v, userId: widget.userId),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _filterChip(context, 'Todas', provider.categoryFilter == null, () {
                  provider.filterByCategory(null, userId: widget.userId);
                }),
                ...CategoryUtils.all.map(
                  (c) => _filterChip(context, c, provider.categoryFilter == c, () {
                    provider.filterByCategory(c, userId: widget.userId);
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildBody(provider)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.alertRed,
        onPressed: () =>
            Navigator.pushNamed(context, '/incident-form'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.darkBlue,
        labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
      ),
    );
  }

  Widget _buildBody(IncidentProvider provider) {

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.incidents.isEmpty) {
      return const Center(
        child: Text(
          'No hay incidentes reportados',
          style: const TextStyle(color: AppColors.alertRed))
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: provider.incidents.length,
      itemBuilder: (context, index) {

        final incident = provider.incidents[index];

        return IncidentCard(
          incident: incident,
          onDelete: () async {
            return await provider.removeIncident(incident.id);
          },
        );
      },
    );
  }
}