import 'package:dart_appwrite/dart_appwrite.dart' hide Response;


Future<void> start(final request, final response) async {
  // Initialise the client SDK
  Map<String, dynamic> envVars = request.env;
  print(envVars);
  final Client client = Client();
  client
      .setEndpoint(envVars['APPWRITE_ENDPOINT'] ??
          'http://192.168.10.4/v1') // This is manually set
      .setProject(envVars[
          'APPWRITE_FUNCTION_PROJECT_ID']) // this is available by default
      .setKey(envVars['APPWRITE_API_KEY']);

  // Initialise the storage SDK
  final storage = new Storage(client);

  int daysToExpire = int.parse(envVars['DAYS_TO_EXPIRE']!);

  final res = await storage.listFiles(orderType: 'DESC', limit: 100);
  final files = res.files;
  var timestamp = DateTime.now()
      .subtract(Duration(days: daysToExpire))
      .millisecondsSinceEpoch;
  var deletedFiles = 0;
  for (final file in files) {
    if (file.dateCreated * 1000 < timestamp) {
      await storage.deleteFile(fileId: file.$id);
      print("Deleted ${file.$id}");
      deletedFiles++;
    }
  }
  print("Total files deleted: $deletedFiles");
}
