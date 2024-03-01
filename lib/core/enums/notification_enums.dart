enum NotificationEnum {
  post('post'),
  upvote('upvote'),
  downvote('downvote'),
  reply('reply'),
  comment('comment'),
  invite('invite'),
  follow('follow');

  const NotificationEnum(this.type);
  final String type;
}

extension ConvertNotification on String {
  NotificationEnum toEnum() {
    switch (this) {
      case 'upvote':
        return NotificationEnum.upvote;
      case 'downvote':
        return NotificationEnum.downvote;
      case 'post':
        return NotificationEnum.post;
      case 'reply':
        return NotificationEnum.reply;
      case 'comment':
        return NotificationEnum.comment;
      case 'invite':
        return NotificationEnum.invite;
      case 'follow':
        return NotificationEnum.follow;
      default:
        return NotificationEnum.post;
    }
  }
}
