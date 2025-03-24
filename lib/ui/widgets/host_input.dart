import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import '../../providers/ping_providers.dart';
import '../../providers/config_provider.dart';
import '../../utils/validation.dart';

class HostInputSheet extends ConsumerStatefulWidget {
  const HostInputSheet({super.key});

  @override
  ConsumerState<HostInputSheet> createState() => _HostInputSheetState();
}

class _HostInputSheetState extends ConsumerState<HostInputSheet> {
  final _controller = TextEditingController();
  List<ValidationResult> _validationResults = [];
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      final text = _controller.text;
      if (text.trim().isEmpty) {
        _validationResults = [];
        _hasError = false;
        return;
      }

      // Split by lines and validate each non-empty line
      final lines = text.split('\n');
      _validationResults = lines.map((line) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) {
          return ValidationResult(
            isValid: false,
            error: 'Please enter a valid IP address, hostname, or CIDR range',
            type: 'invalid',
          );
        }
        return InputValidator.validateInput(trimmed);
      }).toList();

      _hasError = _validationResults.any((result) => !result.isValid);
    });
  }

  String _getTypeIcon(String type) {
    switch (type) {
      case 'ipv4':
        return '🌐'; // Globe for IPv4
      case 'ipv6':
        return '📡'; // Satellite for IPv6
      case 'fqdn':
        return '🔤'; // ABC for domain names
      case 'cidr':
        return '🌍'; // Earth for network ranges
      default:
        return '❌'; // X for invalid
    }
  }

  @override
  Widget build(BuildContext context) {
    return MacosSheet(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter Hosts',
              style: MacosTheme.of(context).typography.headline,
            ),
            const SizedBox(height: 16),
            MacosTooltip(
              message:
                  'Examples:\n'
                  '223.5.5.5 (IPv4)\n'
                  '2001:db8::1 (IPv6)\n'
                  'google.com (Domain)\n'
                  '192.168.1.0/24 (CIDR)',
              child: MacosTextField(
                controller: _controller,
                placeholder: 'Enter hosts (one per line) or CIDR ranges',
                maxLines: 10,
              ),
            ),
            if (_validationResults.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: MacosTheme.of(context).dividerColor,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: MacosScrollbar(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _validationResults.length,
                    itemBuilder: (context, index) {
                      final result = _validationResults[index];
                      final lines = _controller.text.split('\n');
                      if (index >= lines.length) return const SizedBox();

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Text(_getTypeIcon(result.type)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                lines[index],
                                style: TextStyle(
                                  color:
                                      result.isValid
                                          ? MacosTheme.of(
                                            context,
                                          ).typography.body.color
                                          : MacosColors.systemRedColor,
                                ),
                              ),
                            ),
                            if (!result.isValid) ...[
                              const SizedBox(width: 8),
                              MacosTooltip(
                                message: result.error ?? 'Invalid input',
                                child: const Text('ℹ️'),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PushButton(
                  controlSize: ControlSize.large,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                PushButton(
                  controlSize: ControlSize.large,
                  secondary: false,
                  onPressed:
                      _hasError || _controller.text.trim().isEmpty
                          ? null // Disable button if there are errors
                          : () {
                            // Validate all inputs first
                            _validateInput();
                            if (_hasError) return;

                            final text = _controller.text;
                            final config = ref.read(configProvider);
                            final List<String> expandedHosts = [];

                            // Process each line
                            for (final line in text.split('\n')) {
                              final trimmed = line.trim();
                              if (trimmed.isEmpty) continue;

                              // Check if it's a CIDR notation
                              final validation = InputValidator.validateInput(trimmed);
                              if (!validation.isValid) continue;

                              if (validation.type == 'cidr') {
                                // Expand CIDR and add each address individually
                                expandedHosts.addAll(
                                  InputValidator.expandCIDR(
                                    trimmed,
                                    skipFirstAddress: config.skipCidrFirstAddr,
                                    skipLastAddress: config.skipCidrLastAddr,
                                  ),
                                );
                              } else {
                                expandedHosts.add(trimmed);
                              }
                            }

                            if (expandedHosts.isEmpty) {
                              return; // Prevent empty list
                            }

                            final manager = ref.read(pingManagerProvider);
                            manager.startPinging(
                              expandedHosts,
                              config,
                            );
                            Navigator.pop(context);
                          },
                  child: const Text('Start Pinging'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
