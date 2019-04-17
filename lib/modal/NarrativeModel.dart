import 'dart:io';

class NarrativeModel {
  String id, name, level1, orderBy;
  double imoportanceValue = 0.0;
  double imoportanceValueCopy = 0.0;
  List<Achivment> achivmentList;
  List<Recomdation> recommendationtList;
  List<String> certificateListAll;
  List<String> badgeListAll;
  bool isVisible;

  NarrativeModel(
      this.id,
      this.name,
      this.level1,
      this.orderBy,
      this.achivmentList,
      this.recommendationtList,
      this.badgeListAll,
      this.certificateListAll,
      this.isVisible,
      this.imoportanceValue,
      this.imoportanceValueCopy);


  Map<String, dynamic> toJson() => {
    'competencyTypeId': int.parse(id),
    'importance': imoportanceValue.toInt(),

  };

  NarrativeModel.clone(NarrativeModel source)
      : this.id = source.id,
        this.name = source.name,
        this.level1 = source.level1,
        this.orderBy = source.orderBy,
        this.achivmentList = source.achivmentList
            .map((item) => new Achivment.clone(item))
            .toList(),
        this.recommendationtList = source.recommendationtList
            .map((item) => new Recomdation.clone(item))
            .toList(),
        this.certificateListAll =
            source.certificateListAll.map((item) => (item)).toList(),
        this.badgeListAll = source.badgeListAll.map((item) => (item)).toList(),
        this.isVisible = source.isVisible,
        this.imoportanceValue = source.imoportanceValue,
        this.imoportanceValueCopy = source.imoportanceValueCopy
  ;
}

class Recomdation {
  String _id,
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
      __v;
  List<Likes2> likeList;

  Recomdation(
      this._id,
      this.recommendationId,
      this.userId,
      this.recommenderId,
      this.competencyTypeId,
      this.level3Competency,
      this.level2Competency,
      this.title,
      this.request,
      this.recommendation,
      this.stage,
      this.interactionStartDate,
      this.interactionEndDate,
      this.__v,
      this.likeList,
      this.skillList,
      this.assestList,
      this.certificateList,
      this.badgeList,
      this.recommender);

  List<Skill> skillList;
  List<Assest> assestList;
  List<String> certificateList;
  List<String> badgeList;
  Recommender recommender;

  Recomdation.clone(Recomdation source)
      : this._id = source._id,
        this.recommendationId = source.recommendationId,
        this.userId = source.userId,
        this.recommenderId = source.recommenderId,
        this.competencyTypeId = source.competencyTypeId,
        this.level3Competency = source.level3Competency,
        this.level2Competency = source.level2Competency,
        this.title = source.title,
        this.request = source.request,
        this.recommendation = source.recommendation,
        this.stage = source.stage,
        this.interactionStartDate = source.interactionStartDate,
        this.interactionEndDate = source.interactionEndDate,
        this.__v = source.__v,
        this.likeList =
            source.likeList.map((item) => new Likes2.clone(item)).toList(),
        this.skillList =
            source.skillList.map((item) => new Skill.clone(item)).toList(),
        this.assestList =
            source.assestList.map((item) => new Assest.clone(item)).toList(),
        this.certificateList =
            source.certificateList.map((item) => (item)).toList(),
        this.badgeList = source.badgeList.map((item) => (item)).toList(),
        this.recommender = new Recommender.clone(source.recommender);
}

class Achivment {
  String _id,
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
      guidePromptRecommendation,
      __v;
  List<String> storiesList;
  List<Likes2> likeList;
  List<Skill> skillList;
  List<Assest> assestList;
  List<String> certificateList;
  List<String> badgeList;

  Achivment(
      this._id,
      this.achievementId,
      this.competencyTypeId,
      this.level2Competency,
      this.level3Competency,
      this.userId,
      this.title,
      this.description,
      this.fromDate,
      this.toDate,
      this.isActive,
      this.importance,
      this.__v,
      this.guidePromptRecommendation,
      this.storiesList,
      this.likeList,
      this.skillList,
      this.assestList,
      this.certificateList,
      this.badgeList);

  Achivment.clone(Achivment source)
      : this._id = source._id,
        this.achievementId = source.achievementId,
        this.competencyTypeId = source.competencyTypeId,
        this.level2Competency = source.level2Competency,
        this.level3Competency = source.level3Competency,
        this.userId = source.userId,
        this.title = source.title,
        this.description = source.description,
        this.fromDate = source.fromDate,
        this.toDate = source.toDate,
        this.isActive = source.isActive,
        this.importance = source.importance,
        this.__v = source.__v,
        this.guidePromptRecommendation = source.guidePromptRecommendation,
        this.storiesList = source.storiesList.map((item) => (item)).toList(),
        this.likeList =
            source.likeList.map((item) => new Likes2.clone(item)).toList(),
        this.skillList =
            source.skillList.map((item) => new Skill.clone(item)).toList(),
        this.assestList =
            source.assestList.map((item) => new Assest.clone(item)).toList(),
        this.certificateList =
            source.certificateList.map((item) => (item)).toList(),
        this.badgeList = source.badgeList.map((item) => (item)).toList();
}

class Likes2 {
  String userId, name, profilePicture, title;

  Likes2(this.userId, this.name, this.profilePicture, this.title);

  Likes2.clone(Likes2 source)
      : this.userId = source.userId,
        this.name = source.name,
        this.profilePicture = source.profilePicture,
        this.title = source.title;
}

class Assest {
  String type, tag, file;
  bool isSelected = false;

  Assest(this.type, this.tag, this.file, this.isSelected);

  Map<String, dynamic> toJson() => {
        'type': type,
        'tag': tag,
        'file': file,
      };

  Assest.clone(Assest source)
      : this.type = source.type,
        this.tag = source.tag,
        this.file = source.file;
}

class TagsPost {
  String userId;

  TagsPost(this.userId);

  Map<String, dynamic> toJson() => {'userId': int.parse(userId)};
}

class AssestForPost {
  String imagePath;
  String type, file;
  bool isSelected = false;

  AssestForPost(this.imagePath, this.type, this.file, this.isSelected);

  Map<String, dynamic> toJson() => {
        'type': type,
        'file': file,
      };
}

class Images {
  String imagePath;

  Images(this.imagePath);
}

class Skill {
  String label, skillId;

  Skill(this.label, this.skillId);

  Map<String, dynamic> toJson() => {
        'label': label,
        'skillId': skillId,
      };

  Skill.clone(Skill source)
      : this.label = source.label,
        this.skillId = source.skillId;
}

class Recommender {
  String _id,
      userId,
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
      title,
      tempPassword,
      isArchived,
      __v;

  Recommender(
      this._id,
      this.userId,
      this.firstName,
      this.lastName,
      this.email,
      this.password,
      this.salt,
      this.mobileNo,
      this.roleId,
      this.isActive,
      this.isPasswordChanged,
      this.organizationId,
      this.dob,
      this.title,
      this.tempPassword,
      this.isArchived,
      this.__v);

  Recommender.clone(Recommender source)
      : this._id = source._id,
        this.userId = source.userId,
        this.firstName = source.firstName,
        this.lastName = source.lastName,
        this.email = source.email,
        this.password = source.password,
        this.salt = source.salt,
        this.mobileNo = source.mobileNo,
        this.roleId = source.roleId,
        this.isActive = source.isActive,
        this.isPasswordChanged = source.isPasswordChanged,
        this.organizationId = source.organizationId,
        this.dob = source.dob,
        this.title = source.title,
        this.tempPassword = source.tempPassword,
        this.isArchived = source.isArchived,
        this.__v = source.__v;
}
