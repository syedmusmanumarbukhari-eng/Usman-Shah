import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/farm_repository.dart';

class DashboardOverviewScreen extends StatefulWidget {
  const DashboardOverviewScreen({super.key});

  @override
  State<DashboardOverviewScreen> createState() => _DashboardOverviewScreenState();
}

class _DashboardOverviewScreenState extends State<DashboardOverviewScreen> {
  final _repo = FarmRepository.instance;
  final _auth = AuthService.instance;

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

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF397A58);
    final user = _auth.currentUser;
    final farmName = user?.farmName ?? 'Green Valley Poultry';
    final manager = user?.fullName ?? 'Farm Manager';

    final totalLive = _repo.totalLiveStock;
    final totalBreeding = _repo.totalBreedingBirds;
    final totalEggs = _repo.totalEggsCollected;
    final totalChicks = _repo.totalChicksProduced;
    final netProfit = _repo.netProfit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Dashboard Overview'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Card(
            color: green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pets, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              farmName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Manager: $manager',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white30, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _headerStatItem('Live Birds', '$totalLive', Colors.white),
                      _headerStatItem('Eggs Today', '$totalEggs', Colors.white),
                      _headerStatItem('Net Profit', 'Rs ${netProfit.toStringAsFixed(0)}', Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'FARM HEALTH & LIVE METRICS',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 10),

          // Metric Progress Bars
          _metricProgressCard(
            title: 'Flock Capacity & Stock Level',
            value: '$totalLive Birds',
            progress: 0.85,
            color: green,
            subtitle: '$totalBreeding breeding birds | ${_repo.stockRecords.length} sheds active',
          ),
          const SizedBox(height: 10),
          _metricProgressCard(
            title: 'Egg Production Rate',
            value: '$totalEggs Collected',
            progress: 0.78,
            color: Colors.orange,
            subtitle: '${_repo.eggRecords.length} egg collection batches logged',
          ),
          const SizedBox(height: 10),
          _metricProgressCard(
            title: 'Hatchery Productivity',
            value: '$totalChicks Chicks',
            progress: 0.90,
            color: Colors.blue,
            subtitle: '${_repo.incubationRecords.length} incubation batches active',
          ),

          const SizedBox(height: 20),
          const Text(
            'RECENT DAILY LOGS',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 10),

          if (_repo.dailyRecords.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No recent daily logs available.'),
              ),
            )
          else
            ..._repo.dailyRecords.take(5).map((r) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEAF4ED),
                      child: Icon(Icons.receipt_long, color: green),
                    ),
                    title: Text(r.flock, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('Date: ${r.date} | Eggs: ${r.eggs} | Chicks: ${r.chicks}\nExpenses: Rs ${r.expenses.toStringAsFixed(0)}'),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _headerStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _metricProgressCard({
    required String title,
    required String value,
    required double progress,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
