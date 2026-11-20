import 'package:flutter/material.dart';
import '../../models/farm_models.dart';
import '../../services/farm_repository.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _repo = FarmRepository.instance;
  String _selectedCategory = 'All';

  final List<String> categories = ['Feed', 'Medicine', 'Salaries', 'Utilities', 'Equipment', 'Other'];

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

  void _showAddEditDialog([ExpenseRecord? existing]) {
    final isEdit = existing != null;
    String category = existing?.category ?? 'Feed';
    final amountController = TextEditingController(text: existing != null ? '${existing.amount}' : '');
    final paidToController = TextEditingController(text: existing?.paidTo ?? '');
    final notesController = TextEditingController(text: existing?.notes ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Expense Record' : 'Add Farm Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Expense Category'),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => category = val);
                  },
                ),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount (Rs)'),
                ),
                TextField(
                  controller: paidToController,
                  decoration: const InputDecoration(labelText: 'Paid To (Vendor / Employee)'),
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Additional Notes'),
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
                final amount = double.tryParse(amountController.text) ?? 0;
                final paidTo = paidToController.text.trim();

                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid expense amount')),
                  );
                  return;
                }

                final today = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
                final expense = ExpenseRecord(
                  id: isEdit ? existing.id : DateTime.now().millisecondsSinceEpoch.toString(),
                  date: isEdit ? existing.date : today,
                  category: category,
                  amount: amount,
                  paidTo: paidTo,
                  notes: notesController.text.trim(),
                );

                if (isEdit) {
                  _repo.updateExpense(expense);
                } else {
                  _repo.addExpense(expense);
                }

                Navigator.pop(dialogContext);
              },
              child: Text(isEdit ? 'Update' : 'Save Expense'),
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
        title: const Text('Delete Expense?'),
        content: const Text('This expense record will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              _repo.deleteExpense(id);
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

    final expenses = _repo.expenses.where((e) {
      if (_selectedCategory == 'All') return true;
      return e.category == _selectedCategory;
    }).toList();

    double filteredTotal = 0;
    for (var e in expenses) {
      filteredTotal += e.amount;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Farm Expenses')),
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Text(
                            _selectedCategory == 'All' ? 'Total Overall Expenses' : 'Total $_selectedCategory Expenses',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Rs ${filteredTotal.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: ['All', ...categories].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: green.withOpacity(0.2),
                    checkmarkColor: green,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: expenses.isEmpty
                ? const Center(child: Text('No expenses recorded in this category.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final item = expenses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFFDE8E8),
                              child: Icon(Icons.account_balance_wallet_outlined, color: Colors.red),
                            ),
                            title: Text(item.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              'Paid To: ${item.paidTo.isEmpty ? "N/A" : item.paidTo} | Date: ${item.date}\n'
                              '${item.notes.isNotEmpty ? "Notes: ${item.notes}" : ""}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Rs ${item.amount.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14),
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
}
