import 'package:weather_forcast/data/response/status.dart';

class ApiResponse<T> {
  Status? status;
  T? data;
  String? message;

  ApiResponse([this.status, this.data, this.message]);

  // Loading State
  ApiResponse.Loading() : status = Status.Loading;

  // Completed State
  ApiResponse.Completed(this.data) : status = Status.Complete;

  // Error State
  ApiResponse.Error(this.message) : status = Status.Error;

  @override
  String toString() {
    return "Status: $status \n Message: $message \n Data: $data";
  }
}