class User {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final int? height; // cm
  final int? weight; // kg
  final int? age;
  final String? gender;
  final String? fitnessGoal;
  final String? displayName;
  final String? provider;
  final String? photoUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.height,
    this.weight,
    this.age,
    this.gender,
    this.fitnessGoal,
    this.displayName,
    this.provider,
    this.photoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Trích xuất ID từ các trường khác nhau
    String userId = json['id'] ?? json['uid'] ?? '';
    
    // Trích xuất tên từ các trường khác nhau
    String userName = json['name'] ?? json['displayName'] ?? '';
    if (userName.isEmpty && json.containsKey('email')) {
      userName = json['email'].toString().split('@')[0];
    }
    
    return User(
      id: userId,
      name: userName,
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'] ?? json['photoUrl'],
      height: json['height'],
      weight: json['weight'],
      age: json['age'],
      gender: json['gender'],
      fitnessGoal: json['fitnessGoal'],
      displayName: json['displayName'],
      provider: json['provider'],
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
      'fitnessGoal': fitnessGoal,
      'displayName': displayName,
      'provider': provider,
      'photoUrl': photoUrl,
    };
  }
} 