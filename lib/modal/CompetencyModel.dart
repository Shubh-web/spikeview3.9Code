import 'dart:io';

class CompetencyModel {
  String level1;

  List<Level2Competencies> level2Competencylist;

  CompetencyModel(this.level1, this.level2Competencylist);
}

class Level2Competencies {
  String name, competencyTypeId;
  bool isSelected;
  List<Level3Competencies> level3Competencylist;

  Level2Competencies(this.name, this.competencyTypeId,this.isSelected, this.level3Competencylist);
}

class Level3Competencies {
  String name, key;

  Level3Competencies(this.name, this.key);
}
