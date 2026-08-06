import 'package:equatable/equatable.dart';
import 'user_model.dart';

class TeamMemberModel extends Equatable {
  final String studentId;
  final String status; // 'PENDING' | 'ACCEPTED' | 'REJECTED'
  final UserModel? student;

  const TeamMemberModel({
    required this.studentId,
    required this.status,
    this.student,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      studentId: json['studentId'] ?? '',
      status: json['status'] ?? 'PENDING',
      student: json['student'] != null ? UserModel.fromJson(json['student']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'status': status,
      'student': student?.toJson(),
    };
  }

  @override
  List<Object?> get props => [studentId, status, student];
}

class TeamModel extends Equatable {
  final String id;
  final String teamName;
  final String eventId;
  final String leaderId;
  final List<TeamMemberModel> members;
  final Map<String, dynamic>? formResponses;
  final String? transactionId;
  final String? payerName;
  final String? paymentRemarks;

  const TeamModel({
    required this.id,
    required this.teamName,
    required this.eventId,
    required this.leaderId,
    required this.members,
    this.formResponses,
    this.transactionId,
    this.payerName,
    this.paymentRemarks,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    var rawMembers = json['members'] as List?;
    List<TeamMemberModel> membersList = rawMembers != null
        ? rawMembers.map((m) => TeamMemberModel.fromJson(m)).toList()
        : [];
    return TeamModel(
      id: json['id'] ?? json['_id'] ?? '',
      teamName: json['teamName'] ?? '',
      eventId: json['eventId'] ?? '',
      leaderId: json['leaderId'] ?? '',
      members: membersList,
      formResponses: json['formResponses'],
      transactionId: json['transactionId'],
      payerName: json['payerName'],
      paymentRemarks: json['paymentRemarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamName': teamName,
      'eventId': eventId,
      'leaderId': leaderId,
      'members': members.map((m) => m.toJson()).toList(),
      'formResponses': formResponses,
      'transactionId': transactionId,
      'payerName': payerName,
      'paymentRemarks': paymentRemarks,
    };
  }

  @override
  List<Object?> get props => [
        id,
        teamName,
        eventId,
        leaderId,
        members,
        formResponses,
        transactionId,
        payerName,
        paymentRemarks,
      ];
}
