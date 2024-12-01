// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class AgoraRecording {
//   final String baseUrl =
//       'https://api.agora.io/v1/apps/2f3131394cc6417b91aa93cfde567a37/cloud_recording';
//   final String customerId = '';
//   final String customerSecret = '';

//   Future<String> acquireResource(String channelName) async {
//     final url = '$baseUrl/acquire';
//     final headers = {
//       'Authorization':
//           'Basic ${base64Encode(utf8.encode('$customerId:$customerSecret'))}',
//       'Content-Type': 'application/json',
//     };
//     final body =
//         jsonEncode({'cname': channelName, 'uid': '12347', 'clientRequest': {}});

//     final response =
//         await http.post(Uri.parse(url), headers: headers, body: body);
//     if (response.statusCode == 200) {
//       print('aquire hogya');
//       return jsonDecode(response.body)['resourceId'];
//     } else {
//       throw Exception('Failed to acquire resource: ${response.body}');
//     }
//   }

//   Future<String> startRecording(String resourceId, String channelName) async {
//     final url = '$baseUrl/resourceid/$resourceId/mode/mix/start';
//     final headers = {
//       'Authorization':
//           'Basic ${base64Encode(utf8.encode('$customerId:$customerSecret'))}',
//       'Content-Type': 'application/json',
//     };
//     final body = jsonEncode({
//       'cname': channelName,
//       'uid': '12347',
//       "clientRequest": {
//         "recordingConfig": {
//           "maxIdleTime": 30,
//           "streamTypes": 1,
//           "audioProfile": 1,
//           "channelType": 0
//         },
//         'storageConfig': {
//           'vendor': 1,
//           'region': 0,
//           'bucket': '',
//           'accessKey': '',
//           'secretKey': '',
//           'fileNamePrefix': ["audio"],
//         }
//       }
//     });

//     final response =
//         await http.post(Uri.parse(url), headers: headers, body: body);
//     if (response.statusCode == 200) {
//       print('start hogya');
//       return jsonDecode(response.body)['sid'];
//     } else {
//       throw Exception('Failed to start recording: ${response.body}');
//     }
//   }

//   Future<void> stopRecording(
//       String resourceId, String sid, String channelName) async {
//     final url = '$baseUrl/resourceid/$resourceId/sid/$sid/mode/mix/stop';
//     final headers = {
//       'Authorization':
//           'Basic ${base64Encode(utf8.encode('$customerId:$customerSecret'))}',
//       'Content-Type': 'application/json',
//     };
//     final body = jsonEncode({
//       'cname': channelName,
//       'uid': 0,
//       'clientRequest': {
//         'async_stop': false,
//       },
//     });

//     final response =
//         await http.post(Uri.parse(url), headers: headers, body: body);

//     if (response.statusCode != 200) {
//       print('Error response: ${response.body}');
//       throw Exception('Failed to stop recording: ${response.body}');
//     } else {
//       print('stop hogya');
//     }
//   }
// }
