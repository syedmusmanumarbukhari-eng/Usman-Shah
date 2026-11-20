import 'package:flutter/material.dart';
import '../../models/farm_models.dart';
import '../../services/farm_repository.dart';

class EggCollectionScreen extends StatefulWidget {
  const EggCollectionScreen({super.key});

  @override
  State<EggCollectionScreen> createState() => _EggCollectionScreenState();
}

class _EggCollectionScreenState extends State<EggCollectionScreen> {
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

  void _showAddEditDialog([EggRecord? existing]) {
    final isEdit = existing != null;
    final batchController = TextEditingController(text: existing?.batchName ?? '');
    final collectedController = TextEditingController(text: existing != null ? '${existing.collected}' : '');
    final damagedController = TextEditingController(text: existing != null ? '${existing.damaged}' : '');
    final soldController = TextEditingController(text: existing != null ? '${existing.sold}' : '');
    final notesController = TextEditingController(text: existing?.notes ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEdit ? 'Edit Egg Record' : 'Record Egg Collection'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: batchController,
                decoration: const InputDecoration(labelText: 'Batch / Shed Name'),
              ),
              TextField(
                controller: collectedController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Eggs Collected'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: damagedController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Damaged / Broken'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: soldController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Sold Eggs'),
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
              final collected = int.tryParse(collectedController.text) ?? 0;
              final damaged = int.tryParse(damagedController.text) ?? 0;
              final sold = int.tryParse(soldController.text) ?? 0;

              if (batch.isEmpty || collected < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid egg collection numbers')),
                );
                return;
              }

              final today = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
              final record = EggRecord(
                id: isEdit ? existing.id : DateTime.now().millisecondsSinceEpoch.toString(),
                date: isEdit ? existing.date : today,
                batchName: batch,
                collected: collected,
                damaged: damaged,
                sold: sold,
                notes: notesController.text.trim(),
              );

              if (isEdit) {
                _repo.updateEggRecord(record);
              } else {
                _repo.addEggRecord(record);
              }

              Navigator.pop(dialogContext);
            },
            child: Text(isEdit ? 'Update' : 'Save Record'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Egg Record?'),
        content: const Text('This egg record will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              _repo.deleteEggRecord(id);
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
    final records = _repo.eggRecords.where((e) {
      if (_searchQuery.isEmpty) return true;
      return e.batchName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    int totalCollected = 0;
    int totalDamaged = 0;
    int totalSold = 0;
    int totalAvailable = 0;

    for (var e in _repo.eggRecords) {
      totalCollected += e.collected;
      totalDamaged += e.damaged;
      totalSold += e.sold;
      totalAvailable += e.available;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Egg Collection')),
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
                  _statMini('Collected', '$totalCollected', Colors.blue),
                  _statMini('Damaged', '$totalDamaged', Colors.red),
                  _statMini('Sold', '$totalSold', Colors.orange),
                  _statMini('Available', '$totalAvailable', green),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search batch...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: records.isEmpty
                ? const Center(child: Text('No egg records available.'))
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
                              child: Icon(Icons.egg_outlined, color: green),
                            ),
                            title: Text(item.batchName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(
                              'Date: ${item.date}\n'
                              'Collected: ${item.collected} | Damaged: ${item.damaged} | Sold: ${item.sold}\n'
                              'Available Stock: ${item.available} eggs',
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
      width: 95,
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}
