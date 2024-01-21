import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPostScreen extends ConsumerWidget {
  const AddPostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          child: const TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'What\'s on your mind?',
            ),
            maxLines: 5,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.linked_camera),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.link),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.emoji_emotions),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],);
  }
}
