import 'dart:io';

class RequestedTagModel {
  String _id,connectId,userId,partnerId,dateTime,status,userIsActive;
  Patner patner;


  RequestedTagModel(this._id, this.connectId, this.userId, this.partnerId, this.dateTime,
      this.status,this.userIsActive, this.patner);
}


class Patner{
  String _id,userId,firstName,lastName,email,password,salt,mobileNo,roleId,
      isActive,isPasswordChanged,organizationId,dob,isArchived,profilePicture,requireParentApproval,ccToParents,lastAccess,gender
  ,genderAtBirth,usCitizenOrPR,address,summary,coverImage,tagline,title,tempPassword;

  Patner(this._id, this.userId, this.firstName, this.lastName, this.email,
      this.password, this.salt, this.mobileNo, this.roleId, this.isActive,
      this.isPasswordChanged, this.organizationId, this.dob, this.isArchived,
      this.profilePicture, this.requireParentApproval, this.ccToParents,
      this.lastAccess, this.gender, this.genderAtBirth, this.usCitizenOrPR,
      this.address, this.summary, this.coverImage, this.tagline, this.title,
      this.tempPassword);


}
