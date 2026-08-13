import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/notification/notification_bloc.dart';
import 'package:xplore_app/config/theme.dart';

class HeadSendNotificationScreen extends StatefulWidget {
  final String? eventId;
  const HeadSendNotificationScreen({super.key, this.eventId});

  @override
  State<HeadSendNotificationScreen> createState() => _HeadSendNotificationScreenState();
}

class _HeadSendNotificationScreenState extends State<HeadSendNotificationScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _targetType = 'all'; // 'all' or 'event'

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and message body are required.")),
      );
      return;
    }

    context.read<NotificationBloc>().add(SendNotificationRequested(
          targetType: _targetType,
          eventId: widget.eventId,
          title: title,
          message: message,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "BROADCAST ANNOUNCEMENT",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationSendSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Announcement sent successfully!"), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          } else if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text("ALL STUDENTS", style: TextStyle(fontWeight: FontWeight.bold))),
                    selected: _targetType == 'all',
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.cardColor,
                    onSelected: (val) {
                      if (val) setState(() => _targetType = 'all');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text("EVENT PARTICIPANTS", style: TextStyle(fontWeight: FontWeight.bold))),
                    selected: _targetType == 'event',
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.cardColor,
                    onSelected: (val) {
                      if (val) setState(() => _targetType = 'event');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Announcement Heading"),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _messageController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Message Body..."),
            ),
            const SizedBox(height: 30),

            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                final isLoading = state is NotificationLoading;
                return ElevatedButton(
                  onPressed: isLoading ? null : _handleSend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                      : const Text("SEND ANNOUNCEMENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      filled: true,
      fillColor: AppColors.cardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.primary)),
    );
  }
}
