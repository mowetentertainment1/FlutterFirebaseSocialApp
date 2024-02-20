import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/core/common/error_text.dart';
import 'package:untitled/core/common/loader.dart';
import 'package:untitled/features/community/controller/community_controller.dart';
import 'package:untitled/features/home/user_profile/controller/user_profile_controller.dart';

class SelectContactScreen extends SearchDelegate {
  final WidgetRef ref;
  SelectContactScreen({required this.ref});
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = "",
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ref.watch(searchUserProvider(query)).when(
        data: (users) {
          return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.profilePic),
                  ),
                  title: Text('r/${user.name}'),
                  onTap: () {
                    navigateToChatBox(context, user.name, user.uid);
                  },
                );
              });
        },
        loading: () => const Loader(),
        error: (error, stackTrace) => ErrorText(
              error: error.toString(),
            ));
  }

  void navigateToChatBox(BuildContext context, String userName, String userId) {
    Routemaster.of(context).push('/chat/$userName/$userId');
  }
}
