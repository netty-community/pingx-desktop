class ProbeConfig {
  final int interval; // milliseconds between pings
  final int count; // number of pings per probe
  final int timeout; // seconds timeout
  final int size; // ICMP echo size
  final int wait; // seconds wait between probe sets
  final int maxStoreLogs; // maximum number of logs to store
  final int maxConcurrentProbes; // maximum concurrent pings
  final bool skipCidrFirstAddr; // skip first address in CIDR range
  final bool skipCidrLastAddr; // skip last address in CIDR range
  final int ttl; // Time To Live
  final List<String>? recentHosts; // Recently used hosts

  const ProbeConfig({
    this.interval = 1000,
    this.count = 4,
    this.timeout = 2,
    this.size = 56,
    this.wait = 3,
    this.maxStoreLogs = 100,
    this.maxConcurrentProbes = 300,
    this.skipCidrFirstAddr = true,
    this.skipCidrLastAddr = true,
    this.ttl = 64,
    this.recentHosts,
  });

  ProbeConfig copyWith({
    int? interval,
    int? count,
    int? timeout,
    int? size,
    int? wait,
    int? maxStoreLogs,
    int? maxConcurrentProbes,
    bool? skipCidrFirstAddr,
    bool? skipCidrLastAddr,
    int? ttl,
    List<String>? recentHosts,
  }) {
    return ProbeConfig(
      interval: interval ?? this.interval,
      count: count ?? this.count,
      timeout: timeout ?? this.timeout,
      size: size ?? this.size,
      wait: wait ?? this.wait,
      maxStoreLogs: maxStoreLogs ?? this.maxStoreLogs,
      maxConcurrentProbes: maxConcurrentProbes ?? this.maxConcurrentProbes,
      skipCidrFirstAddr: skipCidrFirstAddr ?? this.skipCidrFirstAddr,
      skipCidrLastAddr: skipCidrLastAddr ?? this.skipCidrLastAddr,
      ttl: ttl ?? this.ttl,
      recentHosts: recentHosts ?? this.recentHosts,
    );
  }

  Map<String, dynamic> toJson() => {
        'interval': interval,
        'count': count,
        'timeout': timeout,
        'size': size,
        'wait': wait,
        'maxStoreLogs': maxStoreLogs,
        'maxConcurrentProbes': maxConcurrentProbes,
        'skipCidrFirstAddr': skipCidrFirstAddr,
        'skipCidrLastAddr': skipCidrLastAddr,
        'ttl': ttl,
        'recentHosts': recentHosts,
      };

  factory ProbeConfig.fromJson(Map<String, dynamic> json) => ProbeConfig(
        interval: json['interval'] as int? ?? 1000,
        count: json['count'] as int? ?? 4,
        timeout: json['timeout'] as int? ?? 2,
        size: json['size'] as int? ?? 56,
        wait: json['wait'] as int? ?? 3,
        maxStoreLogs: json['maxStoreLogs'] as int? ?? 100,
        maxConcurrentProbes: json['maxConcurrentProbes'] as int? ?? 300,
        skipCidrFirstAddr: json['skipCidrFirstAddr'] as bool? ?? true,
        skipCidrLastAddr: json['skipCidrLastAddr'] as bool? ?? true,
        ttl: json['ttl'] as int? ?? 64,
        recentHosts: (json['recentHosts'] as List<dynamic>?)?.cast<String>(),
      );
}
