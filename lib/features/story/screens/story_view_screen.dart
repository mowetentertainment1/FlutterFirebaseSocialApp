import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:story_view/story_view.dart' as story_view;

import '../../../core/common/loader.dart';
import '../controller/story_controller.dart';

class StoryViewScreen extends ConsumerStatefulWidget {
  final String storyId;
  const StoryViewScreen({
    super.key,
    required this.storyId,
  });

  @override
  ConsumerState<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends ConsumerState<StoryViewScreen> {
  story_view.StoryController controller = story_view.StoryController();
  List<story_view.StoryItem> storyItems = [];

  @override
  Widget build(BuildContext context) {
    final storyId = widget.storyId;
    if (storyItems.isEmpty) {
      ref.read(getStoryByIdProvider(storyId)).whenData((story) {
        setState(() {
          storyItems = story.linkImage
              .map((e) => story_view.StoryItem.pageImage(
            url: e,
            controller: controller,
          ))
              .toList();
        });
      });

    }
    return Scaffold(
      body: storyItems.isEmpty
          ? const Loader()
          : story_view.StoryView(
        storyItems: storyItems,
        controller: controller,
        onComplete: () {
          Routemaster.of(context).pop();
        },
        onVerticalSwipeComplete: (direction) {
          if (direction == story_view.Direction.down) {
            Routemaster.of(context).pop();
          }
        },
      ),
    );
  }
}
