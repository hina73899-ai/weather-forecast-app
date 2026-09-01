// =========================================================
// FILE: uv_api_services.dart
// =========================================================
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../res/app_url.dart';
import '../widgets/protection.dart';


class UvApiService {
  /// Fetches hourly UV index and returns a rolling window starting
  /// at the current hour. windowSize is increased to ~2.7 days
  /// (65 hours) so multiple complete peak/dip cycles are visible,
  /// matching how commercial weather apps display this chart.
  static Future<List<HourlyUV>> fetchHourlyUV({
    required double latitude,
    required double longitude,
    int windowSize = 65, // ~2.7 days -> shows 2-3 full peaks
  }) async {
    final uri = Uri.parse(AppUrl.forecastEndpoint).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'hourly': 'uv_index',
        'timezone': 'auto',
        'forecast_days': '4', // need enough days to cover the window
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load UV data (${response.statusCode})');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;

    final times = (hourly['time'] as List).cast<String>();
    final uvValues = (hourly['uv_index'] as List)
        .map((v) => (v as num).toDouble())
        .toList();

    final all = List<HourlyUV>.generate(
      times.length,
          (i) => HourlyUV(time: DateTime.parse(times[i]), uv: uvValues[i]),
    );

    final now = DateTime.now();
    int startIndex = all.indexWhere(
          (h) => h.time.isAfter(now) ||
          h.time.isAtSameMomentAs(
            DateTime(now.year, now.month, now.day, now.hour),
          ),
    );
    if (startIndex == -1) startIndex = 0;

    final endIndex = (startIndex + windowSize).clamp(0, all.length);
    return all.sublist(startIndex, endIndex);
  }
}