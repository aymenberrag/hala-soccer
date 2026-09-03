import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'ai_provider.dart';

/// OpenRouter-backed provider. Defaults to a free Qwen instruct model per
/// the spec's preference, but the model id is entirely driven by env
/// config — swap AI_MODEL to any other OpenRouter model id (free or not)
/// without touching app code.
///
/// NOTE: OpenRouter's set of free-tier models changes over time. If
/// AI_MODEL_DEFAULT below ever 404s/400s, check
/// https://openrouter.ai/models?max_price=0 for the current free Qwen
/// slug and either update .env or the default here.
class OpenRouterAiProvider implements AiProvider {
  static const _endpoint = "https://openrouter.ai/api/v1/chat/completions";
  static const _defaultModel = "qwen/qwen-2.5-72b-instruct:free";

  final String _apiKey;
  final String _model;

  OpenRouterAiProvider({String? apiKey, String? model})
      : _apiKey = apiKey ?? dotenv.env["OPENROUTER_API_KEY"] ?? "",
        _model = model ?? dotenv.env["AI_MODEL"] ?? _defaultModel;

  bool get isConfigured => _apiKey.isNotEmpty;

  @override
  String get label => "openrouter:$_model";

  @override
  Future<String> complete({required String systemPrompt, required String userPrompt}) async {
    if (!isConfigured) {
      throw AiProviderException("OPENROUTER_API_KEY is not set.");
    }

    http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              "Authorization": "Bearer $_apiKey",
              "Content-Type": "application/json",
              // Recommended by OpenRouter for attribution; harmless if ignored.
              "HTTP-Referer": "https://halasoccer.app",
              "X-Title": "Hala Soccer",
            },
            body: jsonEncode({
              "model": _model,
              "messages": [
                {"role": "system", "content": systemPrompt},
                {"role": "user", "content": userPrompt},
              ],
              "temperature": 0.2,
              "response_format": {"type": "json_object"},
            }),
          )
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      throw AiProviderException("Couldn't reach OpenRouter: $e");
    }

    if (response.statusCode != 200) {
      throw AiProviderException("OpenRouter request failed (${response.statusCode}): ${response.body}");
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded["choices"] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw AiProviderException("OpenRouter returned no choices.");
    }
    final message = choices.first["message"] as Map<String, dynamic>?;
    final content = message?["content"] as String?;
    if (content == null || content.isEmpty) {
      throw AiProviderException("OpenRouter returned an empty completion.");
    }
    return content;
  }
}
