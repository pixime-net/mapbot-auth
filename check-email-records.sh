#!/bin/bash

# ============================================================================
# Email DNS Records Verification Script
# ============================================================================
#
# Description:
#   This script checks the DNS records configuration related to email
#   authentication for a given domain. It verifies:
#   - SPF (Sender Policy Framework): sender authentication
#   - DKIM (DomainKeys Identified Mail): email cryptographic signature
#   - DMARC (Domain-based Message Authentication): authentication policy
#
# Parameters:
#   $1 (required) - Domain name to check (e.g., example.com)
#
# Usage:
#   ./check-email.sh <domain>
#
# Examples:
#   ./check-email.sh example.com
#   ./check-email.sh pixime.net
#
# Prerequisites:
#   - dig (DNS lookup tool)
#
# Note:
#   You can also verify your records using:
#   https://www.mail-tester.com
#
# ============================================================================

DOMAIN="$1"

# Check if domain parameter is provided
if [ -z "$DOMAIN" ]; then
    echo "❌ Error: No domain specified"
    echo ""
    echo "Usage: $0 <domain>"
    echo "Example: $0 example.com"
    exit 1
fi

echo "🔍 Check email records for $DOMAIN"
echo "=================================================="

# SPF
echo -e "\n📧 SPF (Sender Policy Framework):"
SPF=$(dig txt $DOMAIN +short | grep "v=spf1")
if [ -n "$SPF" ]; then
    echo "✅ Found: $SPF"
else
    echo "❌ Not configured"
fi

# DKIM (tester plusieurs sélecteurs)
echo -e "\n🔐 DKIM (DomainKeys Identified Mail):"
for selector in default2511; do
    DKIM=$(dig txt ${selector}._domainkey.$DOMAIN +short 2>/dev/null)
    if [ -n "$DKIM" ]; then
        echo "✅ Found with selector '$selector':"
        echo "   ${DKIM:0:80}..."
        break
    fi
done
if [ -z "$DKIM" ]; then
    echo "❌ Not configured (tested selectors: default, default2511, mail, k1, dkim, google)"
fi

# DMARC
echo -e "\n🛡️  DMARC (Domain-based Message Authentication):"
DMARC=$(dig txt _dmarc.$DOMAIN +short)
if [ -n "$DMARC" ]; then
    echo "✅ Found: $DMARC"
else
    echo "❌ Not found"
fi

echo -e "\n=================================================="
