# dart_lnurl
[![pub package](https://img.shields.io/badge/pub-0.2.1-blueviolet.svg)](https://pub.dev/packages/dart_lnurl)

A Dart implementation of lnurl to decode bech32 lnurl strings or raw (non bech32-encoded) URLs. Currently supports the following tags:
* withdrawRequest
* payRequest
* channelRequest
* login

## Features
* ✅ Decode a bech32-encoded lnurl string.
* ✅ Handle LUD-17: Protocol schemes and raw (non bech32-encoded) URLs.
* ✅ Make GET request to the decoded ln service and return the response.
* ✅ LinkingKey derivation for BIP-32 based wallets.


Learn more about the lnurl spec here: https://github.com/fiatjaf/lnurl-rfc

# API Reference

`Future<LNURLParseResult> getParams(String encodedUrl)`
Use this to parse an encoded bech32 lnurl string or raw (non bech32-encoded) URLs, call the URI, and return the parsed response from the lnurl service. The `encodedUrl` can either have `lightning:` in it or not.

`String decryptSuccessActionAesPayload({LNURLPaySuccessAction successAction, String preimage})`

When doing lnurl pay, the success action could contain an encrypted payload using the payment preimage. Use this function to decrypt that payload.

## Supported LUDs
🟢 fully supported, 🟠 partially supported, 🔴 not supported.

* 🟠 [LUD-01: Base LNURL encoding and decoding](https://github.com/fiatjaf/lnurl-rfc/blob/luds/01.md)
* 🟢 [LUD-02: channelRequest base spec](https://github.com/fiatjaf/lnurl-rfc/blob/luds/02.md)
* 🟢 [LUD-03: withdrawRequest base spec](https://github.com/fiatjaf/lnurl-rfc/blob/luds/03.md)
* 🟢 [LUD-04: auth base spec](https://github.com/fiatjaf/lnurl-rfc/blob/luds/04.md)
* 🟢 [LUD-05: BIP32-based seed generation for auth protocol](https://github.com/fiatjaf/lnurl-rfc/blob/luds/05.md)
* 🟢 [LUD-06: payRequest base spec](https://github.com/fiatjaf/lnurl-rfc/blob/luds/06.md)
* 🔴 [LUD-07: hostedChannelRequest base spec](https://github.com/fiatjaf/lnurl-rfc/blob/luds/07.md)
* 🔴 [LUD-08: Fast withdrawRequest](https://github.com/fiatjaf/lnurl-rfc/blob/luds/08.md)
* 🟢 [LUD-09: successAction field for payRequest](https://github.com/fiatjaf/lnurl-rfc/blob/luds/09.md)
* 🟢 [LUD-10: aes success action in payRequest](https://github.com/fiatjaf/lnurl-rfc/blob/luds/10.md)
* 🟢 [LUD-11: Disposable and storeable payRequests](https://github.com/fiatjaf/lnurl-rfc/blob/luds/11.md)
* 🟢 [LUD-12: Comments in payRequest](https://github.com/fiatjaf/lnurl-rfc/blob/luds/12.md)
* 🔴 [LUD-13: signMessage-based seed generation for auth protocol](https://github.com/fiatjaf/lnurl-rfc/blob/luds/13.md)
* 🟢 [LUD-14: balanceCheck: reusable withdrawRequests](https://github.com/fiatjaf/lnurl-rfc/blob/luds/14.md)
* 🔴 [LUD-15: balanceNotify: services hurrying up the withdraw process](https://github.com/fiatjaf/lnurl-rfc/blob/luds/15.md)
* 🔴 [LUD-16: Paying to static internet identifiers](https://github.com/fiatjaf/lnurl-rfc/blob/luds/16.md)
* 🟢 [LUD-17: Protocol schemes and raw (non bech32-encoded) URLs](https://github.com/fiatjaf/lnurl-rfc/blob/luds/17.md)
* 🟢 [LUD-18: Payer identity in payRequest protocol](https://github.com/fiatjaf/lnurl-rfc/blob/luds/18.md)
* 🟢 [LUD-19: Pay link discoverable from withdraw link](https://github.com/fiatjaf/lnurl-rfc/blob/luds/19.md)
* 🔴 [LUD-20: Long payment description for pay protocol](https://github.com/fiatjaf/lnurl-rfc/blob/luds/20.md)