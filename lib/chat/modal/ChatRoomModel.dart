class ChatRoomModel {
  String messageId, connectorId, sender, receiver, time, text, type, status;

  ChatRoomModel(String messageId, String connectorId, String sender,
      String receiver, String time, String text, String type, String status) {
    this.messageId = messageId;
    this.connectorId = connectorId;
    this.sender = sender;
    this.receiver = receiver;
    this.time = time;
    this.text = text;
    this.type = type;
    this.status = status;
  }
}
