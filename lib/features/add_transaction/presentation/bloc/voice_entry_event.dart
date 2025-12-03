abstract class VoiceEntryEvent {}

class UploadVoiceRequested extends VoiceEntryEvent {
  final String transcript;
  final String? languageCode;

  UploadVoiceRequested({
    required this.transcript,
    this.languageCode,
  });
}
