import 'package:flutter/material.dart';
import '../../api/model/travel_model.dart';

class TransportSelector extends StatelessWidget {
  final TravelMode selectedMode;
  final Function(TravelMode) onSelected;

  const TransportSelector({
    super.key,
    required this.selectedMode,
    required this.onSelected,
  });

  Widget buildButton(
    IconData icon,
    TravelMode mode,
    TravelMode selectedMode,
    Function onTap,
  ) {
    bool isActive = mode == selectedMode;

    return GestureDetector(
      onTap: () => onTap(mode),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Icon(icon, color: isActive ? Colors.white : Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildButton(
          Icons.directions_car,
          TravelMode.car,
          selectedMode,
          onSelected,
        ),
        buildButton(
          Icons.two_wheeler,
          TravelMode.motorbike,
          selectedMode,
          onSelected,
        ),
        buildButton(
          Icons.directions_bike,
          TravelMode.bike,
          selectedMode,
          onSelected,
        ),
        buildButton(
          Icons.directions_walk,
          TravelMode.walk,
          selectedMode,
          onSelected,
        ),
      ],
    );
  }
}
