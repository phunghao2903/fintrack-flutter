// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../domain/entities/chat_message.dart';
// import '../bloc/chat_bloc/chat_bloc.dart';
// import '../bloc/chat_detail_bloc/chat_detail_bloc.dart';
// import 'widgets/chat_bubble_user.dart';
// import 'widgets/chat_bubble_bot.dart';
// import 'widgets/chat_input_field.dart';

// class ChatDetailPage extends StatefulWidget {
//   final String uid;

//   const ChatDetailPage({super.key, required this.uid});

//   @override
//   State<ChatDetailPage> createState() => _ChatDetailPageState();
// }

// class _ChatDetailPageState extends State<ChatDetailPage> {
//   final ScrollController _scrollController = ScrollController();

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     context.read<ChatBloc>().add(LoadMessages(widget.uid));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("AI Chatbot")),

//       /// Chat messages list
//       body: BlocBuilder<ChatBloc, ChatState>(
//         builder: (context, state) {
//           _scrollToBottom();
//           return ListView.builder(
//             controller: _scrollController,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//             itemCount: state.messages.length,
//             itemBuilder: (context, index) {
//               final ChatMessage msg = state.messages[index];
//               return msg.isUser
//                   ? ChatBubbleUser(message: msg.message)
//                   : ChatBubbleBot(message: msg.message);
//             },
//           );
//         },
//       ),

//       /// Chat input fixed ở dưới, tránh bị BottomNavigationBar che
//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
//           child: BlocBuilder<ChatDetailBloc, ChatDetailState>(
//             builder: (context, detailState) {
//               return ChatInputField(
//                 isSending: detailState.isSending,
//                 onSend: (text) {
//                   context.read<ChatDetailBloc>().add(
//                     SendMessageEvent(widget.uid, text),
//                   );
//                 },
//                 onRegenerate: () {
//                   final messages = context.read<ChatBloc>().state.messages;
//                   final lastUserMessage = messages
//                       .lastWhere((m) => m.isUser)
//                       .message;

//                   context.read<ChatDetailBloc>().add(
//                     RegenerateMessageEvent(widget.uid, lastUserMessage),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_message.dart';
import '../bloc/chat_bloc/chat_bloc.dart';
import '../bloc/chat_detail_bloc/chat_detail_bloc.dart';
import 'widgets/chat_bubble_user.dart';
import 'widgets/chat_bubble_bot.dart';
import 'widgets/chat_input_field.dart';

class ChatDetailPage extends StatefulWidget {
  final String uid;

  const ChatDetailPage({super.key, required this.uid});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadMessages(widget.uid));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Chatbot")),

      /// Chat messages list
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          _scrollToBottom();
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final ChatMessage msg = state.messages[index];
              // hiển thị dựa trên isBot
              return msg.isBot
                  ? ChatBubbleBot(message: msg.message)
                  : ChatBubbleUser(message: msg.message);
            },
          );
        },
      ),

      /// Chat input fixed ở dưới
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
          child: BlocBuilder<ChatDetailBloc, ChatDetailState>(
            builder: (context, detailState) {
              return ChatInputField(
                isSending: detailState.isSending,
                onSend: (text) {
                  context.read<ChatDetailBloc>().add(
                    SendMessageEvent(widget.uid, text),
                  );
                },
                onRegenerate: () {
                  final messages = context.read<ChatBloc>().state.messages;
                  final lastUserMessage = messages
                      .lastWhere((m) => !m.isBot)
                      .message;

                  context.read<ChatDetailBloc>().add(
                    RegenerateMessageEvent(widget.uid, lastUserMessage),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
