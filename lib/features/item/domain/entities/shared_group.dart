class SharedGroup {
  final String id;
  final String userAId;
  final String userBId;
  final String? nameUserA;
  final String? nameUserB;

  SharedGroup({
    required this.id,
    required this.userAId,
    required this.userBId,
    this.nameUserA,
    this.nameUserB,
  });
}
