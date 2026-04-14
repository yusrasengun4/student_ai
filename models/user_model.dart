class UserModel {
  final int    id;
  final String email;
  final int    age;
  final String gender;
  final String academicLevel;
  final int    partTimeJob;

  const UserModel({
    required this.id,
    required this.email,
    required this.age,
    required this.gender,
    required this.academicLevel,
    required this.partTimeJob,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:            json['id'],
    email:         json['email'],
    age:           json['age'],
    gender:        json['gender'],
    academicLevel: json['academic_level'],
    partTimeJob:   json['part_time_job'],
  );

  Map<String, dynamic> toJson() => {
    'id':             id,
    'email':          email,
    'age':            age,
    'gender':         gender,
    'academic_level': academicLevel,
    'part_time_job':  partTimeJob,
  };
}