import 'package:flutter/material.dart';

List<Widget> buildItemsList(List items) {
  if (items.isEmpty) return [];

  final visibleItems = items.take(2).toList();

  final widgets = visibleItems.map<Widget>((item) {
    return Text(
      "${item.quantity}x ${item.productName ?? 'Item'}",
      style: TextStyle(color: Colors.grey[600], fontSize: 13),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }).toList();

  if (items.length > 2) {
    widgets.add(
      Text(
        "+${items.length - 2} itens",
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  return widgets;
}

Widget buildProductCircle(String? url) {
  return Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: Colors.black,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
      image: url != null
          ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
          : null,
    ),
    child: url == null
        ? const Icon(Icons.fastfood, size: 18, color: Colors.white)
        : null,
  );
}
