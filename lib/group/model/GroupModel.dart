import 'dart:io';

import 'package:spike_view_project/modal/StudentDataModel.dart';

class GroupModel {
String groupId,groupName,type,creationDate,createdBy,isActive ,aboutGroup,otherInfo,groupImage,status;
bool isAdmin=false;
String acceptCount;
List<MemberModel> memberList;

GroupModel(this.groupId, this.groupName, this.type, this.creationDate,
    this.createdBy, this.isActive, this.aboutGroup, this.otherInfo,
    this.groupImage,this.memberList,this.isAdmin,this.status,this.acceptCount);

}

class MemberModel {
  String status,isAdmin,userId;

  MemberModel(this.status, this.isAdmin, this.userId);

}
