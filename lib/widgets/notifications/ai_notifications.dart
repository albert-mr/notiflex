import 'package:flutter/material.dart';
import 'package:notiflex/services/icon_service.dart';
import 'package:notiflex/components/section_title.dart';
import 'package:notiflex/components/text_field_widget.dart';

class AIRandomNotificationSettings extends StatelessWidget {
  final Function(String) onSettingsChanged;
  final AppIcon selectedIcon;
  final TextEditingController controller;

  const AIRandomNotificationSettings({
    Key? key,
    required this.onSettingsChanged,
    required this.selectedIcon,
    required this.controller,
  }) : super(key: key);

  String _getHintTextForPlatform(AppIcon platform) {
    switch (platform) {
      case AppIcon.stripe:
        return 'Generate a random range of payment values for transactions.';
      case AppIcon.revolut:
        return 'Create a random payment amount with currency and sender details.';
      case AppIcon.shopify:
        return 'Generate a random order item with ID and price for e-commerce.';
      case AppIcon.ig:
        return 'Select a DM theme with a random famous sender for personalization.';
      case AppIcon.whatsapp:
        return 'Craft a WhatsApp message with a random sender and optional image.';
      default:
        return 'Generate a customizable notification.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'AI Prompt',
            enabled: true,
            showAIBadge: false,
          ),
          const SizedBox(height: 8),
          TextFieldWidget(
            controller: controller,
            hintText: _getHintTextForPlatform(selectedIcon),
            maxLines: 3,
            onChanged: onSettingsChanged,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
