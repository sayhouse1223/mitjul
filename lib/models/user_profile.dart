import 'package:cloud_firestore/cloud_firestore.dart';

/// 사용자 프로필 정보를 나타내는 데이터 모델입니다.
class UserProfile {
  final String userId;
  final String nickname;
  final String profileImageUrl;
  final String bio; // 자기소개
  final int followersCount;
  final int followingCount;
  final List<String> savedPosts; // 저장된 게시물 ID 목록
  final List<String> favoriteGenres; // 사용자가 선택한 선호 장르 목록
  final int characterBody; // 사용자가 선택한 캐릭터 몸체 (아바타)
  final int characterEye; // 선택한 캐릭터 눈
  final int characterColor; // 선택한 캐릭터 색상 팔레트
  final DateTime? createdAt; // 프로필 생성일

  UserProfile({
    required this.userId,
    required this.nickname,
    this.profileImageUrl = '', // 기본값: 빈 문자열
    this.bio = '', // 기본값: 빈 문자열
    this.followersCount = 0,
    this.followingCount = 0,
    this.savedPosts = const [],
    this.favoriteGenres = const [],
    this.characterBody = -1,
    this.characterEye = -1,
    this.characterColor = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now(); // createdAt이 없으면 현재 시간으로 설정

  /// Firestore Map 데이터로부터 UserProfile 객체를 생성하는 팩토리 메서드입니다.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      nickname: json['nickname'] as String,
      profileImageUrl: json['profileImageUrl'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      savedPosts: (json['savedPosts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      favoriteGenres: (json['favoriteGenres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      characterBody: (json['characterBody'] as int?) ?? -1,
      characterEye: (json['characterEye'] as int?) ?? -1,
      characterColor: (json['characterColor'] as int?) ?? 0,
      createdAt: _parseDateTime(json['createdAt']), // Timestamp 또는 String 파싱
    );
  }

  /// JSON에서 DateTime 또는 Timestamp를 유연하게 파싱하기 위한 헬퍼 (private)
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
  
  // Note: 일반적으로 firestore와 같은 외부 시스템에 저장할 때는 toFirestore()를 사용합니다.
  // toJson()이 필요한 경우는 JSON API 통신 등 다른 용도가 있을 때입니다.
  
  /// UserProfile 객체를 Firestore에 저장할 수 있는 Map 형태로 변환합니다.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'savedPosts': savedPosts,
      'favoriteGenres': favoriteGenres,
      'characterBody': characterBody,
      'characterEye': characterEye,
      'characterColor': characterColor,
      // Firestore Timestamp로 변환하여 저장
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(), // 마지막 업데이트 시간
    };
  }
  
  /// 객체의 내용을 출력하기 위한 toString 메서드 오버라이드 (디버깅 용)
  @override
  String toString() {
    return 'UserProfile(userId: $userId, nickname: $nickname, body: $characterBody)';
  }

  /// 유틸리티: 프로필 정보가 최소한으로 채워져 있는지 확인
  bool get isProfileComplete => nickname.isNotEmpty;
}