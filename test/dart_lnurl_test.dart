import 'package:bip32/bip32.dart' as bip32;
import 'package:dart_lnurl/dart_lnurl.dart';
import 'package:dart_lnurl/src/lnurl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex/hex.dart';

import 'util.dart';

void main() {
  test('should match as valid lnurl', () {
    final lnurl =
        'lnurl1dp68gurn8ghj7mrww4exctt5dahkccn00qhxget8wfjk2um0veax2un09e3k7mf0w5lhz0t9xcekzv34vgcx2vfkvcurxwphvgcrwefjvgcnqwrpxqmkxven89skgvp3vs6nwvpjvy6njdfsx5ekgephvcurxdf5xcerwvecvyunsf32lqq';
    expect(validateLnUrl(lnurl), true);
  });

  test('should match as invalid lnurl', () {
    final lnurl = 'InvalidLightningUrlString';
    expect(validateLnUrl(lnurl), false);
  });

  test('should match lnurl without lightning:', () {
    final lnurl =
        'lnurl1dp68gurn8ghj7mrww4exctt5dahkccn00qhxget8wfjk2um0veax2un09e3k7mf0w5lhz0t9xcekzv34vgcx2vfkvcurxwphvgcrwefjvgcnqwrpxqmkxven89skgvp3vs6nwvpjvy6njdfsx5ekgephvcurxdf5xcerwvecvyunsf32lqq';
    expect(findLnUrl(lnurl),
        'lnurl1dp68gurn8ghj7mrww4exctt5dahkccn00qhxget8wfjk2um0veax2un09e3k7mf0w5lhz0t9xcekzv34vgcx2vfkvcurxwphvgcrwefjvgcnqwrpxqmkxven89skgvp3vs6nwvpjvy6njdfsx5ekgephvcurxdf5xcerwvecvyunsf32lqq');
  });

  test('should match lnurl with lightning:', () {
    final lnurl =
        'lightning:lnurl1dp68gurn8ghj7mrww4exctt5dahkccn00qhxget8wfjk2um0veax2un09e3k7mf0w5lhz0t9xcekzv34vgcx2vfkvcurxwphvgcrwefjvgcnqwrpxqmkxven89skgvp3vs6nwvpjvy6njdfsx5ekgephvcurxdf5xcerwvecvyunsf32lqq';
    expect(findLnUrl(lnurl),
        'lnurl1dp68gurn8ghj7mrww4exctt5dahkccn00qhxget8wfjk2um0veax2un09e3k7mf0w5lhz0t9xcekzv34vgcx2vfkvcurxwphvgcrwefjvgcnqwrpxqmkxven89skgvp3vs6nwvpjvy6njdfsx5ekgephvcurxdf5xcerwvecvyunsf32lqq');
  });

  test('should fail matching lnurl on invalid string', () {
    expect(() => findLnUrl('invalid string'), throwsArgumentError);
  });

  test('should decipher preimage', () {
    final plainText = 'Secret message here';
    final preimage =
        '43aa9346163deada83ec49fa670b8a3541c9ef469d942cd2c7f81206e535e031';

    /// Encrypt some data using the preimage as the key
    final data = encrypt(plainText, preimage);

    LNURLPaySuccessAction successAction = LNURLPaySuccessAction.fromJson({
      'description': 'Secret message',
      'tag': 'aes',
      'cipherText': data.cipherText,
      'iv': data.iv,
    });
    if (validateSuccessAction(successAction: successAction)) {
      final decrypted = decryptSuccessActionAesPayload(
        preimage: preimage,
        successAction: successAction,
      );
      expect(decrypted, plainText);
    }
  });

  test('should decode lnurl-pay', () async {
    final url =
        'lightning:LNURL1DP68GURN8GHJ7MRWW4EXCTNXD9SHG6NPVCHXXMMD9AKXUATJDSKHQCTE8AEK2UMND9HKU0F3VFNRVVF5XU6XGD33X9JNJD3SVSMKZVMRX4NX2VPSVCMNWDP4XVUXVEPHVVURJCFCXUUNWDEE8YCNYWTRXQ6NSWP4V56RJEFKVCCXYXKMWAE';
    final uri = decodeLnUri(url);
    final res = await getParams(url);

    expect(uri.host, 'lnurl.fiatjaf.com');
    expect(res.payParams, isNotNull);
  });

  test('should find lnurl-auth params', () async {
    final url =
        'lightning:LNURL1DP68GURN8GHJ7MRWW4EXCTNXD9SHG6NPVCHXXMMD9AKXUATJDSKKCMM8D9HR7ARPVU7KCMM8D9HZV6E384JNXCF3VSCNSE358QMKZVPK8YENZVMYXUEN2DE4X5CNGWP4VSMX2VE58Q6KYCFNX5UXVDNXX9JKXDENVDSNSCE5XU6XVVR9V56XGCTZS8GQ23';
    final res = await getParams(url);
    expect(res.authParams, isNotNull);
    expect(res.error, isNull);
  });

  test('should create linkingKey derivation for BIP-32 based wallet', () async {
    const url =
        'lightning:LNURL1DP68GURN8GHJ7MRFVA58GMNFDENKCMM8D9HZUMRFWEJJ7MR0VA5KU0MTXY7NWCNYXSMKVCEKX3JRSCF4X3SKXWTXXASNGVE5XQ6RZDMXXC6KXDE3VYCRZCENXF3NQVF5XCEXZE3JXVMRGVRY8YURJVNYV43RGDRRVGN8GCT884KX7EMFDCV8DETA';
    final masterKey = bip32.BIP32.fromBase58(
        'xprv9s21ZrQH143K4DRBUU8Dp25M61mtjm9T3LsdLLFCXL2U6AiKEqs7dtCJWGFcDJ9DtHpdwwmoqLgzPrW7unpwUyL49FZvut9xUzpNB6wbEnz');
    const linkingPubKeyHex =
        '034c9c690b5f8e07517bcf16fda57c8fb363ad5edab66fccaa1cbf2287d186fa83';
    final linkingKey = await deriveLinkingKey(url, masterKey);
    final derivedPubKeyHex = HEX.encode(linkingKey.publicKey);

    /// linkingPubKeyHex is send as an identifier (key) to servers
    expect(derivedPubKeyHex, linkingPubKeyHex);
  });

  test('should create signature from signed k1 with linkingKey', () async {
    const url =
        'lightning:LNURL1DP68GURN8GHJ7MRFVA58GMNFDENKCMM8D9HZUMRFWEJJ7MR0VA5KU0MTXY7NWCNYXSMKVCEKX3JRSCF4X3SKXWTXXASNGVE5XQ6RZDMXXC6KXDE3VYCRZCENXF3NQVF5XCEXZE3JXVMRGVRY8YURJVNYV43RGDRRVGN8GCT884KX7EMFDCV8DETA';
    final masterKey = bip32.BIP32.fromBase58(
        'xprv9s21ZrQH143K4DRBUU8Dp25M61mtjm9T3LsdLLFCXL2U6AiKEqs7dtCJWGFcDJ9DtHpdwwmoqLgzPrW7unpwUyL49FZvut9xUzpNB6wbEnz');
    const expectedSig =
        '304402203b6f6fb1c0ae2fcac3b5cce2d528f040f26622470c8bb7ada3fa8c158b4b7c0a02207296db00fdb38f839eae197d90bfca79aa2cbe0d081025f8277fe10e5017bd20';
    const callBackUrl =
        'https://lightninglogin.live/login?k1=7bd47fc64d8a54ac9f7a4340417f65c71a01c32c01462af23640d9892deb44cb&tag=login&sig=304402203b6f6fb1c0ae2fcac3b5cce2d528f040f26622470c8bb7ada3fa8c158b4b7c0a02207296db00fdb38f839eae197d90bfca79aa2cbe0d081025f8277fe10e5017bd20&key=034c9c690b5f8e07517bcf16fda57c8fb363ad5edab66fccaa1cbf2287d186fa83';
    final linkingKey = await deriveLinkingKey(url, masterKey);
    final key = HEX.encode(linkingKey.publicKey);
    final sig = await signK1(url, linkingKey);
    final decodedUrl = decodeLnUri(url);
    final callback = '$decodedUrl&sig=${sig}&key=${key}';
    expect(sig, expectedSig);
    expect(callback, callBackUrl);
  });
}
