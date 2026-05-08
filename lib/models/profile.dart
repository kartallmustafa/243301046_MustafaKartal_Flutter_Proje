class Profile {
  final String id;
  final String role;
  final int? perId;
  final int? topId;
  final String? fullName;

  const Profile({
    required this.id,
    required this.role,
    this.perId,
    this.topId,
    this.fullName,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        role: json['role'] as String,
        perId: json['per_id'] as int?,
        topId: json['top_id'] as int?,
        fullName: json['full_name'] as String?,
      );

  bool get isPerakendeci => role == 'perakendeci';
  bool get isToptanci => role == 'toptanci';
}
