import 'package:flutter_js/flutter_js.dart';
void main() async {
  final flutterJs = getJavascriptRuntime();
  flutterJs.onMessage('test', (args) {
    return {'hello': 'world'};
  });
  final result = await flutterJs.evaluateAsync('''
    new Promise((resolve) => {
      sendMessage('test', JSON.stringify({})).then(res => {
        resolve(typeof res + " " + JSON.stringify(res));
      });
    })
  ''');
  print('Result: \');
}
