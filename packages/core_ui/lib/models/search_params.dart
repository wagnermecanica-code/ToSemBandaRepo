import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_params.freezed.dart';

@freezed
class SearchParams with _$SearchParams {
  const factory SearchParams({
    required String city,
    required double maxDistanceKm,
    String? level,
    @Default({}) Set<String> instruments,
    @Default({}) Set<String> genres,
    String? postType, // 'musician' ou 'band'
    String? availableFor, // 'gig', 'rehearsal', etc.
    bool? hasYoutube,
  }) = _SearchParams;
}
