import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:untitled/features/auth/controller/auth_controller.dart';
import 'package:untitled/features/home/user_profile/controller/user_profile_controller.dart';
import 'package:untitled/model/user.dart';

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
  late TextEditingController _userDesController ;
  late TextEditingController _userNameController ;
  @override
  void initState() {
    super.initState();
    _userDesController = TextEditingController(text: ref.read(userProvider)!.description);
    _userNameController = TextEditingController(text: ref.read(userProvider)!.name);
  }
  @override
  void dispose() {
    super.dispose();
    _userDesController.dispose();
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

  void save(UserModel user) {
    ref.read(userProfileControllerProvider.notifier).editUser(
        avatarFile: avatarFile,
        bannerFile: bannerFile,
        context: context,
        name: _userNameController.text.trim(),
        description: _userDesController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userProfileControllerProvider);
    return ref.watch(getUserDataProvider(widget.uid)).when(
      data: (user) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit profile'),
            actions: [
              TextButton(
                  onPressed: () {
                    save(user);
                  },
                  child: const Text('Save',
                      style: TextStyle(color: Colors.blue)))
            ],
          ),
          body:
          isLoading
              ? const Loader()
              :
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
                              : user.banner.isEmpty ||
                              user.banner ==
                                  Constants.bannerDefault
                              ? const Center(
                              child: Icon(Icons.add_a_photo,
                                  size: 40))
                              : Image.network(user.banner,
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
                            NetworkImage(user.profilePic),
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
                  controller: _userDesController,
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
