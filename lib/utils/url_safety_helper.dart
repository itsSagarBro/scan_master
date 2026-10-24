class UrlComponents {
  final String scheme; // "https://"
  final String subdomain; // "login.sbi.com."
  final String rootDomain; // "attacker.ru" or "sbi.co.in"
  final String pathAndQuery; // "/auth?token=..."
  final bool isSuspiciousStructure;

  const UrlComponents({
    required this.scheme,
    required this.subdomain,
    required this.rootDomain,
    required this.pathAndQuery,
    this.isSuspiciousStructure = false,
  });
}

class UrlSafetyHelper {
  // Comprehensive set of 2-part, 3-part, and multi-part public suffixes (eTLDs)
  static const Set<String> _multiPartSuffixes = {
    // --- India (.in) ---
    'co.in', 'net.in', 'org.in', 'gen.in', 'firm.in', 'ind.in',
    'gov.in', 'mil.in', 'ac.in', 'edu.in', 'res.in', 'nic.in',
    '5g.in', '6g.in', 'ai.in', 'biz.in', 'cloud.in', 'coop.in',
    'cs.in', 'dr.in', 'er.in', 'info.in', 'int.in', 'me.in',
    'mobi.in', 'museum.in', 'name.in', 'post.in', 'pro.in',
    'travel.in', 'tv.in', 'web.in', 'bank.in',

    // --- United Kingdom (.uk) & Crown Dependencies ---
    'co.uk', 'org.uk', 'me.uk', 'ltd.uk', 'plc.uk', 'net.uk',
    'sch.uk', 'ac.uk', 'gov.uk', 'mod.uk', 'mil.uk', 'nhs.uk',
    'police.uk', 'parliament.uk', 'cymru.uk', 'wales.uk',
    'gov.wales', 'gov.scot',

    // --- Australia (.au) & New Zealand (.nz) ---
    'com.au', 'net.au', 'org.au', 'edu.au', 'gov.au', 'asn.au', 'id.au',
    'co.nz', 'net.nz', 'org.nz', 'govt.nz', 'ac.nz', 'geek.nz', 'school.nz',

    // --- United States (.us) & Canada (.ca) ---
    'dni.us', 'fed.us', 'isa.us', 'kids.us', 'nsn.us', 'com.us', 'net.us',
    'org.us',
    'k12.ca.us', 'cc.ca.us', 'lib.ca.us', 'pvt.k12.ma.us', 'state.tx.us',
    'gc.ca', 'gov.ca', 'edu.ca',
    'ab.ca', 'bc.ca', 'mb.ca', 'nb.ca', 'nl.ca', 'ns.ca',
    'nt.ca', 'nu.ca', 'on.ca', 'pe.ca', 'qc.ca', 'sk.ca', 'yk.ca',

    // --- East, Southeast & Central Asia ---
    'co.jp', 'ne.jp', 'or.jp', 'ac.jp', 'go.jp', 'ed.jp', 'gr.jp', 'lg.jp',
    'co.kr', 'ne.kr', 're.kr', 'or.kr', 'pe.kr', 'go.kr', 'mil.kr', 'ac.kr',
    'com.cn', 'net.cn', 'org.cn', 'gov.cn', 'edu.cn', '公司.cn', '網絡.cn',
    'com.tw', 'net.tw', 'org.tw', 'gov.tw', 'edu.tw', 'idv.tw',
    'com.hk', 'net.hk', 'org.hk', 'gov.hk', 'edu.hk', 'idv.hk',
    'com.sg', 'net.sg', 'org.sg', 'gov.sg', 'edu.sg', 'per.sg',
    'com.my', 'net.my', 'org.my', 'gov.my', 'edu.my', 'mil.my',
    'co.id', 'web.id', 'or.id', 'ac.id', 'go.id', 'mil.id', 'sch.id',
    'com.ph', 'net.ph', 'org.ph', 'gov.ph', 'edu.ph',
    'com.vn', 'net.vn', 'org.vn', 'gov.vn', 'edu.vn', 'ac.vn',
    'co.th', 'in.th', 'ac.th', 'go.th', 'mi.th', 'or.th', 'net.th',
    'com.af', 'com.kh', 'com.la', 'com.mm', 'com.mn', 'com.np',
    'com.lk', 'com.mv', 'com.kz', 'com.uz', 'com.ge', 'com.am',
    'com.az', 'com.tm', 'com.tj',

    // --- Middle East & South Asia ---
    'com.pk', 'net.pk', 'org.pk', 'gov.pk', 'edu.pk',
    'com.bd', 'net.bd', 'org.bd', 'gov.bd', 'edu.bd',
    'co.ae', 'net.ae', 'org.ae', 'gov.ae', 'ac.ae', 'sch.ae',
    'com.sa', 'net.sa', 'org.sa', 'gov.sa', 'med.sa', 'edu.sa', 'pub.sa',
    'co.il', 'org.il', 'net.il', 'ac.il', 'gov.il', 'muni.il', 'k12.il',
    'com.om', 'com.qa', 'com.kw', 'com.bh', 'com.jo', 'com.lb',
    'com.iq', 'com.ir', 'com.ps', 'com.sy', 'com.ye',

    // --- Europe ---
    'asso.fr', 'nom.fr', 'prd.fr', 'presse.fr', 'tm.fr', 'gouv.fr',
    'com.de', 'com.nl', 'co.nl', 'org.nl', 'net.nl',
    'com.be', 'co.be', 'com.ch', 'co.ch',
    'com.at', 'co.at', 'or.at', 'gv.at',
    'com.es', 'nom.es', 'org.es', 'gob.es', 'edu.es',
    'co.it', 'com.it', 'gov.it', 'edu.it',
    'com.pt', 'edu.pt', 'gov.pt',
    'com.gr', 'edu.gr', 'gov.gr',
    'com.se', 'org.se', 'pp.se',
    'com.no', 'priv.no', 'fhs.no', 'vgs.no',
    'com.dk', 'co.dk', 'edu.dk',
    'com.fi', 'net.fi', 'org.fi',
    'com.ie', 'gov.ie', 'edu.ie',
    'com.pl', 'net.pl', 'org.pl', 'info.pl', 'biz.pl', 'edu.pl',
    'com.ru', 'net.ru', 'org.ru', 'pp.ru', 'spb.ru', 'msk.ru',
    'com.cz', 'co.cz', 'org.cz',
    'com.ro', 'org.ro', 'info.ro',
    'com.hu', 'co.hu', 'org.hu',
    'com.bg', 'org.bg', 'net.bg',
    'com.hr', 'from.hr',
    'com.rs', 'org.rs', 'edu.rs',
    'com.sk', 'org.sk', 'edu.sk',
    'com.si', 'org.si', 'edu.si',
    'com.tr', 'net.tr', 'org.tr', 'gov.tr', 'edu.tr', 'k12.tr', 'bel.tr',
    'com.ua', 'net.ua', 'org.ua', 'gov.ua', 'edu.ua', 'in.ua',
    'com.lt', 'com.lv', 'com.ee', 'com.is', 'com.lu', 'com.mt',
    'com.cy', 'com.ba', 'com.me', 'com.mk',

    // --- Latin America & Caribbean ---
    'com.br', 'net.br', 'org.br', 'gov.br', 'edu.br', 'art.br', 'dev.br',
    'com.mx', 'net.mx', 'org.mx', 'gob.mx', 'edu.mx',
    'com.ar', 'net.ar', 'org.ar', 'gob.ar', 'edu.ar', 'tur.ar',
    'com.co', 'net.co', 'org.co', 'gov.co', 'edu.co',
    'com.cl', 'gob.cl', 'co.cl',
    'com.pe', 'net.pe', 'org.pe', 'gob.pe',
    'com.uy', 'com.py', 'com.bo', 'com.ec', 'com.ve', 'com.gt',
    'com.pa', 'com.do', 'com.pr', 'com.cr', 'com.hn', 'com.sv',
    'com.ni', 'com.cu', 'com.jm', 'com.tt', 'com.bb', 'com.bs',
    'com.ag', 'com.bz', 'com.gy', 'com.sr', 'com.ht',

    // --- Africa ---
    'co.za', 'net.za', 'org.za', 'gov.za', 'ac.za', 'school.za',
    'com.ng', 'net.ng', 'org.ng', 'gov.ng', 'edu.ng',
    'co.ke', 'or.ke', 'ne.ke', 'go.ke', 'ac.ke', 'sc.ke',
    'com.eg', 'net.eg', 'org.eg', 'gov.eg', 'edu.eg',
    'com.gh', 'com.et', 'com.tz', 'com.ug', 'com.zm', 'com.zw',
    'co.bw', 'co.mz', 'co.ao', 'com.na', 'com.mu', 'com.rw',
    'co.sn', 'com.cm', 'co.ci', 'com.dz', 'com.ma', 'com.tn',
    'com.ly', 'com.sd', 'com.so',

    // --- Oceania ---
    'com.fj', 'com.pg', 'com.sb', 'com.vu', 'com.ws', 'com.to',
    'com.ki', 'com.nr', 'com.pw',

    // --- Cloud Hosting, PaaS, Dynamic DNS & Tunneling Platforms ---
    'github.io', 'gitlab.io', 'bitbucket.io', 'pages.github.io',
    'pantheonsite.io',
    'pages.dev', 'workers.dev', 'r2.dev', 'cloudflarepages.com',
    'trycloudflare.com',
    'vercel.app', 'now.sh', 'netlify.app', 'netlify.com',
    'onrender.com', 'render.com', 'fly.dev', 'deno.dev', 'surge.sh',
    'railway.app', 'up.railway.app', 'replit.app', 'repl.co',
    'glitch.me', 'webflow.io', 'wixsite.com', 'wordpress.com', 'blogspot.com',
    'tumblr.com', 'ghost.io', 'firebaseapp.com', 'web.app', 'appspot.com',
    'run.app',
    'cloudfunctions.net', 'azurewebsites.net', 'azurestaticapps.net',
    'azurefd.net',
    'blob.core.windows.net', 'web.core.windows.net', 'cloudapp.net',
    's3.amazonaws.com', 's3.us-east-1.amazonaws.com', 'elasticbeanstalk.com',
    'cloudfront.net', 'amazonaws.com', 'execute-api.amazonaws.com',
    'elb.amazonaws.com',
    'digitaloceanspaces.com', 'eu.ngrok.io', 'ngrok-free.app',
    'duckdns.org', 'no-ip.org', 'ddns.net', 'dynv6.net',
  };

  // High-value targets commonly targeted by deceptive subdomains
  static const List<String> _highProfileBrands = [
    // --- Big Tech, Identity & Workspaces ---
    'google', 'gmail', 'youtube', 'android', 'googleaccounts', 'accountsgoogle',
    'googleworkspace', 'gworkspace', 'googlecloud', 'firebase',
    'apple', 'icloud', 'itunes', 'appleid', 'appleaccount', 'applemusic',
    'microsoft', 'office365', 'outlook', 'live', 'hotmail', 'onedrive',
    'microsoftonline', 'office', 'azure', 'sharepoint', 'teams',
    'meta', 'facebook', 'instagram', 'whatsapp', 'messenger', 'threads',
    'twitter', 'telegram', 'snapchat', 'tiktok', 'linkedin', 'discord',
    'signal', 'reddit', 'pinterest', 'tumblr', 'quora', 'medium',
    'wechat', 'line', 'kakao', 'viber', 'skype', 'slack',
    'zoom', 'webex', 'meet',

    // --- Indian National & Private Banks ---
    'sbi', 'onlinesbi', 'statebankofindia',
    'hdfc', 'hdfcbank', 'hdfcsec',
    'icici', 'icicibank', 'icicidirect',
    'axis', 'axisbank',
    'pnb', 'punjabnationalbank', 'punjabandsindbank',
    'bob', 'bankofbaroda',
    'kotak', 'kotakbank', 'kotaksecurities',
    'indusind', 'yesbank', 'canarabank', 'unionbank', 'idbibank',
    'bankofindia', 'centralbankofindia', 'indianbank', 'indianoverseasbank',
    'uco', 'ucobank', 'bankofmaharashtra', 'mahabank', 'federalbank',
    'southindianbank', 'karurvysyabank', 'cityunionbank', 'karnatakabank',
    'bandhanbank', 'rblbank', 'idfcfirstbank', 'aubank', 'equitas',
    'ujjivansfb', 'janabank', 'esafbank', 'finocobank', 'suryodaybank',

    // --- Indian Government, Taxation & Citizen Services ---
    'uidai', 'myAadhaar',
    'incometax', 'incometaxindia', 'gst', 'gstin', 'gstportal',
    'epfindia', 'epfo', 'esic', 'rbi', 'mygov', 'digitallocker', 'digilocker',
    'parivahan', 'sarathi', 'mparivahan', 'passportindia', 'passportseva',
    'irctc', 'indianrailways', 'umang', 'gemgov', 'cra-nsdl', 'protean',
    'mca', 'mca21', 'nsdl', 'cdsl', 'eci', 'nvsp', 'indiapost', 'speedpost',
    'upsc', 'ssc', 'nta', 'cbse', 'nic', 'meity', 'mybharat', 'pmkisan',
    'pmjay', 'ayushmanbharat', 'abha',

    // --- Indian UPI, Wallets, Fintech & Brokerages ---
    'npci', 'upi', 'bhim', 'bhimupi', 'phonepe', 'paytm', 'paytmmall',
    'paytmoney',
    'googlepay', 'gpay', 'amazonpay', 'mobikwik', 'freecharge', 'cred',
    'bharatpe',
    'razorpay', 'cashfree', 'payu', 'juspay', 'billdesk', 'ccavenue',
    'pinelabs',
    'groww', 'zerodha', 'kite', 'upstox', 'angelone', '5paisa', 'dhan',
    'motilaloswal', 'sharekhan', 'kuvera', 'smallcase', 'etmoney',
    'jioblackrock',

    // --- Global Banks, Cards & Money Transfer ---
    'paypal', 'stripe', 'wise', 'revolut', 'chase', 'bankofamerica',
    'wellsfargo', 'citibank', 'hsbc', 'barclays', 'standardchartered',
    'americanexpress', 'amex', 'discover', 'capitalone', 'usbank', 'pnc',
    'tdbank', 'ally', 'santander', 'lloydsbank', 'natwest', 'monzo',
    'starlingbank', 'lloyds', 'halifax', 'nationwide', 'virginmoney',
    'bunq', 'n26', 'klarna', 'adyen', 'worldpay', 'payoneer', 'skrill',
    'neteller', 'remitly', 'westernunion', 'moneygram',

    // --- E-Commerce & Quick-Commerce ---
    'amazon', 'amazonprime', 'flipkart', 'myntra', 'meesho', 'ajio', 'nykaa',
    'jiomart', 'tatacliq', 'tataneu', 'reliancedigital', 'croma', 'snapdeal',
    'bigbasket', 'blinkit', 'zepto', 'swiggy', 'zomato', 'instamart',
    'ebay', 'aliexpress', 'alibaba', 'temu', 'shein', 'walmart', 'target',
    'bestbuy', 'etsy', 'shopify', 'mercadolibre', 'rakuten', 'ikea',
    'adidas', 'nike', 'puma', 'samsung', 'sony', 'oneplus', 'xiaomi',

    // --- Crypto, Web3 & Wallets ---
    'binance', 'coinbase', 'kraken', 'kucoin', 'bybit', 'okx',
    'wazirx', 'coindcx', 'coinswitch', 'mudrex', 'zebpay', 'bitbns',
    'metamask', 'trustwallet', 'ledger', 'phantom', 'opensea', 'uniswap',
    'pancakeswap', 'etherscan', 'solscan',

    // --- Streaming, Entertainment & Gaming ---
    'netflix', 'spotify', 'hotstar', 'disneyplus', 'primevideo', 'sonyliv',
    'zee5', 'jiocinema', 'jiotv', 'mxplayer', 'aha', 'steam', 'steampowered',
    'epicgames', 'playstation', 'playstationnetwork', 'xbox', 'xboxlive',
    'nintendo', 'eaaccount', 'ubisoft', 'riotgames', 'valorant', 'minecraft',
    'blizzard', 'roblox', 'twitch', 'kick',

    // --- Telecom & Couriers ---
    'jio', 'reliancejio', 'airtel', 'myairtel', 'vodafone', 'vi', 'bsnl',
    'mtnl',
    'att', 'verizon', 'tmobile', 'delhivery', 'dtdc', 'bluedart', 'ecomexpress',
    'xpressbees', 'shadowfax', 'shiprocket', 'fedex', 'dhl', 'ups', 'usps',
    'royalmail', 'parcelforce', 'evri', 'dpd', 'gls', 'aramex', 'maersk',

    // --- Developer & Cloud Tools ---
    'github', 'gitlab', 'bitbucket', 'npm', 'pypi', 'rubygems', 'docker',
    'dockerhub', 'cloudflare', 'vercel', 'netlify', 'render', 'railway',
    'replit', 'heroku', 'digitalocean', 'linode', 'vultr', 'aws',
    'supabase', 'appwrite', 'mongodb', 'redis', 'datadog', 'sentry',
    'newrelic', 'jenkins', 'circleci', 'travisci',

    // --- Travel, Healthcare & Productivity ---
    'makemytrip', 'goibibo', 'yatra', 'ixigo', 'cleartrip', 'easemytrip',
    'bookingcom', 'airbnb', 'agoda', 'expedia', 'tripadvisor', 'skyscanner',
    'kayak', 'uber', 'ola', 'rapido', 'lyft', 'indigo', 'airindia', 'spicejet',
    'emirates', 'qatarairways', 'apollo', 'pharmeasy', '1mg', 'netmeds',
    'practo', 'cultfit', 'byjus', 'unacademy', 'physicswallah', 'coursera',
    'udemy', 'edx', 'workday', 'servicenow', 'salesforce', 'hubspot',
    'notion', 'atlassian', 'jira', 'trello', 'asana', 'monday', 'canva',
    'figma', 'miro', 'okta', 'auth0', 'duo', 'lastpass', '1password',
    'bitwarden',
  ];

  /// Decomposes any web URL into its constituent security spans
  static UrlComponents? parseUrl(String rawUrl) {
    var trimmed = rawUrl.trim();

    // Strip "URL: ", "Url: ", or "url:" prefix if passed directly
    if (RegExp(r'^url:\s*', caseSensitive: false).hasMatch(trimmed)) {
      trimmed = trimmed
          .replaceFirst(RegExp(r'^url:\s*', caseSensitive: false), '')
          .trim();
    }

    if (trimmed.isEmpty || trimmed.contains(' ')) return null;

    if (!trimmed.startsWith(RegExp(r'^[a-zA-Z]+://'))) {
      trimmed = 'https://$trimmed';
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.host.isEmpty || !uri.host.contains('.')) {
      return null;
    }

    final fullHost = uri.host.toLowerCase();

    // Check if host is an IPv4 address
    final isIpv4 =
        RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(fullHost);

    String rootDomain = fullHost;
    String subdomain = '';

    if (!isIpv4) {
      final labels = fullHost.split('.');

      if (labels.length >= 3) {
        // Check for 2-part suffix (e.g., label[-2].label[-1] == "co.in")
        final twoPartSuffix =
            '${labels[labels.length - 2]}.${labels[labels.length - 1]}';

        // Check for 3-part suffix (e.g., label[-3].label[-2].label[-1] == "s3.us-east-1.amazonaws.com")
        String? threePartSuffix;
        if (labels.length >= 4) {
          threePartSuffix =
              '${labels[labels.length - 3]}.${labels[labels.length - 2]}.${labels[labels.length - 1]}';
        }

        if (threePartSuffix != null &&
            _multiPartSuffixes.contains(threePartSuffix)) {
          rootDomain = labels.sublist(labels.length - 4).join('.');
          final subLabels = labels.sublist(0, labels.length - 4);
          if (subLabels.isNotEmpty) {
            subdomain = '${subLabels.join('.')}.';
          }
        } else if (_multiPartSuffixes.contains(twoPartSuffix)) {
          // Take 3 segments for root: e.g. "sbi.co.in"
          rootDomain = labels.sublist(labels.length - 3).join('.');
          final subLabels = labels.sublist(0, labels.length - 3);
          if (subLabels.isNotEmpty) {
            subdomain = '${subLabels.join('.')}.';
          }
        } else {
          // Standard single TLD: take last 2 labels (e.g. "google.com")
          rootDomain = labels.sublist(labels.length - 2).join('.');
          final subLabels = labels.sublist(0, labels.length - 2);
          if (subLabels.isNotEmpty) {
            subdomain = '${subLabels.join('.')}.';
          }
        }
      } else if (labels.length == 2) {
        rootDomain = fullHost;
        subdomain = '';
      }
    }

    final scheme = uri.hasScheme ? '${uri.scheme}://' : '';
    final pathAndQuery = uri.path +
        (uri.hasQuery ? '?${uri.query}' : '') +
        (uri.hasFragment ? '#${uri.fragment}' : '');

    // Deceptive subdomain check with boundary-aware regex to prevent false positives
    bool isSuspicious = false;
    if (subdomain.isNotEmpty) {
      for (final brand in _highProfileBrands) {
        final brandRegex = RegExp('(^|[.-])$brand([.-]|\$)');
        final inSubdomain = brandRegex.hasMatch(subdomain);
        final inRoot = brandRegex.hasMatch(rootDomain);

        if (inSubdomain && !inRoot) {
          isSuspicious = true;
          break;
        }
      }
    }

    return UrlComponents(
      scheme: scheme,
      subdomain: subdomain,
      rootDomain: rootDomain,
      pathAndQuery: pathAndQuery,
      isSuspiciousStructure: isSuspicious,
    );
  }
}
