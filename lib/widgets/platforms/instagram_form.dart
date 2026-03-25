import 'package:flutter/material.dart';
import '../../components/section_title.dart';
import '../../components/text_field_widget.dart';

class InstagramForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final bool enabled;

  const InstagramForm({
    Key? key,
    required this.titleController,
    required this.bodyController,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Sender',
          enabled: enabled,
          showAIBadge: !enabled,
        ),
        const SizedBox(height: 8),
        TextFieldWidget(
          controller: titleController,
          hintText: '[your account] Sender Name',
          enabled: enabled,
        ),
        const SizedBox(height: 24),
        SectionTitle(
          title: 'Message',
          enabled: enabled,
          showAIBadge: !enabled,
        ),
        const SizedBox(height: 8),
        TextFieldWidget(
          controller: bodyController,
          hintText: 'Enter notification content',
          maxLines: 1,
          enabled: enabled,
        ),
      ],
    );
  }
}
