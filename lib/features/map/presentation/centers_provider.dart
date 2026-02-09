import 'package:blood_donation/features/map/data/centers_repository.dart';
import 'package:blood_donation/features/map/domain/center_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'centers_provider.g.dart';

@riverpod
Future<List<CenterModel>> nearbyCenters(
  Ref ref, {
  required double lat,
  required double lng,
}) async {
  final repository = ref.watch(centersRepositoryProvider);
  return repository.getNearbyCenters(lat: lat, lng: lng);
}
