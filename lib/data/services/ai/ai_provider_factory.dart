import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ai_provider.dart';
import 'openrouter_ai_provider.dart';

/// Picks the configured AiProvider. Today only OpenRouter is wired up,
/// but callers (CurationService) never construct a provider directly —
/// they always go through here, so adding a second provider later is a
/// one-file change plus an AI_PROVIDER=<name> switch in .env.
class AiProviderFactory {
  AiProviderFactory._();

  static AiProvider create() {
    final providerName = (dotenv.env["AI_PROVIDER"] ?? "openrouter").toLowerCase();
    switch (providerName) {
      case "openrouter":
      default:
        return OpenRouterAiProvider();
    }
  }
}
