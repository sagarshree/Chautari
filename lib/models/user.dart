class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;

  User(
      {this.id,
      this.username,
      this.email,
      this.displayName,
      this.photoUrl,
      this.bio});

  factory User.fromDocuments(doc) {
    return User(
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      bio: doc['bio'],
    );
  }
}
