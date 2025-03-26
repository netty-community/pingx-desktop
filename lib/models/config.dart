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
    );
  }

  Map<String, dynamic> toJson() => {
    'interval': interval,
    'count': count,
    'timeout': timeout,
    'size': size,
    'wait': wait,
    'max_store_logs': maxStoreLogs,
    'max_concurrent_probes': maxConcurrentProbes,
    'skip_cidr_first_addr': skipCidrFirstAddr,
    'skip_cidr_last_addr': skipCidrLastAddr,
  };
}
