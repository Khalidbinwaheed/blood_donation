import 'package:blood_donation/features/appointments/data/appointment_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class FirestoreAppointmentRepository implements AppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createAppointment({
    required String userId,
    required String centerId,
    required DateTime date,
    required String timeSlot,
    String? type,
    String? doctorId,
  }) async {
    if (doctorId == null) {
      throw ArgumentError('doctorId is required for booking');
    }

    final dayOnly = _dayStart(date);
    final dateStr = DateFormat('yyyy-MM-dd').format(dayOnly);
    final availabilityDocId = '${doctorId}_$dateStr';
    final availabilityRef = _firestore.collection('availability').doc(
          availabilityDocId,
        );
    final appointmentRef = _firestore.collection('appointments').doc();

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(availabilityRef);

      if (!snapshot.exists) {
        throw Exception('Doctor is not available on this date.');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final List<dynamic> slots = data['slots'] ?? [];
      final List<String> availableSlots = slots.cast<String>();

      if (!availableSlots.contains(timeSlot)) {
        throw Exception('Slot $timeSlot is no longer available.');
      }

      transaction.update(availabilityRef, {
        'slots': FieldValue.arrayRemove([timeSlot])
      });

      transaction.set(appointmentRef, {
        'id': appointmentRef.id,
        ..._buildAppointmentPayload(
          userId: userId,
          centerId: centerId,
          doctorId: doctorId,
          date: dayOnly,
          timeSlot: timeSlot,
          type: type ?? 'Donation',
          status: 'booked',
        ),
      });
    });
  }

  @override
  Future<void> createAppointmentBySuperAdmin({
    required String userId,
    required String centerId,
    required String doctorId,
    required DateTime date,
    required String timeSlot,
    String? type,
    String? status,
  }) async {
    final appointmentRef = _firestore.collection('appointments').doc();
    await appointmentRef.set({
      'id': appointmentRef.id,
      ..._buildAppointmentPayload(
        userId: userId,
        centerId: centerId,
        doctorId: doctorId,
        date: date,
        timeSlot: timeSlot,
        type: (type ?? 'Donation').trim(),
        status: (status ?? 'booked').trim(),
      ),
      'createdByRole': 'super_admin',
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getUserAppointments(String uid) {
    return _firestore.collection('appointments').snapshots().map(
      (snapshot) {
        final items = snapshot.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          return data;
        }).where((item) {
          final ownerId = (item['userId'] ?? item['userUid'] ?? '').toString();
          return ownerId == uid;
        }).toList();

        items.sort((a, b) {
          final aDate = _toDateTime(a['startsAt']) ?? _toDateTime(a['date']);
          final bDate = _toDateTime(b['startsAt']) ?? _toDateTime(b['date']);
          if (aDate == null && bDate == null) {
            return 0;
          }
          if (aDate == null) {
            return 1;
          }
          if (bDate == null) {
            return -1;
          }
          return aDate.compareTo(bDate);
        });
        return items;
      },
    );
  }

  @override
  Stream<List<Map<String, dynamic>>> getAllAppointments() {
    return _firestore.collection('appointments').snapshots().map((snapshot) {
      final items = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return data;
      }).toList();

      items.sort((a, b) {
        final aDate = _toDateTime(a['startsAt']) ?? _toDateTime(a['date']);
        final bDate = _toDateTime(b['startsAt']) ?? _toDateTime(b['date']);
        if (aDate == null && bDate == null) {
          return 0;
        }
        if (aDate == null) {
          return 1;
        }
        if (bDate == null) {
          return -1;
        }
        return aDate.compareTo(bDate);
      });

      return items;
    });
  }

  @override
  Future<void> setAvailability(
      String doctorId, DateTime date, List<String> slots) async {
    final dayOnly = _dayStart(date);
    final dateStr = DateFormat('yyyy-MM-dd').format(dayOnly);
    final availabilityDocId = '${doctorId}_$dateStr';
    await _firestore.collection('availability').doc(availabilityDocId).set({
      'id': availabilityDocId,
      'doctorId': doctorId,
      'date': Timestamp.fromDate(dayOnly),
      'slots': slots,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getDoctorAppointments(String doctorId) {
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return data;
      }).toList();

      items.sort((a, b) {
        final aDate = _toDateTime(a['startsAt']) ?? _toDateTime(a['date']);
        final bDate = _toDateTime(b['startsAt']) ?? _toDateTime(b['date']);
        if (aDate == null && bDate == null) {
          return 0;
        }
        if (aDate == null) {
          return 1;
        }
        if (bDate == null) {
          return -1;
        }
        return aDate.compareTo(bDate);
      });

      return items;
    });
  }

  @override
  Future<void> updateAppointment(
    String appointmentId, {
    String? userId,
    String? centerId,
    String? doctorId,
    DateTime? date,
    String? timeSlot,
    String? type,
    String? status,
  }) async {
    final docRef = _firestore.collection('appointments').doc(appointmentId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      throw Exception('Appointment not found.');
    }

    final current = snapshot.data() ?? const <String, dynamic>{};
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (userId != null && userId.trim().isNotEmpty) {
      updates['userId'] = userId.trim();
      updates['userUid'] = userId.trim();
    }
    if (centerId != null && centerId.trim().isNotEmpty) {
      updates['centerId'] = centerId.trim();
    }
    if (doctorId != null && doctorId.trim().isNotEmpty) {
      updates['doctorId'] = doctorId.trim();
    }
    if (type != null && type.trim().isNotEmpty) {
      updates['type'] = type.trim();
    }
    if (status != null && status.trim().isNotEmpty) {
      updates['status'] = status.trim();
    }
    if (timeSlot != null && timeSlot.trim().isNotEmpty) {
      updates['timeSlot'] = timeSlot.trim();
    }
    if (date != null) {
      updates['date'] = Timestamp.fromDate(_dayStart(date));
    }

    final existingDate = _toDateTime(current['date']) ??
        _toDateTime(current['startsAt']) ??
        DateTime.now();
    final effectiveDate = date ?? existingDate;
    final effectiveSlot = (timeSlot ?? current['timeSlot'])?.toString();

    if (date != null || timeSlot != null) {
      final startsAt = _combineDateAndSlot(
        day: effectiveDate,
        timeSlot: effectiveSlot,
      );
      updates['startsAt'] = Timestamp.fromDate(startsAt);
      updates['endsAt'] =
          Timestamp.fromDate(startsAt.add(const Duration(minutes: 30)));
    }

    await docRef.update(updates);
  }

  @override
  Future<void> deleteAppointment(String appointmentId) async {
    await _firestore.collection('appointments').doc(appointmentId).delete();
  }

  Map<String, dynamic> _buildAppointmentPayload({
    required String userId,
    required String centerId,
    required String doctorId,
    required DateTime date,
    required String timeSlot,
    required String type,
    required String status,
  }) {
    final startsAt = _combineDateAndSlot(day: date, timeSlot: timeSlot);
    final endsAt = startsAt.add(const Duration(minutes: 30));

    return {
      'userId': userId,
      'userUid': userId,
      'centerId': centerId,
      'doctorId': doctorId,
      'date': Timestamp.fromDate(_dayStart(date)),
      'timeSlot': timeSlot,
      'startsAt': Timestamp.fromDate(startsAt),
      'endsAt': Timestamp.fromDate(endsAt),
      'status': status,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  DateTime _dayStart(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _combineDateAndSlot({
    required DateTime day,
    required String? timeSlot,
  }) {
    if (timeSlot == null || timeSlot.trim().isEmpty) {
      return DateTime(day.year, day.month, day.day, 9, 0);
    }

    try {
      final parsed = DateFormat('hh:mm a').parseStrict(timeSlot.trim());
      return DateTime(
        day.year,
        day.month,
        day.day,
        parsed.hour,
        parsed.minute,
      );
    } catch (_) {
      return DateTime(day.year, day.month, day.day, 9, 0);
    }
  }

  DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

// Provider update needed in main/di or here
final firestoreAppointmentRepositoryProvider =
    Provider<AppointmentRepository>((ref) {
  return FirestoreAppointmentRepository();
});
