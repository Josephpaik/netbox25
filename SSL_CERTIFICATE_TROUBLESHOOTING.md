# SSL Certificate Error Troubleshooting Guide

This guide helps you resolve SSL certificate verification errors when installing NetBox in environments with custom certificate authorities (such as corporate proxies or lab environments).

## Problem

When running `pip install -r requirements.txt`, you encounter errors like:

```
SSLError(SSLCertVerificationError('"mirror-lab-imCA" certificate is not trusted'))
```

This occurs because your system uses a custom Certificate Authority (CA) that Python's pip doesn't recognize.

## Solutions

Choose the solution that best fits your environment and security requirements:

---

## Solution 1: Configure pip to Trust Custom CA (Recommended)

This is the most secure approach as it maintains SSL verification while trusting your custom CA.

### Step 1: Locate Your Custom CA Certificate

Find where your custom CA certificate is stored:

```bash
# Check environment variables
echo $SSL_CERT_FILE
echo $CURL_CA_BUNDLE
echo $REQUESTS_CA_BUNDLE

# Common locations on macOS
ls /etc/ssl/certs/
ls /usr/local/share/ca-certificates/
```

### Step 2: Configure pip to Use the CA Certificate

Create or edit `~/.pip/pip.conf`:

```bash
mkdir -p ~/.pip
cat > ~/.pip/pip.conf << 'EOF'
[global]
cert = /etc/ssl/certs/ca-certificates.crt
EOF
```

Or specify a different path if your CA certificate is elsewhere:

```bash
cat > ~/.pip/pip.conf << 'EOF'
[global]
cert = /path/to/your/custom-ca-bundle.crt
EOF
```

### Step 3: Test the Configuration

```bash
pip install --upgrade pip
```

---

## Solution 2: Use pip with Trusted Host Flag (Quick Fix)

This bypasses SSL verification for specific hosts. Less secure but quick for testing.

### For Single Command:

```bash
pip install -r requirements.txt --trusted-host pypi.org --trusted-host files.pythonhosted.org
```

### Make it Permanent:

Add to `~/.pip/pip.conf`:

```bash
mkdir -p ~/.pip
cat > ~/.pip/pip.conf << 'EOF'
[global]
trusted-host = pypi.org
               files.pythonhosted.org
               pypi.python.org
EOF
```

Then install normally:

```bash
pip install -r requirements.txt
```

---

## Solution 3: Disable SSL Verification Globally (Not Recommended)

⚠️ **Warning**: This disables all SSL verification and should only be used temporarily in trusted networks.

### Environment Variable Method:

```bash
# For current session only
export PYTHONHTTPSVERIFY=0
export CURL_CA_BUNDLE=""
export REQUESTS_CA_BUNDLE=""

pip install -r requirements.txt
```

### pip Configuration Method:

```bash
mkdir -p ~/.pip
cat > ~/.pip/pip.conf << 'EOF'
[global]
trusted-host = *
[install]
trusted-host = *
EOF
```

---

## Solution 4: Install Custom CA Certificate System-Wide (macOS)

This makes your custom CA trusted by all applications on macOS.

### Step 1: Export the Custom CA Certificate

If you have the certificate file (`.crt`, `.pem`, or `.cer`):

```bash
# If you need to export from your system
# Open Keychain Access → System → Find your CA → Export
```

### Step 2: Install the Certificate

```bash
# Open the certificate file
open /path/to/mirror-lab-imCA.crt

# Or use command line
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /path/to/mirror-lab-imCA.crt
```

### Step 3: Verify Installation

```bash
# Check if certificate is trusted
security find-certificate -a -c "mirror-lab-imCA" /Library/Keychains/System.keychain
```

### Step 4: Update Python's Certificate Store

```bash
# Install certifi and update certificates
pip install --upgrade certifi

# Find certifi's CA bundle location
python3 -c "import certifi; print(certifi.where())"

# Append your custom CA to certifi's bundle
cat /path/to/mirror-lab-imCA.crt >> $(python3 -c "import certifi; print(certifi.where())")
```

---

## Solution 5: Use Alternative Package Index

If your organization provides an internal PyPI mirror, configure pip to use it:

```bash
mkdir -p ~/.pip
cat > ~/.pip/pip.conf << 'EOF'
[global]
index-url = http://your-internal-pypi.company.com/simple/
trusted-host = your-internal-pypi.company.com
EOF
```

---

## Verification

After applying any solution, verify it works:

```bash
# Test with a small package
pip install colorama

# If successful, install NetBox requirements
pip install -r requirements.txt
```

---

## Troubleshooting

### Check Current pip Configuration

```bash
pip config list
pip config debug
```

### Check SSL Certificate Chain

```bash
openssl s_client -connect pypi.org:443 -showcerts
```

### Test Python SSL

```python
import ssl
import certifi

print("SSL Version:", ssl.OPENSSL_VERSION)
print("Certifi Location:", certifi.where())

# Test connection
import urllib.request
try:
    urllib.request.urlopen('https://pypi.org')
    print("✓ SSL connection successful")
except Exception as e:
    print("✗ SSL connection failed:", e)
```

### Reset pip Configuration

If you need to start fresh:

```bash
rm -f ~/.pip/pip.conf
rm -f ~/Library/Application\ Support/pip/pip.conf  # macOS specific
```

---

## Environment-Specific Notes

### Corporate/Lab Networks

If you're behind a corporate proxy or using a lab mirror:

1. **Contact your IT department** for the custom CA certificate
2. Ask if there's an internal PyPI mirror you should use
3. Check if they have specific Python/pip configuration guidelines

### Docker/Container Environments

If running in a container, you may need to:

```dockerfile
# Add custom CA to container
COPY custom-ca.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

# Or set environment variable
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
```

---

## Quick Reference

| Solution | Security | Difficulty | Use Case |
|----------|----------|------------|----------|
| Solution 1: Configure CA | High | Medium | Production, permanent fix |
| Solution 2: Trusted Host | Medium | Easy | Quick testing |
| Solution 3: Disable SSL | Low | Easy | Last resort, temporary only |
| Solution 4: System-wide CA | High | Medium | Multiple applications need it |
| Solution 5: Alt Index | High | Easy | Internal mirror available |

---

## Additional Resources

- [pip User Guide - SSL Certificate Verification](https://pip.pypa.io/en/stable/topics/https-certificates/)
- [Python Requests - SSL Cert Verification](https://requests.readthedocs.io/en/latest/user/advanced/#ssl-cert-verification)
- [certifi Documentation](https://github.com/certifi/python-certifi)

---

## For NetBox Installation

After resolving SSL issues, continue with NetBox installation:

1. Follow the steps in `MACBOOK_INSTALL_GUIDE.md`
2. Or run the automated script: `./setup_macos.sh`

If you encounter the SSL error during setup, the script will be updated to handle it automatically.
