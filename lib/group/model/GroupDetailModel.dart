import 'dart:io';

import 'package:spike_view_project/modal/StudentDataModel.dart';

class GroupDetailModel {
String _id,groupId,groupName,type,creationDate,createdBy,isActive ,aboutGroup,otherInfo,groupImage,status;
bool isAdmin=false;
String adminName;

List<MemberModelDetail> memberList;

GroupDetailModel(this._id, this.groupId, this.groupName, this.type,
    this.creationDate, this.createdBy, this.isActive, this.aboutGroup,
    this.otherInfo, this.groupImage,
    this.memberList, this.isAdmin,this.status,this.adminName);


}

class MemberModelDetail {
  String status,isAdmin,userId,roleId,firstName,lastName,profilePicture,email,tagline;

  MemberModelDetail(this.status, this.isAdmin, this.userId, this.roleId,
      this.firstName, this.lastName, this.profilePicture, this.email,
      this.tagline);


}
