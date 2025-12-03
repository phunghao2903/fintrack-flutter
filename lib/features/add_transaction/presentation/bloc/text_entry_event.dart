abstract class TextEntryEvent {}

class SubmitTextRequested extends TextEntryEvent {
  final String text;

  SubmitTextRequested(this.text);
}
