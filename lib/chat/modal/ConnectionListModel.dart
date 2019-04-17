class ConnectionListModel {
  final String userId;
  final String firstName, lastName;
  final String email, profilePicture;
  final int dateTime;

  final String partnerFirstName, partnerLastName, partnerProfilePicture,lastMessage, unreadMessageCount;

  final String receiverId, connectId;

  ConnectionListModel(
      this.userId,
      this.firstName,
      this.lastName,
      this.email,
      this.profilePicture,
      this.dateTime,
      this.receiverId,
      this.connectId,
      this.lastMessage,
      this.unreadMessageCount,
      this.partnerFirstName,
      this.partnerLastName,
      this.partnerProfilePicture);
}
