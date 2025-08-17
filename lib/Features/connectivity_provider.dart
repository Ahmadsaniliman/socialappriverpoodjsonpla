import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';


class NetworkService {
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('jsonplaceholder.typicode.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}

final networkServiceProvider = Provider<NetworkService>((ref) => NetworkService());
