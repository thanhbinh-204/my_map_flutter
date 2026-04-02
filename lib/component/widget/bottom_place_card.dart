import 'package:flutter/material.dart';
import '../widget/transport_selector.dart';
import '../../api/model/travel_model.dart';

class BottomPlaceCard extends StatelessWidget {
  final Map<String, dynamic> place;
  final VoidCallback onClose;
  final VoidCallback onDirection;
  final double? distance;
  final double? duration;
  final TravelMode selectedMode;
  final Function(TravelMode) onTransportChange;

  const BottomPlaceCard({
    super.key,
    required this.place,
    required this.onClose,
    required this.onDirection,
    this.distance,
    this.duration,
    required this.selectedMode,
    required this.onTransportChange,
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
          // hiển thị địa chỉ vừa search
          Text(
            place['display_name'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: size.height * 0.015),

          //chọn phương tiện
          TransportSelector(
            selectedMode: selectedMode,
            onSelected: onTransportChange,
          ),

          SizedBox(height: size.height * 0.01),

          // hiển thị khoảng cách và thời gian tới điểm đến
          if (distance != null && duration != null)
            Text(
              "${(distance! / 1000).toStringAsFixed(1)} km | ${(duration! / 60).round()} phút",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: size.width * 0.035,
              ),
            ),

          SizedBox(height: size.height * 0.015),

          // 2 nút
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
