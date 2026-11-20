import 'package:flutter/material.dart';
import '../../models/farm_models.dart';
import '../../services/farm_repository.dart';

class BreedingStockScreen extends StatefulWidget {
  const BreedingStockScreen({super.key});

  @override
  State<BreedingStockScreen> createState() => _BreedingStockScreenState();
}

class _BreedingStockScreenState extends State<BreedingStockScreen> {
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

  void _showAddEditDialog([BreedingStock? existing]) {
    final isEdit = existing != null;
    final batchController = TextEditingController(text: existing?.batchName ?? '');
    final breedController = TextEditingController(text: existing?.breed ?? '');
    final malesController = TextEditingController(text: existing != null ? '${existing.males}' : '');
    final femalesController = TextEditingController(text: existing != null ? '${existing.females}' : '');
    final ageController = TextEditingController(text: existing != null ? '${existing.ageWeeks}' : '');
    final notesController = TextEditingController(text: existing?.notes ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEdit ? 'Edit Breeding Stock' : 'Add Breeding Stock Batch'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: batchController,
                decoration: const InputDecoration(labelText: 'Batch Name / Identifier'),
              ),
              TextField(
                controller: breedController,
                decoration: const InputDecoration(labelText: 'Breed (e.g. Rhode Island, Leghorn)'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: malesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Males Count'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: femalesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Females Count'),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age (in Weeks)'),
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
              final breed = breedController.text.trim();
              final males = int.tryParse(malesController.text) ?? 0;
              final females = int.tryParse(femalesController.text) ?? 0;
              final age = int.tryParse(ageController.text) ?? 0;

              if (batch.isEmpty || breed.isEmpty || (males == 0 && females == 0)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid batch details')),
                );
                return;
              }

              final today = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
              final stock = BreedingStock(
                id: isEdit ? existing.id : DateTime.now().millisecondsSinceEpoch.toString(),
                date: isEdit ? existing.date : today,
                batchName: batch,
                breed: breed,
                males: males,
                females: females,
                ageWeeks: age,
                notes: notesController.text.trim(),
              );

              if (isEdit) {
                _repo.updateBreedingStock(stock);
              } else {
                _repo.addBreedingStock(stock);
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
        title: const Text('Delete Breeding Stock?'),
        content: const Text('This batch record will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              _repo.deleteBreedingStock(id);
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
    final stocks = _repo.breedingStocks.where((b) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return b.batchName.toLowerCase().contains(q) || b.breed.toLowerCase().contains(q);
    }).toList();

    int totalMales = 0;
    int totalFemales = 0;
    for (var b in _repo.breedingStocks) {
      totalMales += b.males;
      totalFemales += b.females;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Breeding Stock'),
      ),
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
                  _statMini('Total Males', '$totalMales', green),
                  _statMini('Total Females', '$totalFemales', green),
                  _statMini('Total Birds', '${totalMales + totalFemales}', green),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search batch or breed...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: stocks.isEmpty
                ? const Center(child: Text('No breeding stock records found.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    itemCount: stocks.length,
                    itemBuilder: (context, index) {
                      final item = stocks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFEAF4ED),
                              child: Icon(Icons.flutter_dash, color: green),
                            ),
                            title: Text(item.batchName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(
                              'Breed: ${item.breed} | Age: ${item.ageWeeks} wks\n'
                              'Males: ${item.males} | Females: ${item.females} (Total: ${item.totalBirds})\n'
                              '${item.notes.isNotEmpty ? "Notes: ${item.notes}" : ""}',
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
