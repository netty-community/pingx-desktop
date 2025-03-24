import 'package:flutter_test/flutter_test.dart';
import 'package:pingx_flutter/utils/validation.dart';

void main() {
  group('InputValidator', () {
    group('validateInput', () {
      test('should validate IPv4 addresses', () {
        // Valid IPv4 addresses
        expect(InputValidator.validateInput('192.168.1.1').isValid, true);
        expect(InputValidator.validateInput('192.168.1.1').type, 'ipv4');
        expect(InputValidator.validateInput('10.0.0.1').isValid, true);
        expect(InputValidator.validateInput('172.16.254.1').isValid, true);
        expect(InputValidator.validateInput('0.0.0.0').isValid, true);
        expect(InputValidator.validateInput('255.255.255.255').isValid, true);

        // Invalid IPv4 addresses
        expect(InputValidator.validateInput('256.1.2.3').isValid, false);
        expect(InputValidator.validateInput('1.2.3.256').isValid, false);
        expect(InputValidator.validateInput('192.168.1').isValid, false);
        expect(InputValidator.validateInput('192.168.1.1.1').isValid, false);
        expect(InputValidator.validateInput('192.168.1.').isValid, false);
        expect(InputValidator.validateInput('192.168').isValid, false);
        expect(InputValidator.validateInput('192').isValid, false);
        
        // Check error messages
        expect(InputValidator.validateInput('192.168.1').error, 'Invalid IPv4 address. Example: 192.168.1.1');
        expect(InputValidator.validateInput('192.168.1').type, 'invalid');
      });

      test('should validate IPv6 addresses', () {
        // Valid IPv6 addresses
        expect(
          InputValidator.validateInput(
            '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
          ).isValid,
          true,
        );
        expect(
          InputValidator.validateInput(
            '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
          ).type,
          'ipv6',
        );
        expect(InputValidator.validateInput('2001:db8::1').isValid, true);
        expect(InputValidator.validateInput('::1').isValid, true);
        expect(InputValidator.validateInput('fe80::1').isValid, true);

        // Invalid IPv6 addresses
        expect(
          InputValidator.validateInput(
            '2001:0db8:85a3:0000:0000:8a2e:0370:7334:',
          ).isValid,
          false,
        );
        expect(
          InputValidator.validateInput(
            '2001:0db8:85a3:0000:0000:8a2e:0370',
          ).isValid,
          false,
        );
        expect(
          InputValidator.validateInput(
            'gggg:0db8:85a3:0000:0000:8a2e:0370:7334',
          ).isValid,
          false,
        );
      });

      test('should validate FQDN', () {
        // Valid FQDNs
        expect(InputValidator.validateInput('google.com').isValid, true);
        expect(InputValidator.validateInput('google.com').type, 'fqdn');
        expect(InputValidator.validateInput('sub.example.com').isValid, true);
        expect(InputValidator.validateInput('test-domain.com').isValid, true);
        expect(InputValidator.validateInput('a.b.c.d.com').isValid, true);

        // Invalid FQDNs
        expect(InputValidator.validateInput('google').isValid, false);
        expect(InputValidator.validateInput('.com').isValid, false);
        expect(InputValidator.validateInput('test@domain.com').isValid, false);
        expect(InputValidator.validateInput('domain..com').isValid, false);
      });

      test('should validate CIDR notation', () {
        // Valid CIDR
        expect(InputValidator.validateInput('192.168.1.0/24').isValid, true);
        expect(InputValidator.validateInput('192.168.1.0/24').type, 'cidr');
        expect(InputValidator.validateInput('10.0.0.0/8').isValid, true);
        expect(InputValidator.validateInput('172.16.0.0/12').isValid, true);
        expect(InputValidator.validateInput('2001:db8::/32').isValid, true);

        // Invalid CIDR
        expect(InputValidator.validateInput('192.168.1.0/33').isValid, false);
        expect(InputValidator.validateInput('192.168.1.0/').isValid, false);
        expect(InputValidator.validateInput('192.168.1/24').isValid, false);
        expect(InputValidator.validateInput('2001:db8::/129').isValid, false);
      });
    });

    group('expandCIDR', () {
      test('should expand IPv4 CIDR correctly', () {
        // Test /30 network (4 addresses)
        final expanded = InputValidator.expandCIDR(
          '192.168.1.0/30',
          skipFirstAddress: false,
          skipLastAddress: false,
        );
        expect(expanded.length, equals(4));
        expect(
          expanded,
          containsAll([
            '192.168.1.0',
            '192.168.1.1',
            '192.168.1.2',
            '192.168.1.3',
          ]),
        );

        // Test with skipping first and last
        final expandedSkipped = InputValidator.expandCIDR('192.168.1.0/30');
        expect(expandedSkipped.length, equals(2));
        expect(expandedSkipped, containsAll(['192.168.1.1', '192.168.1.2']));

        // Test /31 network (2 addresses)
        final expanded31 = InputValidator.expandCIDR(
          '192.168.1.0/31',
          skipFirstAddress: false,
          skipLastAddress: false,
        );
        expect(expanded31.length, equals(2));
        expect(expanded31, containsAll(['192.168.1.0', '192.168.1.1']));

        // Test /32 network (1 address)
        final expanded32 = InputValidator.expandCIDR(
          '192.168.1.0/32',
          skipFirstAddress: false,
          skipLastAddress: false,
        );
        expect(expanded32.length, equals(1));
        expect(expanded32, contains('192.168.1.0'));
      });
    });

    group('validateInputs', () {
      test('should validate multiple inputs', () {
        final results = InputValidator.validateInputs('192.168.1.1\ngoogle.com\n2001:db8::1\n192.168.0.0/24\ninvalid@input\n');

        // Remove empty lines from results
        final nonEmptyResults = results.where((r) => r.error != 'Please enter a valid IP address, hostname, or CIDR range').toList();

        expect(nonEmptyResults.length, equals(5));
        expect(nonEmptyResults[0].isValid, true);
        expect(nonEmptyResults[0].type, 'ipv4');
        expect(nonEmptyResults[1].isValid, true);
        expect(nonEmptyResults[1].type, 'fqdn');
        expect(nonEmptyResults[2].isValid, true);
        expect(nonEmptyResults[2].type, 'ipv6');
        expect(nonEmptyResults[3].isValid, true);
        expect(nonEmptyResults[3].type, 'cidr');
        expect(nonEmptyResults[4].isValid, false);
        expect(nonEmptyResults[4].type, 'invalid');
      });

      test('should handle empty and whitespace inputs', () {
        // Empty or whitespace lines are filtered out
        expect(InputValidator.validateInputs('').length, equals(0));
        expect(InputValidator.validateInputs('  ').length, equals(0));
        expect(InputValidator.validateInputs('\n\n').length, equals(0));

        // Null input returns a single invalid result
        final nullResults = InputValidator.validateInputs(null);
        expect(nullResults.length, equals(1));
        expect(nullResults[0].isValid, false);
        expect(nullResults[0].type, 'invalid');
      });
    });
  });
}
