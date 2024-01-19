import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/features/auth/controller/auth_controller.dart';

import '../../../core/common/loader.dart';
import '../controller/community_controller.dart';

class AddModsScreen extends ConsumerStatefulWidget {
  final String communityName;

  const AddModsScreen({super.key, required this.communityName});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsScreen> {
  final TextEditingController _modNameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _modNameController.dispose();
  }

  // void addMod() {
  //   ref.read(communityControllerProvider.notifier).addMod(
  //       _modNameController.text.trim(),
  //       context);
  // }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Mod'),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.check),
              tooltip: 'Add Mod')
        ],
      ),
      body: isLoading
          ? const Loader()
          : ref.watch(getCommunityByNameProvider(widget.communityName)).when(
              data: (community) => ListView.builder(
                  itemCount: community.members.length,
                  itemBuilder: (context, index) {
                    final member = community.members[index];
                  return  ref.watch(getUserDataProvider(member)).when(
                        data: (user) => CheckboxListTile(
                            title: Text(user.name),
                            value: false,
                            onChanged: (value) {}),
                        loading: () => const Loader(),
                        error: (error, stackTrace) => const Text('Error'));
                  }),
              loading: () => const Loader(),
              error: (error, stackTrace) => const Text('Error')),
    );
  }
}
