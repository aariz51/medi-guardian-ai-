import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphic_card.dart';

class HealthTrackerScreen extends StatefulWidget {
  const HealthTrackerScreen({super.key});

  @override
  State<HealthTrackerScreen> createState() => _HealthTrackerScreenState();
}

class _HealthTrackerScreenState extends State<HealthTrackerScreen> {
  String bloodPressure = '120/80';
  String heartRate = '72';
  String temperature = '98.6';

  Future<void> _showHealthInputDialog(String type) async {
    final controller = TextEditingController();
    
    String? result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter $type'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter $type',
            suffixText: _getUnit(type),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        if (type == 'Blood Pressure') bloodPressure = result;
        if (type == 'Heart Rate') heartRate = result;
        if (type == 'Temperature') temperature = result;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Health metric saved successfully')),
      );
    }
  }

  String _getUnit(String type) {
    switch (type) {
      case 'Blood Pressure':
        return 'mmHg';
      case 'Heart Rate':
        return 'bpm';
      case 'Temperature':
        return '°F';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Tracker'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryGreen.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildMetricCard(
              context,
              'Blood Pressure',
              bloodPressure,
              'mmHg',
              Icons.favorite,
              AppTheme.danger,
            ),
            const SizedBox(height: 16),
            _buildMetricCard(
              context,
              'Heart Rate',
              heartRate,
              'bpm',
              Icons.favorite,
              AppTheme.danger,
            ),
            const SizedBox(height: 16),
            _buildMetricCard(
              context,
              'Temperature',
              temperature,
              '°F',
              Icons.thermostat,
              AppTheme.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return GlassmorphicCard(
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showHealthInputDialog(title),
          ),
        ],
      ),
    );
  }
}
