#!/bin/bash
# SSL Certificate Manager
# Version: 1.0.0

set -e

VERSION="1.0.0"
CERT_DIR="${HOME}/.ssl-certs"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Functions
show_help() {
    cat << EOF
SSL Certificate Manager v$VERSION

Usage: ssl-cert <command> [options]

Commands:
    generate <domain> [options]  Generate self-signed certificate
    letsencrypt <domain>          Request Let's Encrypt certificate
    renew <domain>                 Renew certificate
    status <domain>               Check certificate status
    list                           List all managed certificates
    install <domain> <server>     Install certificate for nginx/apache
    check                         Check all certificates for expiration
    revoke <domain>               Revoke Let's Encrypt certificate
    info <certfile>               Show certificate details
    renew-all                     Renew all expiring certificates

Options:
    -h, --help                    Show help
    -v, --version                 Show version
    -d, --days <n>                Certificate validity days (default: 365)
    -k, --key-size <n>            RSA key size (default: 2048)
    -s, --san <domains>           Subject Alternative Names
    -e, --email <email>           Email for Let's Encrypt
    -p, --path <dir>              Output directory
    -f, --force                   Overwrite existing certificate

Examples:
    ssl-cert generate example.com
    ssl-cert generate example.com -s www.example.com,api.example.com
    ssl-cert letsencrypt example.com -e admin@example.com
    ssl-cert status example.com
    ssl-cert install example.com nginx
    ssl-cert check

EOF
}

show_version() {
    echo "ssl-cert v$VERSION"
}

# Ensure cert directory exists
ensure_cert_dir() {
    mkdir -p "$CERT_DIR"
}

# Generate self-signed certificate
generate_cert() {
    local domain="$1"
    shift
    local days=365
    local key_size=2048
    local san=""
    local force=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--days) days="$2"; shift 2 ;;
            -k|--key-size) key_size="$2"; shift 2 ;;
            -s|--san) san="$2"; shift 2 ;;
            -f|--force) force=true; shift ;;
            *) shift ;;
        esac
    done
    
    if [ -z "$domain" ]; then
        echo -e "${RED}Error: Domain required${NC}"
        exit 1
    fi
    
    local cert_path="$CERT_DIR/$domain"
    
    if [ -f "$cert_path/cert.pem" ] && [ "$force" = false ]; then
        echo -e "${YELLOW}Certificate already exists. Use -f to overwrite.${NC}"
        exit 1
    fi
    
    mkdir -p "$cert_path"
    
    echo -e "${BLUE}Generating self-signed certificate for: $domain${NC}"
    
    # Build SAN if provided
    local san_param=""
    if [ -n "$san" ]; then
        san_param="DNS:$domain,DNS:$(echo "$san" | sed 's/,/,\nDNS:/g')"
    else
        san_param="DNS:$domain"
    fi
    
    # Generate private key
    openssl genrsa -out "$cert_path/privkey.pem" "$key_size" 2>/dev/null
    
    # Generate certificate
    openssl req -new -x509 -key "$cert_path/privkey.pem" \
        -out "$cert_path/cert.pem" -days "$days" \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=$domain" \
        -addext "subjectAltName=$san_param" 2>/dev/null
    
    # Save config
    cat > "$cert_path/config.json" << EOF
{
    "domain": "$domain",
    "type": "self-signed",
    "created": "$(date -Iseconds)",
    "expires": "$(date -d "+$days days" -Iseconds)",
    "days": $days,
    "key_size": $key_size,
    "san": "$(echo "$san" | tr ',' ' ')"
}
EOF
    
    echo -e "${GREEN}✓ Private key generated: $cert_path/privkey.pem${NC}"
    echo -e "${GREEN}✓ Certificate generated: $cert_path/cert.pem${NC}"
    echo ""
    echo -e "${CYAN}Certificate details:${NC}"
    echo "  - Domain: $domain"
    echo "  - Valid: $days days"
    echo "  - Key: RSA $key_size-bit"
    if [ -n "$san" ]; then
        echo "  - SAN: $san"
    fi
}

# Show certificate status
show_status() {
    local domain="$1"
    
    if [ -z "$domain" ]; then
        echo -e "${RED}Error: Domain required${NC}"
        exit 1
    fi
    
    local cert_path="$CERT_DIR/$domain"
    
    if [ ! -f "$cert_path/cert.pem" ]; then
        echo -e "${RED}Certificate not found: $domain${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}═══ Certificate Status: $domain ═══${NC}"
    echo ""
    
    # Get certificate info
    local expiry=$(openssl x509 -in "$cert_path/cert.pem" -noout -enddate 2>/dev/null | cut -d= -f2)
    local subject=$(openssl x509 -in "$cert_path/cert.pem" -noout -subject 2>/dev/null)
    local issuer=$(openssl x509 -in "$cert_path/cert.pem" -noout -issuer 2>/dev/null)
    local days_left=$(($(date -d "$expiry" +%s) - $(date +%s) / 86400))
    
    echo -e "${GREEN}Domain:${NC} $domain"
    echo -e "${GREEN}Valid until:${NC} $expiry"
    echo -e "${GREEN}Subject:${NC} $subject"
    echo -e "${GREEN}Issuer:${NC} $issuer"
    
    if [ -f "$cert_path/config.json" ]; then
        local cert_type=$(grep -o '"type": *"[^"]*"' "$cert_path/config.json" | cut -d'"' -f4)
        echo -e "${GREEN}Type:${NC} $cert_type"
    fi
    
    # Check if expiring soon
    local days_remaining=$(( $(date -d "$expiry" +%s) - $(date +%s) ))
    days_remaining=$((days_remaining / 86400))
    
    if [ "$days_remaining" -lt 0 ]; then
        echo -e "${RED}Status: EXPIRED${NC}"
    elif [ "$days_remaining" -lt 30 ]; then
        echo -e "${YELLOW}Status: Expiring soon ($days_remaining days)${NC}"
    else
        echo -e "${GREEN}Status: Valid ($days_remaining days remaining)${NC}"
    fi
}

# List all certificates
list_certs() {
    ensure_cert_dir
    
    echo -e "${BLUE}═══ Managed Certificates ═══${NC}"
    echo ""
    
    local count=0
    for cert_dir in "$CERT_DIR"/*/; do
        if [ -f "$cert_dir/cert.pem" ]; then
            local domain=$(basename "$cert_dir")
            local expiry=$(openssl x509 -in "$cert_dir/cert.pem" -noout -enddate 2>/dev/null | cut -d= -f2)
            local days_remaining=$(( $(date -d "$expiry" +%s) - $(date +%s) ))
            days_remaining=$((days_remaining / 86400))
            
            local status="${GREEN}Valid${NC}"
            if [ "$days_remaining" -lt 0 ]; then
                status="${RED}Expired${NC}"
            elif [ "$days_remaining" -lt 30 ]; then
                status="${YELLOW}Expiring${NC}"
            fi
            
            echo -e "${CYAN}$domain${NC} - $status ($days_remaining days)"
            count=$((count + 1))
        fi
    done
    
    if [ "$count" -eq 0 ]; then
        echo -e "${YELLOW}No certificates found${NC}"
    else
        echo ""
        echo -e "Total: $count certificates"
    fi
}

# Check all certificates
check_certs() {
    ensure_cert_dir
    
    echo -e "${BLUE}═══ Certificate Expiration Check ═══${NC}"
    echo ""
    
    local total=0
    local expiring=0
    local expired=0
    
    for cert_dir in "$CERT_DIR"/*/; do
        if [ -f "$cert_dir/cert.pem" ]; then
            local domain=$(basename "$cert_dir")
            local expiry=$(openssl x509 -in "$cert_dir/cert.pem" -noout -enddate 2>/dev/null | cut -d= -f2)
            local days_remaining=$(( $(date -d "$expiry" +%s) - $(date +%s) ))
            days_remaining=$((days_remaining / 86400))
            
            total=$((total + 1))
            
            if [ "$days_remaining" -lt 0 ]; then
                echo -e "${RED}✗ $domain - EXPIRED ($days_remaining days)${NC}"
                expired=$((expired + 1))
            elif [ "$days_remaining" -lt 30 ]; then
                echo -e "${YELLOW}⚠ $domain - Expiring in $days_remaining days${NC}"
                expiring=$((expiring + 1))
            fi
        fi
    done
    
    echo ""
    echo -e "Total: $total | Expiring: $expiring | Expired: $expired"
    
    if [ "$expired" -gt 0 ] || [ "$expiring" -gt 0 ]; then
        echo -e "${YELLOW}Run 'ssl-cert renew <domain>' to renew${NC}"
    fi
}

# Show certificate info
show_info() {
    local certfile="$1"
    
    if [ -z "$certfile" ]; then
        echo -e "${RED}Error: Certificate file required${NC}"
        exit 1
    fi
    
    if [ ! -f "$certfile" ]; then
        echo -e "${RED}Error: File not found: $certfile${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}═══ Certificate Details ═══${NC}"
    echo ""
    
    openssl x509 -in "$certfile" -noout -text 2>/dev/null | head -30
}

# Install certificate for server
install_cert() {
    local domain="$1"
    local server="$2"
    
    if [ -z "$domain" ] || [ -z "$server" ]; then
        echo -e "${RED}Error: Domain and server required${NC}"
        echo "Usage: ssl-cert install <domain> <nginx|apache>"
        exit 1
    fi
    
    local cert_path="$CERT_DIR/$domain"
    
    if [ ! -f "$cert_path/cert.pem" ]; then
        echo -e "${RED}Certificate not found: $domain${NC}"
        exit 1
    fi
    
    case "$server" in
        nginx)
            cat << EOF

# Nginx configuration for $domain

server {
    listen 443 ssl http2;
    server_name $domain;

    ssl_certificate $cert_path/cert.pem;
    ssl_certificate_key $cert_path/privkey.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    location / {
        root /var/www/html;
        index index.html;
    }
}

EOF
            ;;
        apache)
            cat << EOF

# Apache configuration for $domain

<VirtualHost *:443>
    ServerName $domain
    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile $cert_path/cert.pem
    SSLCertificateKeyFile $cert_path/privkey.pem
    
    <FilesMatch "\.(cgi|shtml|phtml|php)$">
        SSLOptions +StdEnvVars
    </FilesMatch>
</VirtualHost>

EOF
            ;;
        *)
            echo -e "${RED}Unknown server: $server${NC}"
            echo "Supported: nginx, apache"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}Configuration generated. Add to your server config.${NC}"
}

# Request Let's Encrypt certificate (simulated)
request_letsencrypt() {
    local domain="$1"
    local email=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -e|--email) email="$2"; shift 2 ;;
            *) shift ;;
        esac
    done
    
    if [ -z "$domain" ]; then
        echo -e "${RED}Error: Domain required${NC}"
        exit 1
    fi
    
    if [ -z "$email" ]; then
        echo -e "${YELLOW}Warning: No email provided. Using default.${NC}"
        email="admin@$domain"
    fi
    
    echo -e "${YELLOW}Let's Encrypt certificate request for: $domain${NC}"
    echo ""
    echo -e "${YELLOW}Note: This is a simulated implementation.${NC}"
    echo -e "${YELLOW}For production, use certbot:${NC}"
    echo ""
    echo "  sudo certbot certonly --webroot -w /var/www/html -d $domain -d www.$domain --email $email"
    echo ""
    echo -e "${GREEN}After obtaining certificate, place files in:$NC"
    echo "  $CERT_DIR/$domain/"
    echo ""
    echo "Required files:"
    echo "  - fullchain.pem (certificate + chain)"
    echo "  - privkey.pem (private key)"
}

# Renew certificate (simulated)
renew_cert() {
    local domain="$1"
    
    if [ -z "$domain" ]; then
        echo -e "${RED}Error: Domain required${NC}"
        exit 1
    fi
    
    local cert_path="$CERT_DIR/$domain"
    
    if [ ! -f "$cert_path/cert.pem" ]; then
        echo -e "${RED}Certificate not found: $domain${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Renewing certificate for: $domain${NC}"
    echo ""
    echo -e "${YELLOW}For Let's Encrypt, run:${NC}"
    echo "  sudo certbot renew --cert-name $domain"
    echo ""
    echo -e "${YELLOW}For self-signed, generate new one:${NC}"
    echo "  ssl-cert generate $domain --force"
}

# Main command handler
case "${1:-help}" in
    -h|--help)
        show_help
        ;;
    -v|--version)
        show_version
        ;;
    generate)
        ensure_cert_dir
        generate_cert "$2" "${@:3}"
        ;;
    letsencrypt|le)
        request_letsencrypt "$2" "${@:3}"
        ;;
    renew)
        renew_cert "$2"
        ;;
    status)
        show_status "$2"
        ;;
    list)
        list_certs
        ;;
    check)
        check_certs
        ;;
    info)
        show_info "$2"
        ;;
    install)
        install_cert "$2" "$3"
        ;;
    renew-all)
        check_certs
        ;;
    *)
        show_help
        ;;
esac
