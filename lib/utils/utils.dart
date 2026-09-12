bool fuzzyMatch(String text, String pattern, double threshold) {
  if (pattern.isEmpty) return true;
  if (text.isEmpty) return false;

  // Simple sliding window or word-level similarity check,
  // or checking chunks of the text against the pattern.
  final words = text.split(RegExp(r'\s+'));
  for (final word in words) {
    if (similarity(word, pattern) >= threshold) {
      return true;
    }
  }
  // Also check substrings if pattern is long enough
  for (int i = 0; i <= text.length - pattern.length; i++) {
    final sub = text.substring(i, i + pattern.length);
    if (similarity(sub, pattern) >= threshold) {
      return true;
    }
  }
  return false;
}

double similarity(String s1, String s2) {
  if (s1 == s2) return 1.0;
  if (s1.isEmpty || s2.isEmpty) return 0.0;

  int matches = 0;
  final length = s1.length > s2.length ? s1.length : s2.length;
  for (int i = 0; i < (s1.length < s2.length ? s1.length : s2.length); i++) {
    if (s1[i] == s2[i]) matches++;
  }
  return matches / length;
}
