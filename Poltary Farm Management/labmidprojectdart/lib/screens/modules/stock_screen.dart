import 'package:flutter/material.dart';
import '../../models/farm_models.dart';
import '../../services/farm_repository.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final _repo = FarmRepository.instance;
  String _selectedCategoryFilter = 'All';

  final List<String> categories = ['Newborn', 'Growing', 'Adult', 'Sick'];

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

  void _showAddEditDialog([StockRecord? existing]) {
    final isEdit = existing != null;
    final batchController = TextEditingController(text: existing?.batchName ?? '');
    String category = existing?.category ?? 'Growing';
    final quantityController = TextEditingController(text: existing != null ? '${existing.quantity}' : '');
    final mortalityController = TextEditingController(text: existing != null ? '${existing.mortality}' : '');
    final notesController = TextEditingController(text: existing?.notes ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Chicken Stock' : 'Add Chicken Stock'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: batchController,
                  decoration: const InputDecoration(labelText: 'Shed / Batch Name'),
                ),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => category = val);
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Total Quantity'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: mortalityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Mortality (Deaths)'),
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
                final quantity = int.tryParse(quantityController.text) ?? 0;
                final mortality = int.tryParse(mortalityController.text) ?? 0;

                if (batch.isEmpty || quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid batch & stock count')),
                  );
                  return;
                }

                final today = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
                final stock = StockRecord(
                  id: isEdit ? existing.id : DateTime.now().millisecondsSinceEpoch.toString(),
                  date: isEdit ? existing.date : today,
                  batchName: batch,
                  category: category,
                  quantity: quantity,
                  mortality: mortality,
                  notes: notesController.text.trim(),
                );

                if (isEdit) {
                  _repo.updateStockRecord(stock);
                } else {
                  _repo.addStockRecord(stock);
                }

                Navigator.pop(dialogContext);
              },
              child: Text(isEdit ? 'Update' : 'Save Stock'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Stock Record?'),
        content: const Text('This chicken stock record will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              _repo.deleteStockRecord(id);
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

    final stocks = _repo.stockRecords.where((s) {
      if (_selectedCategoryFilter == 'All') return true;
      return s.category == _selectedCategoryFilter;
    }).toList();

    int totalLive = 0;
    int totalMortality = 0;
    for (var s in _repo.stockRecords) {
      totalLive += s.netLive;
      totalMortality += s.mortality;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chick & Chicken Stock')),
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
                  _statMini('Total Live Birds', '$totalLive', green),
                  _statMini('Total Mortality', '$totalMortality', Colors.red),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: ['All', ...categories].map((cat) {
                final isSelected = _selectedCategoryFilter == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: green.withOpacity(0.2),
                    checkmarkColor: green,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategoryFilter = cat);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: stocks.isEmpty
                ? const Center(child: Text('No stock records in this category.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: stocks.length,
                    itemBuilder: (context, index) {
                      final item = stocks[index];
                      Color categoryColor = green;
                      if (item.category == 'Sick') categoryColor = Colors.red;
                      if (item.category == 'Newborn') categoryColor = Colors.orange;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: categoryColor.withOpacity(0.15),
                              child: Icon(Icons.inventory_2_outlined, color: categoryColor),
                            ),
                            title: Text(item.batchName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(
                              'Category: ${item.category} | Date: ${item.date}\n'
                              'Quantity: ${item.quantity} | Mortality: ${item.mortality}\n'
                              'Net Live Stock: ${item.netLive} birds',
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
      width: 130,
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
