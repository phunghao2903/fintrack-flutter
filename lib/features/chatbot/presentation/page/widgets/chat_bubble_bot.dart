// import 'package:flutter/material.dart';

// class ChatBubbleBot extends StatelessWidget {
//   final String message;

//   const ChatBubbleBot({super.key, required this.message});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.centerLeft,
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         constraints: const BoxConstraints(maxWidth: 260),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade300,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Text(message, style: const TextStyle(color: Colors.black)),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class ChatBubbleBot extends StatelessWidget {
  final String message;

  const ChatBubbleBot({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message, style: const TextStyle(color: Colors.black)),
      ),
    );
  }
}
