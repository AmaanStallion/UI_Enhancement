import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
//import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/websocket/portal_access_service.dart';

Future<void> getDeviceInfo() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  print('App Version: ${packageInfo.version}');
  print('Build Number: ${packageInfo.buildNumber}');
  print('System Name: ${Platform.operatingSystem}'); // 'windows', 'macos'
  print('System Version: ${Platform.operatingSystemVersion}');
  print(packageInfo);
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class NetworkHandler {
  //var log = Logger();

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  /// Returns the project token if one is active (user is inside a project),
  /// otherwise falls back to the master token. This is the correct token for
  /// ALL project-scoped API calls (permissions, legal, towers, etc.).
  Future<String?> _getEffectiveToken() async {
    final prefs = await _prefs;
    final projectToken = prefs.getString('projectToken');
    if (projectToken != null && projectToken.isNotEmpty) {
      return projectToken;
    }
    return prefs.getString('masterToken') ?? prefs.getString('token');
  }

  /// Returns the active token for API requests.
  Future<String?> getToken() async {
    return _getEffectiveToken();
  }

  /// Always returns the master token. Used only for:
  ///   - GET /projects/mobile (project list)
  ///   - POST /auth/mobile/switch-by-project (workspace switch)
  ///   - GET /notifications (global notifications)
  Future<String?> _getMasterToken() async {
    final prefs = await _prefs;
    return prefs.getString('masterToken') ?? prefs.getString('token');
  }

  /// Returns the master token (developer account token).
  Future<String?> getMasterToken() async {
    return _getMasterToken();
  }

  /// Always performs a GET request using the master token. Used for global endpoints
  /// such as GET /notifications and GET /projects/mobile.
  Future getWithMasterToken(String url, {bool skipPortalAccessCheck = false}) async {
    String? token = await _getMasterToken();
    Map<String, String> headers = _buildHeaders(url, token, contentType: "application/json", onlyNewBackend: true);
    if (kDebugMode) {
      print("NetworkHandler.getWithMasterToken sending headers: $headers for url: $url");
    }
    http.Response response = await http.get(Uri.parse(url), headers: headers);
    _checkForceLogout(response);
    return response;
  }

  static String? activeProjectIdCache;

  /// Ensures the active projectToken in SharedPreferences corresponds to targetProjectId.
  /// Calls POST /auth/mobile/switch-by-project with master token if needed.
  Future<bool> ensureProjectContext(String? projectId) async {
    if (projectId == null || projectId.isEmpty || projectId == '0') return false;
    activeProjectIdCache = projectId;
    try {
      final prefs = await _prefs;
      final String? currentActiveId = prefs.getString('activeProjectId');
      final String? currentToken = prefs.getString('projectToken');

      // Check if currentToken has target projectId in its decoded claims
      bool tokenHasProject = false;
      if (currentToken != null && currentToken.isNotEmpty) {
        try {
          final parts = currentToken.split('.');
          if (parts.length >= 2) {
            final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
            final decoded = json.decode(payload);
            final tokenProjId = decoded['project_id']?.toString() ??
                decoded['projectId']?.toString() ??
                decoded['active_project_id']?.toString();
            if (tokenProjId == projectId || (tokenProjId == null && currentActiveId == projectId)) {
              tokenHasProject = true;
            }
          }
        } catch (_) {}
      }

      if (tokenHasProject && currentActiveId == projectId) {
        return true;
      }

      final response = await postWithMasterToken(
        AppUrl.switchByProject,
        {"project_id": projectId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        final String? newToken = decoded['data']?['token']?.toString();
        if (newToken != null && newToken.isNotEmpty) {
          await prefs.setString('projectToken', newToken);
          await prefs.setString('activeProjectId', projectId);
          activeProjectIdCache = projectId;
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<bool> ensureTowerContext(String? projectId, String? towerId) async {
    if (projectId == null || projectId.isEmpty || towerId == null || towerId.isEmpty) return false;
    try {
      final prefs = await _prefs;
      final response = await postWithMasterToken(
        AppUrl.switchByProject,
        {
          "project_id": projectId,
          "tower_id": towerId,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        final String? newToken = decoded['data']?['token']?.toString();
        if (newToken != null && newToken.isNotEmpty) {
          await prefs.setString('projectToken', newToken);
          await prefs.setString('activeProjectId', projectId);
          await prefs.setString('activeTowerId', towerId);
          activeProjectIdCache = projectId;
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  /// Check if response indicates the user is unauthorized (session expired)
  /// and trigger force-logout if so.
  void _checkForceLogout(http.Response response) {
    if (response.statusCode == 401) {
      if (kDebugMode) {
        print('🔒 NetworkHandler: Received 401 — triggering force logout (session expired)');
      }
      PortalAccessService.forceLogout(isAccountDisabled: false);
    }
  }

  Map<String, String> _buildHeaders(String url, String? token, {required String contentType, bool onlyNewBackend = false}) {
    Map<String, String> headers = {};
    if (!onlyNewBackend || AppUrl.useNewBackend) {
      headers["Content-type"] = contentType;
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }
    if (AppUrl.useNewBackend) {
      try {
        final uri = Uri.parse(url);
        String? projId = uri.queryParameters['project_id'];
        if (projId == null || projId.isEmpty) {
          final segments = uri.pathSegments;
          final projectIdx = segments.indexOf('projects');
          if (projectIdx != -1 && projectIdx + 1 < segments.length) {
            projId = segments[projectIdx + 1];
          }
        }
        if (projId == null || projId.isEmpty) {
          projId = activeProjectIdCache;
        }
        if (projId != null && projId.isNotEmpty) {
          headers["x-project-id"] = projId;
          headers["project-id"] = projId;
          headers["project_id"] = projId;
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error parsing project_id: $e");
        }
      }
    }
    return headers;
  }

  // GET
  Future get(String url, {bool skipPortalAccessCheck = false}) async {
    String? token = await _getEffectiveToken();
    Map<String, String> headers = _buildHeaders(url, token, contentType: "application/json", onlyNewBackend: true);
    var response = await http.get(
      Uri.parse(url),
      headers: headers.isEmpty ? null : headers,
    );
    // Strategy 3: Check for 401/403 to detect disabled account
    if (!skipPortalAccessCheck) {
      _checkForceLogout(response);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      //log.i(response.body);
      return response; //json.decode(response.body);
    }
    return response;
  }

  // POST
  Future<http.Response> post(String url, Map<String, String> body) async {
    print(
        'getDeviceInfo---------------------------------------------------------');
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Map<String, String> deviceInfo = {
      "appVersion": packageInfo.version,
      "buildNumber": packageInfo.buildNumber,
      "systemName": Platform.operatingSystem,
      "systemVersion": Platform.operatingSystemVersion,
      "deviceModel": "x86_64", // example
      "model": "", // example
      "screenHeight": "", // example
      "screenWidth": "", // example
      "name": "", // example
      "identifierForVendor": "",
    };

    final Map<String, String> finalPayload = {
      ...body,
      "device_details": jsonEncode(deviceInfo),
      "device_type": Platform.operatingSystem,
    };
    print(deviceInfo);
    print('--------------------------------------------------------------');
    // final mergedBody = {...body, ...deviceInfo};

    // getDeviceInfo();
    String? token = await _getEffectiveToken();
    Map<String, String> headers = _buildHeaders(url, token, contentType: "application/x-www-form-urlencoded", onlyNewBackend: true);
    if (!AppUrl.useNewBackend) {
      headers["Content-type"] = "application/x-www-form-urlencoded";
    }
    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: finalPayload,
    );
    // Strategy 3: Check for 401/403 to detect disabled account
    _checkForceLogout(response);
    print('++++++++++++++++++++++');
    print(finalPayload);
    print(response.body);
    return response;
  }

  Future<http.Response> logoutAllDevices() async {
    // Logout always uses master token
    String? token = await _getMasterToken();
    Map<String, String> headers = _buildHeaders(
      AppUrl.logoutAllDevicesUrl,
      token,
      contentType: "application/json",
      onlyNewBackend: false,
    );
    var response = await http.post(
      Uri.parse(AppUrl.logoutAllDevicesUrl),
      headers: headers,
    );
    _checkForceLogout(response);
    return response;
  }

  Future<http.Response> patch(String url, Map<String, String> body) async {
    String? token = await _getEffectiveToken();
    //log.d(body);
    Map<String, String> headers = _buildHeaders(url, token, contentType: "application/json", onlyNewBackend: false);
    var response = await http.patch(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );
    // Strategy 3: Check for 401/403 to detect disabled account
    _checkForceLogout(response);
    return response;
  }

  Future<http.Response> post1(String url, var body) async {
    String? token = await _getEffectiveToken();
    //log.d(body);
    Map<String, String> headers = _buildHeaders(url, token, contentType: "application/json", onlyNewBackend: false);
    if (token == null) {
      headers.remove("Authorization");
    }
    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );
    // Strategy 3: Check for 401/403 to detect disabled account
    _checkForceLogout(response);
    return response;
  }

  // PUT
  Future<http.Response> put(String url, var body) async {
    String? token = await _getEffectiveToken();
    Map<String, String> headers = _buildHeaders(url, token, contentType: "application/json", onlyNewBackend: false);
    if (token == null) {
      headers.remove("Authorization");
    }
    var response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );
    // Strategy 3: Check for 401/403 to detect disabled account
    _checkForceLogout(response);
    return response;
  }

  // DELETE
  Future<http.Response> delete(String url) async {
    String? token = await _getEffectiveToken();
    Map<String, String> headers = _buildHeaders(url, token, contentType: "application/json", onlyNewBackend: true);
    var response = await http.delete(
      Uri.parse(url),
      headers: headers.isEmpty ? null : headers,
    );
    _checkForceLogout(response);
    return response;
  }

  // Multipart Images
  Future<http.StreamedResponse> patchImage(String url, String filepath) async {
    String? token = await _getEffectiveToken();
    var request = http.MultipartRequest('PATCH', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath("img", filepath));
    request.headers.addAll({
      "Content-type": "multipart/form-data",
      if (token != null) "Authorization": "Bearer $token"
    });
    var response = request.send();
    return response;
  }

  // PATCH Multipart
  Future<http.Response> patchMultipart(String url, Map<String, String> fields) async {
    String? token = await _getEffectiveToken();
    Map<String, String> headers = _buildHeaders(url, token, contentType: "multipart/form-data", onlyNewBackend: true);
    var request = http.MultipartRequest('PATCH', Uri.parse(url));
    request.headers.addAll(headers);
    request.fields.addAll(fields);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    _checkForceLogout(response);
    return response;
  }

  /// POST with explicit master token — use ONLY for workspace switch-by-project.
  /// IMPORTANT: Does NOT call _checkForceLogout — a 200 from switch-by-project
  /// must never be misinterpreted as session expiry.
  Future<http.Response> postWithMasterToken(String url, Map<String, dynamic> body) async {
    final String? token = await _getMasterToken();
    final Map<String, String> headers = _buildHeaders(
      url,
      token,
      contentType: "application/json",
      onlyNewBackend: false,
    );
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );
    return response;
  }

  NetworkImage getImage(String url) {
    return NetworkImage(url);
  }
}
