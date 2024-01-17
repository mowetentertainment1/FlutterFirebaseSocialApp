import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/core/common/error_text.dart';
import 'package:untitled/core/common/loader.dart';
import 'package:untitled/features/community/controller/community_controller.dart';

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
    return ref.watch(searchCommunityProvider(query)).when(
        data: (communities) {
          return ListView.builder(
              itemCount: communities.length,
              itemBuilder: (context, index) {
                final community = communities[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(community.avatar),
                  ),
                  title: Text('r/${community.name}'),
                  onTap: () {
                    navigateToCommunity(context, community.name);
                  },
                );
              });
        },
        loading: () => const Loader(),
        error: (error, stackTrace) => ErrorText(
              error: error.toString(),
            ));
  }

  void navigateToCommunity(BuildContext context, String communityName) {
    Routemaster.of(context).push('/r/${communityName}');
  }
}
