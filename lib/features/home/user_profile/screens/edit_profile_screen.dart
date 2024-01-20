import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/material.dart';
import 'package:untitled/features/auth/controller/auth_controller.dart';

import '../../../../core/common/error_text.dart';
import '../../../../core/common/loader.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/utils.dart';
import '../../../../theme/pallete.dart';


class EditProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreen({super.key, required this.uid});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerFile;
  File? avatarFile;
  late TextEditingController _communityDesController ;
  late TextEditingController _userNameController ;
  @override
  void initState() {
    super.initState();
    _communityDesController = TextEditingController(text: ref.read(userProvider)!.description);
    _userNameController = TextEditingController(text: ref.read(userProvider)!.name);
  }
  @override
  void dispose() {
    super.dispose();
    _communityDesController.dispose();
    _userNameController.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.single.path!);
      });
    }
  }

  void selectAvatarImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        avatarFile = File(res.files.single.path!);
      });
    }
  }

  // void save(Community community) {
  //   ref.read(communityControllerProvider.notifier).editCommunity(
  //       avatarFile: avatarFile,
  //       bannerFile: bannerFile,
  //       context: context,
  //       community: community,
  //       description: _communityDesController.text);
  // }

  @override
  Widget build(BuildContext context) {
    // final isLoading = ref.watch(communityControllerProvider);
    return ref.watch(getUserDataProvider(widget.uid)).when(
      data: (community) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Pallete.darkModeAppTheme.backgroundColor,
            title: const Text('Edit Community'),
            actions: [
              TextButton(
                  onPressed: () {
                    // save(community);
                  },
                  child: const Text('Save',
                      style: TextStyle(color: Colors.blue)))
            ],
          ),
          body:
          // isLoading
          //     ? const Loader()
          //     :
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(children: [
                    GestureDetector(
                      onTap: () => selectBannerImage(),
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(10),
                        dashPattern: const [12, 4],
                        strokeCap: StrokeCap.round,
                        color: Pallete.darkModeAppTheme.textTheme
                            .bodyText2!.color!,
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: double.infinity,
                          child: bannerFile != null
                              ? Image.file(bannerFile!)
                              : community.banner.isEmpty ||
                              community.banner ==
                                  Constants.bannerDefault
                              ? const Center(
                              child: Icon(Icons.add_a_photo,
                                  size: 40))
                              : Image.network(community.banner,
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: 20,
                        left: 30,
                        child: GestureDetector(
                          onTap: () => selectAvatarImage(),
                          child: avatarFile != null
                              ? CircleAvatar(
                            backgroundImage:
                            FileImage(avatarFile!),
                            radius: 35,
                          )
                              : CircleAvatar(
                            backgroundImage:
                            NetworkImage(community.profilePic),
                            radius: 35,
                          ),
                        ))
                  ]),
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(10),
                  ),
                  maxLength: 21,
                  controller: _userNameController,
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(10),
                  ),
                  maxLength: 50,
                  controller: _communityDesController,
                ),
              ],
            ),
          ),
        );},
      loading: () => const Loader(),
      error: (error, stackTrace) => ErrorText(
        error: error.toString(),
      ),
    );
  }
}
