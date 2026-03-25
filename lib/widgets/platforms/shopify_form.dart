import 'package:flutter/material.dart';
import '../../components/section_title.dart';
import '../../components/text_field_widget.dart';

class ShopifyForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final bool enabled;

  const ShopifyForm({
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
          title: 'Order Number',
          enabled: enabled,
          showAIBadge: !enabled,
        ),
        const SizedBox(height: 8),
        TextFieldWidget(
          controller: titleController,
          hintText: '#ORDER-1234',
          enabled: enabled,
        ),
        const SizedBox(height: 24),
        SectionTitle(
          title: 'Order Status',
          enabled: enabled,
          showAIBadge: !enabled,
        ),
        const SizedBox(height: 8),
        TextFieldWidget(
          controller: bodyController,
          hintText: 'Enter order status and details',
          maxLines: 1,
          enabled: enabled,
        ),
      ],
    );
  }
}
