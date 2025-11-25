// import 'package:flutter/material.dart';

// class ChatInputField extends StatefulWidget {
//   final bool isSending;
//   final Function(String text) onSend;
//   final VoidCallback onRegenerate;

//   const ChatInputField({
//     super.key,
//     required this.isSending,
//     required this.onSend,
//     required this.onRegenerate,
//   });

//   @override
//   State<ChatInputField> createState() => _ChatInputFieldState();
// }

// class _ChatInputFieldState extends State<ChatInputField> {
//   final TextEditingController controller = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         border: const Border(top: BorderSide(color: Colors.black12)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (widget.isSending)
//             const Padding(
//               padding: EdgeInsets.only(bottom: 8),
//               child: Row(
//                 children: [
//                   SizedBox(
//                     height: 14,
//                     width: 14,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   ),
//                   SizedBox(width: 10),
//                   Text("AI đang trả lời..."),
//                 ],
//               ),
//             ),

//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: controller,
//                   decoration: const InputDecoration(
//                     hintText: "Nhập tin nhắn...",
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               IconButton(
//                 icon: const Icon(Icons.send),
//                 onPressed: widget.isSending
//                     ? null
//                     : () {
//                         final text = controller.text.trim();
//                         if (text.isEmpty) return;

//                         controller.clear();
//                         widget.onSend(text);
//                       },
//               ),
//             ],
//           ),
//           SizedBox(height: 15),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class ChatInputField extends StatefulWidget {
  final bool isSending;
  final Function(String text) onSend;
  final VoidCallback onRegenerate;

  const ChatInputField({
    super.key,
    required this.isSending,
    required this.onSend,
    required this.onRegenerate,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: const Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isSending)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text("AI đang trả lời..."),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "Nhập tin nhắn...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: widget.isSending
                    ? null
                    : () {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        controller.clear();
                        widget.onSend(text);
                      },
              ),
            ],
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
