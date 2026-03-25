import 'package:flutter/material.dart';
import '../../components/section_title.dart';
import '../../components/text_field_widget.dart';

class StripeForm extends StatelessWidget {
  final TextEditingController amountController;
  final bool enabled;

  const StripeForm({
    Key? key,
    required this.amountController,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Amount',
          enabled: enabled,
          showAIBadge: !enabled,
        ),
        const SizedBox(height: 8),
        TextFieldWidget(
          controller: amountController,
          hintText: 'Enter payment amount',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          enabled: enabled,
          prefix: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Text(
              '€',
              style: TextStyle(
                color: enabled ? const Color(0xFF2C3E50) : Colors.grey[500],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
