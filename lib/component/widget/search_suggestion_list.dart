import 'package:flutter/material.dart';

class SearchSuggestionList extends StatelessWidget {
  final List<dynamic> results;
  final Function(dynamic) onSelect;

  const SearchSuggestionList({
    super.key,
    required this.results,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return SizedBox();

    return Container(
      constraints: BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: results.length,
        itemBuilder: (context, index) {
          final place = results[index];

          return ListTile(
            leading: Icon(Icons.location_on),
            title: Text(
              place['display_name'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              onSelect(place);
            },
          );
        },
      ),
    );
  }
}
