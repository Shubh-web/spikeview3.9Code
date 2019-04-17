import 'package:flutter/painting.dart';

class Constant {
 // static const String BASE_URL = "http://server1.lmsin.com/rentalnew/api/";
 static const String BASE_URL = "https://spikeview.com:3002/";
 // static const String BASE_URL = "http://103.76.253.131:3002/";
 // static const String BASE_URL = "http://103.76.253.131:3002/";

  // ignore: missing_identifier, const_initialized_with_non_constant_value
  static const String ENCRYPTIONKEY= "sd5b75nb7577#^%\$%*&G#CGF*&%@#%*&";

  static const String VALIDATION_PASSWORD_LENGTH =
      "Password length must be 6 digit";

  static const int SERVICE_TIME_OUT = 60000 ;

  static const int CONNECTION_TIME_OUT = 60000 ;
/*  static const String IMAGE_PATH =  "http://server1.lmsin.com/rentalnew/uploads/property/";
  static const String BASE_IMAGE_PATH =  "http://server1.lmsin.com/rentalnew/uploads/";
  static const String COMMON_PATH =  "http://server1.lmsin.com/rentalnew/uploads/";
  static const String PROFILE_IMAGE_PATH =  "http://server1.lmsin.com/rentalnew/uploads/userProfile/";*/
 // http://spikeviewmediastorage.blob.core.windows.net/spikeview-media-development-thumbnails/sv_1031/profile/m-1546002856165hbShE.jpg


//static  String CONTAINER_NAME ="spikeview-media-development";
static  String CONTAINER_NAME ="spikeview-media-production";
  static  String IMAGE_PATH =  "http://spikeviewmediastorage.blob.core.windows.net/"+CONTAINER_NAME+"/";
  static  String IMAGE_PATH_SMALL =  "http://spikeviewmediastorage.blob.core.windows.net/"+CONTAINER_NAME+"/";

// static  String IMAGE_PATH_SMALL =  "http://spikeviewmediastorage.blob.core.windows.net/"+CONTAINER_NAME+"-thumbnails/";
 //static  String IMAGE_PATH_SMALL =  "http://spikeviewmediastorage.blob.core.windows.net/"+CONTAINER_NAME+"/";

  static const String BASE_IMAGE_PATH =  "http://server1.lmsin.com/rentalApp/uploads/";

  //static const String IMAGE_PATH =  "https://spikeviewmediastorage.blob.core.windows.net/spikeview-media-production/";
  static const String CONTAINER_COVER=  "cover";
  static const String CONTAINER_FEED=  "feeds";
  static const String CONTAINER_MEDIA=  "media";
  static const String CONTAINER_ORGANIZATION=  "oragnization";
  static const String CONTAINER_PROFILE = "profile";
  static const String CONTAINER_PREFIX = "sv_";

  static const String COMMON_PATH =  "http://server1.lmsin.com/rentalApp/uploads/";
  static const String PROFILE_IMAGE_PATH =  "http://server1.lmsin.com/rentalApp/uploads/userProfile/";

  // REGISTRATION API KEY'S
  static const String ENDPOINT_REGISTRATION = "register";
  static const String ENDPOINT_LOGIN = "app/login";
  static const String ENDPOINT_NOTIFICATION_COUNT = "ui/header?userId=";
  static const String ENDPOINT_PARENT_SIGNUP = "app/signup";
  static const String ENDPOINT_FORGOT_PASSWORD = "app/reset/password?email=";

  static const String ENDPOINT_FOROT_PASSWORD = "app/forgotPassword";
  static const String ENDPOINT_CHANGE_PASSWORD = "ui/update/password";
  static const String ENDPOINT_PERSONAL_INFO = "ui/personalInfo/";
 static const String ENDPOINT_CHAT_LIST= "ui/message/friendList/info?userId=";
 // static const String ENDPOINT_CHAT_LIST= "ui/connect/chatList?userId=";


  static const String ENDPOINT_NOTIFICATION_ALL= "ui/notification?userId=";
 static const String ENDPOINT_CHECK_IS_FRIEND = "ui/connect/status?userId=";
 static const String ENDPOINT_SHARE_LOG = "ui/share/profile/list?profileOwner=";
 static const String ENDPOINT_GROUPS= "ui/group/mygroups/";
 static const String ENDPOINT_GROUPS_MEMBERS= "ui/group/members/";
 static const String ENDPOINT_CHECK_IS_SUBSCRIBE = "ui/subscription?userId=";
 static const String ENDPOINT_SHARE_PROFILE = "ui/share/profile";
 static const String ENDPOINT_FRIEND_LIST= "ui/mutual/friendlist?userId=";
 static const String ENDPOINT_SEARCH= "ui/search?name=";
 static const String ENDPOINT_REMOVE_COMMENT= "ui/remove/comment";
 static const String ENDPOINT_SUBSCRIBE= "/ui/subscription";

  static const String ENDPOINT_USER_CONNECTION_LIST= "ui/connect/chatList?userId=";
  static const String ENDPOINT_CONNECTION_LIST= "ui/connect/list?userId=";
  static const String ENDPOINT_CONNECTION_UPDATE= "ui/connect";
  static const String ENDPOINT_ADD_RECOMMENDATION= "ui/recommendation";
  static const String ENDPOINT_UPDATE_GROUP_REQUEST= "ui/group/updateMemberStatus";
  static const String ENDPOINT_INVITE_BY_EMAIL= "ui/group/inviteMembers";
  static const String ENDPOINT_LEAVE_GROUP= "ui/group/leave";
  static const String ENDPOINT_FEED_UPDATE= "ui/feed/update";
  static const String ENDPOINT_NOTIFICATION_UPDATE= "ui/header";
  static const String ENDPOINT_FEED_DELETE= "ui/feed";
  static const String ENDPOINT_NOTIFICATION_DELETE= "ui/notification";
  static const String ENDPOINT_ADD_LIKE= "/ui/feed/addLike";
  static const String ENDPOINT_PARENT_PERSONAL_INFO = "ui/personalInfo";
  static const String ENDPOINT_PARENT_PERSONAL_UPDATEUSER_STATUS = "ui/user/updateUserStatus";
  static const String ENDPOINT_SHARE_UPDATE = "ui/share/profile";
  static const String ENDPOINT_PARENT_STUDENTSBYPARENT = "ui/user/studentsbyparent/";
  static const String ENDPOINT_EDUCATION = "ui/education?userId=";
  static const String ENDPOINT_RECOMMENDATION= "ui/user/recommendations?userId=";
  static const String ENDPOINT_ACC_REC_COUNT = "ui/counts/";
  static const String ENDPOINT_ORGANIZATION_LIST= "ui/organization";
  static const String ENDPOINT_ACHIEVMENT_LEVEL_LIST= "ui/importance";
  static const String ENDPOINT_ACHIEVMENT_SKILLS= "ui/skills";
  static const String ENDPOINT_ADD_ACHEVMENT= "ui/achievement";
  static const String ENDPOINT_ADD_RECOOMENDATION= "ui/recommendation";
  static const String ENDPOINT_COMPENTENCY= "ui/competencyAllLevel";
  static const String ENDPOINT_ADD_ORGANIZATION= "ui/education";
  static const String ENDPOINT_USER_COVER_PHOTO_UPDATE= "ui/user";
  static const String ENDPOINT_GROUP_PHOTO_UPDATE= "ui/group";
  static const String ENDPOINT_JOIN_GROUP= "ui/group/join";
  static const String ENDPOINT_PARENT_ADD= "ui/add/parent";
  static const String ENDPOINT_ADD_GROUP= "ui/group";
  static const String ENDPOINT_UPDATE_GROUP= "ui/group/updateGroupInfo";
  static const String ENDPOINT_SAS= "ui/azure/sas";
  static const String ENDPOINT_NARRATIVE= "ui/narratives/";
  static const String ENDPOINT_SPIDER_CHART= "ui/spider/chart/";
  static const String ENDPOINT_ADD_FEED_COMMENT= "ui/feed/addComment";
  static const String ENDPOINT_INVITE_MEMBER= "ui/group/inviteMembers";

  static const String ENDPOINT_ADD_FEED= "ui/feed";
  static const String ENDPOINT_SHARE_FEED= "ui/share/feed";

  static bool IS_INDIVIDUAL = true;
}


