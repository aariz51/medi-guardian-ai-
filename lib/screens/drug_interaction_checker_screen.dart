import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/drug_interaction.dart';

class DrugInteractionCheckerScreen extends StatefulWidget {
  const DrugInteractionCheckerScreen({super.key});

  @override
  State<DrugInteractionCheckerScreen> createState() => _DrugInteractionCheckerScreenState();
}

class _DrugInteractionCheckerScreenState extends State<DrugInteractionCheckerScreen> {
  final _drug1Controller = TextEditingController();
  final _drug2Controller = TextEditingController();
  bool _isLoading = false;
  List<DrugInteraction> _interactions = [];

  final List<String> _recentSearches = [
    'Aspirin',
    'Paracetamol',
    'Ibuprofen',
    'Metformin',
    'Atorvastatin',
  ];

  @override
  void dispose() {
    _drug1Controller.dispose();
    _drug2Controller.dispose();
    super.dispose();
  }

  Future<void> _checkInteractions() async {
    if (_drug1Controller.text.isEmpty || _drug2Controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both medications')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock data - in production, fetch from Supabase
    setState(() {
      _interactions = [
        DrugInteraction(
          drug1: _drug1Controller.text,
          drug2: _drug2Controller.text,
          description: 'These medications may interact and cause side effects.',
          severity: InteractionSeverity.moderate,
          mechanism: 'Pharmacokinetic interaction',
          recommendations: 'Consult your healthcare provider before taking these together.',
          signs: ['Dizziness', 'Nausea', 'Increased heart rate'],
        ),
      ];
      _isLoading = false;
    });
  }

  void _selectDrug(String drug) {
    if (_drug1Controller.text.isEmpty) {
      _drug1Controller.text = drug;
    } else {
      _drug2Controller.text = drug;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drug Interaction Checker'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Check for potential interactions between medications',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Drug 1 Input
              TextField(
                controller: _drug1Controller,
                decoration: const InputDecoration(
                  labelText: 'First Medication',
                  prefixIcon: Icon(Icons.medication),
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),

              // Drug 2 Input
              TextField(
                controller: _drug2Controller,
                decoration: const InputDecoration(
                  labelText: 'Second Medication',
                  prefixIcon: Icon(Icons.medication),
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 30),

              // Check Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _checkInteractions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text(
                          'Check Interaction',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 30),

              // Recent Searches
              const Text(
                'Recent Searches',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _recentSearches.map((drug) {
                  return Chip(
                    label: Text(drug),
                    onDeleted: () => _selectDrug(drug),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // Results
              if (_interactions.isNotEmpty) ...[
                const Text(
                  'Interaction Results',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ..._interactions.map((interaction) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: interaction.getSeverityColor().withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  interaction.getSeverityText(),
                                  style: TextStyle(
                                    color: interaction.getSeverityColor(),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${interaction.drug1} + ${interaction.drug2}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(interaction.description),
                          const SizedBox(height: 16),
                          const Text(
                            'Recommendations:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(interaction.recommendations),
                          if (interaction.signs.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Watch for:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            ...interaction.signs.map((sign) => Padding(
                                  padding: const EdgeInsets.only(left: 8, top: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning, size: 16, color: Colors.orange),
                                      const SizedBox(width: 8),
                                      Text(sign),
                                    ],
                                  ),
                                )),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
