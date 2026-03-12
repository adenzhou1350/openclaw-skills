# SSL Certificate Manager

Manage SSL/TLS certificates with ease. Support for Let's Encrypt, self-signed certificates, and commercial CAs.

## Features

- Generate self-signed certificates
- Request Let's Encrypt certificates (ACME v2)
- Auto-renewal with cron
- Certificate status monitoring
- Multiple domain support (SAN)
- Certificate chain management
- SSL configuration for popular servers (nginx, apache, etc.)
- Expiration alerts

## Commands

| Command | Description |
|---------|-------------|
| `generate <domain> [options]` | Generate self-signed certificate |
| `letsencrypt <domain>` | Request Let's Encrypt certificate |
| `renew <domain>` | Renew certificate |
| `status <domain>` | Check certificate status |
| `list` | List all managed certificates |
| `install <domain> <server>` | Install certificate for nginx/apache |
| `check` | Check all certificates for expiration |
| `revoke <domain>` | Revoke Let's Encrypt certificate |
| `info <certfile>` | Show certificate details |

## Usage Examples

```bash
# Generate self-signed certificate
ssl-cert generate example.com

# Generate with SAN (Multiple domains)
ssl-cert generate example.com -s www.example.com,api.example.com

# Request Let's Encrypt certificate
ssl-cert letsencrypt example.com

# Check certificate status
ssl-cert status example.com

# Install for nginx
ssl-cert install example.com nginx

# Check all certificates
ssl-cert check

# Auto-renewal setup
ssl-cert renew --setup-cron
```

## Installation

```bash
chmod +x ssl-cert-manager.sh
sudo ln -s $(pwd)/ssl-cert-manager.sh /usr/local/bin/ssl-cert
```

## Options

| Option | Description |
|--------|-------------|
| `-d, --days` | Certificate validity days (default: 365) |
| `-k, --key-size` | RSA key size (default: 2048) |
| `-s, --san` | Subject Alternative Names (comma-separated) |
| `-e, --email` | Email for Let's Encrypt |
| `-p, --path` | Output directory |
| `-f, --force` | Overwrite existing certificate |

## Certificate Storage

Default directory: `~/.ssl-certs/`

```
~/.ssl-certs/
├── example.com/
│   ├── fullchain.pem
│   ├── privkey.pem
│   ├── cert.pem
│   ├── chain.pem
│   └── config.json
└── example.org/
    └── ...
```

## Output Examples

### Certificate Status
```
Domain: example.com
Status: Valid
Valid from: 2026-01-01 to 2026-04-01 (90 days remaining)
Issuer: Let's Encrypt
SAN: example.com, www.example.com
Auto-renew: Enabled (renews in 30 days)
```

### Generate Self-Signed
```
✓ Private key generated: example.com/privkey.pem
✓ Certificate generated: example.com/cert.pem
✓ Full chain generated: example.com/fullchain.pem
✓ Certificate details:
  - Subject: CN=example.com
  - Valid: 365 days
  - Key: RSA 2048-bit
```
