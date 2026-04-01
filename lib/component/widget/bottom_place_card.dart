import 'package:flutter/material.dart';

class BottomPlaceCard extends StatelessWidget {
  final Map<String, dynamic> place;
  final VoidCallback onClose;
  final VoidCallback onDirection;
  final double? distance;
  final double? duration;

  const BottomPlaceCard({
    super.key,
    required this.place,
    required this.onClose,
    required this.onDirection,
    this.distance,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            place['display_name'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: size.height * 0.01),

          if (distance != null && duration != null)
            Text(
              "${(distance! / 1000).toStringAsFixed(1)} km | ${(duration! / 60).round()} phút",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: size.width * 0.035,
              ),
            ),

          SizedBox(height: size.height * 0.01),

          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onDirection,
                icon: Icon(Icons.directions),
                label: Text("Chỉ đường"),
                style: ElevatedButton.styleFrom(shape: StadiumBorder()),
              ),

              SizedBox(width: size.width * 0.17),

              OutlinedButton.icon(
                onPressed: onClose,
                icon: Icon(Icons.close),
                label: Text("Đóng"),
                style: OutlinedButton.styleFrom(shape: StadiumBorder()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
