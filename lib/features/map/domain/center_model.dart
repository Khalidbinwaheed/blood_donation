import 'package:freezed_annotation/freezed_annotation.dart';

part 'center_model.freezed.dart';
part 'center_model.g.dart';

@freezed
class CenterModel with _$CenterModel {
  const factory CenterModel({
    required String id,
    required String name,
    required double lat,
    required double lng,
    required String address,
    required String phone,
    @Default([]) List<String> specializations,
    @Default(false) bool openNow,
    @Default([]) List<String> accessibility,
    String? hours,
    String? website,
    double? distance, // Calculated field for UI
  }) = _CenterModel;

  factory CenterModel.fromJson(Map<String, dynamic> json) =>
      _$CenterModelFromJson(json);
}
