import '../services/icon_service.dart';

Map<String, String> generateNotificationContent(
    AppIcon platform, String titleText, String bodyText, String amountText) {
  String title;
  String body;

  switch (platform) {
    case AppIcon.stripe:
      title = "Stripe";
      body = "You have received a payment of €$amountText!";
      break;
    case AppIcon.revolut:
      title = bodyText;
      body = "Has sent you $amountText €. Tap to say thanks 💸";
      break;
    case AppIcon.shopify:
      title = "Shopify Order Update";
      body = "Order $titleText is now: $bodyText.";
      break;
    case AppIcon.ig:
      title = titleText;
      body = bodyText;
      break;
    case AppIcon.whatsapp:
      title = titleText;
      body = bodyText;
      break;
    default:
      title = "Notification";
      body = bodyText;
  }
  return {'title': title, 'body': body};
}

String getPlatformAssetPath(AppIcon platform) {
  switch (platform) {
    case AppIcon.stripe:
      return 'assets/platforms/stripe.png';
    case AppIcon.revolut:
      return 'assets/platforms/revolut.png';
    case AppIcon.shopify:
      return 'assets/platforms/shopify.png';
    case AppIcon.ig:
      return 'assets/platforms/instagram.png';
    case AppIcon.whatsapp:
      return 'assets/platforms/whatsapp.png';
    case AppIcon.gmail:
      return 'assets/platforms/gmail.png';
    case AppIcon.linkedin:
      return 'assets/platforms/linkedin.png';
    case AppIcon.openai:
      return 'assets/platforms/openai.png';
    case AppIcon.uber:
      return 'assets/platforms/uber.png';
    case AppIcon.binance:
      return 'assets/platforms/binance.png';
    case AppIcon.spotify:
      return 'assets/platforms/spotify.png';
    case AppIcon.telegram:
      return 'assets/platforms/telegram.png';
    case AppIcon.reddit:
      return 'assets/platforms/reddit.png';
    case AppIcon.mcdonalds:
      return 'assets/platforms/mcdonalds.png';
    default:
      return '';
  }
}

String getPlatformName(AppIcon platform) {
  switch (platform) {
    case AppIcon.stripe:
      return 'Stripe';
    case AppIcon.revolut:
      return 'Revolut';
    case AppIcon.shopify:
      return 'Shopify';
    case AppIcon.ig:
      return 'Instagram';
    case AppIcon.whatsapp:
      return 'WhatsApp';
    case AppIcon.gmail:
      return 'Gmail';
    case AppIcon.linkedin:
      return 'LinkedIn';
    case AppIcon.openai:
      return 'OpenAI';
    case AppIcon.uber:
      return 'Uber';
    case AppIcon.binance:
      return 'Binance';
    case AppIcon.spotify:
      return 'Spotify';
    case AppIcon.telegram:
      return 'Telegram';
    case AppIcon.reddit:
      return 'Reddit';
    case AppIcon.mcdonalds:
      return 'McDonald\'s';
    default:
      return platform.name;
  }
}

bool isFormValid(AppIcon platform, String title, String body, String amount) {
  switch (platform) {
    case AppIcon.stripe:
      return amount.trim().isNotEmpty;
    case AppIcon.revolut:
      return amount.trim().isNotEmpty && body.trim().isNotEmpty;
    case AppIcon.shopify:
    case AppIcon.ig:
      return title.trim().isNotEmpty && body.trim().isNotEmpty;
    case AppIcon.whatsapp:
      return body.trim().isNotEmpty;
    default:
      return body.trim().isNotEmpty;
  }
}
