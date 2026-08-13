import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/lost_found/lost_found_bloc.dart';
import 'package:xplore_app/config/theme.dart';

class CreateLostFoundScreen extends StatefulWidget {
  const CreateLostFoundScreen({super.key});

  @override
  State<CreateLostFoundScreen> createState() => _CreateLostFoundScreenState();
}

class _CreateLostFoundScreenState extends State<CreateLostFoundScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _whatsappController = TextEditingController();
  String _type = 'Lost'; // 'Lost' or 'Found'

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and description are required.")),
      );
      return;
    }

    context.read<LostFoundBloc>().add(CreateLostFoundPost(
          title: title,
          description: description,
          type: _type,
          imageUrl: _imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null,
          whatsapp: _whatsappController.text.trim().isNotEmpty ? _whatsappController.text.trim() : null,
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
          "POST LOST/FOUND ITEM",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<LostFoundBloc, LostFoundState>(
        listener: (context, state) {
          if (state is LostFoundPostCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.pop(context, true);
          } else if (state is LostFoundError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Type Selector
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text("LOST ITEM", style: TextStyle(fontWeight: FontWeight.bold))),
                    selected: _type == 'Lost',
                    selectedColor: Colors.red[700],
                    backgroundColor: AppColors.cardColor,
                    onSelected: (val) {
                      if (val) setState(() => _type = 'Lost');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text("FOUND ITEM", style: TextStyle(fontWeight: FontWeight.bold))),
                    selected: _type == 'Found',
                    selectedColor: Colors.green[700],
                    backgroundColor: AppColors.cardColor,
                    onSelected: (val) {
                      if (val) setState(() => _type = 'Found');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Title (e.g. Lost HP Laptop Bag, Found Keys)"),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _descriptionController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Detailed Description (where, when, color, marks...)"),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _imageUrlController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Image URL (Optional)"),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _whatsappController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("WhatsApp Number (e.g. +919876543210)"),
            ),
            const SizedBox(height: 30),

            BlocBuilder<LostFoundBloc, LostFoundState>(
              builder: (context, state) {
                final isLoading = state is LostFoundLoading;
                return ElevatedButton(
                  onPressed: isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                      : const Text("SUBMIT POST", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
