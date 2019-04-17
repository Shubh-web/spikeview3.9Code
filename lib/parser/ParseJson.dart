import 'package:dio/dio.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/chat/modal/ConnectionListModel.dart';
import 'package:spike_view_project/common/Connectivity.dart';
import 'package:spike_view_project/common/CustomProgressDialog.dart';
import 'package:spike_view_project/group/model/GroupDetailModel.dart';
import 'package:spike_view_project/group/model/GroupModel.dart';
import 'package:spike_view_project/modal/AcvhievmentImportanceMOdal.dart';
import 'package:spike_view_project/modal/AcvhievmentSkillModel.dart';
import 'package:spike_view_project/modal/CompetencyModel.dart';
import 'package:spike_view_project/modal/ConnectionNotificationModel.dart';
import 'package:spike_view_project/modal/NarrativeModel.dart';
import 'package:spike_view_project/modal/OrganizationModel.dart';
import 'package:spike_view_project/modal/ProfileEducationModel.dart';
import 'package:spike_view_project/modal/ProfileInfoModel.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:spike_view_project/ResponseDart/LoginResponseConstant.dart';
import 'package:spike_view_project/UserPreferences/UserPreference.dart';
import 'package:spike_view_project/common/Connectivity.dart';
import 'package:spike_view_project/common/CustomProgressDialog.dart';
import 'package:spike_view_project/common/ToastWrap.dart';
import 'package:spike_view_project/constant/Constant.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_view_project/constant/Padding_Wrap.dart';
import 'package:spike_view_project/constant/TextView_Wrap.dart';
import 'package:spike_view_project/modal/ProfileInfoModel.dart';
import 'package:spike_view_project/modal/ProfileShareLogModel.dart';
import 'package:spike_view_project/modal/RequestedTagListModel.dart';
import 'package:spike_view_project/modal/SpiderChartModel.dart';
import 'package:spike_view_project/modal/StudentDataModel.dart';
import 'package:spike_view_project/modal/TagModel.dart';
import 'package:spike_view_project/modal/UserPostModel.dart';
import 'package:spike_view_project/notification/model/NotificationModel.dart';
import 'package:spike_view_project/values/ColorValues.dart';

class ParseJson {
  static String getMediumImage(image) {
    if (image == null || image == "" || image == "null") {
      return "";
    } else {
    /*   image = image.replaceAll(
          image.substring(image.lastIndexOf("/") + 1, image.length),
          "m-" + image.substring(image.lastIndexOf("/") + 1, image.length));*/
      return image;
    }
  }

  static String getSmallImage(image) {
    if (image == null || image == "" || image == "null") {
      return "";
    } else {
      /*  image = image.replaceAll(
          image.substring(image.lastIndexOf("/") + 1, image.length),
          "s-" + image.substring(image.lastIndexOf("/") + 1, image.length));*/
      return image;
    }
  }

  static ProfileInfoModal parseMapUserProfile(data) {
    ProfileInfoModal profileInfoModal;
    String groupId = "";
    String groupName = "";
    String groupImage = "";
    String userId = data[ProfileInfoResponse.USER_ID].toString();
    try {
      groupId = data['groupId'].toString();
      groupName = data['groupName'].toString();
      groupImage = data['groupImage'].toString();
    } catch (e) {}
    String firstName = data[ProfileInfoResponse.FIRSTNAME].toString();
    String lastName = data[ProfileInfoResponse.LASTNAME].toString();
    String email = data[ProfileInfoResponse.EMAIL].toString();
    String mobileNo = data[ProfileInfoResponse.MOBILE].toString();
    String profilePicture =
        data[ProfileInfoResponse.PROFILE_PICTURE].toString();
    //   profilePicture= getMediumImage(profilePicture);
    String roleId = data[ProfileInfoResponse.ROLE_ID].toString();
    String isActive = data[ProfileInfoResponse.IS_ACTIVE].toString();
    String requireParentApproval =
        data[ProfileInfoResponse.REQUIRE_PARENT_APPROVEL].toString();
    String ccToParents = data[ProfileInfoResponse.CC_TO_PARENTS].toString();
    String lastAccess = data[ProfileInfoResponse.LAST_ACCESS].toString();
    String isPasswordChanged =
        data[ProfileInfoResponse.IS_PASSWORD_CHANGED].toString();
    String organizationId =
        data[ProfileInfoResponse.ORGANIZATION_ID].toString();
    String gender = data[ProfileInfoResponse.GENDER].toString();
    String dob = data[ProfileInfoResponse.DOB].toString();
    String genderAtBirth = data[ProfileInfoResponse.GENDER_AT_BIRTH].toString();
    String usCitizenOrPR =
        data[ProfileInfoResponse.US_CITIZEN_OR_PR].toString();

    var addressMap = data['address'];
    Address addressModal = new Address("", "", "", "", "", "");
    if (addressMap != null) {
      String street1 = addressMap['street1'].toString();
      String street2 = addressMap['street2'].toString();
      String city = addressMap['city'].toString();
      String state = addressMap['state'].toString();
      String country = addressMap['country'].toString();
      String zip = addressMap['zip'].toString();
      addressModal = new Address(street1, street2, city, state, country, zip);
    }

    String summary = data[ProfileInfoResponse.SUMMARY].toString();
    String coverImage = data[ProfileInfoResponse.COVER_IMAGE].toString();
    //   coverImage= getMediumImage(coverImage);
    String tagline = data[ProfileInfoResponse.TAGLINE].toString();
    String title = data[ProfileInfoResponse.TITLE].toString();
    String tempPassword = data[ProfileInfoResponse.TEMP_PASSWORD].toString();
    String isArchived = data[ProfileInfoResponse.IS_ARCHIVED].toString();
    List<ParentModal> parentList = new List();

    for (int i = 0; i < data[ProfileInfoResponse.PARENTS].length; i++) {
      String email = data[ProfileInfoResponse.PARENTS][i]
              [ProfileInfoResponse.EMAIL]
          .toString();
      String userId = data[ProfileInfoResponse.PARENTS][i]
              [ProfileInfoResponse.USER_ID]
          .toString();
      parentList.add(new ParentModal(email, userId));
    }
    /*  if (profilePicture != "") {
      strNetworkImage = profilePicture;
    }*/

    profileInfoModal = new ProfileInfoModal(
        userId,
        firstName,
        lastName,
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
        addressModal,
        summary,
        coverImage,
        tagline,
        title,
        tempPassword,
        isArchived,
        parentList,
        false,
        groupId,
        groupName,
        groupImage);

    return profileInfoModal;
  }

  static List<UserPostModal> parseHomeData(map, userIdPref) {
    List<UserPostModal> userPostList = new List<UserPostModal>();
    for (int i = 0; i < map.length; i++) {
      try {
        bool isLike = false;
        bool isCommented = false;
        String _id = map[i]['_id'].toString();
        String feedId = map[i]['feedId'].toString();
        String postedBy = map[i]['postedBy'].toString();
        String dateTime = map[i]['dateTime'].toString();
        String visibility = map[i]['visibility'].toString();
        String firstName = map[i]['firstName'].toString();
        String lastName = map[i]['lastName'].toString();
        String email = map[i]['email'].toString();
        String profilePicture = map[i]['profilePicture'].toString();

        // profilePicture = getSmallImage(profilePicture);

        String title = map[i]['title'].toString();
        String tagline = map[i]['tagline'].toString();
        String shareText = map[i]['shareText'].toString();
        String shareTime = map[i]['shareTime'].toString();
        String lastActivityTime = map[i]['lastActivityTime'].toString();
        String lastActivityType = map[i]['lastActivityType'].toString();

        String postOwner = map[i]['postOwner'].toString();
        String postOwnerFirstName = map[i]['postOwnerFirstName'].toString();
        String postOwnerLastName = map[i]['postOwnerLastName'].toString();
        String postOwnerTitle = map[i]['postOwnerTitle'].toString();
        String postOwnerProfilePicture =
            map[i]['postOwnerProfilePicture'].toString();
        //   postOwnerProfilePicture = getSmallImage(postOwnerProfilePicture);
        DateTime currentDate = new DateTime.now();
        if (dateTime != "null") {
          int d = int.tryParse(dateTime);
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(d);

          final differenceDay = currentDate.difference(date).inDays;
          final differenceHours = currentDate.difference(date).inHours;
          final differenceMinutes = currentDate.difference(date).inMinutes;
          final differenceSeconds = currentDate.difference(date).inSeconds;
          if (differenceDay != 0) {
            dateTime = "$differenceDay Days ago";
          } else if (differenceHours != 0) {
            dateTime = "$differenceHours Hours ago";
          } else if (differenceMinutes != 0) {
            dateTime = "$differenceMinutes Minutes ago";
          } else {
            dateTime = "a few seconds ago";
          }
        }
        if (shareTime != "null") {
          int d = int.tryParse(shareTime);
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(d);

          final differenceDay = currentDate.difference(date).inDays;
          final differenceHours = currentDate.difference(date).inHours;
          final differenceMinutes = currentDate.difference(date).inMinutes;
          final differenceSeconds = currentDate.difference(date).inSeconds;
          if (differenceDay != 0) {
            shareTime = "$differenceDay Days ago";
          } else if (differenceHours != 0) {
            shareTime = "$differenceHours Hours ago";
          } else if (differenceMinutes != 0) {
            shareTime = "$differenceMinutes Minutes ago";
          } else {
            shareTime = "a few seconds ago";
          }
        }

        var imageMap = map[i]['post']['images'];
        String text = map[i]['post']['text'];
        String media = map[i]['post']['media'];
        List<String> imageList = new List<String>();
        for (int i = 0; i < imageMap.length; i++) {
          String image = imageMap[i];
          // image = getMediumImage(image);
          if (image != "") imageList.add(image);
        }
        PostData postData = new PostData(imageList, text, media);

        List<CommentData> commentList = new List();
        var commentMap = map[i]['comments'];
        for (int j = 0; j < commentMap.length; j++) {
          String commentId = commentMap[j]['commentId'].toString();
          String comment = commentMap[j]['comment'].toString();
          String commentedBy = commentMap[j]['commentedBy'].toString();
          String dateTime = commentMap[j]['dateTime'].toString();
          String profilePicture = commentMap[j]['profilePicture'].toString();
          String name = commentMap[j]['name'].toString();
          String title = commentMap[j]['title'].toString();
          String userId = commentMap[j]['userId'].toString();
          var likesMap = commentMap[j]['likes'];

          DateTime currentDate = new DateTime.now();
          if (dateTime != "null") {
            int d = int.tryParse(dateTime);
            DateTime date = new DateTime.fromMillisecondsSinceEpoch(d);

            final differenceDay = currentDate.difference(date).inDays;
            final differenceHours = currentDate.difference(date).inHours;
            final differenceMinutes = currentDate.difference(date).inMinutes;
            final differenceSeconds = currentDate.difference(date).inSeconds;
            if (differenceDay != 0) {
              dateTime = "$differenceDay Days ago";
            } else if (differenceHours != 0) {
              dateTime = "$differenceHours Hours ago";
            } else if (differenceMinutes != 0) {
              dateTime = "$differenceMinutes Minutes ago";
            } else {
              dateTime = "a few seconds ago";
            }
          }
          //  profilePicture = getSmallImage(profilePicture);
          List<Likes> likesList = new List();
          bool isCommentLike = false;
          for (int k = 0; k < likesMap.length; k++) {
            String userId = likesMap[k]['userId'].toString();
            String name = likesMap[k]['name'].toString();
            String profilePicture = likesMap[k]['profilePicture'].toString();
            // profilePicture = getSmallImage(profilePicture);
            String title = likesMap[k]['title'].toString();
            likesList.add(new Likes(userId, name, profilePicture, title));
            if (userId == userIdPref) {
              isCommentLike = true;
            }
          }
          commentList.add(new CommentData(
              commentId,
              comment,
              commentedBy,
              dateTime,
              profilePicture,
              name,
              title,
              userId,
              likesList,
              isCommentLike));
          if (commentedBy == userIdPref) {
            isCommented = true;
          }
        }
        List<Likes> likesList = new List();
        var likesMap = map[i]['likes'];
        for (int k = 0; k < likesMap.length; k++) {
          String userId = likesMap[k]['userId'].toString();
          String name = likesMap[k]['name'].toString();
          String profilePicture = likesMap[k]['profilePicture'].toString();
          String title = likesMap[k]['title'].toString();
          likesList.add(new Likes(userId, name, profilePicture, title));
          if (userId == userIdPref) {
            isLike = true;
          }
        }

        List<Tags> tagList = new List();
        try {
          var tagMap = map[i]['tags'];
          for (int k = 0; k < tagMap.length; k++) {
            String userId = tagMap[k]['userId'].toString();
            String name = tagMap[k]['name'].toString();
            String profilePicture = tagMap[k]['profilePicture'].toString();
            String title = tagMap[k]['title'].toString();

            tagList.add(new Tags(userId, name, profilePicture, title));
          }
        } catch (e) {}

        var scopeMap = map[i]['scope'];

        List<String> scopeList = new List<String>();
        for (int k = 0; k < scopeMap.length; k++) {
          String id = scopeMap[k].toString();
          if (id != "") scopeList.add(id);
        }

        userPostList.add(new UserPostModal(
            _id,
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
            isLike,
            isCommented,
            postData,
            commentList,
            likesList,
            tagList,
            scopeList,
            false,
            new TextEditingController(text: ""),
            lastActivityTime,
            lastActivityType,false,false));
      } catch (e) {
        e.toString();
      }
    }

    return userPostList;
  }

  static List<ProfileEducationModal> parseMapEducation(map) {
    List<ProfileEducationModal> userEducationList =
        new List<ProfileEducationModal>();
    for (int i = 0; i < map.length; i++) {
      try {
        String educationId =
            map[i][ProfileEducationConstant.EDUCATION_ID].toString();
        String organizationId =
            map[i][ProfileEducationConstant.ORGANIZATION_ID].toString();
        String userId = map[i][ProfileEducationConstant.USER_ID].toString();
        String institute =
            map[i][ProfileEducationConstant.INSTITUTE].toString();
        String city = map[i][ProfileEducationConstant.CITY].toString();
        String logo = map[i][ProfileEducationConstant.LOGO].toString();
        //logo= getMediumImage(logo);

        String fromGrade =
            map[i][ProfileEducationConstant.FROM_GRADE].toString();
        String toGrade = map[i][ProfileEducationConstant.TO_GRADE].toString();
        String fromYear = map[i][ProfileEducationConstant.FROM_YEAR].toString();
        String toYear = map[i][ProfileEducationConstant.TO_YEAR].toString();
        String description =
            map[i][ProfileEducationConstant.DESCRIPTION].toString();
        String isActive = map[i][ProfileEducationConstant.IS_ACTIVE].toString();

        userEducationList.add(new ProfileEducationModal(
            educationId,
            organizationId,
            userId,
            institute,
            city,
            logo,
            fromGrade,
            toGrade,
            fromYear,
            toYear,
            description,
            isActive));
      } catch (e) {
        e.toString();
      }
    }

    return userEducationList;
  }

  static List<NarrativeModel> parseMapNarrative(map) {
    List<NarrativeModel> narrativeList = new List<NarrativeModel>();
    for (int i = 0; i < map.length; i++) {
      try {
        List<Recomdation> recommendationtList = new List<Recomdation>();
        List<Achivment> achivmentList = new List<Achivment>();
        List<String> badgelistAll = new List<String>();
        List<String> certificateListAll = new List<String>();
        String _id = map[i]['_id'].toString();
        String name = map[i]['name'].toString();
        String level1 = map[i]['level1'].toString();
        String orderBy = map[i]['orderBy'].toString();

        var achivementMap = map[i]['achievement'];
        double minimumImportanceValue = 0.0;
        for (int j = 0; j < achivementMap.length; j++) {
          List<String> badgeList = new List();
          List<String> certificateList = new List();

          String _id = achivementMap[j]['_id'].toString();
          String achievementId = achivementMap[j]['achievementId'].toString();
          String competencyTypeId =
              achivementMap[j]['competencyTypeId'].toString();
          String level2Competency =
              achivementMap[j]['level2Competency'].toString();
          String level3Competency =
              achivementMap[j]['level3Competency'].toString();
          String userId = achivementMap[j]['userId'].toString();
          String title = achivementMap[j]['title'].toString();
          String description = achivementMap[j]['description'].toString();
          String fromDate = achivementMap[j]['fromDate'].toString();
          String toDate = achivementMap[j]['toDate'].toString();
          String isActive = achivementMap[j]['isActive'].toString();
          String importance = achivementMap[j]['importance'].toString();

          List<Assest> assestList = new List<Assest>();
          var asetMap = achivementMap[j]['asset'];
          for (int k = 0; k < asetMap.length; k++) {
            String type = asetMap[k]['type'].toString();
            String tag = asetMap[k]['tag'].toString();
            String file = asetMap[k]['file'].toString();
            //  file= getMediumImage(file);

            assestList.add(new Assest(type, tag, file, false));
            if (tag == "certificates") {
              certificateList.add(file);
            } else if (tag == "badges") {
              badgeList.add(file);
            }
          }
          List<Skill> skillList = new List<Skill>();

          var skillMap = achivementMap[j]['skills'];
          for (int l = 0; l < skillMap.length; l++) {
            String label = skillMap[l]['label'].toString();
            String skillId = skillMap[l]['skillId'].toString();
            skillList.add(new Skill(label, skillId));
          }
          String __v = achivementMap[j]['__v'].toString();

          String guidePromptRecommendation =
              achivementMap[j]['guide']['promptRecommendation'].toString();

          var storiesMap = achivementMap[j]['stories'];

          List<String> storiesList = new List<String>();

          for (int i = 0; i < storiesMap.length; i++) {
            String storie = storiesMap[i];
            if (storie != "") storiesList.add(storie);
          }
          badgelistAll.addAll(badgeList);
          certificateListAll.addAll(certificateList);
          if (j == 0) {
            minimumImportanceValue = double.parse(importance);
          } else {
            if (minimumImportanceValue > int.parse(importance))
              minimumImportanceValue = double.parse(importance);
          }
          List<Likes2> likeList = new List<Likes2>();
          achivmentList.add(new Achivment(
              _id,
              achievementId,
              competencyTypeId,
              level2Competency,
              level3Competency,
              userId,
              title,
              description,
              fromDate,
              toDate,
              isActive,
              importance,
              __v,
              guidePromptRecommendation,
              storiesList,
              likeList,
              skillList,
              assestList,
              certificateList,
              badgeList));
        }

        var recomdenationMap = map[i]['recommendation'];
        for (int j = 0; j < recomdenationMap.length; j++) {
          List<String> badgeList = new List();
          List<String> certificateList = new List();
          String _id = recomdenationMap[j]['_id'].toString();
          String recommendationId =
              recomdenationMap[j]['recommendationId'].toString();
          String userId = recomdenationMap[j]['userId'].toString();
          String recommenderId =
              recomdenationMap[j]['recommenderId'].toString();
          String competencyTypeId =
              recomdenationMap[j]['competencyTypeId'].toString();
          String level3Competency =
              recomdenationMap[j]['level3Competency'].toString();
          String level2Competency =
              recomdenationMap[j]['level2Competency'].toString();
          String title = recomdenationMap[j]['title'].toString();
          String request = recomdenationMap[j]['request'].toString();
          String recommendation =
              recomdenationMap[j]['recommendation'].toString();
          String stage = recomdenationMap[j]['stage'].toString();
          String interactionStartDate =
              recomdenationMap[j]['interactionStartDate'].toString();
          String interactionEndDate =
              recomdenationMap[j]['interactionEndDate'].toString();
          List<Assest> assestList = new List<Assest>();

          var asetMap = recomdenationMap[j]['asset'];
          for (int k = 0; k < asetMap.length; k++) {
            String type = asetMap[k]['type'].toString();
            String tag = asetMap[k]['tag'].toString();
            String file = asetMap[k]['file'].toString();
            //file= getMediumImage(file);

            if (tag == "certificates") {
              certificateList.add(file);
            } else if (tag == "badges") {
              badgeList.add(file);
            } else {
              assestList.add(new Assest(type, tag, file, false));
            }
          }
          List<Skill> skillList = new List<Skill>();

          var skillMap = recomdenationMap[j]['skills'];
          for (int l = 0; l < skillMap.length; l++) {
            String label = skillMap[l]['label'].toString();
            String skillId = skillMap[l]['skillId'].toString();
            skillList.add(new Skill(label, skillId));
          }
          String __v = recomdenationMap[j]['__v'].toString();

          String _id1 = recomdenationMap[j]['recommender']['_id'].toString();
          String userId1 =
              recomdenationMap[j]['recommender']['userId'].toString();
          String firstName =
              recomdenationMap[j]['recommender']['firstName'].toString();
          String lastName =
              recomdenationMap[j]['recommender']['lastName'].toString();
          String email = recomdenationMap[j]['recommender']['email'].toString();
          String password =
              recomdenationMap[j]['recommender']['password'].toString();
          String salt = recomdenationMap[j]['recommender']['salt'].toString();
          String mobileNo =
              recomdenationMap[j]['recommender']['mobileNo'].toString();
          String roleId =
              recomdenationMap[j]['recommender']['roleId'].toString();
          String isActive =
              recomdenationMap[j]['recommender']['isActive'].toString();
          String isPasswordChanged = recomdenationMap[j]['recommender']
                  ['isPasswordChanged']
              .toString();
          String organizationId =
              recomdenationMap[j]['recommender']['organizationId'].toString();
          String dob = recomdenationMap[j]['recommender']['dob'].toString();
          String title1 =
              recomdenationMap[j]['recommender']['title'].toString();
          String tempPassword =
              recomdenationMap[j]['recommender']['tempPassword'].toString();
          String isArchived =
              recomdenationMap[j]['recommender']['isArchived'].toString();
          String __v1 =
              recomdenationMap[j]['recommender']['isArchived'].toString();
          List<Likes2> likeList = new List<Likes2>();
          Recommender recommender = new Recommender(
              _id1,
              userId1,
              firstName,
              lastName,
              email,
              password,
              salt,
              mobileNo,
              roleId,
              isActive,
              isPasswordChanged,
              organizationId,
              dob,
              title1,
              tempPassword,
              isArchived,
              __v1);
          recommendationtList.add(new Recomdation(
              _id,
              recommendationId,
              userId,
              recommenderId,
              competencyTypeId,
              level3Competency,
              level2Competency,
              title,
              request,
              recommendation,
              stage,
              interactionStartDate,
              interactionEndDate,
              __v,
              likeList,
              skillList,
              assestList,
              certificateList,
              badgeList,
              recommender));
        }
        bool isVisible = true;

    //    if (i == 0) isVisible = true;

        narrativeList.add(new NarrativeModel(
            _id,
            name,
            level1,
            orderBy,
            achivmentList,
            recommendationtList,
            badgelistAll,
            certificateListAll,
            isVisible,
            minimumImportanceValue,
            minimumImportanceValue));
      } catch (e) {
        e.toString();
      }
    }

    return narrativeList;
  }

  static List<NarrativeModel> parseMapNarrativeForCompetency(map) {
    List<NarrativeModel> narrativeList = new List<NarrativeModel>();
    for (int i = 0; i < map.length; i++) {
      try {
        List<Recomdation> recommendationtList = new List<Recomdation>();
        List<Achivment> achivmentList = new List<Achivment>();
        List<String> badgelistAll = new List<String>();
        List<String> certificateListAll = new List<String>();
        String _id = map[i]['_id'].toString();
        String name = map[i]['name'].toString();
        String level1 = map[i]['level1'].toString();
        String orderBy = map[i]['orderBy'].toString();

        var achivementMap = map[i]['achievement'];
        for (int j = 0; j < achivementMap.length; j++) {
          List<String> badgeList = new List();
          List<String> certificateList = new List();

          String _id = achivementMap[j]['_id'].toString();
          String achievementId = achivementMap[j]['achievementId'].toString();
          String competencyTypeId =
              achivementMap[j]['competencyTypeId'].toString();
          String level2Competency =
              achivementMap[j]['level2Competency'].toString();
          String level3Competency =
              achivementMap[j]['level3Competency'].toString();
          String userId = achivementMap[j]['userId'].toString();
          String title = achivementMap[j]['title'].toString();
          String description = achivementMap[j]['description'].toString();
          String fromDate = achivementMap[j]['fromDate'].toString();
          String toDate = achivementMap[j]['toDate'].toString();
          String isActive = achivementMap[j]['isActive'].toString();
          String importance = achivementMap[j]['importance'].toString();

          List<Assest> assestList = new List<Assest>();
          var asetMap = achivementMap[j]['asset'];
          for (int k = 0; k < asetMap.length; k++) {
            String type = asetMap[k]['type'].toString();
            String tag = asetMap[k]['tag'].toString();
            String file = asetMap[k]['file'].toString();
            // file= getMediumImage(file);

            assestList.add(new Assest(type, tag, file, false));
            if (tag == "certificates") {
              certificateList.add(file);
            } else if (tag == "badges") {
              badgeList.add(file);
            }
          }
          List<Skill> skillList = new List<Skill>();

          var skillMap = achivementMap[j]['skills'];
          for (int l = 0; l < skillMap.length; l++) {
            String label = skillMap[l]['label'].toString();
            String skillId = skillMap[l]['skillId'].toString();
            skillList.add(new Skill(label, skillId));
          }
          String __v = achivementMap[j]['__v'].toString();

          String guidePromptRecommendation =
              achivementMap[j]['guide']['promptRecommendation'].toString();

          var storiesMap = achivementMap[j]['stories'];

          List<String> storiesList = new List<String>();

          for (int i = 0; i < storiesMap.length; i++) {
            String storie = storiesMap[i];
            if (storie != "") storiesList.add(storie);
          }
          badgelistAll.addAll(badgeList);
          certificateListAll.addAll(certificateList);
          achivmentList.add(new Achivment(
              _id,
              achievementId,
              competencyTypeId,
              level2Competency,
              level3Competency,
              userId,
              title,
              description,
              fromDate,
              toDate,
              isActive,
              importance,
              __v,
              guidePromptRecommendation,
              storiesList,
              null,
              skillList,
              assestList,
              certificateList,
              badgeList));
        }

        bool isVisible = false;

        if (i == 0) isVisible = true;

        narrativeList.add(new NarrativeModel(
            _id,
            name,
            level1,
            orderBy,
            achivmentList,
            recommendationtList,
            badgelistAll,
            certificateListAll,
            isVisible,
            0.0,
            0.0));
      } catch (e) {
        e.toString();
      }
    }

    return narrativeList;
  }

  static List<Recomdation> parseMapRecommdation(recomdenationMap) {
    List<Recomdation> recommendationtList = new List<Recomdation>();

    try {
      for (int j = 0; j < recomdenationMap.length; j++) {
        List<String> badgeList = new List();
        List<String> certificateList = new List();
        String _id = recomdenationMap[j]['_id'].toString();
        String recommendationId =
            recomdenationMap[j]['recommendationId'].toString();
        String userId = recomdenationMap[j]['userId'].toString();
        String recommenderId = recomdenationMap[j]['recommenderId'].toString();
        String competencyTypeId =
            recomdenationMap[j]['competencyTypeId'].toString();
        String level3Competency =
            recomdenationMap[j]['level3Competency'].toString();
        String level2Competency =
            recomdenationMap[j]['level2Competency'].toString();
        String title = recomdenationMap[j]['title'].toString();
        String request = recomdenationMap[j]['request'].toString();
        String recommendation =
            recomdenationMap[j]['recommendation'].toString();
        String stage = recomdenationMap[j]['stage'].toString();
        String interactionStartDate =
            recomdenationMap[j]['interactionStartDate'].toString();
        String interactionEndDate =
            recomdenationMap[j]['interactionEndDate'].toString();
        List<Assest> assestList = new List<Assest>();

        var asetMap = recomdenationMap[j]['asset'];
        for (int k = 0; k < asetMap.length; k++) {
          String type = asetMap[k]['type'].toString();
          String tag = asetMap[k]['tag'].toString();
          String file = asetMap[k]['file'].toString();
          //  file= getMediumImage(file);

          assestList.add(new Assest(type, tag, file, false));
          if (tag == "certificates") {
            certificateList.add(file);
          } else if (tag == "badges") {
            badgeList.add(file);
          }
        }
        List<Skill> skillList = new List<Skill>();

        var skillMap = recomdenationMap[j]['skills'];
        for (int l = 0; l < skillMap.length; l++) {
          String label = skillMap[l]['label'].toString();
          String skillId = skillMap[l]['skillId'].toString();
          skillList.add(new Skill(label, skillId));
        }
        String __v = recomdenationMap[j]['__v'].toString();

        String _id1 = recomdenationMap[j]['recommender']['_id'].toString();
        String userId1 =
            recomdenationMap[j]['recommender']['userId'].toString();
        String firstName =
            recomdenationMap[j]['recommender']['firstName'].toString();
        String lastName =
            recomdenationMap[j]['recommender']['lastName'].toString();
        String email = recomdenationMap[j]['recommender']['email'].toString();
        String password =
            recomdenationMap[j]['recommender']['password'].toString();
        String salt = recomdenationMap[j]['recommender']['salt'].toString();
        String mobileNo =
            recomdenationMap[j]['recommender']['mobileNo'].toString();
        String roleId = recomdenationMap[j]['recommender']['roleId'].toString();
        String isActive =
            recomdenationMap[j]['recommender']['isActive'].toString();
        String isPasswordChanged =
            recomdenationMap[j]['recommender']['isPasswordChanged'].toString();
        String organizationId =
            recomdenationMap[j]['recommender']['organizationId'].toString();
        String dob = recomdenationMap[j]['recommender']['dob'].toString();
        String title1 = recomdenationMap[j]['recommender']['title'].toString();
        String tempPassword =
            recomdenationMap[j]['recommender']['tempPassword'].toString();
        String isArchived =
            recomdenationMap[j]['recommender']['isArchived'].toString();
        String __v1 =
            recomdenationMap[j]['recommender']['isArchived'].toString();
        Recommender recommender = new Recommender(
            _id1,
            userId1,
            firstName,
            lastName,
            email,
            password,
            salt,
            mobileNo,
            roleId,
            isActive,
            isPasswordChanged,
            organizationId,
            dob,
            title1,
            tempPassword,
            isArchived,
            __v1);
        recommendationtList.add(new Recomdation(
            _id,
            recommendationId,
            userId,
            recommenderId,
            competencyTypeId,
            level3Competency,
            level2Competency,
            title,
            request,
            recommendation,
            stage,
            interactionStartDate,
            interactionEndDate,
            __v,
            null,
            skillList,
            assestList,
            certificateList,
            badgeList,
            recommender));
      }
      return recommendationtList;
    } catch (e) {
      return recommendationtList;
    }
  }

  static List<OrganizationModal> parseMapOrganization(organizationMap) {
    List<OrganizationModal> organizationLst = List<OrganizationModal>();

    try {
      for (int j = 0; j < organizationMap.length; j++) {
        String organizationId = organizationMap[j]['organizationId'].toString();
        String name = organizationMap[j]['name'].toString();
        String description = organizationMap[j]['description'].toString();
        String type = organizationMap[j]['type'].toString();
        String logo = organizationMap[j]['logo'].toString();
        //  logo= getMediumImage(logo);

        organizationLst.add(new OrganizationModal(
            organizationId, name, description, type, logo));
      }
    } catch (e) {}
    return organizationLst;
  }

  static List<AchievementImportanceModal> parseMapLevelList(map) {
    List<AchievementImportanceModal> achievementImportanceList =
        List<AchievementImportanceModal>();

    try {
      for (int j = 0; j < map.length; j++) {
        String importanceId = map[j]['importanceId'].toString();
        String title = map[j]['title'].toString();
        String description = map[j]['description'].toString();

        achievementImportanceList.add(
            new AchievementImportanceModal(importanceId, title, description));
      }
    } catch (e) {}
    return achievementImportanceList;
  }

  static List<AcvhievmentSkillModel> parseMapSkillList(map) {
    List<AcvhievmentSkillModel> achievementImportanceList =
        List<AcvhievmentSkillModel>();
    achievementImportanceList
        .add(new AcvhievmentSkillModel("0", "All", "dfvfv"));
    try {
      for (int j = 0; j < map.length; j++) {
        String skillId = map[j]['skillId'].toString();
        String title = map[j]['title'].toString();
        String description = map[j]['description'].toString();

        achievementImportanceList
            .add(new AcvhievmentSkillModel(skillId, title, description));
      }
    } catch (e) {}
    return achievementImportanceList;
  }

  static List<CompetencyModel> parseMapCompetency(competencyMap) {
    List<CompetencyModel> listCompetency = new List();
    try {
// for (int j = 0; j < competencyMap.length; j++) {
      List<Level2Competencies> level2Competencylist = new List();
      String level1 = competencyMap['level1'].toString();
      var level2 = competencyMap['level2'];
      for (int k = 0; k < level2.length; k++) {
        String name = level2[k]['name'].toString();
        String competencyTypeId = level2[k]['competencyTypeId'].toString();
        var level3 = level2[k]['level3'];
        List<Level3Competencies> level3Competencylist = new List();
        for (int l = 0; l < level3.length; l++) {
          String name = level3[l]['name'].toString();
          String key = level3[l]['key'].toString();
          level3Competencylist.add(new Level3Competencies(name, key));
        }
        level2Competencylist.add(new Level2Competencies(
            name, competencyTypeId, false, level3Competencylist));
      }
      listCompetency.add(new CompetencyModel(level1, level2Competencylist));
      //}
    } catch (e) {}
    return listCompetency;
  }

  static List<StudentDataModel> parseMapStudentByParent(competencyMap) {
    List<StudentDataModel> listStudent = new List();
    try {
      for (int j = 0; j < competencyMap.length; j++) {
        String userId = competencyMap[j]['userId'].toString();
        String firstName = competencyMap[j]['firstName'].toString();
        String lastName = competencyMap[j]['lastName'].toString();
        String email = competencyMap[j]['email'].toString();
        String mobileNo = competencyMap[j]['mobileNo'].toString();
        String profilePicture = competencyMap[j]['profilePicture'].toString();
        // profilePicture= getMediumImage(profilePicture);

        String roleId = competencyMap[j]['roleId'].toString();
        String isActive = competencyMap[j]['isActive'].toString();
        String requireParentApproval =
            competencyMap[j]['requireParentApproval'].toString();
        String ccToParents = competencyMap[j]['ccToParents'].toString();
        String lastAccess = competencyMap[j]['lastAccess'].toString();
        String isPasswordChanged =
            competencyMap[j]['isPasswordChanged'].toString();
        String organizationId = competencyMap[j]['organizationId'].toString();
        String gender = competencyMap[j]['gender'].toString();
        String dob = competencyMap[j]['dob'].toString();
        String genderAtBirth = competencyMap[j]['genderAtBirth'].toString();
        String usCitizenOrPR = competencyMap[j]['usCitizenOrPR'].toString();
        String summary = competencyMap[j]['summary'].toString();
        String coverImage = competencyMap[j]['coverImage'].toString();
        String tagline = competencyMap[j]['tagline'].toString();
        String title = competencyMap[j]['title'].toString();
        String tempPassword = competencyMap[j]['tempPassword'].toString();
        String isArchived = competencyMap[j]['isArchived'].toString();
        var parentMap = competencyMap[j]['parents'];
        List<Parents> parentList = new List();
        for (int k = 0; k < parentMap.length; k++) {
          String email = parentMap[k]['email'].toString();
          String userId = parentMap[k]['userId'].toString();
          parentList.add(new Parents(email, userId));
        }
        var addressMap = competencyMap[j]['address'];
        Address addressModal = null;
        if (addressMap != null) {
          String street1 = addressMap['street1'].toString();
          String street2 = addressMap['street2'].toString();
          String city = addressMap['city'].toString();
          String state = addressMap['state'].toString();
          String country = addressMap['country'].toString();
          String zip = addressMap['zip'].toString();
          addressModal =
              new Address(street1, street2, city, state, country, zip);
        }

        listStudent.add(new StudentDataModel(
            userId,
            firstName,
            lastName,
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
            isArchived,
            parentList,
            addressModal));
      }
    } catch (e) {
      e.toString();
    }
    return listStudent;
  }

  static List<TagModel> parseTagList(map) {
    List<TagModel> tagList = new List();
    try {
      for (int k = 0; k < map.length; k++) {
        String profilePicture = map[k]['profilePicture'].toString();
        String userId = map[k]['partner']['userId'].toString();
        String firstName = map[k]['partner']['firstName'].toString();
        String lastName = map[k]['partner']['lastName'].toString();
        String email = map[k]['partner']['email'].toString();

        tagList.add(new TagModel(
            userId, firstName, lastName, email, profilePicture, false));
      }

      //}
    } catch (e) {}
    return tagList;
  }

  static List<RequestedTagModel> parseRequestedTagList(map) {
    List<RequestedTagModel> tagList = new List();
    try {
      for (int k = 0; k < map.length; k++) {
        String _id = map[k]['_id'].toString();
        String connectId = map[k]['connectId'].toString();
        String userId = map[k]['userId'].toString();
        String partnerId = map[k]['partnerId'].toString();
        String dateTime = map[k]['dateTime'].toString();
        String status = map[k]['status'].toString();

        String userIsActive = map[k]['user']['isActive'].toString();
        String id = map[k]['partner']['id'].toString();
        String userId2 = map[k]['partner']['userId'].toString();
        String firstName = map[k]['partner']['firstName'].toString();
        String lastName = map[k]['partner']['lastName'].toString();
        String email = map[k]['partner']['email'].toString();
        String password = map[k]['partner']['password'].toString();
        String salt = map[k]['partner']['salt'].toString();
        String mobileNo = map[k]['partner']['mobileNo'].toString();
        String roleId = map[k]['partner']['roleId'].toString();
        String isActive = map[k]['partner']['isActive'].toString();
        String isPasswordChanged =
            map[k]['partner']['isPasswordChanged'].toString();
        String organizationId = map[k]['partner']['organizationId'].toString();
        String dob = map[k]['partner']['dob'].toString();
        String isArchived = map[k]['partner']['isArchived'].toString();
        String profilePicture = map[k]['partner']['profilePicture'].toString();
        String requireParentApproval =
            map[k]['partner']['requireParentApproval'].toString();
        String ccToParents = map[k]['partner']['ccToParents'].toString();
        String lastAccess = map[k]['partner']['lastAccess'].toString();
        String gender = map[k]['partner']['gender'].toString();
        String genderAtBirth = map[k]['partner']['genderAtBirth'].toString();
        String usCitizenOrPR = map[k]['partner']['usCitizenOrPR'].toString();
        String address = map[k]['partner']['address'].toString();
        String summary = map[k]['partner']['summary'].toString();
        String coverImage = map[k]['partner']['coverImage'].toString();
        String tagline = map[k]['partner']['tagline'].toString();
        String title = map[k]['partner']['title'].toString();
        String tempPassword = map[k]['partner']['tempPassword'].toString();

        Patner patner = new Patner(
            id,
            userId2,
            firstName,
            lastName,
            email,
            password,
            salt,
            mobileNo,
            roleId,
            isActive,
            isPasswordChanged,
            organizationId,
            dob,
            isArchived,
            profilePicture,
            requireParentApproval,
            ccToParents,
            lastAccess,
            gender,
            genderAtBirth,
            usCitizenOrPR,
            address,
            summary,
            coverImage,
            tagline,
            title,
            tempPassword);
        tagList.add(new RequestedTagModel(_id, connectId, userId, partnerId,
            dateTime, status, userIsActive, patner));
      }
    } catch (e) {}
    return tagList;
  }

  static List<ProfileInfoModal> parseUserFriendList(map,useridPref) {
    List<ProfileInfoModal> friendList = new List<ProfileInfoModal>();
    for (int i = 0; i < map.length; i++) {
      String groupId = "";
      String groupName = "";
      String groupImage = "";
      String userId = map[i][ProfileInfoResponse.USER_ID].toString();
      try {
        groupId = map[i]['groupId'].toString();
        groupName = map[i]['groupName'].toString();
        groupImage = map[i]['groupImage'].toString();
      } catch (e) {
        groupId = "";
        groupName = "";
        groupImage = "";
      }

      String firstName = map[i][ProfileInfoResponse.FIRSTNAME].toString();
      String lastName = map[i][ProfileInfoResponse.LASTNAME].toString();
      String email = map[i][ProfileInfoResponse.EMAIL].toString();
      String mobileNo = map[i][ProfileInfoResponse.MOBILE].toString();
      String profilePicture =
      map[i][ProfileInfoResponse.PROFILE_PICTURE].toString();
      //   profilePicture= getMediumImage(profilePicture);
      String roleId = map[i][ProfileInfoResponse.ROLE_ID].toString();
      String isActive = map[i][ProfileInfoResponse.IS_ACTIVE].toString();
      String requireParentApproval =
          ""; //    map[i][ProfileInfoResponse.REQUIRE_PARENT_APPROVEL].toString();
      String ccToParents =
          ""; //   map[i][ProfileInfoResponse.CC_TO_PARENTS].toString();
      String lastAccess =
          ""; //   map[i][ProfileInfoResponse.LAST_ACCESS].toString();
      String isPasswordChanged =
          ""; //        map[i][ProfileInfoResponse.IS_PASSWORD_CHANGED].toString();
      String organizationId =
          ""; //        map[i][ProfileInfoResponse.ORGANIZATION_ID].toString();
      String gender = ""; //  map[i][ProfileInfoResponse.GENDER].toString();
      String dob = ""; //  map[i][ProfileInfoResponse.DOB].toString();
      String genderAtBirth =
          ""; //        map[i][ProfileInfoResponse.GENDER_AT_BIRTH].toString();
      String usCitizenOrPR =
          ""; //        map[i][ProfileInfoResponse.US_CITIZEN_OR_PR].toString();

      //   var addressMap = map[i]['address'];
      Address addressModal = new Address("", "", "", "", "", "");
      /* if (addressMap != null) {
        String street1 = addressMap['street1'].toString();
        String street2 = addressMap['street2'].toString();
        String city = addressMap['city'].toString();
        String state = addressMap['state'].toString();
        String country = addressMap['country'].toString();
        String zip = addressMap['zip'].toString();
        addressModal = new Address(street1, street2, city, state, country, zip);
      }*/

      String summary = ""; //  map[i][ProfileInfoResponse.SUMMARY].toString();
      String coverImage =
          ""; //   map[i][ProfileInfoResponse.COVER_IMAGE].toString();
      //   coverImage= getMediumImage(coverImage);
      String tagline = ""; //   map[i][ProfileInfoResponse.TAGLINE].toString();
      String title = ""; //  map[i][ProfileInfoResponse.TITLE].toString();
      String tempPassword =
          ""; //        map[i][ProfileInfoResponse.TEMP_PASSWORD].toString();
      String isArchived =
          ""; //   map[i][ProfileInfoResponse.IS_ARCHIVED].toString();
      List<ParentModal> parentList = new List();

      /* for (int j = 0; j < map[i][ProfileInfoResponse.PARENTS].length; j++) {
        String email = map[i][ProfileInfoResponse.PARENTS][j]
        [ProfileInfoResponse.EMAIL]
            .toString();
        String userId = map[i][ProfileInfoResponse.PARENTS][j]
        [ProfileInfoResponse.USER_ID]
            .toString();
        parentList.add(new ParentModal(email, userId));
      }*/
      /*  if (profilePicture != "") {
      strNetworkImage = profilePicture;
    }*/
      if (userId != useridPref) {
        friendList.add(new ProfileInfoModal(
            userId,
            firstName,
            lastName,
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
            addressModal,
            summary,
            coverImage,
            tagline,
            title,
            tempPassword,
            isArchived,
            parentList,
            false,
            groupId,
            groupName,
            groupImage));
      }
    }
    return friendList;
  }

  static List<ProfileShareModel> parseMapShareLog(map) {
    List<ProfileShareModel> profileLogList = new List<ProfileShareModel>();

    try {
      for (int j = map.length-1; j >=0 ; j--) {
        String _id = map[j]['_id'].toString();
        String sharedId = map[j]['sharedId'].toString();
        String sharedType = map[j]['sharedType'].toString();
        String profileOwner = map[j]['profileOwner'].toString();
        String shareTime = map[j]['shareTime'].toString();
        String isActive = map[j]['isActive'].toString();
        String isViewed = map[j]['isViewed'].toString();
        String shareTo = map[j]['shareTo'].toString();
        String shareToFirstName = map[j]['shareToFirstName'].toString();
        String shareToLastName = map[j]['shareToLastName'].toString();
        String shareToEmail = map[j]['shareToEmail'].toString();
        String shareToprofilePicture = map[j]['shareToprofilePicture'].toString();
        if (shareTime != "" && shareTime != "null") {
          int d = int.tryParse(shareTime);
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(d);
          final f = new DateFormat('yyyy-MM-dd hh:mm');

          shareTime = f.format(
              new DateTime.fromMillisecondsSinceEpoch(int.tryParse(shareTime)));
        }

        profileLogList.add(new ProfileShareModel(
            _id,
            sharedId,
            sharedType,
            profileOwner,
            shareTime,
            isActive,
            isViewed,
            shareTo,
            shareToFirstName,
            shareToLastName,
            shareToEmail,shareToprofilePicture));
      }
      return profileLogList;
    } catch (e) {
      return profileLogList;
    }
  }

  static List<GroupModel> parseGroupData(map, userIdPref) {
    List<GroupModel> groupList = new List<GroupModel>();

    try {

      for (int j = 0; j < map.length; j++) {
        bool isAdminFlag = false;
        String currentStatus = "";
        String groupId = map[j]['groupId'].toString();
        String groupName = map[j]['groupName'].toString();
        String type = map[j]['type'].toString();
        String creationDate = map[j]['creationDate'].toString();
        String createdBy = map[j]['createdBy'].toString();
        String isActive = map[j]['isActive'].toString();
        String aboutGroup = map[j]['aboutGroup'].toString();
        String otherInfo = map[j]['otherInfo'].toString();
        String groupImage = map[j]['groupImage'].toString();
        int acceptCount = 0;
        var memberMap = map[j]['members'];
        List<MemberModel> memberList = new List();
        for (int k = 0; k < memberMap.length; k++) {
          String status = memberMap[k]["status"].toString();
          String isAdmin = memberMap[k]["isAdmin"].toString();
          String userId = memberMap[k]["userId"].toString();
          if (status == "Accepted") acceptCount++;

          if (userIdPref == userId) {
            currentStatus = status;
            if (isAdmin == "true")
              isAdminFlag = true;
            else
              isAdminFlag = false;
          }

          memberList.add(new MemberModel(status, isAdmin, userId));
        }
        print("Accept count"+acceptCount.toString());
        if (creationDate != "" && creationDate != "null") {
          int d = int.tryParse(creationDate);
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(d);
          //  final f = new DateFormat('yyyy-MM-dd hh:mm');
          final f = new DateFormat.yMMMMd("en_US");
          creationDate = f.format(new DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(creationDate)));
        }

        groupList.add(new GroupModel(
            groupId,
            groupName,
            type,
            creationDate,
            createdBy,
            isActive,
            aboutGroup,
            otherInfo,
            groupImage,
            memberList,
            isAdminFlag,
            currentStatus,acceptCount.toString()));
      }
      return groupList;
    } catch (e) {
      return groupList;
    }
  }

  static List<GroupDetailModel> parseGroupDetailMap(map, userIdPref) {
    List<GroupDetailModel> groupList = new List<GroupDetailModel>();

    try {
      String adminName = "";
      bool isAdminFlag = false;
      String currentStatus = "";
      String _id = map['_id'].toString();
      String groupId = map['groupId'].toString();
      String groupName = map['groupName'].toString();
      String type = map['type'].toString();
      String creationDate = map['creationDate'].toString();
      String createdBy = map['createdBy'].toString();
      String isActive = map['isActive'].toString();
      String aboutGroup = map['aboutGroup'].toString();
      String otherInfo = map['otherInfo'].toString();
      String groupImage = map['groupImage'].toString();

      var memberMap = map['members'];
      List<MemberModelDetail> memberList = new List();
      List<MemberModelDetail> memberList2 = new List();
      for (int k = 0; k < memberMap.length; k++) {
        String status = memberMap[k]["status"].toString();
        String isAdmin = memberMap[k]["isAdmin"].toString();
        String userId = memberMap[k]["userId"].toString();
        String roleId = memberMap[k]["roleId"].toString();
        String firstName = memberMap[k]["firstName"].toString();
        String lastName = memberMap[k]["lastName"].toString();
        String profilePicture = memberMap[k]["profilePicture"].toString();
        String email = memberMap[k]["email"].toString();
        String tagline = memberMap[k]["tagline"].toString();

        if (userIdPref == userId) {
          currentStatus = status;
          if (isAdmin == "true") isAdminFlag = true;
        }
        if (isAdmin == "true") adminName = firstName + " " + lastName;

        memberList.add(new MemberModelDetail(status, isAdmin, userId, roleId,
            firstName, lastName, profilePicture, email, tagline));
      }

      if(isAdminFlag){

      }else {
        for(int i=0;i<memberList.length;i++){
          if(memberList[i].status=="Accepted"){

            memberList2.add(memberList[i]);
          }
        }
        memberList.clear();
        memberList.addAll(memberList2);
      }

      if (creationDate != "" && creationDate != "null") {
        int d = int.tryParse(creationDate);
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(d);
        //  final f = new DateFormat('yyyy-MM-dd hh:mm');
        final f = new DateFormat.yMMMMd("en_US");
        creationDate = f.format(new DateTime.fromMillisecondsSinceEpoch(
            int.tryParse(creationDate)));
      }

      groupList.add(new GroupDetailModel(
          _id,
          groupId,
          groupName,
          type,
          creationDate,
          createdBy,
          isActive,
          aboutGroup,
          otherInfo,
          groupImage,
          memberList,
          isAdminFlag,
          currentStatus,
          adminName));

      return groupList;
    } catch (e) {
      return groupList;
    }
  }

/*  static List<ProfileInfoModal> parseUserFriendList(map) {
    List<ProfileInfoModal> friendList = new List<ProfileInfoModal>();
    for (int i = 0; i < map.length; i++) {
      String userId = map[i][ProfileInfoResponse.USER_ID].toString();
      String firstName = map[i][ProfileInfoResponse.FIRSTNAME].toString();
      String lastName = map[i][ProfileInfoResponse.LASTNAME].toString();
      String email = map[i][ProfileInfoResponse.EMAIL].toString();
      String mobileNo = map[i][ProfileInfoResponse.MOBILE].toString();
      String profilePicture =
      map[i][ProfileInfoResponse.PROFILE_PICTURE].toString();
      //   profilePicture= getMediumImage(profilePicture);
      String roleId = map[i][ProfileInfoResponse.ROLE_ID].toString();
      String isActive = map[i][ProfileInfoResponse.IS_ACTIVE].toString();
      String requireParentApproval =
      map[i][ProfileInfoResponse.REQUIRE_PARENT_APPROVEL].toString();
      String ccToParents = map[i][ProfileInfoResponse.CC_TO_PARENTS].toString();
      String lastAccess = map[i][ProfileInfoResponse.LAST_ACCESS].toString();
      String isPasswordChanged =
      map[i][ProfileInfoResponse.IS_PASSWORD_CHANGED].toString();
      String organizationId =
      map[i][ProfileInfoResponse.ORGANIZATION_ID].toString();
      String gender = map[i][ProfileInfoResponse.GENDER].toString();
      String dob = map[i][ProfileInfoResponse.DOB].toString();
      String genderAtBirth =
      map[i][ProfileInfoResponse.GENDER_AT_BIRTH].toString();
      String usCitizenOrPR =
      map[i][ProfileInfoResponse.US_CITIZEN_OR_PR].toString();

      var addressMap = map[i]['address'];
      Address addressModal = new Address("", "", "", "", "", "");
      if (addressMap != null) {
        String street1 = addressMap['street1'].toString();
        String street2 = addressMap['street2'].toString();
        String city = addressMap['city'].toString();
        String state = addressMap['state'].toString();
        String country = addressMap['country'].toString();
        String zip = addressMap['zip'].toString();
        addressModal = new Address(street1, street2, city, state, country, zip);
      }

      String summary = map[i][ProfileInfoResponse.SUMMARY].toString();
      String coverImage = map[i][ProfileInfoResponse.COVER_IMAGE].toString();
      //   coverImage= getMediumImage(coverImage);
      String tagline = map[i][ProfileInfoResponse.TAGLINE].toString();
      String title = map[i][ProfileInfoResponse.TITLE].toString();
      String tempPassword =
      map[i][ProfileInfoResponse.TEMP_PASSWORD].toString();
      String isArchived = map[i][ProfileInfoResponse.IS_ARCHIVED].toString();
      List<ParentModal> parentList = new List();

      for (int j = 0; j < map[i][ProfileInfoResponse.PARENTS].length; j++) {
        String email = map[i][ProfileInfoResponse.PARENTS][j]
        [ProfileInfoResponse.EMAIL]
            .toString();
        String userId = map[i][ProfileInfoResponse.PARENTS][j]
        [ProfileInfoResponse.USER_ID]
            .toString();
        parentList.add(new ParentModal(email, userId));
      }
      */ /*  if (profilePicture != "") {
      strNetworkImage = profilePicture;
    }*/ /*

      friendList.add(new ProfileInfoModal(
          userId,
          firstName,
          lastName,
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
          addressModal,
          summary,
          coverImage,
          tagline,
          title,
          tempPassword,
          isArchived,
          parentList));
    }
    return friendList;
  }*/
  static List<ConnectionListModel> parseChatData(map) {
    List<ConnectionListModel> dataList = new List();
    for (int i = 0; i < map.length; i++) {
      print(map.length);
      int userId, dateTime = 0, receiverId, connectId;
      String firstName,
          lastName,
          partnerFirstName,
          partnerLastName,
          partnerProfilePicture,
          lastMessage;
      int unreadMessageCount;
      String email = "", profilePicture = "";

      userId = map[i]["userId"];
      receiverId = map[i]["partnerId"];
      connectId = map[i]["connectId"];

      firstName = map[i]["firstName"];
      lastName = map[i]["lastName"];
      unreadMessageCount = map[i]["unreadMessages"];
      lastMessage = map[i]["lastMessage"];

      if (map[i]["profilePicture"] != null)
        profilePicture = map[i]["profilePicture"];

      partnerFirstName = map[i]["partnerFirstName"];
      partnerLastName = map[i]["partnerLastName"];
      if (map[i]["partnerProfilePicture"] != null)
        partnerProfilePicture = map[i]["partnerProfilePicture"];

      print(userId);

      dataList.add(ConnectionListModel(
          userId.toString(),
          firstName,
          lastName,
          email,
          profilePicture,
          dateTime,
          receiverId.toString(),
          connectId.toString(),
          lastMessage,
          unreadMessageCount.toString(),
          partnerFirstName,
          partnerLastName,
          partnerProfilePicture));
    }

    return dataList;
  }

  static List<ConnectionListModel> parseChatDataMainPage(map) {
    List<ConnectionListModel> dataList = new List();
    for (int i = 0; i < map.length; i++) {
      print(map.length);
      int userId, dateTime = 0, receiverId, connectId;
      String firstName,
          lastName,
          partnerFirstName,
          partnerLastName,
          partnerProfilePicture,
          lastMessage;
      int unreadMessageCount;
      String email = "", profilePicture = "";

      userId = map[i]["userId"];
      receiverId = map[i]["partnerId"];
      connectId = map[i]["connectId"];

      firstName = map[i]["firstName"];
      lastName = map[i]["lastName"];
      unreadMessageCount = map[i]["unreadMessages"];
      lastMessage = map[i]["lastMessage"];

      if (map[i]["profilePicture"] != null)
        profilePicture = map[i]["profilePicture"];

      partnerFirstName = map[i]["partnerFirstName"];
      partnerLastName = map[i]["partnerLastName"];
      if (map[i]["partnerProfilePicture"] != null)
        partnerProfilePicture = map[i]["partnerProfilePicture"];

      print(userId);
     if (lastMessage != null && lastMessage != "null" && lastMessage != "") {
        dataList.add(ConnectionListModel(
            userId.toString(),
            firstName,
            lastName,
            email,
            profilePicture,
            dateTime,
            receiverId.toString(),
            connectId.toString(),
            lastMessage,
            unreadMessageCount.toString(),
            partnerFirstName,
            partnerLastName,
            partnerProfilePicture));
   }
    }

    return dataList;
  }


  static List<NotificationModel> parseNotification(map) {
    List<NotificationModel> dataList = new List();
    for (int i = 0; i < map.length; i++) {

    String  notificationId = map[i]["notificationId"].toString();
    String  userId = map[i]["userId"].toString();
    String  actedBy = map[i]["actedBy"].toString();
    String  postId = map[i]["postId"].toString();
    String  profilePicture = map[i]["profilePicture"].toString();
    String  text = map[i]["text"].toString();
    String  dateTime = map[i]["dateTime"].toString();
    String  isRead = map[i]["isRead"].toString();
    DateTime currentDate = new DateTime.now();
    if (dateTime != "null") {
      int d = int.tryParse(dateTime);
      DateTime date = new DateTime.fromMillisecondsSinceEpoch(d);

      final differenceDay = currentDate.difference(date).inDays;
      final differenceHours = currentDate.difference(date).inHours;
      final differenceMinutes = currentDate.difference(date).inMinutes;
      final differenceSeconds = currentDate.difference(date).inSeconds;
      if (differenceDay != 0) {
        if (differenceDay >30)
        {
          dateTime = "a month ago";
        } else {
        dateTime = "$differenceDay Days ago";

      }
      } else if (differenceHours != 0) {
        dateTime = "$differenceHours Hours ago";
      } else if (differenceMinutes != 0) {
        dateTime = "$differenceMinutes Minutes ago";
      } else {
        dateTime = "a few seconds ago";
      }
    }

      dataList.add(new NotificationModel(
          notificationId, userId, actedBy, postId, profilePicture, text, dateTime, isRead));
    }

    return dataList;
  }


  static List<double> parseSpiderChart(map) {
    List<double> dataList = new List();
    for (int i = 0; i < map.length; i++) {

      String  _id = map[i]["_id"].toString();
      String  importance = map[i]["importance"].toString();
      String  name = map[i]["name"].toString();
      String  importanceTitle = map[i]["importanceTitle"].toString();


     // dataList.add(new SpiderChartModel(_id, importance, name, importanceTitle));
   dataList.add(double.parse(importance));
    }

    return dataList;
  }


  static ConnectionNotificationModel parseConnectionNotification(map) {
   try {
     String connectionCount = map[0]["connectionCount"].toString();
     String messagingCount = map[0]["messagingCount"].toString();
     String notificationCount = map[0]["notificationCount"].toString();


     return new ConnectionNotificationModel(
         connectionCount, messagingCount, notificationCount);
   }catch(e){
    return new ConnectionNotificationModel(
    "", "", "");
    }
  }
}
