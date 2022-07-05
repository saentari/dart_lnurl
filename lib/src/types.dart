/// The result returned when you call getParams. The correct response
/// item will be non-null and the rest will be null.
///
/// If error is non-null then an error occurred while calling the lnurl service.
class LNURLParseResult {
  final LNURLChannelParams? channelParams;
  final LNURLWithdrawParams? withdrawalParams;
  final LNURLAuthParams? authParams;
  final LNURLPayParams? payParams;
  final LNURLErrorResponse? error;

  LNURLParseResult({
    this.channelParams,
    this.withdrawalParams,
    this.authParams,
    this.payParams,
    this.error,
  });
}

class LNURLChannelParams {
  final String tag;
  final String callback;
  final String k1;
  final String uri;
  final String domain;

  LNURLChannelParams.fromJson(Map<String, dynamic> json)
      : tag = json['tag'],
        callback = json['callback'],
        k1 = json['k1'],
        uri = json['uri'],
        domain = json['domain'];
}

class LNURLHostedChannelParams {
  final String tag;
  final String k1;
  final String uri;
  final String alias;
  final String domain;

  LNURLHostedChannelParams.fromJson(Map<String, dynamic> json)
      : tag = json['tag'],
        k1 = json['k1'],
        uri = json['uri'],
        alias = json['alias'],
        domain = json['domain'];
}

class LNURLWithdrawParams {
  final String tag;
  final String callback;
  final String k1;
  final int minWithdrawable;
  final int maxWithdrawable;
  final String defaultDescription;
  final String? balanceCheck;
  final String? payLink;
  final String domain;
  final String pr;

  LNURLWithdrawParams.fromJson(Map<String, dynamic> json)
      : tag = json['tag'],
        callback = json['callback'],
        k1 = json['k1'],
        minWithdrawable = json['minWithdrawable'],
        maxWithdrawable = json['maxWithdrawable'],
        defaultDescription = json['defaultDescription'],
        balanceCheck = json['balanceCheck'],
        payLink = json['payLink'],
        domain = json['domain'],
        pr = json['pr'];
}

class LNURLAuthParams {
  final String tag;
  final String k1;
  final String? action;
  final String domain;

  LNURLAuthParams.fromJson(Map<String, dynamic> json)
      : tag = json['tag'],
        k1 = json['k1'],
        action = json['action'],
        domain = json['domain'];
}

class LNURLPayParams {
  final String tag;
  final String callback;
  final int maxSendable;
  final int minSendable;
  final String metadata;
  final int commentAllowed;
  final PayerDataRecord? payerData;
  final String domain;

  LNURLPayParams.fromJson(Map<String, dynamic> json)
      : tag = json['tag'],
        callback = json['callback'],
        minSendable = json['minSendable'],
        maxSendable = json['maxSendable'],
        metadata = json['metadata'],
        commentAllowed = json['commentAllowed'] ?? 0,
        payerData = json['payerData'] != null
            ? PayerDataRecord.fromJson(json['payerData'])
            : null,
        domain = json['domain'];
}

class LNURLErrorResponse {
  final String status;
  final String reason;
  final String domain;
  final String url;

  LNURLErrorResponse.fromJson(Map<String, dynamic> json)
      : status = json['status'],
        reason = json['reason'],
        domain = json['domain'],
        url = json['url'];
}

/// A success action will be returned when making a call to the lnUrl callback url.
class LNURLPaySuccessAction {
  final String tag;
  final String? message;
  final String? url;
  final String? description;
  final String? cipherText;
  final String? iv;

  LNURLPaySuccessAction.fromJson(Map<String, dynamic> json)
      : tag = json['tag'],
        message = json['message'],
        url = json['url'],
        description = json['description'],
        cipherText = json['cipherText'],
        iv = json['iv'];
}

class LNURLPayResult {
  final String pr;
  final List<List<Object>> routes;
  final bool disposable;
  final LNURLPaySuccessAction? successAction;

  LNURLPayResult.fromJson(Map<String, dynamic> json)
      : pr = json['pr'],
        routes = (json['routes'] as List<dynamic>).cast<List<Object>>(),
        disposable = json['disposable'] ?? true,
        successAction = json['successAction'] != null
            ? LNURLPaySuccessAction.fromJson(json['successAction'])
            : null;
}

class PayerData {
  String? name;
  String? pubkey;
  Auth? auth;
  String? email;
  String? identifier;

  PayerData({
    this.name,
    this.pubkey,
    this.auth,
    this.email,
    this.identifier,
  });

  PayerData copyWith({
    String? name,
    String? pubkey,
    Auth? auth,
    String? email,
    String? identifier,
  }) =>
      PayerData(
          name: name ?? this.name,
          pubkey: pubkey ?? this.pubkey,
          auth: auth ?? this.auth,
          email: email ?? this.email,
          identifier: identifier ?? this.identifier);

  PayerData.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        pubkey = json['pubkey'],
        auth = json["auth"] != null ? Auth.fromJson(json["auth"]) : null,
        email = json['email'],
        identifier = json['identifier'];

  Map toJson() => {
        'name': name,
        'pubkey': pubkey,
        'auth': auth?.toJson(),
        'email': email,
        'identifier': identifier,
      };
}

class Auth {
  String? key;
  String? k1;
  String? sig;

  Auth({
    this.key,
    this.k1,
    this.sig,
  });

  Auth copyWith({String? key, String? k1, String? sig}) =>
      Auth(key: key ?? this.key, k1: k1 ?? this.k1, sig: sig ?? this.sig);

  Auth.fromJson(Map<String, dynamic> json)
      : key = json['key'],
        k1 = json['k1'],
        sig = json['sig'];

  Map toJson() => {
        'key': key,
        'k1': k1,
        'sig': sig,
      };
}

class PayerDataRecord {
  PayerDataRecordField? name;
  PayerDataRecordField? pubkey;
  AuthRecord? auth;
  PayerDataRecordField? email;
  PayerDataRecordField? identifier;

  PayerDataRecord.fromJson(Map<String, dynamic> json)
      : name = json["name"] != null
            ? PayerDataRecordField.fromJson(json['name'])
            : null,
        pubkey = json["pubkey"] != null
            ? PayerDataRecordField.fromJson(json['pubkey'])
            : null,
        auth = json["auth"] != null ? AuthRecord.fromJson(json["auth"]) : null,
        email = json["email"] != null
            ? PayerDataRecordField.fromJson(json['email'])
            : null,
        identifier = json["identifier"] != null
            ? PayerDataRecordField.fromJson(json['identifier'])
            : null;
}

class AuthRecord {
  bool mandatory;
  String k1;

  AuthRecord.fromJson(Map<String, dynamic> json)
      : mandatory = json['mandatory'],
        k1 = json['k1'];
}

class PayerDataRecordField {
  bool mandatory;

  PayerDataRecordField.fromJson(Map<String, dynamic> json)
      : mandatory = json['mandatory'];
}
