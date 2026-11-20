import 'package:flutter/material.dart';
import '../models/farm_models.dart';
import '../services/auth_service.dart';
import '../services/farm_repository.dart';
import 'login_screen.dart';
import 'modules/breeding_stock_screen.dart';
import 'modules/dashboard_overview_screen.dart';
import 'modules/egg_collection_screen.dart';
import 'modules/expenses_screen.dart';
import 'modules/incubation_screen.dart';
import 'modules/reports_backup_screen.dart';
import 'modules/stock_screen.dart';
import 'modules/transactions_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedTab = 0;
  final _repo = FarmRepository.instance;
  final _auth = AuthService.instance;
  String _recordsSearchQuery = '';

  final List<Map<String, dynamic>> modules = [
    {
      'title': 'Dashboard',
      'description': 'Live stock, daily activity and alerts',
      'icon': Icons.dashboard_outlined,
    },
    {
      'title': 'Breeding Stock',
      'description': 'Male, female, age, breed and batches',
      'icon': Icons.flutter_dash,
    },
    {
      'title': 'Egg Collection',
      'description': 'Collected, available, sold and damaged',
      'icon': Icons.egg_outlined,
    },
    {
      'title': 'Incubation & Hatching',
      'description': 'Egg setting, hatch results and chicks',
      'icon': Icons.thermostat_outlined,
    },
    {
      'title': 'Chick & Chicken Stock',
      'description': 'Newborn, growing, adult and sick chickens',
      'icon': Icons.inventory_2_outlined,
    },
    {
      'title': 'Sales & Purchases',
      'description': 'Eggs, chickens and farm supplies',
      'icon': Icons.shopping_cart_outlined,
    },
    {
      'title': 'Expenses',
      'description': 'Feed, medicine, salaries and costs',
      'icon': Icons.account_balance_wallet_outlined,
    },
    {
      'title': 'Reports & Backup',
      'description': 'Farm reports and data backup',
      'icon': Icons.description_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChanged);
    _auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  void _showAddEditRecordDialog([FarmRecord? existing]) {
    final isEdit = existing != null;
    final name = TextEditingController(text: existing?.flock ?? '');
    final eggs = TextEditingController(text: existing != null ? '${existing.eggs}' : '');
    final chicks = TextEditingController(text: existing != null ? '${existing.chicks}' : '');
    final expenses = TextEditingController(text: existing != null ? '${existing.expenses}' : '');
    final notes = TextEditingController(text: existing?.notes ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEdit ? 'Edit Daily Farm Record' : 'Add Daily Farm Record'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Batch / Shed Name *',
                  hintText: 'e.g. Shed A, Layer House 1',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: eggs,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Eggs Collected',
                  hintText: '0',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: chicks,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Chicks Produced',
                  hintText: '0',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: expenses,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Expenses (Rs)',
                  hintText: '0.00',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notes,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes',
                  hintText: 'Feed info, remarks...',
                ),
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
              final flockName = name.text.trim();
              final eggCount = int.tryParse(eggs.text) ?? 0;
              final chickCount = int.tryParse(chicks.text) ?? 0;
              final expenseAmount = double.tryParse(expenses.text) ?? 0.0;

              if (flockName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid batch or shed name'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final today = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
              final record = FarmRecord(
                id: isEdit ? existing.id : DateTime.now().millisecondsSinceEpoch.toString(),
                date: isEdit ? existing.date : today,
                flock: flockName,
                eggs: eggCount,
                chicks: chickCount,
                expenses: expenseAmount,
                notes: notes.text.trim(),
              );

              if (isEdit) {
                _repo.updateDailyRecord(record);
              } else {
                _repo.addDailyRecord(record);
              }

              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEdit ? 'Record updated successfully!' : 'New daily record saved successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(isEdit ? 'Update Record' : 'Save Record'),
          ),
        ],
      ),
    );
  }

  void _deleteRecord(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Record?'),
        content: const Text(
          'Are you sure you want to delete this daily record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              _repo.deleteDailyRecord(id);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Record deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout from your farm account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _auth.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _openModuleScreen(int index) {
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardOverviewScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const BreedingStockScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const EggCollectionScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const IncubationScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const StockScreen()));
        break;
      case 5:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen()));
        break;
      case 6:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen()));
        break;
      case 7:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsBackupScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF397A58);
    final currentUser = _auth.currentUser;
    final farmTitle = currentUser?.farmName ?? 'Poultry Farm Records';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              farmTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              currentUser != null ? 'Manager: ${currentUser.fullName}' : 'Farm Management System',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Farm System Alerts'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: const Text('System Operational'),
                        subtitle: Text('${_repo.totalLiveStock} live birds in stock'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.egg, color: Colors.orange),
                        title: const Text('Today Egg Target'),
                        subtitle: Text('${_repo.totalEggsCollected} eggs recorded'),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: selectedTab == 0
          ? dashboardPage()
          : selectedTab == 1
              ? recordsPage()
              : const ReportsBackupScreen(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: green,
        foregroundColor: Colors.white,
        onPressed: () => _showAddEditRecordDialog(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() {
            selectedTab = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            label: 'Records',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            label: 'Backup',
          ),
        ],
      ),
    );
  }

  Widget dashboardPage() {
    const green = Color(0xFF397A58);
    final user = _auth.currentUser;
    final userName = user?.fullName ?? 'Farm Manager';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Welcome back, $userName!',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Today: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _showAddEditRecordDialog(),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(
              'Add New Poultry Record',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'MANAGEMENT HUB',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modules.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 145,
          ),
          itemBuilder: (context, index) {
            final module = modules[index];

            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openModuleScreen(index),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        module['icon'] as IconData,
                        size: 26,
                        color: green,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        module['title'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          module['description'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 22),
        const Text(
          'Live Farm Statistics',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        statCard(
          'Total Eggs Collected',
          '${_repo.totalEggsCollected}',
          Icons.egg_outlined,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EggCollectionScreen())),
        ),
        statCard(
          'Chicks Produced',
          '${_repo.totalChicksProduced}',
          Icons.pets,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IncubationScreen())),
        ),
        statCard(
          'Live Bird Stock',
          '${_repo.totalLiveStock}',
          Icons.inventory_2_outlined,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StockScreen())),
        ),
        statCard(
          'Total Farm Expenses',
          'Rs ${_repo.totalExpensesAmount.toStringAsFixed(0)}',
          Icons.payments_outlined,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen())),
        ),
        statCard(
          'Net Sales Revenue',
          'Rs ${_repo.totalSalesAmount.toStringAsFixed(0)}',
          Icons.shopping_cart_outlined,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen())),
        ),
        statCard(
          'Net Profit / Loss',
          'Rs ${_repo.netProfit.toStringAsFixed(0)}',
          _repo.netProfit >= 0 ? Icons.trending_up : Icons.trending_down,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen())),
        ),
      ],
    );
  }

  Widget statCard(String title, String value, IconData icon, VoidCallback onTap) {
    const green = Color(0xFF397A58);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: green, size: 28),
        title: FittedBox(
          alignment: Alignment.centerLeft,
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        subtitle: Text(title, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      ),
    );
  }

  Widget recordsPage() {
    const green = Color(0xFF397A58);

    final filteredRecords = _repo.dailyRecords.where((r) {
      if (_recordsSearchQuery.isEmpty) return true;
      final q = _recordsSearchQuery.toLowerCase();
      return r.flock.toLowerCase().contains(q) || r.notes.toLowerCase().contains(q) || r.date.contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Poultry Daily Records',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search records by shed or date...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                onChanged: (val) => setState(() => _recordsSearchQuery = val),
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredRecords.isEmpty
              ? const Center(child: Text('No matching records found. Add a new record with +'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];
                    final noteText = record.notes.isNotEmpty ? '\nNotes: ${record.notes}' : '';

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.pets, color: green),
                          title: Text(record.flock, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(
                            'Date: ${record.date}\nEggs: ${record.eggs} | Chicks: ${record.chicks}\nExpenses: Rs ${record.expenses.toStringAsFixed(0)}$noteText',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 20),
                            onSelected: (val) {
                              if (val == 'edit') _showAddEditRecordDialog(record);
                              if (val == 'delete') _deleteRecord(record.id);
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
    );
  }
}
