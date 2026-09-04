import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xplore_app/blocs/lost_found/lost_found_bloc.dart';
import 'package:xplore_app/components/app_primary_button.dart';
import 'package:xplore_app/components/app_text_field.dart';
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
          imageUrl: _imageUrlController.text.trim().isNotEmpty
              ? _imageUrlController.text.trim()
              : null,
          whatsapp: _whatsappController.text.trim().isNotEmpty
              ? _whatsappController.text.trim()
              : null,
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
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
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
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.pop(context, true);
          } else if (state is LostFoundError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
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
                    label: const Center(
                        child: Text("LOST ITEM",
                            style: TextStyle(fontWeight: FontWeight.bold))),
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
                    label: const Center(
                        child: Text("FOUND ITEM",
                            style: TextStyle(fontWeight: FontWeight.bold))),
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

            AppTextField(
              controller: _titleController,
              hintText: "Title (e.g. Lost HP Laptop Bag, Found Keys)",
              prefixIcon: Icons.title_rounded,
            ),
            const SizedBox(height: 14),

            AppTextField(
              controller: _descriptionController,
              hintText: "Detailed Description (where, when, color, marks...)",
              prefixIcon: Icons.description_outlined,
              maxLines: 4,
              height: 120,
            ),
            const SizedBox(height: 14),

            AppTextField(
              controller: _imageUrlController,
              hintText: "Image URL (Optional)",
              prefixIcon: Icons.link_outlined,
            ),
            const SizedBox(height: 14),

            AppTextField(
              controller: _whatsappController,
              hintText: "WhatsApp Number (e.g. +919876543210)",
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 30),

            BlocBuilder<LostFoundBloc, LostFoundState>(
              builder: (context, state) {
                final isLoading = state is LostFoundLoading;
                return AppPrimaryButton(
                  onPressed: isLoading ? null : _handleSubmit,
                  label: "SUBMIT POST",
                  loading: isLoading,
                  height: 55,
                  radius: 30,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
