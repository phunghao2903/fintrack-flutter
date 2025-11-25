// import 'package:flutter/material.dart';

// class ChatBubbleUser extends StatelessWidget {
//   final String message;

//   const ChatBubbleUser({super.key, required this.message});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.centerRight,
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         constraints: const BoxConstraints(maxWidth: 250),
//         decoration: BoxDecoration(
//           color: Colors.blueAccent,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Text(message, style: const TextStyle(color: Colors.white)),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class ChatBubbleUser extends StatelessWidget {
  final String message;

  const ChatBubbleUser({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
