import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../services/farm_repository.dart';
import '../../services/google_drive_service.dart';

class ReportsBackupScreen extends StatefulWidget {
  const ReportsBackupScreen({super.key});

  @override
  State<ReportsBackupScreen> createState() => _ReportsBackupScreenState();
}

class _ReportsBackupScreenState extends State<ReportsBackupScreen> {
  final _repo = FarmRepository.instance;
  final _driveService = GoogleDriveService.instance;
  bool _isLoadingDrive = false;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChanged);
    _driveService.addListener(_onDriveChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    _driveService.removeListener(_onDriveChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  void _onDriveChanged() {
    if (mounted) setState(() {});
  }

  void _handleGoogleDriveUpload() async {
    setState(() => _isLoadingDrive = true);
    final jsonContent = _repo.exportBackupAsJson();
    final result = await _driveService.uploadBackup(jsonContent);
    setState(() => _isLoadingDrive = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] as String),
          backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _handleGoogleDriveRestore() async {
    setState(() => _isLoadingDrive = true);
    final result = await _driveService.restoreBackup();
    setState(() => _isLoadingDrive = false);

    if (mounted) {
      if (result['success'] == true && result['json'] != null) {
        final restored = _repo.importBackupFromJson(result['json'] as String);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              restored
                  ? 'Backup restored successfully from Google Drive!'
                  : 'Downloaded backup JSON invalid.',
            ),
            backgroundColor: restored ? Colors.green : Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] as String),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showGoogleConsoleInstructions() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Google Drive Console Setup Guide'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Follow these steps to connect your app with Google Drive:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('1. Go to console.cloud.google.com and create a project named "PoultryFarm".'),
              SizedBox(height: 6),
              Text('2. Enable "Google Drive API" in APIs & Services > Library.'),
              SizedBox(height: 6),
              Text('3. Configure OAuth Consent Screen with scope: .../auth/drive.appdata.'),
              SizedBox(height: 6),
              Text('4. Create Credentials > OAuth 2.0 Client ID for Android/Web.'),
              SizedBox(height: 6),
              Text('5. For Android: Paste Package Name and SHA-1 fingerprint from Android Studio.'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF397A58),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }

  void _showGeneratedReport() {
    final user = AuthService.instance.currentUser;
    final farmName = user?.farmName ?? 'Green Valley Poultry';
    final manager = user?.fullName ?? 'Farm Manager';
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    final reportText = StringBuffer();
    reportText.writeln('========================================');
    reportText.writeln('       POULTRY FARM SUMMARY REPORT      ');
    reportText.writeln('========================================');
    reportText.writeln('Farm Name: $farmName');
    reportText.writeln('Manager: $manager');
    reportText.writeln('Generated Date: $dateStr');
    reportText.writeln('----------------------------------------');
    reportText.writeln('OVERALL METRICS & INVENTORY:');
    reportText.writeln('  - Breeding Stock Birds: ${_repo.totalBreedingBirds}');
    reportText.writeln('  - Live Chicken Stock: ${_repo.totalLiveStock}');
    reportText.writeln('  - Total Eggs Collected: ${_repo.totalEggsCollected}');
    reportText.writeln('  - Total Chicks Produced: ${_repo.totalChicksProduced}');
    reportText.writeln('----------------------------------------');
    reportText.writeln('FINANCIAL SUMMARY (Rs):');
    reportText.writeln('  - Total Sales Revenue: Rs ${_repo.totalSalesAmount.toStringAsFixed(0)}');
    reportText.writeln('  - Total Expenses / Costs: Rs ${_repo.totalExpensesAmount.toStringAsFixed(0)}');
    reportText.writeln('  - Net Profit / Loss: Rs ${_repo.netProfit.toStringAsFixed(0)}');
    reportText.writeln('----------------------------------------');
    reportText.writeln('RECORD COUNTS:');
    reportText.writeln('  - Daily Records: ${_repo.dailyRecords.length}');
    reportText.writeln('  - Breeding Batches: ${_repo.breedingStocks.length}');
    reportText.writeln('  - Egg Batches: ${_repo.eggRecords.length}');
    reportText.writeln('  - Incubation Batches: ${_repo.incubationRecords.length}');
    reportText.writeln('  - Chicken Stock Batches: ${_repo.stockRecords.length}');
    reportText.writeln('  - Financial Transactions: ${_repo.transactions.length}');
    reportText.writeln('  - Expense Entries: ${_repo.expenses.length}');
    reportText.writeln('========================================');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Farm Executive Report',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(),
            Container(
              constraints: const BoxConstraints(maxHeight: 250),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  reportText.toString(),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF397A58),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: reportText.toString()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report copied to clipboard!')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy Report Summary'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportJsonBackup() {
    final jsonStr = _repo.exportBackupAsJson();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export JSON Data Backup'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your farm records formatted as JSON data:'),
              const SizedBox(height: 10),
              Container(
                constraints: const BoxConstraints(maxHeight: 250),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    jsonStr,
                    style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF397A58),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonStr));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup JSON copied to clipboard!')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy JSON'),
          ),
        ],
      ),
    );
  }

  void _importJsonBackup() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Data from Backup JSON'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paste your exported JSON backup code below to restore:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 8,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              decoration: const InputDecoration(
                hintText: '{\n  "exportedAt": "...",\n  "dailyRecords": [...]\n}',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF397A58),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final success = _repo.importBackupFromJson(controller.text.trim());
              Navigator.pop(ctx);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup restored successfully!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to parse backup JSON. Please check input.')),
                );
              }
            },
            child: const Text('Restore Backup'),
          ),
        ],
      ),
    );
  }

  void _confirmResetData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Farm Records?'),
        content: const Text(
          'Warning: This will delete all records across all modules permanently. This action cannot be undone unless you have a backup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              _repo.clearAllData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All farm records have been cleared.')),
              );
            },
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF397A58);

    final totalRecords = _repo.dailyRecords.length +
        _repo.breedingStocks.length +
        _repo.eggRecords.length +
        _repo.incubationRecords.length +
        _repo.stockRecords.length +
        _repo.transactions.length +
        _repo.expenses.length;

    final driveAccount = _driveService.account;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Backup')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.cloud_done_outlined,
            size: 65,
            color: green,
          ),
          const SizedBox(height: 14),
          const Text(
            'Farm Reports & Cloud Sync',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Keep your poultry farm records safe with Google Drive sync.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Google Drive Account Status Card
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: green.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFEAF4ED),
                        child: Icon(Icons.cloud, color: green),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Google Drive Cloud Backup',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              driveAccount != null ? driveAccount.email : 'Not connected',
                              style: TextStyle(
                                fontSize: 12,
                                color: driveAccount != null ? green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _isLoadingDrive
                              ? null
                              : () async {
                                  if (driveAccount == null) {
                                    await _driveService.signIn();
                                  } else {
                                    await _driveService.signOut();
                                  }
                                },
                          icon: Icon(driveAccount == null ? Icons.login : Icons.logout, size: 18),
                          label: Text(driveAccount == null ? 'Connect Google' : 'Disconnect'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _showGoogleConsoleInstructions,
                        icon: const Icon(Icons.help_outline, color: green),
                        tooltip: 'Google Console Setup Guide',
                      ),
                    ],
                  ),
                  if (driveAccount != null) ...[
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: green),
                            ),
                            onPressed: _isLoadingDrive ? null : _handleGoogleDriveUpload,
                            icon: const Icon(Icons.cloud_upload_outlined, color: green, size: 18),
                            label: const Text('Backup to Drive', style: TextStyle(color: green, fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: green),
                            ),
                            onPressed: _isLoadingDrive ? null : _handleGoogleDriveRestore,
                            icon: const Icon(Icons.cloud_download_outlined, color: green, size: 18),
                            label: const Text('Restore Drive', style: TextStyle(color: green, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Card(
            elevation: 1,
            child: ListTile(
              leading: const Icon(Icons.storage, color: green, size: 30),
              title: const Text('Total Database Entries', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('$totalRecords records stored across 7 modules'),
            ),
          ),
          const SizedBox(height: 20),
          const Text('REPORTS & ANALYTICS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(15),
              alignment: Alignment.centerLeft,
            ),
            onPressed: _showGeneratedReport,
            icon: const Icon(Icons.description_outlined),
            label: const Text('Generate Executive Farm Report', style: TextStyle(fontSize: 15)),
          ),
          const SizedBox(height: 20),
          const Text('MANUAL BACKUP & DATA MANAGEMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(15),
              alignment: Alignment.centerLeft,
              side: const BorderSide(color: green),
            ),
            onPressed: _exportJsonBackup,
            icon: const Icon(Icons.copy, color: green),
            label: const Text('Export JSON Backup (Copy Data)', style: TextStyle(color: green, fontSize: 15)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(15),
              alignment: Alignment.centerLeft,
              side: const BorderSide(color: green),
            ),
            onPressed: _importJsonBackup,
            icon: const Icon(Icons.paste, color: green),
            label: const Text('Restore Data from Backup JSON', style: TextStyle(color: green, fontSize: 15)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(15),
              alignment: Alignment.centerLeft,
            ),
            onPressed: () {
              _repo.loadSampleDemoData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sample demo data loaded successfully!')),
              );
            },
            icon: const Icon(Icons.refresh, color: Colors.blue),
            label: const Text('Load Sample Demo Data', style: TextStyle(color: Colors.blue, fontSize: 15)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(15),
              alignment: Alignment.centerLeft,
              side: const BorderSide(color: Colors.red),
            ),
            onPressed: _confirmResetData,
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            label: const Text('Reset All Farm Data', style: TextStyle(color: Colors.red, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
