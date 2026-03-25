import 'package:flutter/material.dart';
import 'package:notiflex/widgets/platforms/whatsapp_form.dart';
import 'package:notiflex/services/notifications_service.dart';
import 'package:notiflex/widgets/notifications/ai_notifications.dart';
import '../services/icon_service.dart';
import '../components/platform_card.dart';
import '../widgets/platforms/stripe_form.dart';
import '../widgets/platforms/revolut_form.dart';
import '../widgets/platforms/shopify_form.dart';
import '../widgets/platforms/instagram_form.dart';
import '../utils/platform_helpers.dart';
import '../widgets/notifications/notification_scheduler.dart';
import '../services/api_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  final AppIcon selectedPlatform;

  const NotificationSettingsScreen({
    Key? key,
    required this.selectedPlatform,
  }) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _amountController = TextEditingController();
  final _aiPromptController = TextEditingController();
  bool _isFormValid = false;

  bool _showAdvancedOptions = false;
  DateTime? _scheduledTime;
  Duration? _interval;
  int? _notificationCount;

  bool _isLoadingSend = false;
  bool _isLoadingCall = false;

  bool _showAIOptions = false;
  List<String>? _aiSettings;

  @override
  void initState() {
    super.initState();
    _setupControllerListeners();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _amountController.dispose();
    _aiPromptController.dispose();
    super.dispose();
  }

  void _setupControllerListeners() {
    void listener() => _validateForm();
    _titleController.addListener(listener);
    _bodyController.addListener(listener);
    _amountController.addListener(listener);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _showAIOptions
          ? (_aiSettings != null && _aiSettings!.isNotEmpty)
          : isFormValid(
              widget.selectedPlatform,
              _titleController.text,
              _bodyController.text,
              _amountController.text,
            );
    });
  }

  void _updateScheduleOptions(
      DateTime? scheduledTime, Duration? interval, int? count) {
    setState(() {
      _scheduledTime = scheduledTime;
      _interval = interval;
      _notificationCount = count;
    });
  }

  void _updateAIOptions(String content) {
    setState(() {
      _aiSettings = [content];
      _validateForm();
    });
  }

  void sendNotification(bool isCall) async {
    setState(() {
      if (isCall) {
        _isLoadingCall = true;
      } else {
        _isLoadingSend = true;
      }
    });

    Map<String, String>? notificationContent;

    if (_showAIOptions && _aiSettings != null) {
      notificationContent = await ApiService().generateNotificationContent(
        widget.selectedPlatform,
        _aiSettings![0],
      );
    } else {
      notificationContent = generateNotificationContent(
        widget.selectedPlatform,
        _titleController.text,
        _bodyController.text,
        _amountController.text,
      );
    }

    if (notificationContent != null) {
      if (isCall) {
        await NotificationService().showCallkitIncoming(
          newIcon: widget.selectedPlatform,
          title: notificationContent['title']!,
          body: notificationContent['body']!,
        );
      } else {
        await NotificationService().scheduleNotification(
          title: notificationContent['title']!,
          body: notificationContent['body']!,
          payLoad: notificationContent['payLoad'],
          scheduledTime: _scheduledTime,
          interval: _interval,
          notificationCount: _notificationCount,
          platform: widget.selectedPlatform,
          image: notificationContent['image'],
        );
      }
    }

    setState(() {
      _isLoadingSend = false;
      _isLoadingCall = false;
    });
  }

  Widget _buildFormFields() {
    switch (widget.selectedPlatform) {
      case AppIcon.stripe:
        return StripeForm(
          amountController: _amountController,
          enabled: !_showAIOptions,
        );
      case AppIcon.revolut:
        return RevolutForm(
          bodyController: _bodyController,
          amountController: _amountController,
          enabled: !_showAIOptions,
        );
      case AppIcon.shopify:
        return ShopifyForm(
          titleController: _titleController,
          bodyController: _bodyController,
          enabled: !_showAIOptions,
        );
      case AppIcon.ig:
        return InstagramForm(
          titleController: _titleController,
          bodyController: _bodyController,
          enabled: !_showAIOptions,
        );
      case AppIcon.whatsapp:
        return WhatsAppForm(
          titleController: _titleController,
          bodyController: _bodyController,
          enabled: !_showAIOptions,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Notification',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                            ),
                            Text(
                              'Customize your notification for ${getPlatformName(widget.selectedPlatform)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                        child: Column(
                          children: [
                            PlatformCard(
                                selectedPlatform: widget.selectedPlatform),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Column(
                          children: [
                            ListTile(
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    color: _showAIOptions
                                        ? Colors.blue[700]
                                        : Colors.grey[400],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'AI',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Switch(
                                    value: _showAIOptions,
                                    onChanged: (value) {
                                      setState(() {
                                        _showAIOptions = value;
                                        if (!value) {
                                          _aiSettings = null;
                                        }
                                      });
                                    },
                                    activeColor: Colors.blue[800],
                                    activeTrackColor: Colors.blue[100],
                                    inactiveThumbColor: Colors.grey[300],
                                    inactiveTrackColor: Colors.grey[200],
                                  ),
                                ],
                              ),
                            ),
                            if (_showAIOptions)
                              AIRandomNotificationSettings(
                                  onSettingsChanged: _updateAIOptions,
                                  selectedIcon: widget.selectedPlatform,
                                  controller: _aiPromptController),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                        child: Column(
                          children: [
                            _buildFormFields(),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text(
                                'Schedule Options',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              value: _showAdvancedOptions,
                              onChanged: (value) {
                                setState(() {
                                  _showAdvancedOptions = value;
                                  if (!value) {
                                    _scheduledTime = null;
                                    _interval = null;
                                    _notificationCount = null;
                                  }
                                });
                              },
                              activeColor: Colors.blue[800],
                              activeTrackColor: Colors.blue[100],
                              inactiveThumbColor: Colors.grey[300],
                              inactiveTrackColor: Colors.grey[200],
                            ),
                            if (_showAdvancedOptions)
                              NotificationScheduler(
                                  onScheduleChanged: _updateScheduleOptions),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isFormValid && !_isLoadingSend
                            ? () => sendNotification(false)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoadingSend)
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              const Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            const SizedBox(width: 8),
                            Text(
                              _isFormValid
                                  ? (_isLoadingSend ? 'Sending...' : 'Send 🚀')
                                  : ' ',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isFormValid && !_isLoadingCall
                            ? () => sendNotification(true)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoadingCall)
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              const Icon(
                                Icons.call,
                                color: Colors.white,
                              ),
                            const SizedBox(width: 8),
                            Text(
                              _isFormValid
                                  ? (_isLoadingCall ? 'Calling...' : 'Call 📞')
                                  : ' ',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
