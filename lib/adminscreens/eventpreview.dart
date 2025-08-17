import 'package:flutter/material.dart';
import 'package:xplore_app/Homepage/workshop.dart';

class EventPreview extends StatelessWidget {
  final Function(int) changeindex;
  const EventPreview({super.key, required this.changeindex});

  @override
  Widget build(BuildContext context) {
    return Workshop(
      changeindex: changeindex,
      preview: EventDraft.yes,
    );
  }
}
