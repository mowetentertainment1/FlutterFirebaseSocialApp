import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import '../../../responsive/responsive.dart';
import '../controller/community_controller.dart';

class ModToolScreen extends ConsumerStatefulWidget {
  final String communityName;

  const ModToolScreen({super.key, required this.communityName});




  ConsumerState createState() => _ModToolScreen();
}

class _ModToolScreen extends ConsumerState<ModToolScreen> {
  String get communityName => widget.communityName;
  void deleteCommunity(BuildContext context, String communityName) {
    ref.read(communityControllerProvider.notifier).deleteCommunity(communityName, context);

  }
  void showDeleteDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete Community'),
            content: const Text('Are you sure you want to delete this community?'),
            actions: [
              TextButton(
                  onPressed: () => Routemaster.of(context).pop(),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => deleteCommunity(context, communityName),
                  child: const Text('Delete')),
            ],
          );
        });
  }
  void navigateToEditCommunity(BuildContext context) {
    Routemaster.of(context).push('/edit-community/$communityName');
  }
  void navigateToAddMods(BuildContext context) {
    Routemaster.of(context).push('/add_mods/$communityName');
  }

  @override
  Widget build(BuildContext context) {
    return Responsive(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Mod Tools'),
          ),
          body: Column(children: [
            ListTile(
                leading: const Icon(Icons.add_moderator),
                title: const Text('Add Moderators'),
                onTap: () => navigateToAddMods(context)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Community'),
              onTap: () => navigateToEditCommunity(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Community'),
              onTap: () => showDeleteDialog(context),
            ),
            const Divider(),
          ])),
    );
  }
}
