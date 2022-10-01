library dart_lnurl;

import 'dart:convert';
import 'dart:typed_data';

import 'package:bech32/bech32.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_lnurl/src/bech32.dart';
import 'package:dart_lnurl/src/lnurl.dart';
import 'package:dart_lnurl/src/types.dart';
import 'package:ecdsa/ecdsa.dart' as ecdsa;
import 'package:elliptic/elliptic.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

export 'src/bech32.dart';
export 'src/success_action.dart';
export 'src/types.dart';

/// Get params from a lnurl string. Possible types are:
/// * `LNURLResponse`
/// * `LNURLChannelParams`
/// * `LNURLWithdrawParams`
/// * `LNURLAuthParams`
/// * `LNURLPayParams`
///
/// Throws [ArgumentError] if the provided input is not a valid lnurl.
Future<LNURLParseResult> getParams(String encodedUrl) async {
  /// Try to parse the input as a lnUrl. Will throw an error if it fails.
  final lnUrl = findLnUrl(encodedUrl);

  final Uri decodedUri = decodeLnUri(encodedUrl);

  try {
    Map<String, dynamic> uriParams = {};

    /// No HTTP GET when tag holds login value
    if (decodedUri.query.contains('tag=login') &&
        decodedUri.query.contains('sig') == false) {
      /// Extract parameters from uri
      uriParams = decodedUri.queryParameters;
    } else {
      /// Call the lnurl to get a response
      final res = await http.get(decodedUri);

      /// If there's an error then throw it
      if (res.statusCode >= 300) {
        throw res.body;
      }

      /// Parse the response body to json
      uriParams = json.decode(res.body);
    }

    /// If it contains a callback then add the domain as a key
    if (uriParams['callback'] != null) {
      uriParams['domain'] = Uri.parse(uriParams['callback']).host;
    }

    if (uriParams['tag'] == null) {
      throw Exception('Response was missing a tag');
    }

    switch (uriParams['tag']) {
      case 'withdrawRequest':
        return LNURLParseResult(
          withdrawalParams: LNURLWithdrawParams.fromJson({
            ...uriParams,
            ...{'pr': lnUrl}
          }),
        );

      case 'payRequest':
        return LNURLParseResult(
          payParams: LNURLPayParams.fromJson(uriParams),
        );

      case 'channelRequest':
        return LNURLParseResult(
          channelParams: LNURLChannelParams.fromJson(uriParams),
        );

      case 'login':
        return LNURLParseResult(
          authParams: LNURLAuthParams.fromJson({
            ...uriParams,
            ...{'domain': decodedUri.host}
          }),
        );

      default:
        if (uriParams['status'] == 'ERROR') {
          return LNURLParseResult(
            error: LNURLErrorResponse.fromJson({
              ...uriParams,
              ...{
                'domain': decodedUri.host,
                'url': decodedUri.toString(),
              }
            }),
          );
        }

        throw Exception('Unknown tag: ${uriParams['tag']}');
    }
  } catch (e) {
    return LNURLParseResult(
      error: LNURLErrorResponse.fromJson({
        'status': 'ERROR',
        'reason': '${decodedUri.toString()} returned error: ${e.toString()}',
        'url': decodedUri.toString(),
        'domain': decodedUri.host,
      }),
    );
  }
}

Uri decodeLnUri(String encodedUrl) {
  final lnUrl = findLnUrl(encodedUrl);
  late final Uri decodedUri;
  if (lnUrl.startsWith('http')) {
    decodedUri = Uri.parse(lnUrl);
  } else {
    /// Decode the lnurl using bech32
    final bech32 = Bech32Codec().decode(lnUrl, lnUrl.length);
    decodedUri = Uri.parse(utf8.decode(fromWords(bech32.data)));
  }
  return decodedUri;
}

bool validateLnUrl(encodedUrl) {
  try {
    findLnUrl(encodedUrl);
    return true;
  } catch (e) {
    return false;
  }
}

/// LUD-05: BIP32-based seed generation for auth protocol.
Future<dynamic> deriveLinkingKey(url, masterKey) async {
  /// Domain is message, secret is m/138'/0 private key for HMAC-SHA256
  final res = await getParams(url);
  final messageString = res.authParams!.domain;
  const pathPrefix = "m/138'/0";
  final hashingKey = masterKey.derivePath(pathPrefix);
  final hashingPrivKey = hashingKey.privateKey;
  final secret = hashingPrivKey!;
  final hmacSha256 = new Hmac(sha256, secret); // HMAC-SHA256
  final digest = hmacSha256.convert(utf8.encode(messageString));

  /// Convert first 16 bytes of 32x 1byte array to array of 4x 4byte unsigned integers (Uint32)
  List pathSuffix =
      Uint8List.fromList(digest.bytes).buffer.asUint32List().sublist(0, 4);

  /// Use those 4x 4byte integers as 4 parts of path after m/138'/
  final path = "m/138'/${pathSuffix.join('/')}";

  /// Return LinkingKey
  return masterKey.derivePath(path);
}

Future<String> signK1(url, linkingKey) async {
  final res = await getParams(url);
  final linkingPrivKey = linkingKey.privateKey!;

  /// Sign k1 with linkingPrivKey
  final k1Buffer = decodeHexString(res.authParams!.k1);
  final ec = getSecp256k1();
  final priv = PrivateKey.fromBytes(ec, linkingPrivKey);
  final signedK1 = ecdsa.deterministicSign(priv, k1Buffer);

  /// Convert k1 signature to hex values
  return signedK1.toDERHex();
}
