import 'package:chat_app/widget/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, chatSnapshots) {
          if (chatSnapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (chatSnapshots.hasData && chatSnapshots.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Messages Found"),
            );
          }

          final loadedMessages = chatSnapshots.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.only(
              left: 13,
              right: 13,
              bottom: 10,
            ),
            reverse: true,
            itemCount: chatSnapshots.data!.docs.length,
            itemBuilder: (ctx, index) {
              final currentMessage = loadedMessages[index].data();
              final nextMessage = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data()
                  : null;

              final currentMessageUserId = currentMessage["userId"];
              final nextMessageUserId =
                  nextMessage == null ? null : nextMessage["userId"];

              final nextUserIsSame = currentMessageUserId == nextMessageUserId;

              if (nextUserIsSame) {
                return MessageBubble.next(
                  message: currentMessage["message"],
                  isMe: FirebaseAuth.instance.currentUser!.uid ==
                      currentMessage["userId"],
                );
              } else {
                return MessageBubble.first(
                  userImage: currentMessage["image"],
                  username: currentMessage["username"],
                  message: currentMessage["message"],
                  isMe: FirebaseAuth.instance.currentUser!.uid ==
                      currentMessage["userId"],
                );
              }
            },
          );
        });
  }
}
