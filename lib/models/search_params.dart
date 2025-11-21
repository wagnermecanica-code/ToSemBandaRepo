class SearchParams {
  final String city;
  final String? level;
  final Set<String> instruments;
  final Set<String> genres;
  final double maxDistanceKm;

  SearchParams({
    required this.city,
    this.level,
    Set<String>? instruments,
    Set<String>? genres,
    required this.maxDistanceKm,
  }) : instruments = instruments ?? {}, genres = genres ?? {};

  SearchParams copyWith({
    String? city,
    String? level,
    Set<String>? instruments,
    Set<String>? genres,
    double? maxDistanceKm,
  }) {
    return SearchParams(
      city: city ?? this.city,
      level: level ?? this.level,
      instruments: instruments ?? this.instruments,
      genres: genres ?? this.genres,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
    );
  }
}
