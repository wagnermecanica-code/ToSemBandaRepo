import 'dart:math' show pi, sin, cos, sqrt, asin;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Utilitários para cálculos geográficos
/// 
/// Implementa fórmula de Haversine para cálculo de distância entre coordenadas

/// Calcula distância entre duas coordenadas usando fórmula de Haversine
/// 
/// Retorna distância em quilômetros
/// 
/// Exemplo:
/// ```dart
/// final distance = calculateDistance(
///   LatLng(-23.5505, -46.6333), // São Paulo
///   LatLng(-22.9068, -43.1729), // Rio de Janeiro
/// );
/// print('Distância: ${distance.toStringAsFixed(1)} km'); // ~360 km
/// ```
double calculateDistance(LatLng point1, LatLng point2) {
  const earthRadiusKm = 6371.0;

  final lat1Rad = _degreesToRadians(point1.latitude);
  final lat2Rad = _degreesToRadians(point2.latitude);
  final deltaLatRad = _degreesToRadians(point2.latitude - point1.latitude);
  final deltaLonRad = _degreesToRadians(point2.longitude - point1.longitude);

  final a = (sin(deltaLatRad / 2) * sin(deltaLatRad / 2)) +
      (cos(lat1Rad) * cos(lat2Rad) * sin(deltaLonRad / 2) * sin(deltaLonRad / 2));

  final c = 2 * asin(sqrt(a));

  return earthRadiusKm * c;
}

/// Calcula distância entre GeoPoint e LatLng
/// 
/// Wrapper conveniente para calcular distância quando um ponto é GeoPoint
double calculateDistanceFromGeoPoint(GeoPoint point1, LatLng point2) {
  return calculateDistance(
    LatLng(point1.latitude, point1.longitude),
    point2,
  );
}

/// Converte GeoPoint para LatLng
LatLng geoPointToLatLng(GeoPoint geoPoint) {
  return LatLng(geoPoint.latitude, geoPoint.longitude);
}

/// Calcula distância entre dois GeoPoints
double calculateDistanceBetweenGeoPoints(GeoPoint point1, GeoPoint point2) {
  return calculateDistance(
    LatLng(point1.latitude, point1.longitude),
    LatLng(point2.latitude, point2.longitude),
  );
}

/// Converte graus para radianos
double _degreesToRadians(double degrees) {
  return degrees * pi / 180.0;
}
