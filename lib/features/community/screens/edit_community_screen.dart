import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/features/community/controller/community_controller.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String communityName;

  const EditCommunityScreen( {super.key, required this.communityName});

  @override
  ConsumerState createState() => _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
