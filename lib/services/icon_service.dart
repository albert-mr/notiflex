import 'package:flutter/services.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';

enum AppIcon {
  black,
  ig,
  whatsapp,
  stripe,
  revolut,
  shopify,
  gmail,
  linkedin,
  openai,
  uber,
  binance,
  spotify,
  telegram,
  reddit,
  mcdonalds,
}

class IconService {
  static Future<AppIcon> getCurrentAppIcon() async {
    try {
      String? iconName = await FlutterDynamicIcon.getAlternateIconName();
      return AppIcon.values.byName(iconName ?? 'black');
    } on PlatformException catch (_) {
      return AppIcon.black;
    }
  }

  static Future<void> changeAppIcon(AppIcon icon) async {
    try {
      if (await FlutterDynamicIcon.supportsAlternateIcons) {
        await FlutterDynamicIcon.setAlternateIconName(icon.name,
            showAlert: false);
      }
    } on PlatformException catch (_) {}
  }
}
