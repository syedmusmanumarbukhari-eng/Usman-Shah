import 'package:flutter/material.dart';
import '../../models/farm_models.dart';
import '../../services/farm_repository.dart';

class IncubationScreen extends StatefulWidget {
  const IncubationScreen({super.key});

  @override
  State<IncubationScreen> createState() => _IncubationScreenState();
}

class _IncubationScreenState extends State<IncubationScreen> {
  final _repo = FarmRepository.instance;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  void _showAddEditDialog([IncubationRecord? existing]) {
    final isEdit = existing != null;
    final batchController = TextEditingController(text: existing?.batchName ?? '');
    final settingDateController = TextEditingController(text: existing?.settingDate ?? '');
    final hatchDateController = TextEditingController(text: existing?.hatchDate ?? '');
    final eggsSetController = TextEditingController(text: existing != null ? '${existing.eggsSet}' : '');
    final chicksHatchedController = TextEditingController(text: existing != null ? '${existing.chicksHatched}' : '');
    final infertileController = TextEditingController(text: existing != null ? '${existing.infertile}' : '');
    final notesController = TextEditingController(text: existing?.notes ?? '');

    if (!isEdit && settingDateController.text.isEmpty) {
      final now = DateTime.now();
      settingDateController.text = '${now.day}/${now.month}/${now.year}';
      final hatch = now.add(const Duration(days: 21));
      hatchDateController.text = '${hatch.day}/${hatch.month}/${hatch.year}';
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEdit ? 'Edit Incubation Record' : 'Add Incubation Batch'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: batchController,
                decoration: const InputDecoration(labelText: 'Incubator / Batch Name'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: settingDateController,
                      decoration: const InputDecoration(labelText: 'Setting Date'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: hatchDateController,
                      decoration: const InputDecoration(labelText: 'Hatch Date'),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: eggsSetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Eggs Set'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: chicksHatchedController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Chicks Hatched'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: infertileController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Infertile Eggs'),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF397A58),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final batch = batchController.text.trim();
              final setDate = settingDateController.text.trim();
              final hDate = hatchDateController.text.trim();
              final eggsSet = int.tryParse(eggsSetController.text) ?? 0;
              final chicksHatched = int.tryParse(chicksHatchedController.text) ?? 0;
              final infertile = int.tryParse(infertileController.text) ?? 0;

              if (batch.isEmpty || eggsSet <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid batch & eggs count')),
                );
                return;
              }

              final record = IncubationRecord(
                id: isEdit ? existing.id : DateTime.now().millisecondsSinceEpoch.toString(),
                settingDate: setDate,
                hatchDate: hDate,
                batchName: batch,
                eggsSet: eggsSet,
                chicksHatched: chicksHatched,
                infertile: infertile,
                notes: notesController.text.trim(),
              );

              if (isEdit) {
                _repo.updateIncubationRecord(record);
              } else {
                _repo.addIncubationRecord(record);
              }

              Navigator.pop(dialogContext);
            },
            child: Text(isEdit ? 'Update' : 'Save Batch'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Incubation Record?'),
        content: const Text('This incubation batch record will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              _repo.deleteIncubationRecord(id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF397A58);
    final records = _repo.incubationRecords.where((i) {
      if (_searchQuery.isEmpty) return true;
      return i.batchName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    int totalSet = 0;
    int totalHatched = 0;
    for (var i in _repo.incubationRecords) {
      totalSet += i.eggsSet;
      totalHatched += i.chicksHatched;
    }
    final avgHatchRate = totalSet > 0 ? (totalHatched / totalSet) * 100 : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Incubation & Hatching')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: green,
        foregroundColor: Colors.white,
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            color: green.withOpacity(0.08),
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _statMini('Eggs Set', '$totalSet', green),
                  _statMini('Hatched', '$totalHatched', green),
                  _statMini('Hatch Rate', '${avgHatchRate.toStringAsFixed(1)}%', green),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search incubator batch...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: records.isEmpty
                ? const Center(child: Text('No incubation records found.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final item = records[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFEAF4ED),
                              child: Icon(Icons.thermostat_outlined, color: green),
                            ),
                            title: Text(item.batchName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(
                              'Setting: ${item.settingDate} | Hatch: ${item.hatchDate}\n'
                              'Set: ${item.eggsSet} | Hatched: ${item.chicksHatched} | Infertile: ${item.infertile}\n'
                              'Hatch Rate: ${item.hatchRate.toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20),
                              onSelected: (val) {
                                if (val == 'edit') _showAddEditDialog(item);
                                if (val == 'delete') _confirmDelete(item.id);
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 18, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statMini(String title, String val, Color color) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}
