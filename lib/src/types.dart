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

  LNURLChannelParams.fromJson(Map<String, dynamic> json)
      : tag = json['tag'],
        callback = json['callback'],
        k1 = json['k1'],
        uri = json['uri'];
}

class LNURLHostedChannelParams {
  final String tag;
  final String k1;
  final String uri;
  final String alias;

  LNURLHostedChannelParams.fromJson(Map<String, dynamic> json)
      : tag = json['tag'],
        k1 = json['k1'],
        uri = json['uri'],
        alias = json['alias'];
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

  LNURLWithdrawParams.fromJson(Map<String, dynamic> json)
      : tag = json['tag'],
        callback = json['callback'],
        k1 = json['k1'],
        minWithdrawable = json['minWithdrawable'],
        maxWithdrawable = json['maxWithdrawable'],
        defaultDescription = json['defaultDescription'],
        balanceCheck = json['balanceCheck'],
        payLink = json['payLink'];
}

class LNURLAuthParams {
  final String tag;
  final String k1;
  final String? action;

  LNURLAuthParams.fromJson(Map<String, dynamic> json)
      : tag = json['tag'],
        k1 = json['k1'],
        action = json['action'];
}

class LNURLPayParams {
  final String tag;
  final String callback;
  final int maxSendable;
  final int minSendable;
  final String metadata;
  final int commentAllowed;
  final PayerData? payerData;

  LNURLPayParams.fromJson(Map<String, dynamic> json)
      : tag = json['tag'],
        callback = json['callback'],
        minSendable = json['minSendable'],
        maxSendable = json['maxSendable'],
        metadata = json['metadata'],
        commentAllowed = json['commentAllowed'] ?? 0,
        payerData = PayerData.fromJson(json['payerData']);
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
  final String description;
  final String cipherText;
  final String iv;

  LNURLPaySuccessAction.fromJson(Map<String, dynamic> json)
      : tag = json['tag'],
        description = json['description'],
        cipherText = json['cipherText'],
        iv = json['iv'];
}

class LNURLPayResult {
  final String pr;
  final List<List<Object>> routes;
  final bool disposable;
  final LNURLPaySuccessAction successAction;

  LNURLPayResult.fromJson(Map<String, dynamic> json)
      : pr = json['pr'],
        routes = json['routes'],
        disposable = json['disposable'] ?? true,
        successAction = json['successAction'];
}

class PayerData {
  String? name;
  String? pubkey;
  Auth? auth;
  String? email;
  String? identifier;

  PayerData.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        pubkey = json['pubkey'],
        auth = Auth.fromJson(json["auth"]),
        email = json['email'],
        identifier = json['identifier'];
}

class Auth {
  String? key;
  String? k1;
  String? sig;

  Auth.fromJson(Map<String, dynamic> json)
      : key = json['key'],
        k1 = json['k1'],
        sig = json['sig'];
}
