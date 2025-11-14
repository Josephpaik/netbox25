# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About NetBox

NetBox is a Django-based web application for network infrastructure management (IPAM/DCIM). It serves as the source of truth for network infrastructure, providing a comprehensive and inter-linked data model for network primitives like devices, racks, cables, IP addresses, VLANs, circuits, power distribution, VPNs, and more.

**Tech Stack**: Python 3.10+ (supports 3.10, 3.11, 3.12), Django 5.2.7, PostgreSQL, Redis, Django REST Framework 3.16.1, Strawberry GraphQL 0.283.3, TypeScript, Vue.js

**NetBox Version**: 4.4.4

## Repository-Specific Features

This repository (Josephpaik/netbox25) is a fork of the official NetBox repository with additional features:

### 1. Korean Localization (한글화)
- **Korean interface translations** in `netbox/translations/`
- Korean documentation files:
  - `QUICKSTART_CHECKLIST.md` - Korean installation and setup checklist
  - `MACBOOK_INSTALL_GUIDE.md` - Detailed macOS installation guide in Korean
- Korean language support enabled by default in the interface
- Account details and menu items translated to Korean

### 2. IDC Scenario Simulation
Located in `idc_scenario/` directory, this feature provides:
- **Realistic test data** for a data center scenario (SMS Pangyo facility)
- **12 CSV templates** for sequential data import:
  1. Sites (사이트)
  2. Manufacturers (제조사)
  3. Device Roles (장비 역할)
  4. Device Types (장비 모델)
  5. Locations (위치/층)
  6. Racks (랙/캐비넷)
  7. Devices - Datacenter (데이터센터 서버 ~60대)
  8. Devices - Test products (테스트 제품)
  9. Interfaces (네트워크 인터페이스)
  10. VLANs
  11. Prefixes (IP 대역)
  12. IP Addresses (IP 주소)
- **Complete documentation**:
  - `idc_scenario/README.md` - Overview and import/export guide
  - `idc_scenario/SUMMARY.md` - Scenario summary
  - `idc_scenario/USAGE_GUIDE.md` - Detailed usage guide
- **Python upload script**: `idc_scenario/upload_script.py` for automated bulk import

### 3. Automated Setup Scripts
- **`setup_macos.sh`**: Automated installation script for macOS
  - Installs Homebrew, Python 3.11, PostgreSQL, Redis
  - Creates and configures NetBox database
  - Sets up Python virtual environment
  - Configures NetBox settings automatically
  - Creates superuser and collects static files
  - One-command setup for development environment

- **`setup_rocky.sh`**: Automated installation script for Rocky Linux
  - Similar functionality for Rocky Linux/RHEL-based systems
  - Production-ready configuration
  - Includes firewall and SELinux configuration

### 4. Additional Documentation
- Comprehensive Korean guides for non-English users
- Step-by-step checklists for installation and data population
- Real-world IDC scenario for learning and testing

## Development Commands

### Quick Start (Automated Setup)

For the fastest setup, use the automated installation scripts:

#### macOS
```bash
# One-command automated setup
./setup_macos.sh

# After installation completes:
source venv/bin/activate
python netbox/manage.py runserver

# Access at http://localhost:8000/
# Default credentials: admin / admin123
```

#### Rocky Linux / RHEL
```bash
# Automated setup for production
sudo ./setup_rocky.sh

# Start services
sudo systemctl start netbox netbox-rq
```

See `MACBOOK_INSTALL_GUIDE.md` (Korean) or `QUICKSTART_CHECKLIST.md` for detailed installation steps.

### Initial Setup (Manual)
```bash
# Install Python dependencies
pip install -r requirements.txt

# Copy and configure settings (edit with your SECRET_KEY, ALLOWED_HOSTS, DB, REDIS)
cp netbox/netbox/configuration_example.py netbox/netbox/configuration.py

# Run database migrations
python netbox/manage.py migrate

# Create superuser
python netbox/manage.py createsuperuser

# Collect static files
python netbox/manage.py collectstatic --no-input

# Run development server
python netbox/manage.py runserver
```

### Testing
```bash
# Run all tests
python netbox/manage.py test netbox/

# Run tests in parallel
python netbox/manage.py test netbox/ --parallel

# Run tests with coverage
coverage run --source="netbox/" netbox/manage.py test netbox/ --parallel
coverage report --skip-covered --omit '*/migrations/*,*/tests/*'

# Run tests for a specific app
python netbox/manage.py test netbox/ipam/tests/

# Run a single test file
python netbox/manage.py test netbox.ipam.tests.test_models

# Run a specific test class
python netbox/manage.py test netbox.ipam.tests.test_models.PrefixTestCase

# Run a specific test method
python netbox/manage.py test netbox.ipam.tests.test_models.PrefixTestCase.test_method_name
```

### Code Quality
```bash
# Run Python linting (PEP 8 compliance, line length 120)
ruff check netbox/

# Check for missing migrations
python netbox/manage.py makemigrations --check

# Frontend validation (ESLint, TypeScript, Prettier)
yarn --cwd netbox/project-static validate

# Verify static asset integrity
scripts/verify-bundles.sh
```

### Frontend Development
```bash
# Install frontend dependencies
yarn --cwd netbox/project-static install

# Build frontend assets
yarn --cwd netbox/project-static build

# Development mode with watch
yarn --cwd netbox/project-static dev
```

### Management Commands
```bash
# Interactive NetBox shell (like Django shell with pre-loaded models)
python netbox/manage.py nbshell

# Run RQ worker for background jobs
python netbox/manage.py rqworker

# Run a custom script
python netbox/manage.py runscript <script_name>

# Sync data from a DataSource
python netbox/manage.py syncdatasource <datasource_name>

# Perform housekeeping tasks (cleanup old records)
python netbox/manage.py housekeeping

# Reindex search database
python netbox/manage.py reindex

# Rebuild IP prefix hierarchy
python netbox/manage.py rebuild_prefixes

# Calculate cached counter values
python netbox/manage.py calculate_cached_counts

# Trace cable paths
python netbox/manage.py trace_paths
```

### IDC Scenario Data Import

This repository includes realistic test data for a data center scenario. To populate NetBox with this test data:

#### Option 1: Web UI Import (Recommended for learning)
```bash
# 1. Start NetBox
python netbox/manage.py runserver

# 2. Login to http://localhost:8000/ (admin / admin123)

# 3. Import CSV files in order via Web UI:
#    DCIM > Sites > Import -> upload idc_scenario/csv_templates/01_sites.csv
#    DCIM > Device Types > Manufacturers > Import -> upload 02_manufacturers.csv
#    ... continue in sequence through 12_ip_addresses.csv

# See idc_scenario/README.md for detailed import instructions
```

#### Option 2: Automated Import Script
```bash
# Use the Python bulk import script
cd idc_scenario
python upload_script.py

# This will automatically import all CSV files in the correct order
# Requires NetBox to be running and API token configured
```

#### Data Included
- **1 Site**: SMS Pangyo facility (9-story building)
- **4 Locations**: B1F-DataCenter, 3F/4F/5F-TestLab
- **12 Racks**: 42U cabinets in the data center
- **~60 Devices**: Servers, switches, firewalls
- **Network Configuration**: VLANs, IP prefixes, assigned IPs
- **Complete topology**: Realistic IDC infrastructure

See `idc_scenario/README.md` and `idc_scenario/USAGE_GUIDE.md` for complete documentation.

### Documentation
```bash
# Build documentation (MkDocs)
mkdocs build

# Serve documentation locally
mkdocs serve
```

---

## High-Level Architecture

### Core Django Apps Structure

NetBox is organized into 11 core Django apps under `netbox/`:

- **account**: Authentication, login/logout, OAuth integration
- **circuits**: Provider circuits and circuit terminations management
- **core**: Central infrastructure (ObjectType, ObjectChange changelog, DataFile, ManagedFile, Jobs)
- **dcim**: Data Center Infrastructure Management (Sites, Racks, Devices, Cables, Power, Modules)
- **extras**: Extensibility features (CustomFields, Tags, Scripts, EventRules, Webhooks, Dashboards)
- **ipam**: IP Address Management (Prefixes, IPs, VRFs, VLANs, ASNs, FHRPs, Services)
- **tenancy**: Multi-tenancy support (Tenants, Tenant Groups, Contacts)
- **users**: User management and permissions (User, Group, Token)
- **utilities**: Shared utilities (Forms, Views, Tables, Filters, API helpers)
- **virtualization**: Virtual machine management (VMs, Clusters, VM Interfaces)
- **vpn**: VPN configuration (Tunnels, IKE/IPSec configurations)
- **wireless**: Wireless network management (WLANs, Wireless Links)

### Standard App Structure

Each app follows Django's standard structure with NetBox-specific additions:

```
app/
├── __init__.py
├── admin.py                 # Django admin configuration (rarely used)
├── choices.py               # Choice sets for model fields
├── constants.py             # App-level constants
├── models/                  # Data models (often split into multiple files)
│   ├── __init__.py
│   └── *.py                # Individual model definitions
├── forms/                   # Django forms
│   ├── __init__.py
│   ├── bulk_edit.py        # Bulk edit forms
│   ├── bulk_import.py      # CSV import forms
│   ├── filtersets.py       # Filter forms for list views
│   └── model_forms.py      # Create/edit forms
├── tables/                  # django-tables2 table definitions
│   ├── __init__.py
│   └── *.py
├── filtersets.py            # django-filter FilterSet classes
├── graphql/                 # GraphQL schema (Strawberry)
│   ├── __init__.py
│   ├── types.py            # GraphQL type definitions
│   └── filters.py          # GraphQL filter definitions
├── api/                     # REST API
│   ├── __init__.py
│   ├── serializers.py      # DRF serializers
│   ├── views.py            # API ViewSets
│   └── urls.py             # API URL routing
├── views.py                 # Web UI views
├── urls.py                  # Web URL routing
├── search.py                # Search index definitions
├── signals.py               # Django signal handlers
├── navigation.py            # Navigation menu items
├── template_content.py      # Template extensions
├── tests/                   # Test suite
│   ├── __init__.py
│   ├── test_models.py
│   ├── test_views.py
│   ├── test_api.py
│   └── test_filters.py
└── migrations/              # Database migrations
    ├── __init__.py
    └── *.py
```

---

## Detailed Source Code Architecture

### Model Layer

#### Base Model Classes

Located at: `netbox/netbox/models/__init__.py`

**Inheritance Hierarchy**:
```
models.Model (Django)
    └─ NetBoxModel (abstract base for all NetBox models)
        ├─ PrimaryModel (objects with full feature set)
        │   └─ Used by: Device, Site, IPAddress, Prefix, etc.
        ├─ OrganizationalModel (organizational/container objects)
        │   └─ Used by: Region, Manufacturer, DeviceRole, etc.
        ├─ ChangeLoggedModel (minimal change tracking only)
        │   └─ Used by: Tag, CustomField, EventRule, etc.
        └─ NestedGroupModel (hierarchical/tree structures)
            └─ Used by: Region, Location, TenantGroup, etc.
```

**NetBoxModel** provides:
- Custom manager with RestrictedQuerySet
- clone_fields for object cloning
- `clean()` validation framework
- `get_absolute_url()` implementation

**PrimaryModel** adds:
- Inherits all feature mixins (see Model Features section)
- comments field (Markdown support)
- tags support via TaggableManager
- Custom field support
- Full change logging
- GenericRelations for attachments, bookmarks, journal entries, etc.

**Key Model Fields**:
- `created` (DateTimeField, auto_now_add): Timestamp of creation
- `last_updated` (DateTimeField, auto_now): Timestamp of last modification
- `custom_field_data` (JSONField): Stores custom field values
- `description` (CharField): Human-readable description
- `comments` (TextField): Markdown-formatted notes

#### Model Features System

Located at: `netbox/netbox/models/features.py`

NetBox uses mixins to provide cross-cutting concerns. Models inherit the mixins they need:

**ChangeLoggingMixin**: Automatic change tracking
- Fields: `created`, `last_updated`
- Methods:
  - `serialize_object(exclude=None)`: JSON representation for changelog
  - `snapshot()`: Saves pre-change state to `_prechange_snapshot`
  - `to_objectchange(action)`: Creates ObjectChange instance
- Used by: Nearly all models

**CloningMixin**: Object cloning support
- Method: `clone()` returns dict of attrs for duplication
- Reads from model's `clone_fields` attribute
- Used by: Most models

**CustomFieldsMixin**: Dynamic custom field support
- Requires `custom_field_data` JSONField
- Methods:
  - `get_custom_fields()`: Returns applicable CustomField objects
  - `clean()`: Validates custom field data
- GenericRelation to CustomField model
- Used by: Most user-facing models

**TagsMixin**: Flexible tagging
- Adds `tags` TaggableManager (django-taggit)
- Integrates with NetBox Tag model
- Provides tag filtering and display
- Used by: Most organizational models

**CustomLinksMixin**: User-defined external links
- GenericRelation to CustomLink model
- Links displayed in object detail views
- Used by: Most models

**CustomValidationMixin**: User-defined validation
- Validates against CustomValidationRule objects
- Raises ValidationError if rules fail
- Used by: Models requiring custom constraints

**ExportTemplatesMixin**: Jinja2-based data export
- Allows custom export formats (JSON, YAML, XML, etc.)
- Templates render object data
- Used by: Most models

**ImageAttachmentsMixin**: Image attachment support
- GenericRelation to ImageAttachment model
- Display in object detail views
- Used by: Device, DeviceType, Site, etc.

**BookmarksMixin**: User bookmarks
- GenericRelation to Bookmark model
- Per-user object favorites
- Used by: Most models

**JournalingMixin**: Object journal/notes
- GenericRelation to JournalEntry model
- Timestamped notes on objects
- Used by: Most infrastructure models

**ContactsMixin**: Contact associations
- GenericRelation to ContactAssignment model
- Links objects to Contact records
- Used by: Organizational models

**EventRulesMixin**: Event automation triggers
- Enables EventRule triggering on object changes
- Required for webhook/script automation
- Used by: Most models

**JobsMixin**: Background job execution
- GenericRelation to Job model
- Tracks async operations
- Used by: Script, DataSource, etc.

**SyncedDataMixin**: External data synchronization
- Tracks sync state from DataSource
- Fields: data_source, data_file, data_path, auto_sync_enabled
- Used by: ConfigTemplate, ExportTemplate, etc.

**WeightMixin**: Physical weight tracking
- Fields: weight, weight_unit
- Used by: Device, DeviceType, Module

**ContactsMixin**: Contact associations
- M2M relationship to Contact via ContactAssignment
- Role-based contact assignment
- Used by: Site, Manufacturer, Provider, etc.

#### DCIM Models

Located at: `netbox/dcim/models/`

**Device** (`devices.py`):
```python
class Device(
    ImageAttachmentsMixin,
    PrimaryModel,
    WeightMixin,
    ConfigContextModel,
    RenderConfigMixin,
    TrackingModelMixin
):
    # Location
    site = models.ForeignKey('dcim.Site', on_delete=models.PROTECT)
    location = models.ForeignKey('dcim.Location', on_delete=models.PROTECT, null=True, blank=True)
    rack = models.ForeignKey('dcim.Rack', on_delete=models.PROTECT, null=True, blank=True)
    position = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    face = models.CharField(max_length=50, choices=DeviceFaceChoices, blank=True)

    # Type & Configuration
    device_type = models.ForeignKey('dcim.DeviceType', on_delete=models.PROTECT)
    device_role = models.ForeignKey('dcim.DeviceRole', on_delete=models.PROTECT)
    platform = models.ForeignKey('dcim.Platform', on_delete=models.SET_NULL, null=True, blank=True)

    # Identity
    name = models.CharField(max_length=64, unique=True)
    serial = models.CharField(max_length=50, blank=True)
    asset_tag = models.CharField(max_length=50, unique=True, null=True, blank=True)

    # Operational
    status = models.CharField(max_length=50, choices=DeviceStatusChoices, default=DeviceStatusChoices.STATUS_ACTIVE)
    airflow = models.CharField(max_length=50, choices=DeviceAirflowChoices, blank=True)

    # Organization
    tenant = models.ForeignKey('tenancy.Tenant', on_delete=models.PROTECT, null=True, blank=True)

    # Virtualization
    virtual_chassis = models.ForeignKey('dcim.VirtualChassis', on_delete=models.SET_NULL, null=True, blank=True)
    vc_position = models.PositiveSmallIntegerField(null=True, blank=True)
    vc_priority = models.PositiveSmallIntegerField(null=True, blank=True)

    # Configuration context (inherited from ConfigContextModel)
    local_context_data = models.JSONField(blank=True, null=True)

    # Special methods
    def clean(self):
        # Validates rack position, VC membership, etc.

    @property
    def primary_ip(self):
        # Returns primary IPv4 or IPv6 address

    def get_cables(self, pk_list=False):
        # Returns all connected cables
```

**DeviceType** (`devices.py`):
```python
class DeviceType(ImageAttachmentsMixin, PrimaryModel, WeightMixin):
    manufacturer = models.ForeignKey('dcim.Manufacturer', on_delete=models.PROTECT)
    model = models.CharField(max_length=100)
    slug = models.SlugField(max_length=100)
    part_number = models.CharField(max_length=50, blank=True)
    u_height = models.DecimalField(max_digits=4, decimal_places=1, default=1.0)
    exclude_from_utilization = models.BooleanField(default=False)
    is_full_depth = models.BooleanField(default=True)
    subdevice_role = models.CharField(max_length=50, choices=SubdeviceRoleChoices, blank=True)
    airflow = models.CharField(max_length=50, choices=DeviceAirflowChoices, blank=True)

    # Images
    front_image = models.ImageField(upload_to='devicetype-images', blank=True)
    rear_image = models.ImageField(upload_to='devicetype-images', blank=True)

    # Counter fields (denormalized counts of component templates)
    console_port_template_count = CounterCacheField(to_model='dcim.ConsolePortTemplate')
    power_port_template_count = CounterCacheField(to_model='dcim.PowerPortTemplate')
    interface_template_count = CounterCacheField(to_model='dcim.InterfaceTemplate')
    # ... more counters

    class Meta:
        ordering = ('manufacturer', 'model')
        unique_together = (('manufacturer', 'model'), ('manufacturer', 'slug'))
```

**Site** (`sites.py`):
```python
class Site(ContactsMixin, PrimaryModel):
    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(max_length=100, unique=True)
    status = models.CharField(max_length=50, choices=SiteStatusChoices, default=SiteStatusChoices.STATUS_ACTIVE)
    region = models.ForeignKey('dcim.Region', on_delete=models.SET_NULL, null=True, blank=True)
    group = models.ForeignKey('dcim.SiteGroup', on_delete=models.SET_NULL, null=True, blank=True)
    tenant = models.ForeignKey('tenancy.Tenant', on_delete=models.PROTECT, null=True, blank=True)
    facility = models.CharField(max_length=50, blank=True)
    time_zone = TimeZoneField(blank=True)
    physical_address = models.CharField(max_length=200, blank=True)
    shipping_address = models.CharField(max_length=200, blank=True)
    latitude = models.DecimalField(max_digits=8, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)

    # Reverse relations (not actual fields, but queryable)
    # devices, racks, locations, prefixes, vlans, etc.
```

**Cable** (`cables.py`):
```python
class Cable(PrimaryModel):
    # Terminations (GenericForeignKey to any cable-compatible component)
    termination_a_type = models.ForeignKey('contenttypes.ContentType', on_delete=models.PROTECT, related_name='+')
    termination_a_id = models.PositiveBigIntegerField()
    termination_a = GenericForeignKey('termination_a_type', 'termination_a_id')

    termination_b_type = models.ForeignKey('contenttypes.ContentType', on_delete=models.PROTECT, related_name='+')
    termination_b_id = models.PositiveBigIntegerField()
    termination_b = GenericForeignKey('termination_b_type', 'termination_b_id')

    # Attributes
    type = models.CharField(max_length=50, choices=CableTypeChoices, blank=True)
    status = models.CharField(max_length=50, choices=LinkStatusChoices, default=LinkStatusChoices.STATUS_CONNECTED)
    tenant = models.ForeignKey('tenancy.Tenant', on_delete=models.PROTECT, null=True, blank=True)
    label = models.CharField(max_length=100, blank=True)
    color = ColorField(blank=True)
    length = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)
    length_unit = models.CharField(max_length=50, choices=CableLengthUnitChoices, blank=True)

    # Normalized field for ordering
    _abs_length = models.DecimalField(max_digits=10, decimal_places=4, null=True, blank=True)

    def clean(self):
        # Validates termination compatibility

    def save(self, *args, **kwargs):
        # Calculates _abs_length from length and length_unit
```

**Interface** (`device_components.py`):
```python
class Interface(ModularComponentModel, BaseInterface, PathEndpoint):
    device = models.ForeignKey('dcim.Device', on_delete=models.CASCADE, related_name='interfaces')
    module = models.ForeignKey('dcim.Module', on_delete=models.CASCADE, null=True, blank=True)
    name = models.CharField(max_length=64)
    label = models.CharField(max_length=64, blank=True)
    type = models.CharField(max_length=50, choices=InterfaceTypeChoices)
    enabled = models.BooleanField(default=True)
    parent = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='child_interfaces')
    bridge = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='bridged_interfaces')
    lag = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='member_interfaces')
    mtu = models.PositiveIntegerField(null=True, blank=True)
    mac_address = MACAddressField(null=True, blank=True)
    speed = models.PositiveIntegerField(null=True, blank=True)
    duplex = models.CharField(max_length=50, choices=InterfaceDuplexChoices, blank=True)
    wwn = models.CharField(max_length=18, null=True, blank=True)
    mgmt_only = models.BooleanField(default=False)
    mode = models.CharField(max_length=50, choices=InterfaceModeChoices, blank=True)
    rf_role = models.CharField(max_length=30, choices=WirelessRoleChoices, blank=True)
    rf_channel = models.CharField(max_length=50, choices=WirelessChannelChoices, blank=True)

    # VLANs
    untagged_vlan = models.ForeignKey('ipam.VLAN', on_delete=models.SET_NULL, null=True, blank=True)
    tagged_vlans = models.ManyToManyField('ipam.VLAN', blank=True)

    # VRF
    vrf = models.ForeignKey('ipam.VRF', on_delete=models.SET_NULL, null=True, blank=True)

    # Reverse relations: ip_addresses, member_interfaces, child_interfaces, etc.
```

#### IPAM Models

Located at: `netbox/ipam/models/`

**IPAddress** (`ip.py`):
```python
class IPAddress(PrimaryModel, CachedScopeMixin):
    # Core field
    address = IPAddressField()  # Custom field handling netaddr.IPAddress

    # VRF context
    vrf = models.ForeignKey('ipam.VRF', on_delete=models.PROTECT, null=True, blank=True)

    # Metadata
    tenant = models.ForeignKey('tenancy.Tenant', on_delete=models.PROTECT, null=True, blank=True)
    status = models.CharField(max_length=50, choices=IPAddressStatusChoices, default=IPAddressStatusChoices.STATUS_ACTIVE)
    role = models.CharField(max_length=50, choices=IPAddressRoleChoices, blank=True)

    # Assignment (GenericForeignKey to Interface, VMInterface, or FHRP)
    assigned_object_type = models.ForeignKey('contenttypes.ContentType', on_delete=models.PROTECT, null=True, blank=True)
    assigned_object_id = models.PositiveBigIntegerField(null=True, blank=True)
    assigned_object = GenericForeignKey('assigned_object_type', 'assigned_object_id')

    # NAT
    nat_inside = models.OneToOneField('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='nat_outside')

    # DNS
    dns_name = models.CharField(max_length=255, blank=True)

    # Custom manager
    objects = IPAddressManager()

    class Meta:
        ordering = ('vrf', 'address')
        unique_together = (('vrf', 'address'),)

    def get_duplicates(self):
        # Returns other IPs with same address in VRF

    @property
    def family(self):
        # Returns 4 or 6 for IPv4/IPv6
```

**Prefix** (`ip.py`):
```python
class Prefix(GetAvailablePrefixesMixin, PrimaryModel, CachedScopeMixin):
    # Core field
    prefix = IPNetworkField()  # Custom field handling netaddr.IPNetwork

    # VRF context
    vrf = models.ForeignKey('ipam.VRF', on_delete=models.PROTECT, null=True, blank=True)

    # Organization
    site = models.ForeignKey('dcim.Site', on_delete=models.PROTECT, null=True, blank=True)
    tenant = models.ForeignKey('tenancy.Tenant', on_delete=models.PROTECT, null=True, blank=True)

    # Attributes
    status = models.CharField(max_length=50, choices=PrefixStatusChoices, default=PrefixStatusChoices.STATUS_ACTIVE)
    role = models.ForeignKey('ipam.Role', on_delete=models.SET_NULL, null=True, blank=True)
    is_pool = models.BooleanField(default=False)
    mark_utilized = models.BooleanField(default=False)

    # Custom queryset
    objects = PrefixQuerySet.as_manager()

    class Meta:
        ordering = ('vrf', 'prefix')
        unique_together = (('vrf', 'prefix'),)

    # Methods from GetAvailablePrefixesMixin
    def get_available_prefixes(self):
        # Returns netaddr.IPSet of available child prefixes

    def get_available_ips(self):
        # Returns netaddr.IPSet of available IP addresses

    def get_first_available_ip(self):
        # Returns first available IP address string
```

**VLAN** (`vlans.py`):
```python
class VLAN(PrimaryModel):
    site = models.ForeignKey('dcim.Site', on_delete=models.PROTECT, null=True, blank=True)
    group = models.ForeignKey('ipam.VLANGroup', on_delete=models.PROTECT, null=True, blank=True)
    vid = models.PositiveSmallIntegerField(validators=[MinValueValidator(1), MaxValueValidator(4094)])
    name = models.CharField(max_length=64)
    tenant = models.ForeignKey('tenancy.Tenant', on_delete=models.PROTECT, null=True, blank=True)
    status = models.CharField(max_length=50, choices=VLANStatusChoices, default=VLANStatusChoices.STATUS_ACTIVE)
    role = models.ForeignKey('ipam.Role', on_delete=models.SET_NULL, null=True, blank=True)

    class Meta:
        ordering = ('site', 'group', 'vid')
        unique_together = (
            ('site', 'group', 'vid'),
            ('site', 'group', 'name'),
        )
```

**VRF** (`vrfs.py`):
```python
class VRF(PrimaryModel):
    name = models.CharField(max_length=100, unique=True)
    rd = models.CharField(max_length=21, unique=True, blank=True, null=True)  # Route distinguisher
    tenant = models.ForeignKey('tenancy.Tenant', on_delete=models.PROTECT, null=True, blank=True)
    enforce_unique = models.BooleanField(default=True)
    description = models.CharField(max_length=200, blank=True)

    # Import/export route targets
    import_targets = models.ManyToManyField('ipam.RouteTarget', blank=True, related_name='importing_vrfs')
    export_targets = models.ManyToManyField('ipam.RouteTarget', blank=True, related_name='exporting_vrfs')
```

#### Extras Models

Located at: `netbox/extras/models/`

**CustomField** (`customfields.py`):
```python
class CustomField(CloningMixin, ExportTemplatesMixin, ChangeLoggedModel):
    # Applicability
    object_types = models.ManyToManyField('contenttypes.ContentType', related_name='custom_fields')

    # Field definition
    type = models.CharField(max_length=50, choices=CustomFieldTypeChoices, default=CustomFieldTypeChoices.TYPE_TEXT)
    related_object_type = models.ForeignKey('contenttypes.ContentType', on_delete=models.PROTECT, null=True, blank=True)
    name = models.CharField(max_length=50, unique=True, validators=[
        RegexValidator(regex=r'^[a-z0-9_]+$', message="Only alphanumeric and underscores"),
        RegexValidator(regex=r'__', message="Double underscores not permitted", inverse_match=True)
    ])
    label = models.CharField(max_length=50, blank=True)
    group_name = models.CharField(max_length=50, blank=True)
    description = models.CharField(max_length=200, blank=True)

    # Constraints
    required = models.BooleanField(default=False)
    unique = models.BooleanField(default=False)
    search_weight = models.PositiveSmallIntegerField(default=1000)
    filter_logic = models.CharField(max_length=50, choices=CustomFieldFilterLogicChoices, default=CustomFieldFilterLogicChoices.FILTER_LOOSE)

    # UI
    ui_visible = models.CharField(max_length=50, choices=CustomFieldUIVisibleChoices, default=CustomFieldUIVisibleChoices.ALWAYS)
    ui_editable = models.CharField(max_length=50, choices=CustomFieldUIEditableChoices, default=CustomFieldUIEditableChoices.YES)
    weight = models.PositiveSmallIntegerField(default=100)

    # Validation
    validation_minimum = models.BigIntegerField(null=True, blank=True)
    validation_maximum = models.BigIntegerField(null=True, blank=True)
    validation_regex = models.CharField(max_length=500, blank=True)

    # Choices
    choice_set = models.ForeignKey('extras.CustomFieldChoiceSet', on_delete=models.PROTECT, null=True, blank=True)

    # Default value
    default = models.JSONField(blank=True, null=True)

    # Custom manager
    objects = CustomFieldManager()

    def to_form_field(self, set_initial=True, enforce_required=True):
        # Dynamically creates Django form field
        # Returns forms.CharField, forms.IntegerField, DynamicModelChoiceField, etc.
```

**Tag** (`tags.py`):
```python
class Tag(PrimaryModel):
    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(max_length=100, unique=True)
    color = ColorField(default=ColorChoices.COLOR_GREY)
    object_types = models.ManyToManyField('contenttypes.ContentType', blank=True, related_name='tags')

    class Meta:
        ordering = ('name',)
```

**EventRule** (`models.py`):
```python
class EventRule(ChangeLoggedModel):
    # Applicability
    object_types = models.ManyToManyField('contenttypes.ContentType', related_name='event_rules')

    # Rule definition
    name = models.CharField(max_length=150, unique=True)
    event_types = ArrayField(models.CharField(max_length=50, choices=EventRuleEventTypeChoices), default=list)
    enabled = models.BooleanField(default=True)

    # Conditions (ConditionSet JSON)
    conditions = models.JSONField(blank=True, null=True)

    # Action
    action_type = models.CharField(max_length=50, choices=EventRuleActionTypeChoices)
    action_object_type = models.ForeignKey('contenttypes.ContentType', on_delete=models.CASCADE, related_name='+')
    action_object_id = models.PositiveBigIntegerField()
    action_object = GenericForeignKey('action_object_type', 'action_object_id')
    action_data = models.JSONField(blank=True, null=True)

    def eval_conditions(self, data):
        """Evaluate rule conditions against event data"""
        if not self.conditions:
            return True
        # Recursively evaluates ConditionSet
```

**Webhook** (`models.py`):
```python
class Webhook(ChangeLoggedModel):
    name = models.CharField(max_length=150, unique=True)

    # HTTP configuration
    payload_url = models.CharField(max_length=500)
    http_method = models.CharField(max_length=30, choices=WebhookHttpMethodChoices, default=WebhookHttpMethodChoices.METHOD_POST)
    http_content_type = models.CharField(max_length=100)
    additional_headers = models.TextField(blank=True)
    body_template = models.TextField(blank=True)

    # SSL
    ssl_verification = models.BooleanField(default=True)
    ca_file_path = models.CharField(max_length=4096, blank=True, null=True)

    # Secret for HMAC signing
    secret = models.CharField(max_length=255, blank=True)

    def render(self, context):
        """Render Jinja2 templates for headers and body"""
        headers = self.render_headers(context)
        body = self.render_body(context)
        return headers, body
```

**Script** (`scripts.py`):
```python
class Script(ChangeLoggedModel):
    module = models.ForeignKey('extras.ScriptModule', on_delete=models.CASCADE, related_name='scripts')
    name = models.CharField(max_length=100)
    is_executable = models.BooleanField(default=True)

    # Reverse relations
    jobs = GenericRelation('core.Job')
    events = GenericRelation('extras.EventRule')

    class Meta:
        ordering = ('module', 'name')
        unique_together = (('module', 'name'),)

    @cached_property
    def python_class(self):
        """Returns the actual Script class from the module"""
        # Uses introspection to load Script class from file
```

#### Core Models

Located at: `netbox/core/models/`

**ObjectChange** (`change_logging.py`):
```python
class ObjectChange(models.Model):
    time = models.DateTimeField(auto_now_add=True, db_index=True)
    user = models.ForeignKey('users.User', on_delete=models.SET_NULL, null=True, blank=True)
    user_name = models.CharField(max_length=150, blank=True)
    request_id = models.UUIDField(db_index=True)

    # Changed object
    changed_object_type = models.ForeignKey('contenttypes.ContentType', on_delete=models.CASCADE)
    changed_object_id = models.PositiveBigIntegerField()
    changed_object = GenericForeignKey('changed_object_type', 'changed_object_id')

    # Related object (for context, e.g. device for interface change)
    related_object_type = models.ForeignKey('contenttypes.ContentType', on_delete=models.CASCADE, null=True, blank=True, related_name='+')
    related_object_id = models.PositiveBigIntegerField(null=True, blank=True)
    related_object = GenericForeignKey('related_object_type', 'related_object_id')

    # Change details
    action = models.CharField(max_length=50, choices=ObjectChangeActionChoices)
    message = models.CharField(max_length=500, blank=True)
    prechange_data = models.JSONField(blank=True, null=True)
    postchange_data = models.JSONField(blank=True, null=True)

    class Meta:
        ordering = ('-time',)
        indexes = [
            models.Index(fields=('changed_object_type', 'changed_object_id')),
        ]
```

**Job** (`jobs.py`):
```python
class Job(models.Model):
    # Associated object
    object_type = models.ForeignKey('contenttypes.ContentType', on_delete=models.CASCADE, null=True, blank=True)
    object_id = models.PositiveBigIntegerField(null=True, blank=True)
    object = GenericForeignKey('object_type', 'object_id')

    # Job metadata
    name = models.CharField(max_length=200)
    created = models.DateTimeField(auto_now_add=True)
    scheduled = models.DateTimeField(null=True, blank=True)
    interval = models.PositiveIntegerField(null=True, blank=True)
    started = models.DateTimeField(null=True, blank=True)
    completed = models.DateTimeField(null=True, blank=True)

    # User context
    user = models.ForeignKey('users.User', on_delete=models.SET_NULL, null=True, blank=True)

    # Status
    status = models.CharField(max_length=30, choices=JobStatusChoices, default=JobStatusChoices.STATUS_PENDING)

    # Data & logging
    data = models.JSONField(blank=True, null=True)
    error = models.TextField(blank=True)
    log_entries = ArrayField(models.JSONField(), default=list, blank=True)

    # RQ job ID
    job_id = models.UUIDField(unique=True)

    class Meta:
        ordering = ('-created',)
```

---

## View Layer Architecture

Located at: `netbox/utilities/views.py` and app-specific `views.py` files

### View Mixins

**ConditionalLoginRequiredMixin**:
```python
class ConditionalLoginRequiredMixin(AccessMixin):
    """Enforces authentication only if LOGIN_REQUIRED is True"""
    def dispatch(self, request, *args, **kwargs):
        if settings.LOGIN_REQUIRED and not request.user.is_authenticated:
            return self.handle_no_permission()
        return super().dispatch(request, *args, **kwargs)
```

**TokenConditionalLoginRequiredMixin**:
- Extends ConditionalLoginRequiredMixin
- Attempts DRF token authentication before checking LOGIN_REQUIRED
- Allows API token access to UI views

**ContentTypePermissionRequiredMixin**:
```python
class ContentTypePermissionRequiredMixin(ConditionalLoginRequiredMixin):
    """Model-level permission checking"""
    additional_permissions = []

    def get_required_permission(self):
        """Returns permission string like 'dcim.view_site'"""
        raise NotImplementedError()

    def has_permission(self):
        user = self.request.user
        permission_required = self.get_required_permission()
        return user.has_perms((permission_required, *self.additional_permissions))

    def dispatch(self, request, *args, **kwargs):
        if not self.has_permission():
            return self.handle_no_permission()
        return super().dispatch(request, *args, **kwargs)
```

**ObjectPermissionRequiredMixin**:
```python
class ObjectPermissionRequiredMixin(ConditionalLoginRequiredMixin):
    """Object-level permission checking with queryset filtering"""

    def get_required_permission(self):
        """Returns permission string"""

    def has_permission(self):
        """Checks if user has permission at all"""

    def get_queryset(self):
        """Returns RestrictedQuerySet filtered by user permissions"""
        queryset = super().get_queryset()
        if self.request.user.is_authenticated:
            action = self._get_action()
            return queryset.restrict(self.request.user, action)
        return queryset.none()
```

**GetReturnURLMixin**:
```python
class GetReturnURLMixin:
    """Redirect URL resolution after form submission"""
    default_return_url = None

    def get_return_url(self, request, obj=None):
        # Priority order:
        # 1. Query param: ?return_url=...
        # 2. Form data: return_url field
        # 3. Object's get_absolute_url()
        # 4. default_return_url attribute
        # 5. Fallback to home

        # Validates URL is safe for redirect
        if url := request.GET.get('return_url') or request.POST.get('return_url'):
            if safe_for_redirect(url):
                return url
        if obj and hasattr(obj, 'get_absolute_url'):
            return obj.get_absolute_url()
        if self.default_return_url:
            return reverse(self.default_return_url)
        return reverse('home')
```

**GetRelatedModelsMixin**:
```python
@dataclass
class RelatedObjectCount:
    queryset: QuerySet
    filter_param: str
    label: str

class GetRelatedModelsMixin:
    """Discovers related objects for display in tabs"""

    def get_related_models(self, request, instance, omit=None, extra=None):
        """Returns list of RelatedObjectCount dataclasses"""
        # Uses utilities.relations.get_related_models()
        # Finds all ForeignKey/GenericForeignKey pointing to this model
        # Filters each by permission
        # Returns counts for tab badges
```

### ViewTab System

```python
@dataclass
class ViewTab:
    label: str                              # Display name
    badge: Callable = None                  # Badge count function
    visible: Callable = lambda obj: True    # Visibility function
    permission: str = None                  # Required permission
    hide_if_empty: bool = False            # Hide tab if badge == 0
    weight: int = 1000                      # Sort order
```

### Generic View Classes

Located in app-specific `views.py` files, inheriting from utilities classes:

**ObjectView**: Single object display
```python
class ObjectView(ObjectPermissionRequiredMixin, View):
    queryset = None
    template_name = 'generic/object.html'

    def get_required_permission(self):
        return get_permission_for_model(self.queryset.model, 'view')

    def get_object(self):
        return get_object_or_404(self.queryset, pk=self.kwargs['pk'])

    def get(self, request, **kwargs):
        instance = self.get_object()
        return render(request, self.template_name, {
            'object': instance,
            'tab': request.GET.get('tab'),
        })
```

**ObjectListView**: Multi-object list with filtering
```python
class ObjectListView(ObjectPermissionRequiredMixin, View):
    queryset = None
    filterset = None
    filterset_form = None
    table = None
    template_name = 'generic/object_list.html'

    def get(self, request):
        queryset = self.queryset

        # Apply filterset
        if self.filterset:
            filterset = self.filterset(request.GET, queryset, request=request)
            queryset = filterset.qs

        # Build table
        table = self.table(queryset, user=request.user)
        table.configure(request)

        return render(request, self.template_name, {
            'table': table,
            'filterset': filterset,
            'filterset_form': self.filterset_form(request.GET) if self.filterset_form else None,
        })
```

**ObjectEditView**: Create/edit object
```python
class ObjectEditView(GetReturnURLMixin, ObjectPermissionRequiredMixin, View):
    queryset = None
    model_form = None
    template_name = 'generic/object_edit.html'

    def get_required_permission(self):
        if 'pk' in self.kwargs:
            return get_permission_for_model(self.queryset.model, 'change')
        return get_permission_for_model(self.queryset.model, 'add')

    def get_object(self):
        if 'pk' in self.kwargs:
            return get_object_or_404(self.queryset, pk=self.kwargs['pk'])
        return self.queryset.model()

    def get(self, request, **kwargs):
        instance = self.get_object()
        form = self.model_form(instance=instance)
        return render(request, self.template_name, {
            'object': instance,
            'form': form,
            'return_url': self.get_return_url(request, instance),
        })

    def post(self, request, **kwargs):
        instance = self.get_object()
        form = self.model_form(request.POST, request.FILES, instance=instance)

        if form.is_valid():
            instance = form.save()
            messages.success(request, f"Successfully saved {instance}")
            return redirect(self.get_return_url(request, instance))

        return render(request, self.template_name, {
            'object': instance,
            'form': form,
            'return_url': self.get_return_url(request, instance),
        })
```

**ObjectDeleteView**: Delete object with confirmation
```python
class ObjectDeleteView(GetReturnURLMixin, ObjectPermissionRequiredMixin, View):
    queryset = None
    template_name = 'generic/object_delete.html'

    def get_required_permission(self):
        return get_permission_for_model(self.queryset.model, 'delete')

    def get_object(self):
        return get_object_or_404(self.queryset, pk=self.kwargs['pk'])

    def get(self, request, **kwargs):
        instance = self.get_object()
        return render(request, self.template_name, {
            'object': instance,
            'return_url': self.get_return_url(request),
        })

    def post(self, request, **kwargs):
        instance = self.get_object()
        instance.delete()
        messages.success(request, f"Deleted {instance}")
        return redirect(self.get_return_url(request))
```

**BulkImportView**: CSV import
```python
class BulkImportView(ObjectPermissionRequiredMixin, View):
    queryset = None
    model_form = None
    template_name = 'generic/object_bulk_import.html'

    def get_required_permission(self):
        return get_permission_for_model(self.queryset.model, 'add')

    def post(self, request):
        # Parse CSV
        # Create form for each row
        # Validate all forms
        # Save if all valid
```

**BulkEditView**: Multi-object edit
```python
class BulkEditView(GetReturnURLMixin, ObjectPermissionRequiredMixin, View):
    queryset = None
    filterset = None
    form = None
    template_name = 'generic/object_bulk_edit.html'

    def get_required_permission(self):
        return get_permission_for_model(self.queryset.model, 'change')

    def post(self, request):
        # Get selected PKs from form
        # Apply changes from form to all selected objects
        # Bulk update
```

**BulkDeleteView**: Multi-object delete
```python
class BulkDeleteView(GetReturnURLMixin, ObjectPermissionRequiredMixin, View):
    queryset = None
    filterset = None
    template_name = 'generic/object_bulk_delete.html'

    def get_required_permission(self):
        return get_permission_for_model(self.queryset.model, 'delete')

    def post(self, request):
        # Get selected PKs
        # Delete all
```

### View Registration

Views are registered in the registry for dynamic URL generation:

```python
from utilities.views import register_model_view

# In app's __init__.py or models.py
register_model_view(
    model=Site,
    viewname='custom_view',
    path='custom-action',
    view='dcim.views.SiteCustomView',
    detail=True,  # True for object-specific, False for list
    kwargs=None
)
```

---

## Form System

Located at: `netbox/utilities/forms/` and app-specific `forms/` directories

### Base Form Classes

**NetBoxModelForm** (`netbox/utilities/forms/forms.py`):
```python
class NetBoxModelForm(
    ChangelogMessageMixin,
    CheckLastUpdatedMixin,
    CustomFieldsMixin,
    TagsMixin,
    forms.ModelForm
):
    """
    Standard form for creating/editing NetBox models

    Attributes:
        fieldsets: Tuple of (name, {'fields': tuple}) for field grouping
        comments: TextField for Markdown notes
    """

    comments = CommentField()

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        # Add custom fields
        self._append_customfield_fields()

        # Add tags field if model is taggable
        if is_taggable(self._meta.model):
            self.fields['tags'] = DynamicModelMultipleChoiceField(
                queryset=Tag.objects.all(),
                required=False
            )

    def clean(self):
        # Save custom field data to instance
        if hasattr(self, 'custom_fields'):
            self.instance.custom_field_data = self.custom_fields
        return super().clean()

    def save(self, commit=True):
        instance = super().save(commit=False)

        # Handle custom fields
        if hasattr(self, 'custom_fields'):
            instance.custom_field_data = self.custom_fields

        if commit:
            instance.save()
            self.save_m2m()  # Save tags and other M2M

        return instance
```

**Fieldsets Example**:
```python
class SiteForm(NetBoxModelForm):
    fieldsets = (
        ('Site', ('name', 'slug', 'status')),
        ('Location', ('region', 'group', 'facility', 'time_zone')),
        ('Physical Address', ('physical_address', 'shipping_address', 'latitude', 'longitude')),
        ('Tenancy', ('tenant',)),
    )

    class Meta:
        model = Site
        fields = '__all__'
```

**NetBoxModelImportForm**: CSV bulk import
```python
class NetBoxModelImportForm(CSVModelForm, NetBoxModelForm):
    """
    Form for importing objects from CSV

    Features:
    - Field matching by slug or name
    - Custom field support
    - ForeignKey resolution
    - Validation before bulk create
    """

    # Override fields for CSV import
    name = CSVModelChoiceField(...)
    site = CSVModelChoiceField(
        queryset=Site.objects.all(),
        to_field_name='name',  # Match by name instead of PK
        help_text='Site name'
    )

    def _get_custom_fields(self):
        # Only include ui_editable custom fields for import
        return CustomField.objects.filter(
            object_types=self.object_type,
            ui_editable=CustomFieldUIEditableChoices.YES
        )
```

**NetBoxModelBulkEditForm**: Bulk modification
```python
class NetBoxModelBulkEditForm(
    ChangelogMessageMixin,
    CustomFieldsMixin,
    BulkEditForm
):
    """
    Form for editing multiple objects at once

    Features:
    - Nullable fields (allow unsetting values)
    - Partial updates (only specified fields changed)
    - Tag add/remove operations
    """

    pk = forms.ModelMultipleChoiceField(
        queryset=Model.objects.all(),
        widget=forms.MultipleHiddenInput
    )

    nullable_fields = ('description', 'comments')

    add_tags = DynamicModelMultipleChoiceField(queryset=Tag.objects.all(), required=False)
    remove_tags = DynamicModelMultipleChoiceField(queryset=Tag.objects.all(), required=False)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._extend_nullable_fields()  # Add custom field nullable options
```

### Form Mixins

**ChangelogMessageMixin**:
```python
class ChangelogMessageMixin:
    """Adds optional changelog_message field"""
    changelog_message = forms.CharField(
        max_length=500,
        required=False,
        label='Changelog message',
        widget=forms.Textarea(attrs={'rows': 3})
    )

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Pass changelog_message to model instance
        if self.instance and hasattr(self.instance, '_changelog_message'):
            self.instance._changelog_message = self.data.get('changelog_message')
```

**CustomFieldsMixin**:
```python
class CustomFieldsMixin:
    """Dynamically adds custom fields to form"""

    def _append_customfield_fields(self):
        object_type = ObjectType.objects.get_for_model(self._meta.model)
        custom_fields = CustomField.objects.filter(object_types=object_type)

        for cf in custom_fields:
            field = cf.to_form_field(
                set_initial=not self.instance.pk,
                enforce_required=True
            )
            self.fields[cf.name] = field

            # Set initial value from instance
            if self.instance.pk and cf.name in self.instance.custom_field_data:
                self.initial[cf.name] = self.instance.custom_field_data[cf.name]

    def clean(self):
        # Collect custom field data
        self.custom_fields = {}
        for cf in self.custom_field_objects:
            value = self.cleaned_data.get(cf.name)
            if value is not None:
                self.custom_fields[cf.name] = value
        return super().clean()
```

**TagsMixin**:
```python
class TagsMixin:
    """Adds tags field for taggable models"""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        if is_taggable(self._meta.model):
            self.fields['tags'] = DynamicModelMultipleChoiceField(
                queryset=Tag.objects.all(),
                required=False
            )

            # Set initial tags
            if self.instance.pk:
                self.initial['tags'] = self.instance.tags.all()
```

### Custom Form Fields

**DynamicModelChoiceField**: Ajax-powered model selection
```python
class DynamicModelChoiceField(forms.ModelChoiceField):
    """
    ModelChoiceField with Ajax autocomplete

    Features:
    - Lazy loading of options
    - Search/filter via API
    - Dependent field support (filter based on other field values)
    """
    widget = APISelect

    def __init__(self, query_params=None, *args, **kwargs):
        self.query_params = query_params or {}
        super().__init__(*args, **kwargs)
```

**IPAddressField**: IP address input
**IPNetworkField**: IP prefix/network input
**JSONField**: JSON editor
**MACAddressField**: MAC address validation
**ColorField**: Color picker

---

## Table System

Located at: `netbox/utilities/tables/` and app-specific `tables/` directories

### Base Table Classes

**BaseTable** (`netbox/utilities/tables/tables.py`):
```python
import django_tables2 as tables

class BaseTable(tables.Table):
    """
    Base table for all NetBox tables

    Features:
    - Automatic prefetch optimization
    - User column preferences
    - Pagination
    - Ordering
    """

    exempt_columns = ()  # Columns always visible

    def __init__(self, *args, user=None, **kwargs):
        super().__init__(*args, **kwargs)

        # Optimize queryset with prefetch_related
        if self.data and hasattr(self.data, 'query'):
            prefetches = self._get_prefetches()
            self.data.data = self.data.data.prefetch_related(*prefetches)

    def _get_prefetches(self):
        """Extract prefetch paths from column accessors"""
        prefetches = []
        for column in self.columns:
            if hasattr(column, 'accessor'):
                # Parse accessor like 'device.site.name'
                parts = str(column.accessor).split('__')
                if len(parts) > 1:
                    prefetch_path = '__'.join(parts[:-1])
                    prefetches.append(prefetch_path)
        return prefetches

    def configure(self, request):
        """Apply user preferences, pagination, ordering"""
        # Load user's column configuration
        if request.user.is_authenticated:
            table_config = TableConfig.objects.filter(
                user=request.user,
                table=self.__class__.__name__
            ).first()
            if table_config:
                self._set_columns(table_config.columns)
```

**NetBoxTable** (`netbox/utilities/tables/tables.py`):
```python
class NetBoxTable(BaseTable):
    """
    Extended table with NetBox-specific features

    Features:
    - Action checkboxes for bulk operations
    - Dynamic column visibility
    - Prefetch optimization for ForeignKeys
    """

    pk = tables.CheckBoxColumn()  # Selection checkbox

    def _get_columns(self, visible=True):
        """Get visible or all columns"""
        if visible:
            return [col for col in self.columns if col.visible]
        return self.columns

    def _set_columns(self, selected_columns):
        """Reorder/hide columns per user preference"""
        sequence = list(selected_columns)
        sequence.extend([col for col in self.columns if col not in sequence])
        self.sequence = sequence

        for col in self.columns:
            if col.name not in selected_columns and col.name not in self.exempt_columns:
                self.columns.hide(col.name)
```

### Custom Table Columns

**TemplateColumn**: Custom HTML rendering
```python
class DeviceTable(NetBoxTable):
    name = tables.TemplateColumn(
        template_code='<a href="{{ record.get_absolute_url }}">{{ value }}</a>'
    )
```

**ColorColumn**: Color-coded display
```python
class StatusColumn(tables.TemplateColumn):
    template_code='''
    <span class="badge bg-{{ record.get_status_color }}">
        {{ record.get_status_display }}
    </span>
    '''
```

**ChoiceFieldColumn**: Choice field with color/icon
```python
status = ChoiceFieldColumn()  # Automatically renders with badge
```

**TagsColumn**: Tag display
```python
class NetBoxTable(BaseTable):
    tags = TagsColumn(url_name='ipam:ipaddress_list')
```

**ButtonsColumn**: Action buttons
```python
class DeviceTable(NetBoxTable):
    actions = ButtonsColumn(
        model=Device,
        buttons=('edit', 'delete'),
        prepend_template='<a href="{% url "dcim:device_console" pk=record.pk %}">Console</a>'
    )
```

### Table Configuration

**User Preferences** (`extras/models/models.py:TableConfig`):
```python
class TableConfig(models.Model):
    user = models.ForeignKey('users.User', on_delete=models.CASCADE)
    table = models.CharField(max_length=255)  # Table class name
    columns = ArrayField(models.CharField(max_length=255))  # Ordered list

    class Meta:
        unique_together = ('user', 'table')
```

**Pagination**:
```python
# In view
table = SiteTable(sites, user=request.user)
table.paginate(page=request.GET.get('page'), per_page=50)
```

**Ordering**:
```python
class SiteTable(NetBoxTable):
    class Meta:
        model = Site
        default_order = ('name',)  # Default sort
        orderable = True  # Enable column sorting
```

---

## Filtering System

Located at: `netbox/utilities/filtersets.py` and app-specific `filtersets.py` files

### Base FilterSet Classes

**BaseFilterSet** (`netbox/utilities/filtersets.py`):
```python
import django_filters

class BaseFilterSet(django_filters.FilterSet):
    """
    Base filterset for all NetBox models

    Features:
    - MultiValue filters (comma-separated values)
    - SavedFilter integration
    - Q object generation
    """

    FILTER_DEFAULTS = {
        models.AutoField: {'filter_class': MultiValueNumberFilter},
        models.CharField: {'filter_class': MultiValueCharFilter},
        models.TextField: {'filter_class': MultiValueCharFilter},
        models.IntegerField: {'filter_class': MultiValueNumberFilter},
        models.ForeignKey: {'filter_class': MultiValueNumberFilter},
        # ... more mappings
    }

    def __init__(self, data=None, *args, **kwargs):
        # Load SavedFilter if specified
        if data and ('filter' in data or 'filter_id' in data):
            filter_id = data.get('filter') or data.get('filter_id')
            saved_filter = SavedFilter.objects.get(pk=filter_id)
            # Merge saved parameters with request data
            merged_data = saved_filter.parameters.copy()
            merged_data.update(data)
            data = merged_data

        super().__init__(data, *args, **kwargs)
```

**NetBoxModelFilterSet** (`netbox/utilities/filtersets.py`):
```python
class NetBoxModelFilterSet(BaseFilterSet):
    """
    FilterSet for NetBox models with standard filters

    Automatic filters:
    - id, name (if applicable)
    - created, last_updated (if ChangeLoggingMixin)
    - tenant (if applicable)
    - tags (if TagsMixin)
    - Custom fields
    """

    q = django_filters.CharFilter(
        method='search',
        label='Search'
    )

    tag = TagFilter()
    tag_id = TagIDFilter()

    def search(self, queryset, name, value):
        """Full-text search across configured fields"""
        # Uses search index or Q objects
        return queryset.filter(
            Q(name__icontains=value) |
            Q(description__icontains=value) |
            Q(comments__icontains=value)
        )
```

### Filter Types

**MultiValueCharFilter**: Multiple string values
```python
# URL: ?name=site1,site2,site3
# Matches: WHERE name IN ('site1', 'site2', 'site3')

name = MultiValueCharFilter()
```

**MultiValueNumberFilter**: Multiple numeric values
```python
# URL: ?id=1,2,3
# Matches: WHERE id IN (1, 2, 3)

id = MultiValueNumberFilter()
```

**TreeNodeMultipleChoiceFilter**: Hierarchical filtering
```python
# For MPTT models like Region
# Matches node and all descendants

region = TreeNodeMultipleChoiceFilter(
    queryset=Region.objects.all(),
    field_name='site__region',
    lookup_expr='in'
)
```

**ContentTypeFilter**: Model type filtering
```python
object_type = ContentTypeFilter()
# URL: ?object_type=dcim.device
```

**TagFilter**: Tag-based filtering
```python
tag = TagFilter()
# URL: ?tag=production,critical
# Matches objects with ANY of these tags
```

### Lookup Expressions

NetBox extends django-filter with additional lookups:

```python
FILTER_CHAR_BASED_LOOKUP_MAP = {
    'n': 'exact',
    'ic': 'icontains',
    'nic': 'icontains',
    'iew': 'iendswith',
    'niew': 'iendswith',
    'isw': 'istartswith',
    'nisw': 'istartswith',
    'ie': 'iexact',
    'nie': 'iexact',
    'empty': 'empty',
    're': 'regex',
    'nre': 'regex',
}

FILTER_NUMERIC_BASED_LOOKUP_MAP = {
    'n': 'exact',
    'lt': 'lt',
    'lte': 'lte',
    'gt': 'gt',
    'gte': 'gte',
    'empty': 'empty',
}

# URL examples:
# ?name__ic=production  -> name ILIKE '%production%'
# ?vid__gt=100          -> vid > 100
# ?description__empty=true  -> description IS NULL OR description = ''
```

### SavedFilter Integration

```python
# Create SavedFilter
saved_filter = SavedFilter.objects.create(
    name='Active Production Sites',
    slug='active-prod-sites',
    object_types=[ObjectType.objects.get_for_model(Site)],
    parameters={
        'status': 'active',
        'tag': 'production'
    }
)

# Apply SavedFilter
# URL: ?filter=<pk> or ?filter_id=<pk>
# FilterSet automatically merges saved parameters
```

### Example FilterSet

```python
class SiteFilterSet(NetBoxModelFilterSet):
    # Basic filters
    region_id = django_filters.ModelMultipleChoiceFilter(
        queryset=Region.objects.all(),
        label='Region (ID)'
    )
    region = django_filters.ModelMultipleChoiceFilter(
        field_name='region__slug',
        queryset=Region.objects.all(),
        to_field_name='slug',
        label='Region (slug)'
    )

    # Status filter
    status = django_filters.MultipleChoiceFilter(
        choices=SiteStatusChoices,
        null_value=None
    )

    # Tenant filter (hierarchical)
    tenant = TreeNodeMultipleChoiceFilter(
        queryset=Tenant.objects.all(),
        field_name='tenant',
        lookup_expr='in'
    )

    class Meta:
        model = Site
        fields = ('id', 'name', 'slug', 'facility', 'time_zone')
```

---

## API Architecture

Located at: `netbox/netbox/api/` and app-specific `api/` directories

### ViewSet Hierarchy

**BaseViewSet** (`netbox/netbox/api/viewsets/__init__.py`):
```python
from rest_framework.viewsets import GenericViewSet

HTTP_ACTIONS = {
    'GET': 'view',
    'OPTIONS': None,
    'HEAD': 'view',
    'POST': 'add',
    'PUT': 'change',
    'PATCH': 'change',
    'DELETE': 'delete',
}

class BaseViewSet(GenericViewSet):
    """
    Base class for all API ViewSets

    Features:
    - Permission-based queryset restriction
    - Dynamic field selection
    - Prefetch optimization
    """

    brief = False

    def initial(self, request, *args, **kwargs):
        """Restrict queryset based on user permissions"""
        super().initial(request, *args, **kwargs)

        if request.user.is_authenticated:
            if action := HTTP_ACTIONS[request.method]:
                # Filter queryset to only permitted objects
                self.queryset = self.queryset.restrict(request.user, action)

    def initialize_request(self, request, *args, **kwargs):
        """Detect brief mode from query param"""
        self.brief = request.method == 'GET' and request.GET.get('brief')
        return super().initialize_request(request, *args, **kwargs)

    def get_queryset(self):
        """Optimize queryset with prefetching"""
        qs = super().get_queryset()
        serializer_class = self.get_serializer_class()

        # Dynamically resolve prefetches for included fields
        if prefetch := get_prefetches_for_serializer(
            serializer_class,
            fields_to_include=self.requested_fields
        ):
            qs = qs.prefetch_related(*prefetch)

        # Dynamically resolve annotations (e.g. for counts)
        if annotations := get_annotations_for_serializer(
            serializer_class,
            fields_to_include=self.requested_fields
        ):
            qs = qs.annotate(**annotations)

        return qs

    def get_serializer(self, *args, **kwargs):
        """Pass requested fields to serializer"""
        if self.requested_fields:
            kwargs['fields'] = self.requested_fields
        return super().get_serializer(*args, **kwargs)

    @cached_property
    def requested_fields(self):
        """Parse ?fields=field1,field2 or use brief_fields"""
        if requested_fields := self.request.query_params.get('fields'):
            return requested_fields.split(',')
        elif self.brief:
            serializer_class = self.get_serializer_class()
            return getattr(serializer_class.Meta, 'brief_fields', None)
        return None
```

**NetBoxReadOnlyModelViewSet**:
```python
class NetBoxReadOnlyModelViewSet(
    CustomFieldsMixin,
    ExportTemplatesMixin,
    RetrieveModelMixin,
    ListModelMixin,
    BaseViewSet
):
    """Read-only API ViewSet (GET only)"""
    pass
```

**NetBoxModelViewSet**:
```python
class NetBoxModelViewSet(
    BulkUpdateModelMixin,
    BulkDestroyModelMixin,
    ObjectValidationMixin,
    CustomFieldsMixin,
    ExportTemplatesMixin,
    CreateModelMixin,
    RetrieveModelMixin,
    UpdateModelMixin,
    DestroyModelMixin,
    ListModelMixin,
    BaseViewSet
):
    """
    Full CRUD API ViewSet

    Supports:
    - List: GET /api/dcim/sites/
    - Retrieve: GET /api/dcim/sites/{id}/
    - Create: POST /api/dcim/sites/
    - Update: PUT/PATCH /api/dcim/sites/{id}/
    - Delete: DELETE /api/dcim/sites/{id}/
    - Bulk create: POST /api/dcim/sites/ with list
    - Bulk update: PATCH /api/dcim/sites/ with list
    - Bulk delete: DELETE /api/dcim/sites/ with list
    """

    def get_object_with_snapshot(self):
        """Save pre-change snapshot for changelog"""
        obj = super().get_object()
        if hasattr(obj, 'snapshot'):
            obj.snapshot()
        return obj

    def get_serializer(self, *args, **kwargs):
        """Enable many=True for list input"""
        if isinstance(kwargs.get('data', {}), list):
            kwargs['many'] = True
        return super().get_serializer(*args, **kwargs)
```

### Serializer Hierarchy

**BaseModelSerializer** (`netbox/netbox/api/serializers/base.py`):
```python
from rest_framework import serializers

class BaseModelSerializer(serializers.ModelSerializer):
    """
    Base serializer for NetBox models

    Standard fields:
    - url: API URL
    - display_url: Web UI URL
    - display: String representation
    """

    url = NetBoxAPIHyperlinkedIdentityField()
    display_url = NetBoxURLHyperlinkedIdentityField()
    display = serializers.SerializerMethodField(read_only=True)

    def __init__(self, *args, nested=False, fields=None, **kwargs):
        """
        Args:
            nested: If True, accept object attributes or PK for ForeignKeys
            fields: List of fields to include (for ?fields= support)
        """
        self.nested = nested
        self._requested_fields = fields
        super().__init__(*args, **kwargs)

    @cached_property
    def fields(self):
        """Dynamically filter fields"""
        fields = super().fields
        if self._requested_fields:
            # Only include requested fields
            allowed = set(self._requested_fields) | {'url', 'display', 'id'}
            for field_name in list(fields.keys()):
                if field_name not in allowed:
                    fields.pop(field_name)
        return fields

    def get_display(self, obj):
        return str(obj)

    def to_internal_value(self, data):
        """Handle nested serialization"""
        if self.nested:
            # Accept {"name": "Site A"} or just the ID
            if isinstance(data, dict):
                return get_related_object_by_attrs(self.Meta.model, data)
        return super().to_internal_value(data)
```

**ValidatedModelSerializer**:
```python
class ValidatedModelSerializer(BaseModelSerializer):
    """
    Serializer that enforces model's full_clean() validation

    Ensures all model validators run, not just field-level
    """

    def validate(self, attrs):
        # Build temporary instance
        instance = self.instance or self.Meta.model()
        for field, value in attrs.items():
            setattr(instance, field, value)

        # Run model validation
        instance.full_clean()

        return super().validate(attrs)
```

### Feature Serializers

**CustomFieldModelSerializer**:
```python
class CustomFieldModelSerializer(serializers.Serializer):
    custom_fields = CustomFieldsDataField(
        source='custom_field_data',
        default=CreateOnlyDefault(CustomFieldDefaultValues())
    )
```

**TaggableModelSerializer**:
```python
class TaggableModelSerializer(serializers.Serializer):
    tags = NestedTagSerializer(many=True, required=False)

    def create(self, validated_data):
        tags = validated_data.pop('tags', [])
        instance = super().create(validated_data)
        instance.tags.set([tag.name for tag in tags])
        return instance
```

**ChangeLogMessageSerializer**:
```python
class ChangeLogMessageSerializer(serializers.Serializer):
    changelog_message = serializers.CharField(write_only=True, required=False)

    def create(self, validated_data):
        message = validated_data.pop('changelog_message', None)
        instance = super().create(validated_data)
        if message:
            instance._changelog_message = message
        return instance
```

### Nested Serializers

For representing related objects without full detail:

```python
class NestedSiteSerializer(BaseModelSerializer):
    url = serializers.HyperlinkedIdentityField(view_name='dcim-api:site-detail')

    class Meta:
        model = Site
        fields = ('id', 'url', 'display', 'name', 'slug')
        brief_fields = ('id', 'url', 'display', 'name')

class DeviceSerializer(NetBoxModelSerializer):
    site = NestedSiteSerializer()

    class Meta:
        model = Device
        fields = '__all__'
```

### Custom API Actions

```python
from rest_framework.decorators import action
from rest_framework.response import Response

class DeviceViewSet(NetBoxModelViewSet):
    queryset = Device.objects.all()
    serializer_class = DeviceSerializer

    @action(detail=True, methods=['post'])
    def console(self, request, pk=None):
        """Custom action: /api/dcim/devices/{id}/console/"""
        device = self.get_object()
        # Custom logic
        return Response({'status': 'connected'})

    @action(detail=False, methods=['get'])
    def available(self, request):
        """Custom action: /api/dcim/devices/available/"""
        available_devices = self.get_queryset().filter(status='available')
        serializer = self.get_serializer(available_devices, many=True)
        return Response(serializer.data)
```

### API URL Routing

```python
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register('sites', SiteViewSet)
router.register('devices', DeviceViewSet)
router.register('cables', CableViewSet)

urlpatterns = router.urls
```

---

## Permission System

Located at: `netbox/utilities/permissions.py` and `netbox/utilities/querysets.py`

### Permission Resolution

```python
def get_permission_for_model(model, action):
    """
    Returns permission string for model and action

    Example:
        get_permission_for_model(Site, 'view') -> 'dcim.view_site'
        get_permission_for_model(Device, 'add') -> 'dcim.add_device'
    """
    model = model._meta.concrete_model
    return f'{model._meta.app_label}.{action}_{model._meta.model_name}'


def resolve_permission(name):
    """
    Parse permission string into components

    Example:
        resolve_permission('dcim.view_site') -> ('dcim', 'view', 'site')
    """
    app_label, codename = name.split('.')
    action, model_name = codename.rsplit('_', 1)
    return app_label, action, model_name


def resolve_permission_type(name):
    """
    Returns (ObjectType, action) tuple

    Example:
        resolve_permission_type('dcim.view_site') -> (ObjectType<Site>, 'view')
    """
    app_label, action, model_name = resolve_permission(name)
    object_type = ObjectType.objects.get_by_natural_key(
        app_label=app_label,
        model=model_name
    )
    return object_type, action
```

### Permission Exemption

```python
def permission_is_exempt(name):
    """
    Check if permission is exempt from enforcement

    Configured via settings:
    - EXEMPT_VIEW_PERMISSIONS: ['*'] for all or ['dcim.site'] for specific
    - EXEMPT_EXCLUDE_MODELS: [('users', 'user')] to exclude from wildcard
    """
    app_label, action, model_name = resolve_permission(name)

    if action == 'view':
        # Check wildcard exemption
        if '*' in settings.EXEMPT_VIEW_PERMISSIONS:
            if (app_label, model_name) not in settings.EXEMPT_EXCLUDE_MODELS:
                return True

        # Check specific exemption
        if f'{app_label}.{model_name}' in settings.EXEMPT_VIEW_PERMISSIONS:
            return True

    return False
```

### ObjectPermission Model

```python
class ObjectPermission(models.Model):
    """
    Grants specific permissions to users/groups with optional constraints

    Example:
        - Grant 'dcim.change_device' to 'network_admins' group
        - Only for devices where site__name='LAX' OR tenant_id=5
    """

    name = models.CharField(max_length=100, unique=True)

    # Permissions granted
    object_types = models.ManyToManyField('contenttypes.ContentType')
    actions = ArrayField(models.CharField(max_length=30), default=list)

    # Who receives the permission
    groups = models.ManyToManyField('users.Group', blank=True)
    users = models.ManyToManyField('users.User', blank=True)

    # Constraints (list of Q-filter dicts)
    constraints = models.JSONField(blank=True, null=True)
    # Example: [{"site__slug": "lax"}, {"tenant__id": 5}]
    # Means: WHERE (site.slug = 'lax') OR (tenant_id = 5)
```

### RestrictedQuerySet

```python
class RestrictedQuerySet(QuerySet):
    """
    QuerySet that filters objects based on user permissions

    Usage:
        sites = Site.objects.restrict(request.user, 'view')
        devices = Device.objects.restrict(request.user, 'change')
    """

    def restrict(self, user, action='view'):
        """
        Filter QuerySet to only permitted objects

        Args:
            user: User instance
            action: 'view', 'add', 'change', or 'delete'

        Returns:
            Filtered QuerySet
        """
        permission_required = get_permission_for_model(self.model, action)

        # Bypass for superusers and exempt permissions
        if user and user.is_superuser or permission_is_exempt(permission_required):
            return self

        # Deny if not authenticated or no permission
        if user is None or not user.is_authenticated:
            return self.none()

        if permission_required not in user.get_all_permissions():
            return self.none()

        # Apply constraints from ObjectPermission
        tokens = {
            CONSTRAINT_TOKEN_USER: user.id,  # $user -> actual user ID
        }

        # Get constraints from user's cached permissions
        constraints = user._object_perm_cache.get(permission_required, [])

        # Convert constraints to Q object
        q_filter = qs_filter_from_constraints(constraints, tokens)

        # Filter to allowed objects only
        allowed_objects = self.model.objects.filter(q_filter)
        return self.filter(pk__in=allowed_objects)
```

### RestrictedPrefetch

```python
class RestrictedPrefetch(Prefetch):
    """
    Prefetch that applies permission filtering to related objects

    Usage:
        devices = Device.objects.prefetch_related(
            RestrictedPrefetch('interfaces', user=request.user, action='view')
        )
    """

    def __init__(self, lookup, user, action='view', queryset=None, to_attr=None):
        self.restrict_user = user
        self.restrict_action = action
        super().__init__(lookup, queryset=queryset, to_attr=to_attr)

    def get_current_querysets(self, level):
        querysets = super().get_current_querysets(level)
        if querysets:
            return [qs.restrict(self.restrict_user, self.restrict_action) for qs in querysets]
        return querysets
```

### Constraint Evaluation

```python
def qs_filter_from_constraints(constraints, tokens=None):
    """
    Convert ObjectPermission constraints to Q filter

    Args:
        constraints: List of dict constraints
            Example: [{"site__name": "LAX"}, {"tenant__id": "$user"}]
        tokens: Dict of token replacements
            Example: {"$user": 42}

    Returns:
        Q object for filtering

    Example:
        constraints = [{"site__id": 1}, {"tenant__id": "$user"}]
        tokens = {"$user": 42}
        Result: Q(site__id=1) | Q(tenant__id=42)
    """
    if tokens is None:
        tokens = {}

    q = Q()
    for constraint in constraints:
        constraint_q = Q()
        for key, value in constraint.items():
            # Replace tokens
            if value in tokens:
                value = tokens[value]
            constraint_q &= Q(**{key: value})
        q |= constraint_q

    return q
```

### Permission Checking in Views

```python
class ObjectView(ObjectPermissionRequiredMixin, View):
    queryset = Site.objects.all()

    def get_required_permission(self):
        return get_permission_for_model(self.queryset.model, 'view')

    def get_queryset(self):
        # Automatically restricted by mixin
        return super().get_queryset()
```

---

## Custom Scripts System

Located at: `netbox/extras/scripts.py`

### Script Base Class

```python
class Script:
    """
    Base class for custom scripts

    Attributes:
        description: Script description
        version: Script version
        commit_default: Default value for "commit changes" checkbox
        hidden: Hide from UI
        task_queues: RQ queue names for execution

    Variables:
        Define input parameters as class attributes using ScriptVariable types
    """

    description = ''
    version = '1.0'
    commit_default = True
    hidden = False
    task_queues = ['default']

    # Example variables
    site = ObjectVar(
        model=Site,
        label='Site',
        required=True
    )
    device_count = IntegerVar(
        min_value=1,
        max_value=100,
        default=10,
        label='Number of devices'
    )
    prefix = StringVar(
        regex=r'^[A-Z]{3}-\d{2}$',
        label='Device name prefix'
    )

    def __init__(self, job):
        self.job = job
        self.log = job.log
        self.log_success = job.log_success
        self.log_info = job.log_info
        self.log_warning = job.log_warning
        self.log_failure = job.log_failure

    def run(self, data, commit=True):
        """
        Main script execution method

        Args:
            data: Dict of input values
            commit: Whether to commit changes

        Example:
            site = data['site']
            count = data['device_count']
            prefix = data['prefix']

            for i in range(count):
                device = Device(
                    name=f'{prefix}-{i:02d}',
                    site=site,
                    ...
                )
                device.save()
                self.log_success(f'Created device {device}')
        """
        raise NotImplementedError("Subclasses must implement run()")
```

### Script Variable Types

**StringVar**: Text input
```python
name = StringVar(
    min_length=3,
    max_length=50,
    regex=r'^[A-Z0-9-]+$',
    label='Device name',
    description='Alphanumeric and hyphens only',
    default='DEFAULT',
    required=True
)
```

**TextVar**: Multi-line text
```python
description = TextVar(
    label='Description',
    required=False
)
```

**IntegerVar**: Integer input
```python
vlan_id = IntegerVar(
    min_value=1,
    max_value=4094,
    label='VLAN ID',
    required=True
)
```

**BooleanVar**: Checkbox
```python
enable_monitoring = BooleanVar(
    label='Enable monitoring',
    default=True
)
```

**ChoiceVar**: Dropdown selection
```python
device_role = ChoiceVar(
    choices=[
        ('access', 'Access Switch'),
        ('distribution', 'Distribution Switch'),
        ('core', 'Core Router'),
    ],
    label='Device role'
)
```

**MultiChoiceVar**: Multiple selection
```python
features = MultiChoiceVar(
    choices=[
        ('poe', 'Power over Ethernet'),
        ('stacking', 'Stackable'),
        ('redundant_psu', 'Redundant Power Supply'),
    ],
    label='Features'
)
```

**ObjectVar**: Model instance selection
```python
site = ObjectVar(
    model=Site,
    query_params={'status': 'active'},
    label='Site',
    required=True
)
```

**MultiObjectVar**: Multiple model instances
```python
devices = MultiObjectVar(
    model=Device,
    query_params={'site_id': '$site'},  # Dynamic filter
    label='Devices',
    required=False
)
```

**IPAddressVar**: IP address input
```python
management_ip = IPAddressVar(
    label='Management IP'
)
```

**IPNetworkVar**: IP prefix input
```python
subnet = IPNetworkVar(
    label='Subnet',
    min_prefix_length=24,
    max_prefix_length=30
)
```

**FileVar**: File upload
```python
csv_file = FileVar(
    label='CSV file'
)
```

### Script Discovery and Registration

```python
class ScriptModule(PythonModuleMixin, ManagedFile):
    """
    Proxy model for script files

    Scans /scripts/ directory for Python files
    Discovers Script classes via introspection
    """

    @property
    def module_scripts(self):
        """Returns dict of {name: ScriptClass}"""
        module = self.get_module()

        scripts = {}
        for name, cls in inspect.getmembers(module):
            if inspect.isclass(cls) and issubclass(cls, Script) and cls is not Script:
                scripts[name] = cls

        # Sort by script_order if defined
        if hasattr(module, 'script_order'):
            ordered = {}
            for name in module.script_order:
                if name in scripts:
                    ordered[name] = scripts.pop(name)
            ordered.update(scripts)
            scripts = ordered

        return scripts
```

### Script Execution Flow

1. **User triggers script** from UI at `/extras/scripts/{module}/{script}/`
2. **Form rendered** with ScriptVariable fields
3. **User submits form** with input data
4. **Job created**:
   ```python
   job = Job.objects.create(
       object=script,
       name=script.name,
       user=request.user,
       job_id=uuid.uuid4(),
       data=form.cleaned_data
   )
   ```
5. **Job queued** to RQ:
   ```python
   queue = get_queue(script.task_queues[0])
   queue.enqueue(run_script, job_id=job.job_id, commit=commit)
   ```
6. **Worker processes job**:
   ```python
   @job('default')
   def run_script(job_id, commit):
       job = Job.objects.get(job_id=job_id)
       script_instance = job.object.python_class(job)

       try:
           job.start()
           script_instance.run(job.data, commit=commit)
           job.complete()
       except Exception as e:
           job.fail(error=str(e))
   ```
7. **Logging captured**:
   ```python
   def log_success(self, message):
       self.job.log_entries.append({
           'level': LogLevelChoices.LOG_SUCCESS,
           'message': message,
           'time': timezone.now().isoformat()
       })
       self.job.save()
   ```

### Example Script

```python
from extras.scripts import Script, StringVar, ObjectVar, IntegerVar
from dcim.models import Site, Device, DeviceRole, DeviceType

class ProvisionSite(Script):
    """Provision a new site with standard devices"""

    description = "Creates a new site and provisions standard network devices"
    version = "1.0"

    # Input variables
    site_name = StringVar(
        label="Site name",
        regex=r'^[A-Z]{3}-[A-Z]{2}$',
        description="Format: XXX-YY (e.g., LAX-01)"
    )

    access_switch_count = IntegerVar(
        label="Number of access switches",
        min_value=1,
        max_value=48,
        default=24
    )

    device_type = ObjectVar(
        model=DeviceType,
        query_params={'manufacturer__slug': 'cisco'},
        label="Switch model"
    )

    def run(self, data, commit=True):
        # Extract input
        site_name = data['site_name']
        switch_count = data['access_switch_count']
        device_type = data['device_type']

        # Create site
        site = Site(
            name=site_name,
            slug=site_name.lower(),
            status='planned'
        )
        site.full_clean()
        if commit:
            site.save()
        self.log_success(f"Created site {site}")

        # Get or create device role
        role, _ = DeviceRole.objects.get_or_create(
            slug='access-switch',
            defaults={'name': 'Access Switch', 'color': '00bcd4'}
        )

        # Create devices
        for i in range(1, switch_count + 1):
            device = Device(
                name=f'{site_name}-SW-{i:02d}',
                site=site,
                device_type=device_type,
                device_role=role,
                status='planned'
            )
            device.full_clean()
            if commit:
                device.save()
            self.log_success(f"Created device {device}")

        # Summary
        self.log_info(f"Provisioned {switch_count} devices at site {site}")

        return f"Successfully provisioned site {site_name}"
```

---

## Webhook & Event System

Located at: `netbox/extras/webhooks.py`, `netbox/extras/events.py`

### Event Types

```python
from django.dispatch import Signal

# Core signals
post_clean = Signal()  # After model.clean()

# Event types for EventRule
EventRuleEventTypeChoices = (
    ('object_created', 'Object created'),
    ('object_updated', 'Object updated'),
    ('object_deleted', 'Object deleted'),
    ('job_start', 'Job started'),
    ('job_end', 'Job ended'),
)
```

### EventRule Processing

```python
def process_event_rules(instance, action, request=None):
    """
    Triggered by signal handlers after object save/delete

    Args:
        instance: Model instance
        action: 'create', 'update', or 'delete'
        request: Current request (for user context)
    """
    object_type = ObjectType.objects.get_for_model(instance)

    # Find applicable event rules
    event_rules = EventRule.objects.filter(
        object_types=object_type,
        event_types__contains=action,
        enabled=True
    )

    for event_rule in event_rules:
        # Evaluate conditions
        event_data = serialize_object(instance)
        if not event_rule.eval_conditions(event_data):
            continue

        # Execute action
        if event_rule.action_type == EventRuleActionTypeChoices.WEBHOOK:
            webhook = event_rule.action_object
            enqueue_webhook(webhook, instance, action, request)

        elif event_rule.action_type == EventRuleActionTypeChoices.SCRIPT:
            script = event_rule.action_object
            enqueue_script(script, instance, request)

        elif event_rule.action_type == EventRuleActionTypeChoices.NOTIFICATION:
            notification_group = event_rule.action_object
            send_notification(notification_group, instance, action)
```

### Webhook Execution

```python
@job('default')
def send_webhook(event_rule, model_name, event_type, data, timestamp, username, request_id):
    """
    Background job for webhook delivery

    Features:
    - Jinja2 template rendering
    - HMAC signature generation
    - Retry logic
    - SSL verification
    """
    webhook = event_rule.action_object

    # Build context for Jinja2 templates
    context = {
        'event': event_type,
        'timestamp': timestamp,
        'model': model_name,
        'username': username,
        'request_id': request_id,
        'data': data,
    }

    # Render templates
    headers = webhook.render_headers(context)
    body = webhook.render_body(context)
    url = webhook.render_url(context)

    # Add HMAC signature if secret defined
    if webhook.secret:
        signature = hmac.new(
            key=webhook.secret.encode('utf-8'),
            msg=body.encode('utf-8'),
            digestmod=hashlib.sha512
        ).hexdigest()
        headers['X-Hook-Signature'] = signature

    # Prepare request
    session = requests.Session()

    # SSL verification
    if webhook.ssl_verification:
        if webhook.ca_file_path:
            session.verify = webhook.ca_file_path
    else:
        session.verify = False

    # Send request
    prepared_request = requests.Request(
        method=webhook.http_method,
        url=url,
        headers=headers,
        data=body
    ).prepare()

    try:
        response = session.send(prepared_request, timeout=30)
        response.raise_for_status()
        return f"Webhook sent: {response.status_code}"
    except requests.RequestException as e:
        raise Exception(f"Webhook failed: {e}")
```

### Webhook Template Rendering

```python
class Webhook(ChangeLoggedModel):
    payload_url = models.CharField(max_length=500)
    additional_headers = models.TextField(blank=True)
    body_template = models.TextField(blank=True)

    def render_headers(self, context):
        """Render Jinja2 template for headers"""
        if not self.additional_headers:
            return {}

        template = Template(self.additional_headers)
        rendered = template.render(context)

        # Parse as key: value pairs
        headers = {}
        for line in rendered.splitlines():
            if ':' in line:
                key, value = line.split(':', 1)
                headers[key.strip()] = value.strip()
        return headers

    def render_body(self, context):
        """Render Jinja2 template for body"""
        if not self.body_template:
            # Default: JSON dump of data
            return json.dumps(context['data'], indent=2)

        template = Template(self.body_template)
        return template.render(context)

    def render_url(self, context):
        """Render Jinja2 template for URL (supports dynamic URLs)"""
        template = Template(self.payload_url)
        return template.render(context)
```

### Condition Evaluation

```python
class ConditionSet:
    """
    Evaluates nested conditions with AND/OR logic

    JSON structure:
    {
        "op": "and",  # or "or"
        "conditions": [
            {"attr": "status", "op": "eq", "value": "active"},
            {"attr": "site.name", "op": "contains", "value": "prod"}
        ]
    }
    """

    def eval(self, obj):
        operator = self.data.get('op', 'and')
        conditions = self.data.get('conditions', [])

        results = []
        for condition in conditions:
            if 'op' in condition:
                # Nested ConditionSet
                nested = ConditionSet(condition)
                results.append(nested.eval(obj))
            else:
                # Single condition
                results.append(self.eval_condition(obj, condition))

        if operator == 'and':
            return all(results)
        elif operator == 'or':
            return any(results)
        return False

    def eval_condition(self, obj, condition):
        """Evaluate single condition"""
        attr_path = condition['attr'].split('.')
        value = obj
        for attr in attr_path:
            value = getattr(value, attr, None)
            if value is None:
                return False

        op = condition['op']
        expected = condition['value']

        if op == 'eq':
            return value == expected
        elif op == 'neq':
            return value != expected
        elif op == 'contains':
            return expected in str(value)
        elif op == 'regex':
            return re.match(expected, str(value))
        # ... more operators
```

---

## Registry System

Located at: `netbox/netbox/registry.py`

### Registry Structure

```python
from collections import defaultdict

class Registry(dict):
    """
    Central registry for NetBox functionality

    Keys cannot be added/removed after initialization
    Values are mutable for registration
    """

    def __setitem__(self, key, value):
        raise TypeError("Cannot add stores to registry after initialization")

    def __delitem__(self, key):
        raise TypeError("Cannot delete stores from registry")


# Global registry instance
registry = Registry({
    'counter_fields': defaultdict(dict),
    'data_backends': dict(),
    'denormalized_fields': defaultdict(list),
    'event_types': dict(),
    'model_features': dict(),
    'models': defaultdict(set),
    'plugins': dict(),
    'request_processors': list(),
    'search': dict(),
    'system_jobs': dict(),
    'tables': defaultdict(dict),
    'views': defaultdict(dict),
    'webhook_callbacks': list(),
    'widgets': dict(),
})
```

### Registry Usage

**Registering Views**:
```python
from netbox.registry import registry

registry['views']['dcim']['site'].append({
    'name': 'custom_action',
    'path': 'custom-action',
    'view': 'dcim.views.SiteCustomActionView',
    'detail': True,  # Object-specific URL
    'kwargs': None
})

# Generates URL: /dcim/sites/<pk>/custom-action/
```

**Registering Data Backends**:
```python
from netbox.registry import registry

class CustomBackend(DataBackend):
    label = 'custom'

    def sync(self, datasource):
        # Fetch and sync data
        pass

registry['data_backends']['custom'] = CustomBackend
```

**Registering Model Features**:
```python
from netbox.registry import registry

registry['model_features']['custom_fields'].add(Device)
registry['model_features']['tags'].add(Site)
```

**Registering Search Indexes**:
```python
from netbox.registry import registry
from netbox.search import SearchIndex

class DeviceIndex(SearchIndex):
    model = Device
    fields = (
        ('name', 100),
        ('serial', 200),
        ('asset_tag', 200),
    )

registry['search']['dcim.device'] = DeviceIndex
```

---

## URL Routing

Located at: `netbox/utilities/urls.py` and app-specific `urls.py` files

### Dynamic URL Generation

```python
from utilities.urls import get_model_urls

# In dcim/urls.py
urlpatterns = [
    # List views
    path('sites/', include(get_model_urls('dcim', 'site', detail=False))),

    # Detail views
    path('sites/<int:pk>/', include(get_model_urls('dcim', 'site', detail=True))),
]

# Generates URLs:
# /dcim/sites/                     -> dcim:site_list
# /dcim/sites/add/                 -> dcim:site_add
# /dcim/sites/import/              -> dcim:site_import
# /dcim/sites/<pk>/                -> dcim:site
# /dcim/sites/<pk>/edit/           -> dcim:site_edit
# /dcim/sites/<pk>/delete/         -> dcim:site_delete
# /dcim/sites/<pk>/changelog/      -> dcim:site_changelog
```

### URL Naming Conventions

```
# List views (detail=False)
<app>:<model>_list          # Object list
<app>:<model>_add           # Create form
<app>:<model>_import        # CSV import
<app>:<model>_bulk_edit     # Bulk edit form
<app>:<model>_bulk_delete   # Bulk delete confirmation

# Detail views (detail=True)
<app>:<model>               # Object detail
<app>:<model>_edit          # Edit form
<app>:<model>_delete        # Delete confirmation
<app>:<model>_changelog     # Change log
<app>:<model>_notes         # Journal entries
<app>:<model>_contacts      # Contact assignments
```

---

## Testing Patterns

Located at: `netbox/utilities/testing/`

### APITestCase

```python
from utilities.testing import APITestCase

class SiteAPITestCase(APITestCase):
    model = Site
    brief_fields = ['display', 'id', 'name', 'slug', 'url']

    @classmethod
    def setUpTestData(cls):
        """Create test data once for all tests"""
        cls.sites = [
            Site.objects.create(name=f'Site {i}', slug=f'site-{i}')
            for i in range(1, 4)
        ]

    def test_list_sites(self):
        """GET /api/dcim/sites/"""
        url = self._get_list_url()
        response = self.client.get(url, **self.header)

        self.assertHttpStatus(response, 200)
        self.assertEqual(response.data['count'], 3)

    def test_get_site(self):
        """GET /api/dcim/sites/{id}/"""
        site = self.sites[0]
        url = self._get_detail_url(site)
        response = self.client.get(url, **self.header)

        self.assertHttpStatus(response, 200)
        self.assertEqual(response.data['name'], site.name)

    def test_create_site(self):
        """POST /api/dcim/sites/"""
        data = {
            'name': 'New Site',
            'slug': 'new-site',
            'status': 'active'
        }
        url = self._get_list_url()
        response = self.client.post(url, data, format='json', **self.header)

        self.assertHttpStatus(response, 201)
        self.assertEqual(Site.objects.count(), 4)

    def test_update_site(self):
        """PATCH /api/dcim/sites/{id}/"""
        site = self.sites[0]
        data = {'description': 'Updated description'}
        url = self._get_detail_url(site)
        response = self.client.patch(url, data, format='json', **self.header)

        self.assertHttpStatus(response, 200)
        site.refresh_from_db()
        self.assertEqual(site.description, 'Updated description')

    def test_delete_site(self):
        """DELETE /api/dcim/sites/{id}/"""
        site = self.sites[0]
        url = self._get_detail_url(site)
        response = self.client.delete(url, **self.header)

        self.assertHttpStatus(response, 204)
        self.assertEqual(Site.objects.count(), 2)
```

### ModelTestCase

```python
from utilities.testing import ModelTestCase

class SiteTestCase(ModelTestCase):
    model = Site

    def test_site_creation(self):
        """Test basic site creation"""
        site = Site(
            name='Test Site',
            slug='test-site',
            status='active'
        )
        site.full_clean()
        site.save()

        self.assertEqual(str(site), 'Test Site')
        self.assertEqual(site.status, 'active')

    def test_slug_uniqueness(self):
        """Test slug must be unique"""
        Site.objects.create(name='Site 1', slug='test')

        duplicate = Site(name='Site 2', slug='test')
        with self.assertRaises(ValidationError):
            duplicate.full_clean()
```

### ViewTestCase

```python
from utilities.testing import ViewTestCase

class SiteViewTestCase(ViewTestCase):
    model = Site

    @classmethod
    def setUpTestData(cls):
        cls.sites = [
            Site.objects.create(name=f'Site {i}', slug=f'site-{i}')
            for i in range(1, 4)
        ]

    def test_list_sites(self):
        """Test site list view"""
        response = self.client.get(reverse('dcim:site_list'))
        self.assertHttpStatus(response, 200)

    def test_view_site(self):
        """Test site detail view"""
        site = self.sites[0]
        response = self.client.get(site.get_absolute_url())
        self.assertHttpStatus(response, 200)
        self.assertContains(response, site.name)
```

---

## Common Code Patterns

### Creating a New Model

```python
# 1. Define model in models/
from netbox.models import PrimaryModel

class NetworkSegment(PrimaryModel):
    name = models.CharField(max_length=100)
    vlan = models.ForeignKey('ipam.VLAN', on_delete=models.PROTECT)
    description = models.CharField(max_length=200, blank=True)

    class Meta:
        ordering = ('name',)

    def __str__(self):
        return self.name

# 2. Create migration
python netbox/manage.py makemigrations dcim

# 3. Create form in forms/model_forms.py
from utilities.forms import NetBoxModelForm

class NetworkSegmentForm(NetBoxModelForm):
    class Meta:
        model = NetworkSegment
        fields = ('name', 'vlan', 'description', 'tags')

# 4. Create table in tables/
from utilities.tables import NetBoxTable

class NetworkSegmentTable(NetBoxTable):
    name = tables.Column(linkify=True)

    class Meta(NetBoxTable.Meta):
        model = NetworkSegment
        fields = ('pk', 'name', 'vlan', 'description')

# 5. Create filterset
from utilities.filtersets import NetBoxModelFilterSet

class NetworkSegmentFilterSet(NetBoxModelFilterSet):
    class Meta:
        model = NetworkSegment
        fields = ('name', 'vlan')

# 6. Create views in views.py
from utilities.views import ObjectView, ObjectListView, ObjectEditView

class NetworkSegmentView(ObjectView):
    queryset = NetworkSegment.objects.all()

class NetworkSegmentListView(ObjectListView):
    queryset = NetworkSegment.objects.all()
    table = NetworkSegmentTable
    filterset = NetworkSegmentFilterSet

# 7. Create API serializer
from netbox.api.serializers import NetBoxModelSerializer

class NetworkSegmentSerializer(NetBoxModelSerializer):
    class Meta:
        model = NetworkSegment
        fields = '__all__'

# 8. Create API viewset
from netbox.api.viewsets import NetBoxModelViewSet

class NetworkSegmentViewSet(NetBoxModelViewSet):
    queryset = NetworkSegment.objects.all()
    serializer_class = NetworkSegmentSerializer

# 9. Register URLs
# In urls.py and api/urls.py
```

---

## Important File Paths Reference

**Core Framework**:
- `netbox/netbox/settings.py` - Django settings
- `netbox/netbox/urls.py` - Root URL configuration
- `netbox/netbox/registry.py` - Central registry
- `netbox/netbox/models/` - Base model classes
- `netbox/netbox/models/features.py` - Model mixins
- `netbox/netbox/signals.py` - Custom signals

**Utilities**:
- `netbox/utilities/views.py` - View mixins and helpers
- `netbox/utilities/forms/` - Form classes and mixins
- `netbox/utilities/tables/` - Table classes
- `netbox/utilities/filtersets.py` - FilterSet base classes
- `netbox/utilities/permissions.py` - Permission helpers
- `netbox/utilities/querysets.py` - RestrictedQuerySet
- `netbox/utilities/urls.py` - URL generation helpers
- `netbox/utilities/testing/` - Test base classes

**API**:
- `netbox/netbox/api/viewsets/` - ViewSet base classes
- `netbox/netbox/api/serializers/` - Serializer base classes
- `netbox/netbox/api/authentication.py` - Authentication
- `netbox/netbox/graphql/schema.py` - GraphQL schema

**Plugin System**:
- `netbox/netbox/plugins/__init__.py` - PluginConfig
- `netbox/netbox/plugins/registration.py` - Plugin registration
- `netbox/netbox/plugins/urls.py` - Plugin URL routing

**Core Apps** (repeat pattern for each app):
- `netbox/<app>/models/` - Data models
- `netbox/<app>/forms/` - Forms
- `netbox/<app>/tables/` - Tables
- `netbox/<app>/filtersets.py` - FilterSets
- `netbox/<app>/views.py` - Views
- `netbox/<app>/urls.py` - URL routing
- `netbox/<app>/api/` - API implementation
- `netbox/<app>/tests/` - Tests

**Extras**:
- `netbox/extras/models/customfields.py` - CustomField
- `netbox/extras/models/scripts.py` - Script system
- `netbox/extras/scripts.py` - Script base classes
- `netbox/extras/webhooks.py` - Webhook delivery
- `netbox/extras/events.py` - Event processing

**Testing & CI**:
- `.github/workflows/ci.yml` - GitHub Actions
- `pyproject.toml` - Tool configuration
- `ruff.toml` - Linting rules

---

## Data Model Philosophy

NetBox models represent the **intended state** of network infrastructure, not operational state. It doesn't interact with network nodes directly; rather, it makes data available programmatically to automation, monitoring, and assurance tools.

**Key Design Principles**:
- Comprehensive inter-linking between models (e.g., Devices → Interfaces → IPs → VLANs → Sites)
- Generic relations via Django's ContentType framework for extensibility
- Immutable change log for all modifications
- Support for multi-tenancy and flexible permissions
- Custom validation and protection rules
- Feature-based architecture using mixins
- RestrictedQuerySet for permission enforcement at database level

**Model Relationships**:
- ForeignKey: One-to-many (e.g., Device → Site)
- ManyToMany: Many-to-many (e.g., VLAN ← → Interface via tagged_vlans)
- GenericForeignKey: Flexible relationships (e.g., IPAddress → Interface or VMInterface)
- Reverse relations: Automatic via Django ORM (e.g., site.devices.all())

---

## Contributing Guidelines

### For Upstream NetBox

From CONTRIBUTING.md:

- **No AI-generated code**: All contributions must be entirely original work
- **Branch**: Base new PRs off `main` branch (trunk-based development)
- **Issue First**: Open and get assigned an issue before submitting a PR
- **Tests Required**: All new functionality must include relevant tests
- **Code Quality**:
  - Python syntax must be valid
  - All tests must pass: `./manage.py test`
  - PEP 8 compliance (line length 120 chars, configured in `ruff.toml`)
  - Ruff linting must pass: `ruff check netbox/`
  - Frontend: ESLint, TypeScript, Prettier compliance
- **Changelog**: Maintainers handle changelog entries (avoid in PRs to prevent conflicts)
- **Documentation**: Update docs for new features

### For This Repository (Josephpaik/netbox25)

When working on repository-specific features:

- **Korean Translations**:
  - Translations are in `netbox/translations/`
  - Follow Django i18n conventions
  - Test both Korean and English interfaces

- **IDC Scenario**:
  - CSV templates must maintain correct field order and dependencies
  - Test import/export functionality after changes
  - Update documentation in `idc_scenario/` directory

- **Setup Scripts**:
  - Test on clean macOS/Rocky Linux installations when possible
  - Ensure idempotency (scripts can be run multiple times safely)
  - Update version pinning carefully

---

## Additional Resources

### Official NetBox Resources
- **Official Documentation**: https://docs.netbox.dev/
- **API Documentation**: Available at `/api/schema/swagger-ui/` and `/api/schema/redoc/`
- **Plugin Tutorial**: https://github.com/netbox-community/netbox-plugin-tutorial
- **Community**: GitHub Discussions and NetDev Slack (#netbox channel)
- **Demo Instance**: https://demo.netbox.dev/
- **Source Repository**: https://github.com/netbox-community/netbox

### Repository-Specific Resources (Josephpaik/netbox25)
- **Korean Installation Guide**: `MACBOOK_INSTALL_GUIDE.md`
- **Korean Quickstart Checklist**: `QUICKSTART_CHECKLIST.md`
- **IDC Scenario Documentation**:
  - Overview: `idc_scenario/README.md`
  - Summary: `idc_scenario/SUMMARY.md`
  - Usage Guide: `idc_scenario/USAGE_GUIDE.md`
- **Setup Scripts**:
  - macOS: `setup_macos.sh`
  - Rocky Linux: `setup_rocky.sh`
  - Upgrade: `upgrade.sh`

### Quick Reference Files
- **Contributing**: `CONTRIBUTING.md`
- **Security**: `SECURITY.md`
- **License**: `LICENSE.txt`
- **Requirements**: `requirements.txt`, `base_requirements.txt`
- **Project Config**: `pyproject.toml`, `ruff.toml`

---

*This comprehensive guide covers the essential architecture, patterns, and implementation details needed to work effectively with the NetBox codebase. For specific implementation details not covered here, refer to the source code or official documentation.*

## Summary for AI Assistants

When working with this repository, remember:

1. **This is a fork** with Korean localization and IDC scenario features
2. **Use automated setup** when possible (`setup_macos.sh` or `setup_rocky.sh`)
3. **Test data is available** in `idc_scenario/` for realistic scenarios
4. **Code quality** is enforced with Ruff (line length: 120, Python 3.10+)
5. **Django patterns** follow NetBox conventions (PrimaryModel, NetBoxModelForm, etc.)
6. **API-first design** - REST API and GraphQL are first-class citizens
7. **Permission system** uses RestrictedQuerySet for object-level permissions
8. **Change logging** is automatic for all PrimaryModel objects
9. **Korean documentation** is available for non-English users
10. **Import order matters** for CSV data (Sites → Manufacturers → DeviceTypes → Devices → ...)

For detailed architecture information, see the extensive sections above on Models, Views, Forms, Tables, API, Permissions, Scripts, Webhooks, and Testing.
