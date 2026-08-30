import 'dart:async'; // TimeoutException ke liye required hai
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:weather_forcast/data/app_exception.dart';
import 'package:weather_forcast/data/network/base_api_services.dart';

class NetworkApiServices extends BaseApiServices {
  @override
  Future<dynamic> getGetApiResponse(String url) async {
    dynamic responseJson;

    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException("No network connection");
    } on TimeoutException {
      throw FetchDataException("Request timed out. Please try again.");
    }

    return responseJson;
  }

  @override
  Future<dynamic> getPostApiResponse(String url, dynamic data) async {
    dynamic responseJson;

    try {
      final response = await http
          .post(
        Uri.parse(url),
        body: data,
      )
          .timeout(
        const Duration(seconds: 10),
      );

      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException("No network connection");
    } on TimeoutException {
      throw FetchDataException("Request timed out. Please try again.");
    }

    return responseJson;
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;

      case 400:
        throw BadDataException(
          "Bad Request: ${response.statusCode}",
        );

      case 401:
      case 403:
        throw UnauthorizedDataException(
          "Unauthorized Access: ${response.statusCode}",
        );

      case 404:
        throw FetchDataException(
          "Resource not found (404)",
        );

      case 500:
      case 502:
      case 503:
        throw FetchDataException(
          "Server internal error (${response.statusCode}). Please try again later.",
        );

      default:
        throw FetchDataException(
          "Error occurred while communicating with server with status code ${response.statusCode}",
        );
    }
  }
}