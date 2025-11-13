import 'package:cloud_firestore/cloud_firestore.dart';

/// 사용자 프로필 모델
class UserProfile {
  final String userId;
  final String nickname;
  final List<String> favoriteGenres;
  final int characterBody; // 1-8
  final int characterEye; // 1-4
  final int characterColor; // 0-4 (파랑, 하늘색, 초록, 빨강, 노랑)
  final DateTime createdAt;

  UserProfile({
    required this.userId,
    required this.nickname,
    required this.favoriteGenres,
    required this.characterBody,
    required this.characterEye,
    required this.characterColor,
    required this.createdAt,
  });

  /// Firestore로부터 데이터 변환
  factory UserProfile.fromFirestore(Map<String, dynamic> data, String userId) {
    return UserProfile(
      userId: userId,
      nickname: data['nickname'] as String? ?? '',
      favoriteGenres: List<String>.from(data['favoriteGenres'] as List? ?? []),
      characterBody: data['characterBody'] as int? ?? 1,
      characterEye: data['characterEye'] as int? ?? 1,
      characterColor: data['characterColor'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore에 저장할 데이터로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'nickname': nickname,
      'favoriteGenres': favoriteGenres,
      'characterBody': characterBody,
      'characterEye': characterEye,
      'characterColor': characterColor,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// 복사본 생성 (불변성 유지)
  UserProfile copyWith({
    String? userId,
    String? nickname,
    List<String>? favoriteGenres,
    int? characterBody,
    int? characterEye,
    int? characterColor,
    DateTime? createdAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      characterBody: characterBody ?? this.characterBody,
      characterEye: characterEye ?? this.characterEye,
      characterColor: characterColor ?? this.characterColor,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}