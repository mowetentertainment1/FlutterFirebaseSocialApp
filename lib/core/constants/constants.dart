import 'package:untitled/features/chat/screens/chat_screen.dart';
import 'package:untitled/features/feed/feed_screen.dart';

import '../../features/notification/screens/notification_screen.dart';
import '../../features/post/screens/create_post_screen.dart';

class Constants {
  static const logoPath = "assets/images/logo.jpg";
  static const loginEmotePath = "assets/images/logo.jpg";
  static const googlePath = "assets/images/google.png";
  static const bannerDefault =
      'https://raw.githubusercontent.com/seven1106/host-file/master/social_app/High_resolution_wallpaper_background_ID_77701520645.webp';
  static const avatarDefault =
      'https://raw.githubusercontent.com/seven1106/host-file/master/social_app/avt_default.jpg';
  static const communityAvatarPath = "community/avatar";
  static const communityBannerPath = "community/banner";
  static const tabWidgets = [
    FeedScreen(),
    CreatePostScreen(),
    ChatScreen(),
    NotificationScreen(),

  ];
}
