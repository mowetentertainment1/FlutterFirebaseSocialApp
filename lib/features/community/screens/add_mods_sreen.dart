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
Set<String> uids = {};
int count = 0;
void addUid(String uid) {
  setState(() {
    uids.add(uid);
  });
}
void removeUid(String uid) {
  setState(() {
    uids.add(uid);
  });
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
                        data: (user) {
                          if (community.mods.contains(member) && count == 0)
                            {
                              uids.add(member);
                            }
                          count++;
                          return CheckboxListTile(
                              title: Text(user.name),
                              value: uids.contains(user.uid),
                              onChanged: (value) {
                                if (value!) {
                                  addUid(user.uid);
                                } else {
                                  removeUid(user.uid);
                                }
                              },);
                        },
                        loading: () => const Loader(),
                        error: (error, stackTrace) => const Text('Error'));
                  }),
              loading: () => const Loader(),
              error: (error, stackTrace) => const Text('Error')),
    );
  }
}
