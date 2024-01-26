enum ThemeType {
  light,
  dark,
}enum UserKarma {
  comment(1),
  textPost(5),
  imagePost(10),
  deletePost(-5);

  final int karma;
  const UserKarma(this.karma);
}


