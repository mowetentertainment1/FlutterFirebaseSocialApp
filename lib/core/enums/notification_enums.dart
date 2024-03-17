enum NotificationEnum {
  post('post'),
  video('video'),
  follow('follow');

  const NotificationEnum(this.type);
  final String type;
}

extension ConvertNotification on String {
  NotificationEnum toEnum() {
    switch (this) {
      case 'post':
        return NotificationEnum.post;
      case 'video':
        return NotificationEnum.video;
      case 'follow':
        return NotificationEnum.follow;
      default:
        return NotificationEnum.post;
    }
  }
}
