import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final TextEditingController _communityNameController =
      TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _communityNameController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Community'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
               const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Community Name:')),
              const SizedBox(height: 14),
              TextField(
                controller: _communityNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'r/Community_name',
                  contentPadding: EdgeInsets.all(10),
                ),
                maxLength: 21,
              ),
              const SizedBox(height: 34),
              ElevatedButton(
                onPressed: () {},

                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blueAccent,

                ),
                child: const Text('Create Community', style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),),

              )
            ],
          )),
    );
  }
}
