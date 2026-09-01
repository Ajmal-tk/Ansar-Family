class FeeModel {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final String? period;
  final String status;
  final DateTime paymentDate;
  final String? createdBy;
  final String? userName;

  FeeModel({
    required this.id,
    required this.userId,
    required this.amount,
    this.currency = 'INR',
    this.period,
    this.status = 'paid',
    required this.paymentDate,
    this.createdBy,
    this.userName,
  });

  factory FeeModel.fromJson(Map<String, dynamic> json) {
    String? name;
    if (json['profiles'] != null && json['profiles'] is Map) {
      name = json['profiles']['full_name'] as String?;
    }

    return FeeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : double.parse(json['amount'].toString()),
      currency: json['currency'] as String? ?? 'INR',
      period: json['period'] as String?,
      status: json['status'] as String? ?? 'paid',
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'].toString())
          : DateTime.now(),
      createdBy: json['created_by'] as String?,
      userName: name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'currency': currency,
      'period': period,
      'status': status,
      'payment_date': paymentDate.toIso8601String(),
      'created_by': createdBy,
    };
  }
}
