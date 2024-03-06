import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/core/common/error_text.dart';
import 'package:untitled/core/common/loader.dart';
import 'package:untitled/features/community/controller/community_controller.dart';
import 'package:untitled/features/home/user_profile/controller/user_profile_controller.dart';

class SearchCommunityScreen extends SearchDelegate {
  final WidgetRef ref;
  SearchCommunityScreen({required this.ref});
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
    return ref.watch(searchCommunityProvider(query)).when(data: (communities) {
      return ref.watch(searchUserProvider(query)).when(
          data: (users) {
            return ListView.builder(
                itemCount: communities.length + users.length,
                itemBuilder: (context, index) {
                  if (index < communities.length) {
                    return ListTile(
                      title: Text('r/${communities[index].name}'),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(communities[index].avatar),
                      ),
                      onTap: () {
                        navigateToCommunity(context, communities[index].name);
                      },
                    );
                  } else {
                    return ListTile(
                      title: Text('u/${users[index - communities.length].name}'),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(users[index].profilePic),
                      ),
                      onTap: () => navigateToUserProfile(context, users[index].uid,
                          users[index].name, users[index].token),
                    );
                  }
                });
          },
          loading: () => const Loader(),
          error: (error, stackTrace) => ErrorText(
                error: error.toString(),
              ));
    }, error: (Object error, StackTrace stackTrace) {
      return ErrorText(error: error.toString());
    }, loading: () {
      return const Loader();
    });
  }

  void navigateToCommunity(BuildContext context, String communityName) {
    Routemaster.of(context).push('/r/$communityName');
  }

  void navigateToUserProfile(
      BuildContext context, String uid, String name, String token) {
    Routemaster.of(context).push('/u/$name/$uid/$token');
  }
}
