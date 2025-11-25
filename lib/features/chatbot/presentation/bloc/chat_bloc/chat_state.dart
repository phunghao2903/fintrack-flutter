// part of 'chat_bloc.dart';

// class ChatState extends Equatable {
//   final bool isLoading;
//   final List<ChatMessage> messages;

//   const ChatState({required this.isLoading, required this.messages});

//   factory ChatState.initial() {
//     return const ChatState(isLoading: false, messages: []);
//   }

//   ChatState copyWith({bool? isLoading, List<ChatMessage>? messages}) {
//     return ChatState(
//       isLoading: isLoading ?? this.isLoading,
//       messages: messages ?? this.messages,
//     );
//   }

//   @override
//   List<Object?> get props => [isLoading, messages];
// }

part of 'chat_bloc.dart';

class ChatState extends Equatable {
  final bool isLoading;
  final List<ChatMessage> messages;

  const ChatState({required this.isLoading, required this.messages});

  factory ChatState.initial() {
    return const ChatState(isLoading: false, messages: []);
  }

  ChatState copyWith({bool? isLoading, List<ChatMessage>? messages}) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [isLoading, messages];
}
