import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final bool enabled;
  final bool showAIBadge;

  const SectionTitle({
    Key? key,
    required this.title,
    this.enabled = true,
    this.showAIBadge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: enabled ? const Color(0xFF2C3E50) : Colors.grey[400],
          ),
        ),
        if (!enabled && showAIBadge) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.blue[700],
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  'AI Enabled',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
