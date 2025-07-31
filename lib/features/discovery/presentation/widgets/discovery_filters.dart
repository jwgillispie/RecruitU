import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// Widget for filtering discovery results
class DiscoveryFilters extends StatelessWidget {
  final List<SoccerPosition> selectedPositions;
  final List<DivisionLevel> selectedDivisions;
  final String? selectedRegion;
  final ValueChanged<List<SoccerPosition>> onPositionsChanged;
  final ValueChanged<List<DivisionLevel>> onDivisionsChanged;
  final ValueChanged<String?> onRegionChanged;

  const DiscoveryFilters({
    super.key,
    required this.selectedPositions,
    required this.selectedDivisions,
    this.selectedRegion,
    required this.onPositionsChanged,
    required this.onDivisionsChanged,
    required this.onRegionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF2A2A2A),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Positions Filter
          const Text(
            'Positions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: SoccerPosition.values.map((position) {
              final isSelected = selectedPositions.contains(position);
              return GestureDetector(
                onTap: () {
                  List<SoccerPosition> newPositions = List.from(selectedPositions);
                  if (isSelected) {
                    newPositions.remove(position);
                  } else {
                    newPositions.add(position);
                  }
                  onPositionsChanged(newPositions);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF424242),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    position.code,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Divisions Filter
          const Text(
            'Divisions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: DivisionLevel.values.map((division) {
              final isSelected = selectedDivisions.contains(division);
              return GestureDetector(
                onTap: () {
                  List<DivisionLevel> newDivisions = List.from(selectedDivisions);
                  if (isSelected) {
                    newDivisions.remove(division);
                  } else {
                    newDivisions.add(division);
                  }
                  onDivisionsChanged(newDivisions);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF424242),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    division.displayName.split(' ').last, // Show just "I", "II", etc.
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Region Filter
          const Text(
            'Region',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF424242),
                width: 1,
              ),
            ),
            child: DropdownButton<String>(
              value: selectedRegion,
              hint: const Text(
                'Select Region',
                style: TextStyle(color: Color(0xFF9E9E9E)),
              ),
              isExpanded: true,
              dropdownColor: const Color(0xFF2A2A2A),
              underline: const SizedBox(),
              style: const TextStyle(color: Colors.white),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF9E9E9E),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    'All Regions',
                    style: TextStyle(color: Color(0xFF9E9E9E)),
                  ),
                ),
                ...AppConstants.usRegions.map((region) {
                  return DropdownMenuItem<String>(
                    value: region,
                    child: Text(
                      region,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }),
              ],
              onChanged: onRegionChanged,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Clear filters button
          if (selectedPositions.isNotEmpty || 
              selectedDivisions.isNotEmpty || 
              selectedRegion != null)
            Center(
              child: TextButton(
                onPressed: () {
                  onPositionsChanged([]);
                  onDivisionsChanged([]);
                  onRegionChanged(null);
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4CAF50),
                ),
                child: const Text(
                  'Clear All Filters',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}