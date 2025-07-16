class User {
  final int id;
  final String email;
  final String name;
  final String userType;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? profilePicture;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.userType,
    this.phoneNumber,
    this.dateOfBirth,
    this.profilePicture,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      userType: json['user_type'],
      phoneNumber: json['phone_number'],
      dateOfBirth:
          json['date_of_birth'] != null
              ? DateTime.parse(json['date_of_birth'])
              : null,
      profilePicture: json['profile_picture'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'user_type': userType,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'profile_picture': profilePicture,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Branch {
  final int id;
  final String name;
  final String location;
  final String? description;
  final int capacity;
  final bool isActive;

  Branch({
    required this.id,
    required this.name,
    required this.location,
    this.description,
    required this.capacity,
    required this.isActive,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      description: json['description'],
      capacity: json['capacity'],
      isActive: json['is_active'] ?? true,
    );
  }
}

class Attendance {
  final int id;
  final int athleteId;
  final DateTime date;
  final bool present;
  final String? notes;

  Attendance({
    required this.id,
    required this.athleteId,
    required this.date,
    required this.present,
    this.notes,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      athleteId: json['athlete_id'],
      date: DateTime.parse(json['date']),
      present: json['present'],
      notes: json['notes'],
    );
  }
}

class Thread {
  final int id;
  final String title;
  final int createdBy;
  final DateTime createdAt;
  final List<Message>? messages;

  Thread({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.createdAt,
    this.messages,
  });

  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      id: json['id'],
      title: json['title'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      messages:
          json['messages'] != null
              ? (json['messages'] as List)
                  .map((m) => Message.fromJson(m))
                  .toList()
              : null,
    );
  }
}

class Message {
  final int id;
  final int threadId;
  final int senderId;
  final String content;
  final DateTime createdAt;
  final String? senderName;

  Message({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.senderName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      threadId: json['thread_id'],
      senderId: json['sender_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      senderName: json['sender_name'],
    );
  }
}

class Gear {
  final int id;
  final String name;
  final String category;
  final String? description;
  final double? price;
  final String? imageUrl;
  final bool isAvailable;

  Gear({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.price,
    this.imageUrl,
    required this.isAvailable,
  });

  factory Gear.fromJson(Map<String, dynamic> json) {
    return Gear(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      price: json['price']?.toDouble(),
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] ?? true,
    );
  }
}

class Measurement {
  final int id;
  final int athleteId;
  final double? weight;
  final double? height;
  final double? bodyFat;
  final double? muscleMass;
  final DateTime recordedAt;
  final String? notes;

  Measurement({
    required this.id,
    required this.athleteId,
    this.weight,
    this.height,
    this.bodyFat,
    this.muscleMass,
    required this.recordedAt,
    this.notes,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      id: json['id'],
      athleteId: json['athlete_id'],
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      bodyFat: json['body_fat']?.toDouble(),
      muscleMass: json['muscle_mass']?.toDouble(),
      recordedAt: DateTime.parse(json['recorded_at']),
      notes: json['notes'],
    );
  }
}
