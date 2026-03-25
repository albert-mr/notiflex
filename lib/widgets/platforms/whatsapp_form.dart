import 'package:flutter/material.dart';
import '../../components/section_title.dart';
import '../../components/text_field_widget.dart';

class WhatsAppForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final bool enabled;

  const WhatsAppForm({
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
          hintText: 'Enter sender name',
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
          hintText: 'Enter message content',
          maxLines: 1,
          enabled: enabled,
        ),
      ],
    );
  }
}
