import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/features/auth/controller/auth_controller.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../controller/community_controller.dart';

class InviteScreen extends ConsumerStatefulWidget {
  final String communityName;
  const InviteScreen({
    super.key,
    required this.communityName,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<InviteScreen> {
  Set<String> uids = {};
  int ctr = 0;

  void addUid(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUid(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void inviteToCommunity() {
    ref.read(communityControllerProvider.notifier).inviteUser(
          widget.communityName,
          uids.toList(),
          context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite to Community'),
        actions: [
          IconButton(
            onPressed: isLoading ? null : () => inviteToCommunity(),
            icon: isLoading ? const Loader() : const Icon(Icons.done),
          ),
        ],
      ),
      body: ref.watch(getCurrentUserDataProvider).when(
            data: (follower) => ListView.builder(
              itemCount: follower.followers.length,
              itemBuilder: (BuildContext context, int index) {
                final member = follower.followers[index];
                return ref.watch(getUserDataProvider(member)).when(
                      data: (user) {
                        ref.read(getCommunityByNameProvider(widget.communityName)).when(
                              data: (community) {
                                if (community.members.contains(member) && ctr == 0) {
                                  uids.add(member);
                                  ctr++;
                                }
                              },
                              error: (Object error, StackTrace stackTrace) {},
                              loading: () {},
                            );
                        return CheckboxListTile(
                          value: uids.contains(user.uid),
                          onChanged: (val) {
                            if (val!) {
                              addUid(user.uid);
                            } else {
                              removeUid(user.uid);
                            }
                          },
                          title: Text(user.name),
                        );
                      },
                      error: (error, stackTrace) => ErrorText(
                        error: error.toString(),
                      ),
                      loading: () => const Loader(),
                    );
              },
            ),
            error: (error, stackTrace) => ErrorText(
              error: error.toString(),
            ),
            loading: () => const Loader(),
          ),
    );
  }
}
