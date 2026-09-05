import 'package:flutter_test/flutter_test.dart';
import 'package:xplore_app/models/user_model.dart';
import 'package:xplore_app/models/club_model.dart';
import 'package:xplore_app/models/event_model.dart';
import 'package:xplore_app/models/participation_model.dart';
import 'package:xplore_app/models/notification_model.dart';
import 'package:xplore_app/models/payment_model.dart';

void main() {
  group('Models Serialization and Deserialization Tests', () {
    test('UserModel parse and helper getters', () {
      final json = {
        '_id': 'user123',
        'name': 'Vikrant Saini',
        'email': 'vikrant@nitj.ac.in',
        'role': 'club',
        'userType': 'student',
        'rollNo': '21103045',
        'branch': 'CSE',
        'year': 4,
        'program': 'BTECH',
        'clubId': 'clubGDGC',
        'memberships': [
          {
            'id': 'mem1',
            'clubId': 'clubGDGC',
            'clubName': 'GDGC',
            'role': 'CLUB_HEAD',
            'canTakeAttendance': true,
            'canEditEvents': true,
          }
        ]
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 'user123');
      expect(user.name, 'Vikrant Saini');
      expect(user.email, 'vikrant@nitj.ac.in');
      expect(user.isClubHead, true);
      expect(user.isCoordinator, true);
      expect(user.memberships.length, 1);
      expect(user.memberships.first.canTakeAttendance, true);
    });

    test('ClubModel and SocialLinkModel parse', () {
      final json = {
        'id': 'c1',
        'clubName': 'GDGC Club',
        'slug': 'gdgc',
        'description': 'Google Developer Student Clubs',
        'category': 'TECH',
        'clubLogo': 'https://res.cloudinary.com/test/logo.png',
        'socialLinks': [
          {'platform': 'instagram', 'url': 'https://instagram.com/gdgc'}
        ],
        'clubGallery': ['https://res.cloudinary.com/test/pic1.png'],
        'clubSponsors': ['https://res.cloudinary.com/test/sp1.png'],
        'role': 'HEAD',
      };

      final club = ClubModel.fromJson(json);
      expect(club.id, 'c1');
      expect(club.name, 'GDGC Club');
      expect(club.socialLinks.length, 1);
      expect(club.socialLinks.first.platform, 'instagram');
      expect(club.clubGallery.length, 1);
    });

    test('EventModel parse and time formatters', () {
      final json = {
        '_id': 'event99',
        'title': 'Hackathon 2026',
        'venue': 'Main Auditorium',
        'startTime': '2026-09-15T17:30:00.000Z',
        'endTime': '2026-09-15T21:00:00.000Z',
        'totalSeats': 200,
        'registeredCount': 50,
        'entryFee': 150,
        'reviewStatus': 'PUBLISHED',
        'status': 'UPCOMING',
        'club': {
          'name': 'Kalakaar',
          'socialLinks': [
            {'platform': 'instagram', 'url': 'https://instagram.com/kalakaar'},
            {'platform': 'website', 'url': 'https://kalakaar.nitj.ac.in'}
          ]
        }
      };

      final event = EventModel.fromJson(json);
      expect(event.id, 'event99');
      expect(event.title, 'Hackathon 2026');
      expect(event.isPaid, true);
      expect(event.formattedTime, isNotEmpty);
      expect(event.formattedDate, isNotEmpty);
      expect(event.instagramUrl, 'https://instagram.com/kalakaar');
      expect(event.portfolioUrl, 'https://kalakaar.nitj.ac.in');
      expect(event.subtitle, 'Venue : Main Auditorium');
    });

    test('ParticipationModel parse and ticket verification', () {
      final json = {
        '_id': 'part123',
        'studentId': 'stud1',
        'status': 'ATTENDED',
        'qrCode': 'INT-65ABCD1234',
        'amountPaid': 150.0,
        'paymentStatus': 'SUCCESS',
        'student': {
          'id': 'stud1',
          'name': 'Alice Doe',
          'email': 'alice@nitj.ac.in',
          'rollNo': '21103099',
        },
      };

      final p = ParticipationModel.fromJson(json);
      expect(p.id, 'part123');
      expect(p.isAttended, true);
      expect(p.participantName, 'Alice Doe');
      expect(p.participantRollNo, '21103099');
      expect(p.qrCode, 'INT-65ABCD1234');
    });

    test('NotificationModel parse and sender info', () {
      final json = {
        '_id': 'notif1',
        'title': 'Workshop Rescheduled',
        'message': 'The workshop is moved to 6 PM.',
        'createdAt': '2026-08-30T10:00:00.000Z',
        'readBy': ['user1'],
        'sender': {'clubName': 'Octave Club', 'email': 'octave@nitj.ac.in'},
      };

      final notif = NotificationModel.fromJson(json);
      expect(notif.id, 'notif1');
      expect(notif.title, 'Workshop Rescheduled');
      expect(notif.senderName, 'Octave Club');
      expect(notif.isReadBy('user1'), true);
      expect(notif.isReadBy('user2'), false);
    });

    test('PaymentOrderModel parse', () {
      final json = {
        'success': true,
        'orderId': 'order_NM1234567890',
        'amount': 150,
        'currency': 'INR',
        'keyId': 'rzp_test_xxxx',
        'eventTitle': 'Hackathon 2026',
      };

      final order = PaymentOrderModel.fromJson(json);
      expect(order.success, true);
      expect(order.orderId, 'order_NM1234567890');
      expect(order.amount, 150.0);
      expect(order.currency, 'INR');
    });
  });
}
