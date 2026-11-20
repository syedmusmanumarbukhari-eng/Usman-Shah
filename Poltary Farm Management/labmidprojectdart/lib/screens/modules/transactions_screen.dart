import 'package:flutter/material.dart';
import '../../models/farm_models.dart';
import '../../services/farm_repository.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _repo = FarmRepository.instance;
  String _selectedFilter = 'All'; // 'All', 'Sale', 'Purchase'

  final List<String> itemTypes = ['Eggs', 'Chickens', 'Feed', 'Supplies', 'Other'];

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

  void _showAddEditDialog([TransactionRecord? existing]) {
    final isEdit = existing != null;
    String type = existing?.type ?? 'Sale';
    String itemType = existing?.itemType ?? 'Eggs';
    final partyController = TextEditingController(text: existing?.partyName ?? '');
    final quantityController = TextEditingController(text: existing != null ? '${existing.quantity}' : '');
    final priceController = TextEditingController(text: existing != null ? '${existing.unitPrice}' : '');
    final notesController = TextEditingController(text: existing?.notes ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Transaction' : 'Record Transaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Sale')),
                        selected: type == 'Sale',
                        selectedColor: Colors.green.shade100,
                        onSelected: (selected) {
                          if (selected) setDialogState(() => type = 'Sale');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Purchase')),
                        selected: type == 'Purchase',
                        selectedColor: Colors.red.shade100,
                        onSelected: (selected) {
                          if (selected) setDialogState(() => type = 'Purchase');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: itemType,
                  decoration: const InputDecoration(labelText: 'Item Category'),
                  items: itemTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => itemType = val);
                  },
                ),
                TextField(
                  controller: partyController,
                  decoration: InputDecoration(
                    labelText: type == 'Sale' ? 'Buyer / Customer Name' : 'Supplier / Vendor Name',
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Quantity'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Unit Price (Rs)'),
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
                final party = partyController.text.trim();
                final quantity = double.tryParse(quantityController.text) ?? 0;
                final price = double.tryParse(priceController.text) ?? 0;
                final total = quantity * price;

                if (quantity <= 0 || price < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid quantity and price')),
                  );
                  return;
                }

                final today = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
                final transaction = TransactionRecord(
                  id: isEdit ? existing.id : DateTime.now().millisecondsSinceEpoch.toString(),
                  date: isEdit ? existing.date : today,
                  type: type,
                  itemType: itemType,
                  partyName: party.isEmpty ? (type == 'Sale' ? 'General Customer' : 'Vendor') : party,
                  quantity: quantity,
                  unitPrice: price,
                  totalAmount: total,
                  notes: notesController.text.trim(),
                );

                if (isEdit) {
                  _repo.updateTransaction(transaction);
                } else {
                  _repo.addTransaction(transaction);
                }

                Navigator.pop(dialogContext);
              },
              child: Text(isEdit ? 'Update' : 'Save Transaction'),
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
        title: const Text('Delete Transaction?'),
        content: const Text('This financial transaction will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              _repo.deleteTransaction(id);
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

    final transactions = _repo.transactions.where((t) {
      if (_selectedFilter == 'All') return true;
      return t.type == _selectedFilter;
    }).toList();

    double totalSales = 0;
    double totalPurchases = 0;
    for (var t in _repo.transactions) {
      if (t.type == 'Sale') {
        totalSales += t.totalAmount;
      } else {
        totalPurchases += t.totalAmount;
      }
    }
    final netRevenue = totalSales - totalPurchases;

    return Scaffold(
      appBar: AppBar(title: const Text('Sales & Purchases')),
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
                  _summaryMiniCard('Total Sales', 'Rs ${totalSales.toStringAsFixed(0)}', Colors.green),
                  const SizedBox(width: 8),
                  _summaryMiniCard('Purchases', 'Rs ${totalPurchases.toStringAsFixed(0)}', Colors.red),
                  const SizedBox(width: 8),
                  _summaryMiniCard('Net Balance', 'Rs ${netRevenue.toStringAsFixed(0)}', netRevenue >= 0 ? green : Colors.red),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['All', 'Sale', 'Purchase'].map((f) {
                final isSelected = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(f == 'All' ? 'All' : '${f}s'),
                    selected: isSelected,
                    selectedColor: green.withOpacity(0.2),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilter = f);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text('No transactions recorded.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final item = transactions[index];
                      final isSale = item.type == 'Sale';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSale ? Colors.green.shade50 : Colors.red.shade50,
                              child: Icon(
                                isSale ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isSale ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(
                              '${item.type}: ${item.itemType}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              'Party: ${item.partyName}\n'
                              'Date: ${item.date} | Qty: ${item.quantity.toStringAsFixed(0)} @ Rs ${item.unitPrice.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${isSale ? "+" : "-"}Rs ${item.totalAmount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSale ? Colors.green : Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                PopupMenuButton<String>(
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

  Widget _summaryMiniCard(String title, String val, Color color) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              val,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
