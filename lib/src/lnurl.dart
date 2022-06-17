RegExp lnurlPrefix = RegExp(',*?((lnurl)([0-9]{1,}[a-z0-9]+){1})');
RegExp lud17schemePrefix = RegExp('(lnurl)(c|w|p)');

/// Parse and return a given lnurl string if it's valid. Will remove
/// `lightning:` from the beginning of it if present.
String findLnUrl(String input) {
  final lnurlPrefixMatch = lnurlPrefix.firstMatch(input);
  if (lnurlPrefixMatch is RegExpMatch) {
    return lnurlPrefixMatch[0]!;
  }
  if (input.contains(lud17schemePrefix) || input.startsWith('keyauth://')) {
    // Check if input is a valid url
    if (Uri.tryParse(input)?.hasAbsolutePath ?? false) {
      // Replace prefix with https for clearnet URL's, http for onion URLs
      var prefix = RegExp(r'\.onion($|\W)').hasMatch(input) ? 'http' : 'https';
      return input.replaceFirst(lud17schemePrefix, prefix);
    }
  }
  throw ArgumentError('Not a valid lnurl string');
}
