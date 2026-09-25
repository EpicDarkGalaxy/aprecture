import 'package:flutter_test/flutter_test.dart';
import 'package:aprecture/utils/utils.dart';

void main() {
  test('formatAppData should sanitize author URLs and preserve other values', () {
    final input = {
      'name': 'Test App',
      'author': 'https://example.com',
      'iconUrl': 'https://example.com/icon.png',
      'sourceName': 'Test Source',
    };

    final result = formatAppData(
      name: input['name'] ?? 'Unknown',
      author: input['author'] ?? 'Unknown',
      iconUrl: input['iconUrl'] ?? '',
      sourceName: input['sourceName'] ?? 'Unknown',
    );

    expect(result['name'], 'Test App');
    expect(result['author'], 'Active Developer');
    expect(result['iconUrl'], 'https://example.com/icon.png');
    expect(result['sourceName'], 'Test Source');
  });

  test('formatAppData should use defaults for missing values', () {
    final result = formatAppData(
      name: 'Unknown',
      author: '',
      iconUrl: '',
      sourceName: 'Unknown',
    );

    expect(result['name'], 'Unknown');
    expect(result['author'], 'Unknown');
    expect(result['iconUrl'], '');
    expect(result['sourceName'], 'Unknown');
  });
}