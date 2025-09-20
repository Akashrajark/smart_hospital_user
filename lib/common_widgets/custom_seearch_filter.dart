import 'package:flutter/material.dart';

class CustomSearchFilter extends StatefulWidget {
  final Function(String) onSearch;
  final Function() onFilter;
  const CustomSearchFilter({super.key, required this.onSearch, required this.onFilter});

  @override
  State<CustomSearchFilter> createState() => _CustomSearchFilterState();
}

class _CustomSearchFilterState extends State<CustomSearchFilter> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12), width: 3),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) {
                widget.onSearch(value);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search appointments, patients, doctors...',
                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6), letterSpacing: 0.1),
                errorBorder: OutlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                prefixIcon: Container(
                  padding: EdgeInsets.all(10),
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.clear_rounded, color: theme.colorScheme.error),
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.all(0),
                            minimumSize: Size(40, 40),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            widget.onSearch.call('');
                          },
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
        ),
        Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.12), width: 3),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: widget.onFilter,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Icon(Icons.filter_list, color: theme.colorScheme.secondary),
            ),
          ),
        ),
      ],
    );
  }
}
