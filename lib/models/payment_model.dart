import 'package:equatable/equatable.dart';

class PaymentOrderModel extends Equatable {
  final bool success;
  final String orderId;
  final double amount;
  final String currency;
  final String keyId;
  final String? eventTitle;

  const PaymentOrderModel({
    required this.success,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.keyId,
    this.eventTitle,
  });

  factory PaymentOrderModel.fromJson(Map<String, dynamic> json) {
    return PaymentOrderModel(
      success: json['success'] == true,
      orderId: json['orderId']?.toString() ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      currency: json['currency']?.toString() ?? 'INR',
      keyId: json['keyId']?.toString() ?? '',
      eventTitle: json['eventTitle']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      'keyId': keyId,
      'eventTitle': eventTitle,
    };
  }

  @override
  List<Object?> get props => [success, orderId, amount, currency, keyId, eventTitle];
}
