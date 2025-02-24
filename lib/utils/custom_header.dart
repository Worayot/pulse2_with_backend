import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pulse/provider/user_data_provider.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen for changes in UserDataProvider
    final userDataProvider = Provider.of<UserDataProvider>(context);

    String firstLetter =
        userDataProvider.name.isNotEmpty ? userDataProvider.name[0] : 'N';

    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            child: Text(
              firstLetter,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userDataProvider.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${"nurseID".tr()} : ${userDataProvider.nurseID}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
