import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_constants.dart';

/// Widget for selecting soccer positions
class PositionSelectorWidget extends StatefulWidget {
  final SoccerPosition? selectedPosition;
  final Function(SoccerPosition) onPositionSelected;
  final String title;
  final bool allowMultiple;
  final List<SoccerPosition> selectedPositions;
  final Function(List<SoccerPosition>)? onMultiplePositionsSelected;

  const PositionSelectorWidget({
    super.key,
    this.selectedPosition,
    required this.onPositionSelected,
    this.title = 'Select Position',
    this.allowMultiple = false,
    this.selectedPositions = const [],
    this.onMultiplePositionsSelected,
  });

  @override
  State<PositionSelectorWidget> createState() => _PositionSelectorWidgetState();
}

class _PositionSelectorWidgetState extends State<PositionSelectorWidget> {
  final Map<String, List<SoccerPosition>> _positionsByCategory = {
    'Goalkeeper': SoccerPosition.getPositionsByCategory('Goalkeeper'),
    'Defender': SoccerPosition.getPositionsByCategory('Defender'),
    'Midfielder': SoccerPosition.getPositionsByCategory('Midfielder'),
    'Forward': SoccerPosition.getPositionsByCategory('Forward'),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.allowMultiple
              ? 'Select all positions you can play'
              : 'Choose your primary position',
          style: const TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        
        // Position categories
        Column(
          children: _positionsByCategory.entries.map((entry) {
            return _buildPositionCategory(entry.key, entry.value);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPositionCategory(String category, List<SoccerPosition> positions) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E1E1E).withValues(alpha: 0.8),
            const Color(0xFF2A2A2A).withValues(alpha: 0.6),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(category),
                  color: const Color(0xFF4CAF50),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Position chips
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: positions.map((position) {
                final isSelected = widget.allowMultiple
                    ? widget.selectedPositions.contains(position)
                    : widget.selectedPosition == position;
                
                return _buildPositionChip(position, isSelected);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionChip(SoccerPosition position, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        
        if (widget.allowMultiple) {
          List<SoccerPosition> newSelections = List.from(widget.selectedPositions);
          if (isSelected) {
            newSelections.remove(position);
          } else {
            newSelections.add(position);
          }
          widget.onMultiplePositionsSelected?.call(newSelections);
        } else {
          widget.onPositionSelected(position);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                )
              : null,
          color: isSelected ? null : const Color(0xFF333333),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFF444444),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              position.code,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFBBBBBB),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              position.displayName,
              style: TextStyle(
                color: isSelected 
                    ? Colors.white.withValues(alpha: 0.9)
                    : const Color(0xFF888888),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Goalkeeper':
        return Icons.sports_volleyball;
      case 'Defender':
        return Icons.shield;
      case 'Midfielder':
        return Icons.compare_arrows;
      case 'Forward':
        return Icons.sports_soccer;
      default:
        return Icons.sports;
    }
  }
}

/// Position selection modal for full-screen selection
class PositionSelectionModal extends StatefulWidget {
  final SoccerPosition? initialPosition;
  final bool allowMultiple;
  final List<SoccerPosition> initialPositions;
  final String title;

  const PositionSelectionModal({
    super.key,
    this.initialPosition,
    this.allowMultiple = false,
    this.initialPositions = const [],
    this.title = 'Select Position',
  });

  @override
  State<PositionSelectionModal> createState() => _PositionSelectionModalState();
}

class _PositionSelectionModalState extends State<PositionSelectionModal> {
  SoccerPosition? _selectedPosition;
  List<SoccerPosition> _selectedPositions = [];

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
    _selectedPositions = List.from(widget.initialPositions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF9E9E9E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _canConfirm() ? _confirmSelection : null,
            child: Text(
              'Done',
              style: TextStyle(
                color: _canConfirm() ? const Color(0xFF4CAF50) : const Color(0xFF666666),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A1A),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: PositionSelectorWidget(
            selectedPosition: _selectedPosition,
            selectedPositions: _selectedPositions,
            allowMultiple: widget.allowMultiple,
            title: widget.allowMultiple ? 'Select Positions' : 'Select Primary Position',
            onPositionSelected: (position) {
              setState(() {
                _selectedPosition = position;
              });
            },
            onMultiplePositionsSelected: (positions) {
              setState(() {
                _selectedPositions = positions;
              });
            },
          ),
        ),
      ),
    );
  }

  bool _canConfirm() {
    return widget.allowMultiple 
        ? _selectedPositions.isNotEmpty
        : _selectedPosition != null;
  }

  void _confirmSelection() {
    if (widget.allowMultiple) {
      Navigator.of(context).pop(_selectedPositions);
    } else {
      Navigator.of(context).pop(_selectedPosition);
    }
  }
}

/// Helper function to show position selection modal
Future<T?> showPositionSelectionModal<T>(
  BuildContext context, {
  SoccerPosition? initialPosition,
  List<SoccerPosition> initialPositions = const [],
  bool allowMultiple = false,
  String title = 'Select Position',
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return PositionSelectionModal(
          initialPosition: initialPosition,
          initialPositions: initialPositions,
          allowMultiple: allowMultiple,
          title: title,
        );
      },
    ),
  );
}