class MarriageRegistrationModel {
  const MarriageRegistrationModel({
    required this.id,
    required this.groomName,
    required this.groomAddress,
    required this.brideName,
    required this.brideAddress,
    required this.marriagePlace,
    required this.venue,
    required this.marriageDate,
    required this.registeredAt,
  });

  final String id;
  final String groomName;
  final String groomAddress;
  final String brideName;
  final String brideAddress;
  final String marriagePlace;
  final String venue;
  final DateTime marriageDate;
  final DateTime registeredAt;

  factory MarriageRegistrationModel.fromJson(Map<String, dynamic> json) {
    return MarriageRegistrationModel(
      id: json['id'] as String,
      groomName: json['groom_name'] as String,
      groomAddress: json['groom_address'] as String,
      brideName: json['bride_name'] as String,
      brideAddress: json['bride_address'] as String,
      marriagePlace: json['marriage_place'] as String,
      venue: json['venue'] as String,
      marriageDate: DateTime.parse(json['marriage_date'] as String),
      registeredAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'groom_name': groomName,
        'groom_address': groomAddress,
        'bride_name': brideName,
        'bride_address': brideAddress,
        'marriage_place': marriagePlace,
        'venue': venue,
        'marriage_date': marriageDate.toIso8601String().split('T').first,
      };
}
