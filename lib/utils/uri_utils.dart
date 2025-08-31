import 'package:finalyear/constants/constants.dart';

/// Utility class for URI building operations
class UriUtils {
  /// Helper method to build URI based on environment (HTTP or HTTPS)
  /// 
  /// This method dynamically constructs URIs based on the environment by:
  /// - Parsing the base URL to determine the scheme (http or https)
  /// - Extracting the host and port information
  /// - Using the appropriate URI constructor ([Uri.http] or [Uri.https]) based on the scheme
  /// 
  /// [endpoint] The API endpoint path
  /// [queryParams] Optional query parameters to include in the URI
  static Uri buildUri(String endpoint, [Map<String, String>? queryParams]) {
    // Parse the base URL to determine scheme, host, and port
    final uri = Uri.parse(Constants.baseUrl);
    
    // Use the appropriate URI constructor based on the scheme
    if (uri.scheme == 'https') {
      return Uri.https(uri.host + (uri.hasPort ? ':${uri.port}' : ''), endpoint, queryParams);
    } else {
      return Uri.http(uri.host + (uri.hasPort ? ':${uri.port}' : ''), endpoint, queryParams);
    }
  }
}