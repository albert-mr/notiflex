import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../services/icon_service.dart';
import 'dart:io';

class ApiService {
  static const String url = "https://api.together.xyz/v1";
  static final String apiKey = dotenv.env['TOGETHER_API_KEY'] ?? '';

  Future<String?> describeImage(String? imageUrl) async {
    try {
      final response = await http.post(
        Uri.parse("$url/chat/completions"),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "model": "meta-llama/Llama-Vision-Free",
          "temperature": 0.2,
          "messages": [
            {"role": "user", "content": "Describe this image in 2 sentences."},
            {
              "type": "image_url",
              "image_url": {"url": imageUrl}
            },
          ],
        }),
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['choices'][0]['message']['content'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> generateImage(String? description) async {
    try {
      final response = await http.post(
        Uri.parse("$url/images/generations"),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "model": "black-forest-labs/FLUX.1-schnell-Free",
          "prompt": description,
          "width": 1024,
          "height": 1024,
          "steps": 1,
          "n": 1,
          "response_format": "b64_json"
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        String? base64Image = jsonResponse['data'][0]['b64_json'];
        if (base64Image != null) {
          final bytes = base64Decode(base64Image);

          final tempDir = Directory.systemTemp;
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
          final filePath = '${tempDir.path}/generated_images/$fileName';

          final imageDir = Directory('${tempDir.path}/generated_images');
          if (!await imageDir.exists()) {
            await imageDir.create(recursive: true);
          }

          final file = File(filePath);
          await file.writeAsBytes(bytes);

          return filePath;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, String>?> generateNotificationContent(
      AppIcon platform, String prompt,
      {double? amount}) async {
    try {
      final systemPrompt = _getSystemPromptForPlatform(platform);

      final response = await http.post(
        Uri.parse("$url/chat/completions"),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "model": "meta-llama/Llama-Vision-Free",
          "temperature": 0.7,
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['choices'][0]['message']['content'];
        final parsedResponse = await _parseAIResponse(content, platform);
        return parsedResponse
            ?.map((key, value) => MapEntry(key, value.toString()));
      }
      return null;
    } catch (e) {
      print("Error generating notification content: $e");
      return null;
    }
  }

  String _getSystemPromptForPlatform(AppIcon platform) {
    switch (platform) {
      case AppIcon.stripe:
        return """You are a payment amount generator. Generate a single random amount within the range specified in the user's prompt. 
                 Use proper format with commas for thousands and decimal points (e.g., 1,234.56 or 42.99). Do not include any other text nor currency symbols.
                 Format: AMOUNT""";

      case AppIcon.revolut:
        return """Generate a money transfer with these exact components:
                 1. Pick a random famous person's first name and last name (e.g., Elon Musk, Taylor Swift, Leonardo DiCaprio, etc.)
                 2. Generate a random amount between 5,00 and 10.000,00 using European format (points for thousands, commas for decimals)
                 Format: NAME|||AMOUNT""";

      case AppIcon.shopify:
        return """Generate an order notification with these exact components:
                 1. An order number in this format: #1234567
                 2. A store name from this list: [Fashion Store, Tech Shop, Home Goods, Sports Outlet]
                 3. A status from this list: [Confirmed, Shipped, Delivered]
                 Format: ORDER_NUMBER|||STORE|||STATUS""";

      case AppIcon.ig:
        return """Generate an Instagram message from a famous person based on the theme in the user's prompt.
                 Pick a relevant celebrity and write a short, authentic-sounding message (max 60 chars).
                 Format: NAME|||MESSAGE""";

      case AppIcon.whatsapp:
        return """Generate a message with these exact components:
                 1. Pick a random famous person's first name and last name (e.g., Elon Musk, Taylor Swift, Leonardo DiCaprio, etc.)
                 2. Create a random message based on the user's prompt, ensuring it sounds natural and engaging. Make it short and concise.
                 Format: NAME|||MESSAGE""";

      default:
        return "Generate a notification. Format: TITLE|||BODY";
    }
  }

  Future<Map<String, dynamic>?> _parseAIResponse(
      String aiResponse, AppIcon platform) async {
    try {
      switch (platform) {
        case AppIcon.stripe:
          final amount = aiResponse.trim();
          return {
            'title': 'Stripe',
            'body': 'You have received a payment of € $amount!',
            'amount': amount,
          };
        case AppIcon.revolut:
          final parts = aiResponse.split('|||');
          if (parts.length >= 2) {
            return {
              'title': parts[0],
              'body': 'Has sent you ${parts[1]} €. Tap to say thanks 💸',
            };
          }
          break;

        case AppIcon.shopify:
          if (aiResponse.contains('|||')) {
            final parts = aiResponse.split('|||');
            final status = parts[2].trim().toLowerCase();
            final title = status == 'shipped'
                ? 'Order Shipped'
                : status == 'delivered'
                    ? 'Order Delivered'
                    : 'Order Confirmed';
            return {
              'title': title,
              'body': 'Order ${parts[0]} from ${parts[1]} has been $status',
              'orderNumber': parts[0].trim(),
              'storeName': parts[1].trim(),
              'status': parts[2].trim(),
            };
          }
          break;

        case AppIcon.ig:
          final parts = aiResponse.split('|||');
          if (parts.length >= 2) {
            return {
              'title':
                  '[@${parts[0].toLowerCase().replaceAll(' ', '')}] ${parts[0]}',
              'body': parts[1].trim(),
              'username': parts[0].trim(),
              'message': parts[1].trim(),
            };
          }
          break;

        case AppIcon.whatsapp:
          final parts = aiResponse.split('|||');
          if (parts.length >= 2) {
            return {
              'title': parts[0].trim(),
              'body': parts[1].trim().replaceAll('"', ''),
              'contact': parts[0].trim(),
              'preview': parts[1].trim(),
              'image': await generateImage(
                  '${parts[0].trim()} ${parts[1].trim().replaceAll('"', '')}'),
            };
          }
          break;

        default:
          if (aiResponse.contains('|||')) {
            final parts = aiResponse.split('|||');
            return {
              'title': parts[0].trim(),
              'body': parts[1].trim(),
            };
          }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
