import 'dart:io';

class ValidationResult {
  final bool isValid;
  final String? error;
  final String type; // 'ipv4', 'ipv6', 'fqdn', 'cidr'

  ValidationResult({required this.isValid, this.error, required this.type});
}

class InputValidator {
  static final RegExp _ipv4Regex = RegExp(
    r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
  );

  static final RegExp _ipv6Regex = RegExp(
    r'^(?:(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|(?:[0-9a-fA-F]{1,4}:){1,7}:|(?:[0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|(?:[0-9a-fA-F]{1,4}:){1,5}(?::[0-9a-fA-F]{1,4}){1,2}|(?:[0-9a-fA-F]{1,4}:){1,4}(?::[0-9a-fA-F]{1,4}){1,3}|(?:[0-9a-fA-F]{1,4}:){1,3}(?::[0-9a-fA-F]{1,4}){1,4}|(?:[0-9a-fA-F]{1,4}:){1,2}(?::[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:(?:(?::[0-9a-fA-F]{1,4}){1,6})|:(?:(?::[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(?::[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(?:ffff(?::0{1,4}){0,1}:){0,1}(?:(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9])|(?:[0-9a-fA-F]{1,4}:){1,4}:(?:(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$',
  );

  static final RegExp _fqdnRegex = RegExp(
    r'^(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$',
  );

  static final RegExp _cidrRegex = RegExp(
    r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\/(?:[0-9]|[1-2][0-9]|3[0-2])$|^(?:(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|(?:[0-9a-fA-F]{1,4}:){1,7}:|(?:[0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|(?:[0-9a-fA-F]{1,4}:){1,5}(?::[0-9a-fA-F]{1,4}){1,2}|(?:[0-9a-fA-F]{1,4}:){1,4}(?::[0-9a-fA-F]{1,4}){1,3}|(?:[0-9a-fA-F]{1,4}:){1,3}(?::[0-9a-fA-F]{1,4}){1,4}|(?:[0-9a-fA-F]{1,4}:){1,2}(?::[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:(?:(?::[0-9a-fA-F]{1,4}){1,6})|:(?:(?::[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(?::[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(?:ffff(?::0{1,4}){0,1}:){0,1}(?:(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9])|(?:[0-9a-fA-F]{1,4}:){1,4}:(?:(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9]))\/(?:[0-9]|[1-9][0-9]|1[0-1][0-9]|12[0-8])$',
  );

  static ValidationResult validateInput(String? input) {
    if (input == null) {
      return ValidationResult(
        isValid: false,
        error: 'Input cannot be null',
        type: 'invalid',
      );
    }

    input = input.trim();

    if (input.isEmpty) {
      return ValidationResult(
        isValid: false,
        error: 'Please enter a valid IP address, hostname, or CIDR range',
        type: 'invalid',
      );
    }

    // Check for CIDR notation first
    if (_cidrRegex.hasMatch(input)) {
      final parts = input.split('/');
      final prefix = int.parse(parts[1]);
      if (input.contains('.')) {
        // IPv4 CIDR
        if (prefix > 32) {
          return ValidationResult(
            isValid: false,
            error: 'Invalid IPv4 CIDR prefix (must be 0-32)',
            type: 'cidr',
          );
        }
      } else {
        // IPv6 CIDR
        if (prefix > 128) {
          return ValidationResult(
            isValid: false,
            error: 'Invalid IPv6 CIDR prefix (must be 0-128)',
            type: 'cidr',
          );
        }
      }
      return ValidationResult(isValid: true, type: 'cidr');
    }

    // Check for IPv4
    if (_ipv4Regex.hasMatch(input)) {
      return ValidationResult(isValid: true, type: 'ipv4');
    }

    // Check for IPv6
    if (_ipv6Regex.hasMatch(input)) {
      return ValidationResult(isValid: true, type: 'ipv6');
    }

    // Check for FQDN
    if (_fqdnRegex.hasMatch(input)) {
      return ValidationResult(isValid: true, type: 'fqdn');
    }

    // If none of the above, try to determine what the user was attempting
    String error =
        'Invalid input. Expected IPv4, IPv6, FQDN, or CIDR notation.';
    if (input.contains('/')) {
      error = 'Invalid CIDR notation. Example: 192.168.1.0/24 or 2001:db8::/32';
    } else if (input.contains(':')) {
      error = 'Invalid IPv6 address. Example: 2001:db8::1';
    } else if (input.contains('.')) {
      if (input.split('.').length == 4) {
        error = 'Invalid IPv4 address. Example: 192.168.1.1';
      } else {
        error = 'Invalid FQDN. Example: example.com';
      }
    }

    return ValidationResult(isValid: false, error: error, type: 'invalid');
  }

  static List<ValidationResult> validateInputs(String? inputs) {
    if (inputs == null) {
      return [
        ValidationResult(
          isValid: false,
          error: 'Input cannot be null',
          type: 'invalid',
        ),
      ];
    }

    final lines = inputs.split('\n');
    return lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) => validateInput(line))
        .toList();
  }

  static bool isValidCIDRPrefix(String cidr) {
    final parts = cidr.split('/');
    if (parts.length != 2) return false;

    final prefix = int.tryParse(parts[1]);
    if (prefix == null) return false;

    if (parts[0].contains('.')) {
      // IPv4
      return prefix >= 0 && prefix <= 32;
    } else {
      // IPv6
      return prefix >= 0 && prefix <= 128;
    }
  }

  static List<String> expandCIDR(String cidr) {
    // TODO: Implement CIDR expansion if needed
    return [cidr];
  }
}
