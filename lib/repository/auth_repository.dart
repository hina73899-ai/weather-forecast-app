

import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../res/app_url.dart';

class AuthRepository {
  BaseApiServices _apiServices = NetworkApiServices();

  Future<dynamic> loginApi(dynamic data) async {

    try{
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.loginEndpoint,
          data);
      return response;
    } catch (e) {
      throw e;

    }

  }
  Future<dynamic> registerApi(dynamic data) async {

    try{
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.registeredApiEndpoints,
          data);
      return response;
    } catch (e) {
      throw e;

    }

  }

}