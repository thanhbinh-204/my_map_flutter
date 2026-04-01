import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: Colors.grey),

          SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Search location...",
                border: InputBorder.none,
                suffixIcon:
                    controller.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.close),
                          onPressed: onClear,
                        )
                        : null,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
