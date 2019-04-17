import 'dart:io';

import 'package:spike_view_project/modal/StudentDataModel.dart';

class ProfileInfoModal {

Address address;


  String userId,groupId,groupName,groupImage,
      firstName,lastName,
      email,
      mobileNo,
      profilePicture,
      roleId,
      isActive,
      requireParentApproval,
      ccToParents,
      lastAccess,
      isPasswordChanged,
      organizationId,
      gender,
      dob,
      genderAtBirth,
      usCitizenOrPR,

      summary,
      coverImage,
      tagline,
      title,
      tempPassword,
      isArchived;
  bool isSelected=false;
  List<ParentModal> parentList;

  ProfileInfoModal(this.userId, this.firstName, this.lastName, this.email,
      this.mobileNo, this.profilePicture, this.roleId, this.isActive,
      this.requireParentApproval, this.ccToParents, this.lastAccess,
      this.isPasswordChanged, this.organizationId, this.gender, this.dob,
      this.genderAtBirth, this.usCitizenOrPR, this.address, this.summary,
      this.coverImage, this.tagline, this.title, this.tempPassword,
      this.isArchived, this.parentList,this.isSelected,this.groupId,this.groupName,this.groupImage);

Map<String, dynamic> toJson() => {
  'userId': int.parse(userId),

};
}


class ParentModal {
  String email, userId;

  ParentModal(this.email, this.userId);
  Map<String, dynamic> toJson() => {
    'email': email,
    'userId': userId,
  };
}
