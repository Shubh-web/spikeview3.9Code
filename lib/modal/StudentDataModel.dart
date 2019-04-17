import 'dart:io';

class StudentDataModel {

List<Parents> parentList;
Address address;
String userId,firstName,lastName,email,mobileNo,profilePicture,roleId,isActive,
    requireParentApproval,ccToParents,lastAccess,isPasswordChanged,organizationId,gender,dob,
    genderAtBirth,usCitizenOrPR,summary,coverImage,tagline,title,tempPassword,isArchived;

StudentDataModel( this.userId, this.firstName,
    this.lastName, this.email, this.mobileNo, this.profilePicture, this.roleId,
    this.isActive, this.requireParentApproval, this.ccToParents,
    this.lastAccess, this.isPasswordChanged, this.organizationId, this.gender,
    this.dob, this.genderAtBirth, this.usCitizenOrPR, this.summary,
    this.coverImage, this.tagline, this.title, this.tempPassword,
    this.isArchived,this.parentList, this.address,);


}
class Address{
  String street1,street2,city,state,country,zip;

  Address(this.street1, this.street2, this.city, this.state, this.country,
      this.zip);

}

class Parents{
  String email,userId;

  Parents(this.email, this.userId);

}