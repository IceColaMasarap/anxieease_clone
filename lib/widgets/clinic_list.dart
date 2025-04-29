import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ClinicListView extends StatefulWidget {
  final List<Map<String, dynamic>> clinics;
  final Position? currentPosition;
  final Function(Map<String, dynamic>) onClinicSelected;
  final Function(String) onTravelModeChanged;
  final String selectedTravelMode;

  const ClinicListView({
    Key? key,
    required this.clinics,
    required this.currentPosition,
    required this.onClinicSelected,
    required this.onTravelModeChanged,
    required this.selectedTravelMode,
  }) : super(key: key);

  @override
  State<ClinicListView> createState() => _ClinicListViewState();
}

class _ClinicListViewState extends State<ClinicListView> {
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredClinics = [];

  @override
  void initState() {
    super.initState();
    _filteredClinics = widget.clinics;
  }

  @override
  void didUpdateWidget(ClinicListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clinics != widget.clinics) {
      _filterClinics();
    }
  }

  void _filterClinics() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredClinics = widget.clinics;
      });
    } else {
      setState(() {
        _filteredClinics = widget.clinics.where((clinic) {
          final name = clinic['name'].toString().toLowerCase();
          final vicinity = (clinic['vicinity'] ?? '').toString().toLowerCase();
          return name.contains(_searchQuery.toLowerCase()) ||
              vicinity.contains(_searchQuery.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a custom scroll view for better performance in a draggable sheet
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        // Handle indicator at top
        SliverToBoxAdapter(
          child: Column(
            children: [
              // Handle for dragging
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Header text
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Nearby Mental Health Clinics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[700],
                        ),
                      ),
                    ),
                    Text(
                      '${widget.clinics.length} clinics found',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Travel mode selection
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTravelModeButton(
                  icon: Icons.directions_car,
                  label: "Drive",
                  mode: "driving",
                ),
                _buildTravelModeButton(
                  icon: Icons.directions_walk,
                  label: "Walk",
                  mode: "walking",
                ),
                _buildTravelModeButton(
                  icon: Icons.directions_bike,
                  label: "Bike",
                  mode: "bicycling",
                ),
                _buildTravelModeButton(
                  icon: Icons.directions_transit,
                  label: "Transit",
                  mode: "transit",
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: Divider(),
        ),

        // Clinic list
        _filteredClinics.isEmpty
            ? SliverFillRemaining(
                child: _buildEmptyState(context),
              )
            : SliverPadding(
                padding: const EdgeInsets.only(bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final clinic = _filteredClinics[index];
                      return _buildClinicItem(context, clinic);
                    },
                    childCount: _filteredClinics.length,
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No clinics found nearby'
                : 'No results for "$_searchQuery"',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Try adjusting your search area or travel mode'
                : 'Try different keywords or clear your search',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
                _filterClinics();
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700],
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTravelModeButton({
    required IconData icon,
    required String label,
    required String mode,
  }) {
    final isSelected = widget.selectedTravelMode == mode;

    return GestureDetector(
      onTap: () => widget.onTravelModeChanged(mode),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.teal[700] : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.teal[700] : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicItem(BuildContext context, Map<String, dynamic> clinic) {
    // Determine if it's a hospital or clinic based on types
    bool isHospital = false;
    if (clinic['types'] != null) {
      final types = List<String>.from(clinic['types']);
      isHospital = types.contains('hospital');
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => widget.onClinicSelected(clinic),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isHospital ? Colors.red[50] : Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isHospital
                          ? Icons.local_hospital
                          : Icons.medical_services,
                      color: isHospital ? Colors.red[700] : Colors.blue[700],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clinic['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          clinic['vicinity'] ?? 'Address unavailable',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (clinic['rating'] != null)
                          _buildRatingBar(clinic['rating']),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // We'd calculate this based on real data in a real app
                  Row(
                    children: [
                      Icon(
                        _getTravelModeIcon(),
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '~10 min',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '3.2 km',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () => widget.onClinicSelected(clinic),
                    icon: const Icon(Icons.directions, size: 16),
                    label: const Text('Directions'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal[700],
                      side: BorderSide(color: Colors.teal[700]!),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBar(dynamic rating) {
    final double ratingValue =
        rating is int ? rating.toDouble() : (rating as double);
    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < ratingValue.floor()
                ? Icons.star
                : (index < ratingValue ? Icons.star_half : Icons.star_border),
            color: Colors.amber,
            size: 16,
          );
        }),
        const SizedBox(width: 4),
        Text(
          ratingValue.toStringAsFixed(1),
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getTravelModeIcon() {
    switch (widget.selectedTravelMode) {
      case 'walking':
        return Icons.directions_walk;
      case 'bicycling':
        return Icons.directions_bike;
      case 'transit':
        return Icons.directions_transit;
      case 'driving':
      default:
        return Icons.directions_car;
    }
  }
}
