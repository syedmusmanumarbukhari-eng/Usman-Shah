import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleAuthHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

class GoogleDriveService extends ChangeNotifier {
  static final GoogleDriveService instance = GoogleDriveService._internal();

  factory GoogleDriveService() => instance;

  GoogleDriveService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope,
      drive.DriveApi.driveFileScope,
    ],
  );

  GoogleSignInAccount? _account;
  GoogleSignInAccount? get account => _account;
  bool get isSignedIn => _account != null;

  static const String _backupFileName = 'poultry_farm_backup.json';

  Future<bool> signIn() async {
    try {
      _account = await _googleSignIn.signIn();
      notifyListeners();
      return _account != null;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _account = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Google Sign-Out Error: $e');
    }
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    if (_account == null) {
      final signedIn = await signIn();
      if (!signedIn || _account == null) return null;
    }

    try {
      final authHeaders = await _account!.authHeaders;
      final authenticateClient = GoogleAuthHttpClient(authHeaders);
      return drive.DriveApi(authenticateClient);
    } catch (e) {
      debugPrint('Error creating Drive API client: $e');
      return null;
    }
  }

  /// Uploads backup JSON to Google Drive
  Future<Map<String, dynamic>> uploadBackup(String jsonContent) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) {
      return {
        'success': false,
        'message': 'Google Account sign-in is required.',
      };
    }

    try {
      // Check if backup file already exists in Drive AppData
      final fileList = await driveApi.files.list(
        q: "name = '$_backupFileName' and trashed = false",
        spaces: 'appDataFolder',
      );

      final media = drive.Media(
        Stream.value(utf8.encode(jsonContent)),
        jsonContent.length,
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        // Update existing file
        final fileId = fileList.files!.first.id!;
        await driveApi.files.update(
          drive.File(),
          fileId,
          uploadMedia: media,
        );
      } else {
        // Create new backup file
        final fileToCreate = drive.File()
          ..name = _backupFileName
          ..parents = ['appDataFolder'];

        await driveApi.files.create(
          fileToCreate,
          uploadMedia: media,
        );
      }

      notifyListeners();
      return {
        'success': true,
        'message': 'Backup uploaded successfully to Google Drive!',
      };
    } catch (e) {
      debugPrint('Error uploading backup to Drive: $e');
      return {
        'success': false,
        'message': 'Upload failed: $e. Make sure Google Cloud Console OAuth is configured.',
      };
    }
  }

  /// Downloads backup JSON from Google Drive
  Future<Map<String, dynamic>> restoreBackup() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) {
      return {
        'success': false,
        'message': 'Google Account sign-in is required.',
      };
    }

    try {
      final fileList = await driveApi.files.list(
        q: "name = '$_backupFileName' and trashed = false",
        spaces: 'appDataFolder',
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        return {
          'success': false,
          'message': 'No backup file found on Google Drive for this account.',
        };
      }

      final fileId = fileList.files!.first.id!;
      final drive.Media fileMedia = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final List<int> dataBytes = [];
      await for (var data in fileMedia.stream) {
        dataBytes.addAll(data);
      }

      final jsonContent = utf8.decode(dataBytes);

      return {
        'success': true,
        'json': jsonContent,
        'message': 'Backup downloaded successfully from Google Drive!',
      };
    } catch (e) {
      debugPrint('Error restoring backup from Drive: $e');
      return {
        'success': false,
        'message': 'Download failed: $e. Make sure Google Cloud Console OAuth is configured.',
      };
    }
  }
}
