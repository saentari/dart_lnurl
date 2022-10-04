import 'dart:convert';

import 'package:bip32/bip32.dart' as bip32;
import 'package:dart_lnurl/dart_lnurl.dart';
import 'package:dart_lnurl/src/lnurl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart';

import 'util.dart';

void main() {
  group('LUD-01: Base LNURL encoding and decoding', () {
    const encodedLnurl =
        'lnurl1dp68gurn8ghj7mrww4exctnxd9shg6npvchxxmmd9akxuatjdskhqcte8aek2umnd9hku0fjx43nvdm9vsekxdnr8qenzdrxxccnsv33vfjkvefkxuuxgwrzxucnzefnvy6nwd3cvfnrqep4893rqvfk8psngd358y6rxd3evccxx94zkxx';
    const decodedLnurl =
        'https://lnurl.fiatjaf.com/lnurl-pay?session=25c67ed3c6c8314f61821befe678d8b711e3a5768bf0d59b0168a46494369f0c';

    test('base LNURL decoding', () {
      final res = decodeLnUri(encodedLnurl);

      expect(res.toString(), decodedLnurl);
    });

    test('base LNURL encoding', () {
      // TODO: missing implementation.
    });
  });

  group('LUD-02: channelRequest base spec', () {
    test('should decode lnurl-channel', () async {
      const url =
          'lightning:LNURL1DP68GURN8GHJ7MRWW4EXCTNXD9SHG6NPVCHXXMMD9AKXUATJDSKKX6RPDEHX2MPLWDJHXUMFDAHR6VF4V5MNXENP8Y6NXEPSXV6XGD33XGUNQWT9XYENGWRYX3JNYCEJXU6XGDFSVYCXXWTXX5CRZDM9V33NWVFCXCMRVVEJX5MRQV3K8Y6QSN500R';
      final res = await getParams(url);

      expect(res.channelParams?.tag, 'channelRequest');
      expect(res.channelParams?.callback, isNotEmpty);
    });
  });

  group('LUD-03: withdrawRequest base spec', () {
    test('should decode lnurl-withdraw', () async {
      const url =
          'lightning:LNURL1DP68GURN8GHJ7MRWW4EXCTNXD9SHG6NPVCHXXMMD9AKXUATJDSKHW6T5DPJ8YCTH8AEK2UMND9HKU0TPV4NRGCN9XA3NQWRP8YMKXVTPVCCXGWTZ8YER2WTPVYMRGWFSVS6RYEPKVVMNJETYVGEXYVPJXFNRZCMZXAJN2CENXVENGEFNV9SNX09GNJU';
      final res = await getParams(url);

      expect(res.withdrawalParams?.tag, 'withdrawRequest');
      expect(res.withdrawalParams?.maxWithdrawable, greaterThan(0));
      expect(res.withdrawalParams, isNotNull);
      expect(res.error, isNull);
    });
  });

  group('LUD-04: auth base spec', () {
    test('should find lnurl-auth params', () async {
      const url =
          'lightning:LNURL1DP68GURN8GHJ7MRWW4EXCTNXD9SHG6NPVCHXXMMD9AKXUATJDSKKCMM8D9HR7ARPVU7KCMM8D9HZV6E384JNXCF3VSCNSE358QMKZVPK8YENZVMYXUEN2DE4X5CNGWP4VSMX2VE58Q6KYCFNX5UXVDNXX9JKXDENVDSNSCE5XU6XVVR9V56XGCTZS8GQ23';
      final res = await getParams(url);

      expect(res.authParams?.tag, 'login');
      expect(res.authParams, isNotNull);
      expect(res.error, isNull);
    });
  });

  group('LUD-05: BIP32-based seed generation for auth protocol', () {
    const url =
        'lightning:LNURL1DP68GURN8GHJ7MRFVA58GMNFDENKCMM8D9HZUMRFWEJJ7MR0VA5KU0MTXY7NWCNYXSMKVCEKX3JRSCF4X3SKXWTXXASNGVE5XQ6RZDMXXC6KXDE3VYCRZCENXF3NQVF5XCEXZE3JXVMRGVRY8YURJVNYV43RGDRRVGN8GCT884KX7EMFDCV8DETA';
    final masterKey = bip32.BIP32.fromBase58(
        'xprv9s21ZrQH143K4DRBUU8Dp25M61mtjm9T3LsdLLFCXL2U6AiKEqs7dtCJWGFcDJ9DtHpdwwmoqLgzPrW7unpwUyL49FZvut9xUzpNB6wbEnz');

    test('should create linkingKey derivation for BIP-32 based wallet',
        () async {
      const linkingPubKeyHex =
          '034c9c690b5f8e07517bcf16fda57c8fb363ad5edab66fccaa1cbf2287d186fa83';
      final linkingKey = await deriveLinkingKey(url, masterKey);
      final derivedPubKeyHex = HEX.encode(linkingKey.publicKey);

      expect(derivedPubKeyHex, linkingPubKeyHex);
    });

    test('should create signature from signed k1 with linkingKey', () async {
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
  });

  group('LUD-06: payRequest base spec', () {
    test('should decode lnurl-pay', () async {
      final url =
          'lightning:LNURL1DP68GURN8GHJ7MRWW4EXCTNXD9SHG6NPVCHXXMMD9AKXUATJDSKHQCTE8AEK2UMND9HKU0F3VFNRVVF5XU6XGD33X9JNJD3SVSMKZVMRX4NX2VPSVCMNWDP4XVUXVEPHVVURJCFCXUUNWDEE8YCNYWTRXQ6NSWP4V56RJEFKVCCXYXKMWAE';
      final res = await getParams(url);

      expect(res.payParams?.minSendable, greaterThan(0));
      expect(res.payParams?.metadata, isNotNull);
      expect(res.error, isNull);
    });
  });

  group('LUD-07: hostedChannelRequest base spec', () {
    test('placeholder', () {
      // TODO: missing implementation.
    });
  });

  group('LUD-08: Fast withdrawRequest', () {
    test('placeholder', () {
      // TODO: missing implementation.
    });
  });

  group('LUD-09: successAction field for payRequest', () {
    test('should create and validate successAction', () {
      final plainText = 'Secret message here';
      final preimage =
          '43aa9346163deada83ec49fa670b8a3541c9ef469d942cd2c7f81206e535e031';
      // Encrypt some data using the preimage as the key
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
  });

  group('LUD-10: aes success action in payRequest', () {
    test('should create and validate aes successAction', () {
      // The test for for LUD-10 is included in LUD-09
    });
  });

  group('LUD-11: Disposable and storeable payRequests', () {
    test('should include disposable field in LNURL-pay callback', () {
      LNURLPayResult payResult = LNURLPayResult.fromJson(
          {'pr': 'payRequest string', 'routes': [], 'disposable': true});

      expect(payResult.disposable, true);
    });
  });

  group('LUD-12: Comments in payRequest', () {
    test('should support commentAllowed tag', () async {
      final url =
          'lightning:LNURL1DP68GURN8GHJ7MRWW4EXCTNXD9SHG6NPVCHXXMMD9AKXUATJDSKHQCTE8AEK2UMND9HKU0F3VFNRVVF5XU6XGD33X9JNJD3SVSMKZVMRX4NX2VPSVCMNWDP4XVUXVEPHVVURJCFCXUUNWDEE8YCNYWTRXQ6NSWP4V56RJEFKVCCXYXKMWAE';
      final res = await getParams(url);

      expect(res.payParams?.commentAllowed, greaterThanOrEqualTo(0));
      expect(res.error, isNull);
    });
  });

  group('LUD-13: signMessage-based seed generation for auth protocol', () {
    test('placeholder', () {
      // TODO: missing implementation.
    });
  });

  group('LUD-14: balanceCheck: reusable withdrawRequests', () {
    test('should support balanceCheck in withdrawRequests', () async {
      const url =
          'lightning:LNURL1DP68GURN8GHJ7MRWW4EXCTNXD9SHG6NPVCHXXMMD9AKXUATJDSKHW6T5DPJ8YCTH8AEK2UMND9HKU0TPV4NRGCN9XA3NQWRP8YMKXVTPVCCXGWTZ8YER2WTPVYMRGWFSVS6RYEPKVVMNJETYVGEXYVPJXFNRZCMZXAJN2CENXVENGEFNV9SNX09GNJU';
      final res = await getParams(url);
      // Workaround for optional currentBalance field not being present
      final maxWithdrawableBefore = res.withdrawalParams?.maxWithdrawable;
      final balanceCheckUrl = res.withdrawalParams?.balanceCheck;
      final callback = await get(Uri.parse(balanceCheckUrl!));
      final resBody = jsonDecode(callback.body);
      final maxWithdrawableAfter = resBody['maxWithdrawable'];

      expect(res.withdrawalParams?.balanceCheck, isNotEmpty);
      // maxWithdrawableAfter should be less than maxWithdrawableBefore, but test service uses random numbers.
      expect(true, maxWithdrawableBefore != maxWithdrawableAfter);
      expect(res.withdrawalParams, isNotNull);
      expect(res.error, isNull);
    });
  });

  group('LUD-15: balanceNotify: services hurrying up the withdraw process', () {
    test('placeholder', () {
      // TODO: missing implementation.
    });
  });

  group('LUD-16: Paying to static internet identifiers', () {
    test('placeholder', () {
      // TODO: missing implementation.
    });
  });

  group('LUD-17: Protocol schemes and raw (non bech32-encoded) URLs', () {
    test('should support lnurlc scheme', () async {
      final lnurlc =
          'lnurlc://lnurl.fiatjaf.com/lnurl-channel?session=fe89283f63dd5514902c41b2c5e98b3cc529c0af985212bc0921726be18d4bcd';
      final res = await getParams(lnurlc);

      expect(res.channelParams, isNotNull);
      expect(res.error, isNull);
    });
    test('should support lnurlw scheme', () async {
      final lnurlw =
          'lnurlw://lnurl.fiatjaf.com/lnurl-withdraw?session=df9c930b4ae3c879517e436d6f04e6b09aa9f8364f1e02a55d8feb73594b5189';
      final res = await getParams(lnurlw);

      expect(res.withdrawalParams, isNotNull);
      expect(res.error, isNull);
    });
    test('should support lnurlp scheme', () async {
      final lnurlp =
          'lnurlp://lnurl.fiatjaf.com/lnurl-pay?session=4d2636d9ae7d9db55e1ed21c5da514a8dee29f37fcf844a3a3a9ea89faff7cc0';
      final res = await getParams(lnurlp);

      expect(res.payParams, isNotNull);
      expect(res.error, isNull);
    });
    test('should support keyauth scheme', () async {
      final keyauth =
          'keyauth://lnurl.fiatjaf.com/lnurl-login?tag=login&k1=db667ee286556bebe60796ab4c7ea48393fa647054c40c67750c663ab1705c30';
      final res = await getParams(keyauth);

      expect(res.authParams, isNotNull);
      expect(res.error, isNull);
    });
  });

  group('LUD-18: Payer identity in payRequest protocol', () {
    test('should identify if SERVICE requires payer identities', () async {
      final url =
          'lightning:LNURL1DP68GURN8GHJ7MRWW4EXCTNXD9SHG6NPVCHXXMMD9AKXUATJDSKHQCTE8AEK2UMND9HKU0F3VFNRVVF5XU6XGD33X9JNJD3SVSMKZVMRX4NX2VPSVCMNWDP4XVUXVEPHVVURJCFCXUUNWDEE8YCNYWTRXQ6NSWP4V56RJEFKVCCXYXKMWAE';
      final res = await getParams(url);

      expect(res.payParams?.payerData?.name?.mandatory, false);
      expect(res.payParams?.payerData?.email?.mandatory, false);
      expect(res.payParams?.payerData, isNotNull);
      expect(res.error, isNull);
    });
  });

  group('LUD-19: Pay link discoverable from withdraw link', () {
    test('should include a payLink', () async {
      const url =
          'lightning:LNURL1DP68GURN8GHJ7MRWW4EXCTNXD9SHG6NPVCHXXMMD9AKXUATJDSKHW6T5DPJ8YCTH8AEK2UMND9HKU0TPV4NRGCN9XA3NQWRP8YMKXVTPVCCXGWTZ8YER2WTPVYMRGWFSVS6RYEPKVVMNJETYVGEXYVPJXFNRZCMZXAJN2CENXVENGEFNV9SNX09GNJU';
      final res = await getParams(url);

      expect(res.withdrawalParams?.payLink, isNotNull);
      expect(res.error, isNull);
    });
  });

  group('LUD-20: Long payment description for pay protocol', () {
    test('placeholder', () {
      // TODO: missing implementation.
    });
  });

  group('Miscellaneous: Validate LNURL', () {
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
  });
}
