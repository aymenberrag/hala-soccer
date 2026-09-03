/// Anything that can turn a prompt into a text completion. Hala's AI
/// curation logic (see `curation_service.dart`) only depends on this
/// interface, never on a specific vendor — so the model/provider can be
/// swapped later (section 6 of the spec: "make the AI provider modular").
abstract class AiProvider {
  /// Returns the raw text completion, or throws on failure. Implementations
  /// should keep this a single non-streaming call — curation prompts are
  /// small and we want a plain string back, ideally JSON.
  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
  });

  /// Human-readable name for logs/debugging (e.g. "openrouter:qwen/qwen-2.5-72b-instruct:free").
  String get label;
}

class AiProviderException implements Exception {
  final String message;
  AiProviderException(this.message);
  @override
  String toString() => "AiProviderException: $message";
}
