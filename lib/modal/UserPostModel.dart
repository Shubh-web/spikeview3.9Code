import 'dart:io';
import 'package:flutter/material.dart';

class UserPostModal {
  String _id,
      feedId,
      postedBy,
      dateTime,
      visibility,
      firstName,
      lastName,
      email,
      profilePicture,
      title,
      tagline,
      shareText,
      shareTime,
      postOwner,
      postOwnerFirstName,
      postOwnerLastName,
      postOwnerTitle,
      postOwnerProfilePicture,
      lastActivityTime,
      lastActivityType;
bool isReadMore=false;
bool isShareMore=false;
  PostData postdata;
  List<CommentData> commentList;
  List<Likes> likeList;
  List<Tags> tagList;
  List<String> scopeList;
  bool isLike;
  bool isCommented;
  bool isCommentIconVisible = false;
  TextEditingController txtController;

  UserPostModal(
      this._id,
      this.feedId,
      this.postedBy,
      this.dateTime,
      this.visibility,
      this.firstName,
      this.lastName,
      this.email,
      this.profilePicture,
      this.title,
      this.tagline,
      this.shareText,
      this.shareTime,
      this.postOwner,
      this.postOwnerFirstName,
      this.postOwnerLastName,
      this.postOwnerTitle,
      this.postOwnerProfilePicture,
      this.isLike,
      this.isCommented,
      this.postdata,
      this.commentList,
      this.likeList,
      this.tagList,
      this.scopeList,
      this.isCommentIconVisible,
      this.txtController,
      this.lastActivityTime,
      this.lastActivityType,this.isReadMore,this.isShareMore);
}

class PostData {
  List<String> imageList;
  String text, media;

  PostData(this.imageList, this.text, this.media);
}

class CommentData {
  bool isLike;
  String commentId,
      comment,
      commentedBy,
      dateTime,
      profilePicture,
      name,
      title,
      userId;
  List<Likes> likesList;

  CommentData(
      this.commentId,
      this.comment,
      this.commentedBy,
      this.dateTime,
      this.profilePicture,
      this.name,
      this.title,
      this.userId,
      this.likesList,
      this.isLike);
}

class Likes {
  String userId, name, profilePicture, title;

  Likes(this.userId, this.name, this.profilePicture, this.title);
}

class Tags {
  String userId, name, profilePicture, title;

  Tags(this.userId, this.name, this.profilePicture, this.title);
}
