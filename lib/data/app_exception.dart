import 'package:flutter/material.dart';

class AppException implements Exception {
 final String? _message;
 final String? _prefix;
     AppException([this._message, this._prefix]);
 @override
  String toString() {
   if(_message == null || _message!.isEmpty) {
     return '$_prefix';
   }
   return '$_message: $_prefix';
 }
}
class FetchDataException extends AppException{
  FetchDataException([String? message]) :
        super(message, 'Error during communication');
}
class BadDataException extends AppException{
  BadDataException([String? message]) :
        super(message, 'Invalid Request');
}
class UnauthorizedDataException extends AppException{
  UnauthorizedDataException([String? message]) :
        super(message, 'Unauthorized Request');
}