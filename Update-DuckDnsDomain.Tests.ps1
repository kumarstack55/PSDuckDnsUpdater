﻿BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe 'Update-DuckDnsDomain' {
    Context "when executed" {
        BeforeEach {
            Mock Invoke-DuckDnsWebRequest {
                $lines = @("OK", "203.0.113.1", "", "NOCHANGE")
                $body = $lines -join "\n"
                return $body
            } -Verifiable
            $domain = "dummy-domain"
            $token = "dummy-token-488b-88a0-7659ae0f147a"
            $actual = Update-DuckDnsDomain -Domain $domain -Token $token

            # Ignore warnings about unused variables.
            $actual | Out-Null
        }
        It "calls functions" {
            Should -InvokeVerifiable
        }
        It "calls Invoke-DuckDnsWebRequest with the specified arguments" {
            Assert-MockCalled -CommandName Invoke-DuckDnsWebRequest -Exactly 1 -ParameterFilter {
                $Uri -ceq "https://www.duckdns.org/update?domains=dummy-domain&token=dummy-token-488b-88a0-7659ae0f147a&verbose=true"
            }
        }
        It "returns results" {
            $lines = @("OK", "203.0.113.1", "", "NOCHANGE")
            $expected = $lines -join "\n"
            $actual | Should -Be $expected
        }
    }
}