import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/core/constants/constants.dart';
import 'package:untitled/theme/pallete.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../core/utils.dart';
import '../controller/community_controller.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String communityName;

  const EditCommunityScreen({super.key, required this.communityName});

  @override
  ConsumerState createState() => _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? avatarFile;

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


  @override
  Widget build(BuildContext context) {
    return ref.watch(getCommunityByNameProvider(widget.communityName)).when(
          data: (community) => Scaffold(
            appBar: AppBar(
              backgroundColor: Pallete.darkModeAppTheme.backgroundColor,
              title: const Text('Edit Community'),
              actions: [
                TextButton(
                    onPressed: () {},
                    child: const Text('Save',
                        style: TextStyle(color: Colors.blue)))
              ],
            ),
            body: Padding(
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
                          color: Pallete
                              .darkModeAppTheme.textTheme.bodyText2!.color!,
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
                                        child:
                                            Icon(Icons.add_a_photo, size: 40))
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
                            child: avatarFile != null ? CircleAvatar(
                              backgroundImage: FileImage(avatarFile!),
                              radius: 35,
                            ): CircleAvatar(
                              backgroundImage: NetworkImage(community.avatar),
                              radius: 35,
                            ),
                          ))
                    ]),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(10),
                    ),
                    maxLength: 50,
                    controller: TextEditingController(
                        text: community.description),
                  ),
                ],
              ),
            ),
          ),
          loading: () => const Loader(),
          error: (error, stackTrace) => ErrorText(
            error: error.toString(),
          ),
        );
  }
}
