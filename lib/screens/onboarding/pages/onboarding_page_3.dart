import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../models/onboarding_data.dart';

class OnboardingPage3 extends StatefulWidget {
  const OnboardingPage3({super.key});

  @override
  State<OnboardingPage3> createState() => _OnboardingPage3State();
}

class _OnboardingPage3State extends State<OnboardingPage3> {
  final List<String> _selectedConditions = [];
  final List<String> _selectedAllergies = [];
  bool _hasInsurance = false;

  final List<String> _commonConditions = [
    'Hypertension',
    'Diabetes',
    'Asthma',
    'Heart Disease',
    'Thyroid Disorders',
    'Arthritis',
    'Chronic Pain',
    'Mental Health Conditions',
  ];

  final List<String> _commonAllergies = [
    'Penicillin',
    'Aspirin',
    'Ibuprofen',
    'Latex',
    'Peanuts',
    'Shellfish',
    'Dairy',
    'None',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medical Information',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Help us provide personalized medication safety alerts',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 32),
            
            // Medical Conditions
            const Text(
              'Medical Conditions (Select all that apply)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonConditions.map((condition) {
                final isSelected = _selectedConditions.contains(condition);
                return FilterChip(
                  label: Text(
                    condition,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.darkBlue,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedConditions.add(condition);
                      } else {
                        _selectedConditions.remove(condition);
                      }
                    });
                  },
                  selectedColor: AppTheme.primaryBlue,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppTheme.primaryBlue : Colors.grey.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            
            // Allergies
            const Text(
              'Known Allergies (Select all that apply)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonAllergies.map((allergy) {
                final isSelected = _selectedAllergies.contains(allergy);
                return FilterChip(
                  label: Text(
                    allergy,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.darkBlue,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected && allergy != 'None') {
                        _selectedAllergies.remove('None');
                        _selectedAllergies.add(allergy);
                      } else if (selected && allergy == 'None') {
                        _selectedAllergies.clear();
                        _selectedAllergies.add('None');
                      } else {
                        _selectedAllergies.remove(allergy);
                      }
                    });
                  },
                  selectedColor: AppTheme.primaryBlue,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppTheme.primaryBlue : Colors.grey.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            
            // Insurance
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Do you have health insurance?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Switch(
                    value: _hasInsurance,
                    onChanged: (value) {
                      setState(() {
                        _hasInsurance = value;
                      });
                    },
                    activeColor: Colors.white,
                    activeTrackColor: Colors.white.withOpacity(0.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Persist page answers into shared holder
            // (Collected again on page change and on final submit)
            Builder(builder: (_) {
              OnboardingData.current['conditions'] = _selectedConditions;
              OnboardingData.current['allergies'] = _selectedAllergies;
              OnboardingData.current['has_insurance'] = _hasInsurance;
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}