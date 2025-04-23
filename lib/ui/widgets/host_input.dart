import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../providers/config_provider.dart';
import '../../utils/validation.dart';

// 添加 hostsProvider
final hostsProvider = StateProvider<List<String>>((ref) => []);

class HostInputSheet extends ConsumerStatefulWidget {
  const HostInputSheet({super.key});

  @override
  ConsumerState<HostInputSheet> createState() => _HostInputSheetState();
}

class _HostInputSheetState extends ConsumerState<HostInputSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
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
    _focusNode.dispose();
    super.dispose();
  }

  ValidationResult validateHost(String input) {
    if (input.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        error: 'Please enter a valid IP address, hostname, or CIDR range',
        type: 'invalid',
      );
    }
    return InputValidator.validateInput(input);
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
      _validationResults =
          lines.map((line) {
            final trimmed = line.trim();
            if (trimmed.isEmpty) {
              return ValidationResult(
                isValid: false,
                error:
                    'Please enter a valid IP address, hostname, or CIDR range',
                type: 'invalid',
              );
            }
            return validateHost(trimmed);
          }).toList();

      _hasError = _validationResults.any((result) => !result.isValid);
    });
  }

  Future<List<String>> _getSuggestions(String pattern) async {
    final config = ref.read(configProvider);
    final recentHosts = config.recentHosts ?? [];

    if (pattern.isEmpty) {
      return recentHosts;
    }

    return recentHosts
        .where((host) => host.toLowerCase().contains(pattern.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('Enter Hosts'),
        actions: [
          ToolBarIconButton(
            label: 'Done',
            icon: const MacosIcon(
              CupertinoIcons.check_mark,
              color: CupertinoColors.activeBlue,
            ),
            onPressed:
                _hasError
                    ? null
                    : () {
                      final hosts =
                          _controller.text
                              .split('\n')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList();
                      ref.read(hostsProvider.notifier).state = hosts;

                      // Save to recent hosts
                      final config = ref.read(configProvider);
                      final recentHosts = {
                        ...config.recentHosts ?? [],
                        ...hosts,
                      };
                      ref
                          .read(configProvider.notifier)
                          .updateConfig(
                            config.copyWith(recentHosts: recentHosts.toList()),
                          );

                      Navigator.of(context).pop();
                    },
            showLabel: false,
          ),
        ],
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: null,
                        enableInteractiveSelection: true,
                        cursorColor: MacosTheme.of(context).primaryColor,
                        style: MacosTheme.of(context).typography.body,
                        keyboardAppearance: Brightness.light,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: MacosColors.textBackgroundColor,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  _hasError
                                      ? MacosColors.systemRedColor
                                      : MacosColors.separatorColor,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: MacosColors.separatorColor,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: MacosTheme.of(context).primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          contentPadding: const EdgeInsets.all(8),
                          hintText:
                              'Enter IP addresses, hostnames, or CIDR ranges (one per line)',
                          hintStyle: MacosTheme.of(
                            context,
                          ).typography.body.copyWith(
                            color: MacosColors.placeholderTextColor,
                          ),
                        ),
                      ),
                      suggestionsCallback: _getSuggestions,
                      itemBuilder: (context, suggestion) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            suggestion.toString(),
                            style: MacosTheme.of(context).typography.body,
                          ),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        _controller.text = suggestion.toString();
                      },
                      suggestionsBoxDecoration: SuggestionsBoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        elevation: 4,
                      ),
                    ),
                  ),
                  if (_hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please fix the invalid entries',
                        style: MacosTheme.of(context).typography.body.copyWith(
                          color: MacosColors.systemRedColor,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
