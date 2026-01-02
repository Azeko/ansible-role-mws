# MWS Cloud Platform Ansible Role

An Ansible role for provisioning virtual machines and configuring networking in the MWS cloud platform.

## Requirements

- Ansible 2.9 or higher
- `mws` CLI tool installed and configured
- MWS credentials configured (via environment variables)
- Python 3.x on the control node

## Installation

1. Install the role in your Ansible roles directory:
   ```bash
   git clone <repository-url> ansible-role-mws
   ```

2. Or add to your `requirements.yml`:
   ```yaml
   - src: <repository-url>
     name: ansible-role-mws
   ```

## Authentication

The role expects the `mws` CLI tool to be installed and authenticated. Credentials should be configured via environment variables as per MWS documentation.

Ensure the `mws` command is available in your PATH and properly authenticated before running playbooks.

## Role Variables

### Required Variables

- `mws_project`: MWS project name (required)

### Optional Variables

- `mws_zone`: Default zone for resources (default: `ru-central1-a`)
- `mws_default_vm_type`: Default VM type (default: `vmTypes/gen-2-4`)
- `mws_default_disk_type`: Default disk type (default: `diskTypes/nbs-pl2`)
- `mws_default_disk_iops`: Default disk IOPS (default: `1000`)
- `mws_default_boot_disk_size`: Default boot disk size (default: `20GB`)
- `mws_default_boot_disk_image`: Default boot disk source image (default: `compute/projects/mws-ubuntu/images/mws-ubuntu-2404-lts-v20250529`)
- `mws_default_network_mtu`: Default network MTU (default: `1500`)
- `mws_default_network_internet_access`: Default network internet access (default: `true`)
- `mws_default_network_name`: Default network name (used when network is not explicitly specified in resources)
- `mws_default_cloud_init`: Default cloud-init template (default: `cloud-init/basic.yml`)
- `mws_compute_vm_ssh_username`: SSH username for cloud-init templates (optional)
- `mws_compute_vm_ssh_public_key`: SSH public key for cloud-init templates (optional)

### Resource Lists

Define resources to create using the following list variables:

#### Networks

```yaml
networks:
  - name: "my-network"
    description: "My VPC network"  # optional
    internet_access: true  # optional, defaults to mws_default_network_internet_access
    mtu: 1500  # optional, defaults to mws_default_network_mtu
```

#### Subnets

```yaml
subnets:
  - name: "my-subnet"
    network_name: "my-network"  # optional if mws_default_network_name is set
    cidr: "192.168.0.0/24"
```

#### External Static IP Addresses

```yaml
external_static_addresses:
  - name: "my-external-ip"
```

#### Private Static IP Addresses

```yaml
private_static_addresses:
  - name: "my-private-ip"
    network_name: "my-network"  # optional if mws_default_network_name is set
    subnet: "my-subnet"
```

Private static addresses can be referenced in firewall rules using the format `private_address:<address-name>` or `private_address:<address-name>/<cidr>`. The role will automatically resolve these references to actual IP addresses.

#### Firewall Rules

```yaml
firewall_rules:
  - name: "allow-ssh"
    network_name: "my-network"  # optional if mws_default_network_name is set
    description: "Allow SSH access"  # optional
    display_name: "Allow SSH"  # optional, defaults to name
    action: "ALLOW"  # ALLOW or DENY
    direction: "INGRESS"  # INGRESS or EGRESS
    proto_ports:
      - "TCP:22"
    priority: 1000  # optional, default: 1000
    active: true  # optional, default: true
    source:
      cidrs: ["0.0.0.0/0"]
    destination:
      cidrs: ["192.168.0.0/24", "private_address:my-private-ip"]
```

#### Disks

```yaml
disks:
  - name: "my-disk"
    size: "50GB"
    zone: "ru-central1-a"  # optional, defaults to mws_zone
    disk_type: "diskTypes/nbs-pl2"  # optional, defaults to mws_default_disk_type
    iops: 2000  # optional, defaults to mws_default_disk_iops
```

#### Virtual Machines

VMs support multiple network interfaces. Cloud-init must be specified as a template file reference from `templates/cloud-init/`:

```yaml
vms:
  - name: "my-vm"
    zone: "ru-central1-a"  # optional, defaults to mws_zone
    vm_type: "vmTypes/gen-2-8"  # optional, defaults to mws_default_vm_type
    power: "ON"  # optional, default: ON
    service_account: "service-account-name"  # optional
    network_interfaces:
      - name: eth0
        network_name: "my-network"  # optional if mws_default_network_name is set
        subnet: "my-subnet"  # required if private_static_address_name is not set
        primary: true
        external_static_address_name: "my-external-ip"  # optional
        private_static_address_name: "my-private-ip"  # optional (if set, subnet can be omitted)
    boot_disk:
      disk_type: "diskTypes/nbs-pl2"  # optional, defaults to mws_default_disk_type
      iops: 1000  # optional, defaults to mws_default_disk_iops
      size: "20GB"  # optional, defaults to mws_default_boot_disk_size
      source_image: "compute/projects/mws-ubuntu/images/mws-ubuntu-2404-lts-v20250529"  # optional, defaults to mws_default_boot_disk_image
    cloud_init: "cloud-init/basic.yml"  # optional, defaults to mws_default_cloud_init
    standard_dns_records: true  # optional, default: true
    additional_disks:
      # Attach existing disk
      - name: "data-disk"
        managed: false
        ref: "projects/{{ mws_project }}/disks/data-disk"
      # Create new managed disk
      - name: "managed-disk"
        managed: true
        disk_type: "diskTypes/nbs-pl2"
        iops: 1000
        size: "50GB"
```

**Available Cloud-init Templates:**
- `cloud-init/basic.yml` - Basic configuration with admin user and common packages (htop, vim, curl, wget, net-tools)

Templates support Jinja2 variables (e.g., `{{ mws_compute_vm_ssh_username }}`, `{{ mws_compute_vm_ssh_public_key }}`). You can create custom templates in `templates/cloud-init/`.

## Dependencies

- Networks must exist before creating subnets
- Networks must exist before creating firewall rules
- Networks must exist before creating private static addresses
- Networks and subnets (or private static addresses) must exist before creating VMs
- External static addresses must exist before referencing them in VM network interfaces
- Private static addresses must exist before referencing them in VM network interfaces or firewall rules
- Disks must exist before referencing them in VM additional_disks (when managed: false)

The role validates dependencies and will fail if they don't exist.

## Example Playbook

See `examples/playbook.yml` for a complete example.

Basic usage:

```yaml
- hosts: localhost
  gather_facts: false
  vars:
    mws_project: "my-project"
    mws_default_network_name: "my-network"
    mws_compute_vm_ssh_username: "admin"
    mws_compute_vm_ssh_public_key: "ssh-ed25519 AAAA..."
  
  roles:
    - ansible-role-mws
  
  vars:
    networks:
      - name: "{{ mws_default_network_name }}"
        description: "My VPC network"
        internet_access: true
    
    subnets:
      - name: "my-subnet"
        cidr: "192.168.0.0/24"
    
    firewall_rules:
      - name: "allow-ssh"
        description: "Allow SSH access"
        display_name: "Allow SSH"
        action: "ALLOW"
        direction: "INGRESS"
        proto_ports:
          - "TCP:22"
        priority: 1000
        source:
          cidrs: ["0.0.0.0/0"]
        destination:
          cidrs: ["192.168.0.0/24"]
    
    vms:
      - name: "my-vm"
        vm_type: "vmTypes/gen-2-8"
        network_interfaces:
          - name: eth0
            subnet: "my-subnet"
            primary: true
        boot_disk:
          size: "20GB"
        cloud_init: "cloud-init/basic.yml"
```

## Idempotency

The role is idempotent - it checks if resources exist before creating them. If a resource already exists, it will be skipped. This allows you to run the playbook multiple times safely.

**Note:** The role does not detect changes to existing resources. If you modify a firewall rule or other resource configuration, the changes will not be applied. The role only creates resources that don't exist.

## License

MIT

## Author Information

This role was created for provisioning infrastructure in the MWS cloud platform.
