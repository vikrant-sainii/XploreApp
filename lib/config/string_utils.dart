import 'env.dart';

String cleanHtmlText(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';

  String text = raw;

  // Replace HTML headings with clean double newlines
  text = text.replaceAll(RegExp(r'<h[1-6]\b[^>]*>', caseSensitive: false), '\n\n');
  text = text.replaceAll(RegExp(r'</h[1-6]>', caseSensitive: false), '\n');

  // Format list items cleanly into bullet points
  text = text.replaceAll(RegExp(r'<li\b[^>]*>', caseSensitive: false), '\n• ');
  text = text.replaceAll(RegExp(r'</li>', caseSensitive: false), '');

  // Replace HTML line breaks and paragraph closing tags with newlines
  text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
  text = text.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n');
  text = text.replaceAll(RegExp(r'</div>', caseSensitive: false), '\n');

  // Strip all remaining HTML tags
  text = text.replaceAll(RegExp(r'<[^>]*>'), '');

  // Unescape common HTML entities (both with and without trailing semicolon)
  text = text.replaceAll(RegExp(r'&nbsp;?'), ' ');
  text = text.replaceAll(RegExp(r'&amp;?'), '&');
  text = text.replaceAll(RegExp(r'&quot;?'), '"');
  text = text.replaceAll(RegExp(r'&#39;?|&apos;?'), "'");
  text = text.replaceAll(RegExp(r'&lt;?'), '<');
  text = text.replaceAll(RegExp(r'&gt;?'), '>');
  text = text.replaceAll(RegExp(r'&ndash;?'), '–');
  text = text.replaceAll(RegExp(r'&mdash;?'), '—');
  text = text.replaceAll(RegExp(r'&bull;?'), '•');

  // Clean up whitespace: replace multiple horizontal spaces with a single space
  text = text.replaceAll(RegExp(r'[ \t]+'), ' ');

  // Normalize 3+ newlines into double newlines
  text = text.replaceAll(RegExp(r'\n\s*\n\s*\n+'), '\n\n');

  return text.trim();
}

/// Helper function to format and resolve image URLs from API responses.
/// Handles full HTTP/HTTPS URLs, relative server paths (/uploads/...),
/// media array fallback, and empty strings.
String formatImageUrl(dynamic rawUrl, {dynamic media}) {
  String candidate = '';

  // 1. Check rawUrl string if not empty
  if (rawUrl is String && rawUrl.trim().isNotEmpty) {
    candidate = rawUrl.trim();
  }

  // 2. Fallback to media array if rawUrl is empty
  if (candidate.isEmpty && media is List && media.isNotEmpty) {
    final first = media.first;
    if (first is String && first.trim().isNotEmpty) {
      candidate = first.trim();
    } else if (first is Map && first['url'] != null) {
      candidate = first['url'].toString().trim();
    }
  }

  if (candidate.isEmpty) return '';

  // 3. Full URL (http:// or https://)
  if (candidate.startsWith('http://') || candidate.startsWith('https://')) {
    return candidate;
  }

  // 4. Flutter asset path
  if (candidate.startsWith('assets/')) {
    return candidate;
  }

  // 5. Relative server path (e.g. /uploads/events/xyz.jpeg or uploads/events/xyz.jpg)
  final serverOrigin = EnvConfig.baseUrl.replaceAll('/api', '');
  if (candidate.startsWith('/')) {
    return '$serverOrigin$candidate';
  } else {
    return '$serverOrigin/$candidate';
  }
}

