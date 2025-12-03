abstract class VoiceEntryEvent {}

class UploadVoiceRequested extends VoiceEntryEvent {
  final String transcript;
  final String? languageCode;
  final String audioPath;

  UploadVoiceRequested({
    required this.transcript,
    required this.audioPath,
    this.languageCode,
  });
}

class VoiceEntryReset extends VoiceEntryEvent {}
