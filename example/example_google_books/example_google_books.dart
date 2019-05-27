import 'dart:convert';
import 'package:http/http.dart' as _hhtp;

import 'json_objects.dart';

Future<void> main() async {
  var url = 'https://www.googleapis.com/books/v1/volumes?q=Mowgli';
  var response = await _hhtp.get(url);
  if (response.statusCode == 200) {
    var jsonObject = jsonDecode(response.body) as Map;
    var booksResponse = BooksResponse.fromJson(jsonObject);
    print('Total items: ${booksResponse.totalItems}');
    print('Kind: ${booksResponse.kind}');
    for (var volume in booksResponse.items) {
      print('  ${volume.volumeInfo.title}: ${volume.volumeInfo.authors}');
    }
  }
}
