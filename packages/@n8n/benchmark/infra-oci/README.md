# Oracle Cloud Infrastructure (OCI) Deployment

This directory contains Terraform configuration to deploy n8n benchmark infrastructure on Oracle Cloud Infrastructure.

## Prerequisites

1. **Oracle Cloud Account**: You need an active OCI account with appropriate permissions
2. **OCI CLI**: Install and configure the [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
3. **Terraform**: Install [Terraform](https://www.terraform.io/downloads.html) v1.8.5 or higher

## Setup

### 1. Configure OCI CLI

Run the OCI CLI configuration wizard:

```bash
oci setup config
```

This will create a configuration file at `~/.oci/config` with your credentials.

Alternatively, you can set the following environment variables:

```bash
export OCI_TENANCY_OCID="ocid1.tenancy.oc1..aaaaaaaa..."
export OCI_USER_OCID="ocid1.user.oc1..aaaaaaaa..."
export OCI_FINGERPRINT="aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99"
export OCI_PRIVATE_KEY_PATH="~/.oci/oci_api_key.pem"
export OCI_REGION="us-ashburn-1"
```

### 2. Configure Terraform Variables

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and set your compartment OCID:
   ```hcl
   compartment_ocid = "ocid1.compartment.oc1..aaaaaaaa..."
   ```

3. (Optional) Customize other settings like region, instance shape, etc.

### 3. Deploy Infrastructure

Initialize Terraform:

```bash
terraform init
```

Review the planned changes:

```bash
terraform plan
```

Deploy the infrastructure:

```bash
terraform apply
```

### 4. Get Connection Information

After deployment, retrieve the connection information:

```bash
# Get the public IP
terraform output ip

# Get the SSH username
terraform output ssh_username

# Save the SSH private key
terraform output -raw ssh_private_key > privatekey.pem
chmod 600 privatekey.pem
```

### 5. Connect to the Instance

```bash
ssh -i privatekey.pem benchmark@$(terraform output -raw ip)
```

## Clean Up

To destroy all resources:

```bash
terraform destroy
```

## Instance Configuration

### Default Configuration

- **Shape**: VM.Standard.E4.Flex (AMD EPYC 7J13)
- **OCPUs**: 8
- **Memory**: 32 GB
- **Boot Volume**: 100 GB
- **OS**: Ubuntu 22.04 LTS

### Customization

You can customize the instance configuration in `terraform.tfvars`:

```hcl
# Use a different shape
instance_shape = "VM.Standard.E4.Flex"

# Adjust resources
instance_ocpus = 16
instance_memory_in_gbs = 64
instance_boot_volume_size_in_gbs = 200
```

## Available Shapes

Some commonly used shapes for benchmarking:

- **VM.Standard.E4.Flex**: AMD EPYC 7J13, flexible OCPUs (1-64) and memory
- **VM.Standard3.Flex**: Intel Xeon Platinum 8358, flexible OCPUs (1-32) and memory
- **VM.Standard.A1.Flex**: Ampere Altra, Arm-based, flexible OCPUs (1-80) and memory
- **VM.Optimized3.Flex**: Intel Xeon 8375C, optimized for compute-intensive workloads

## Networking

The configuration creates:

- Virtual Cloud Network (VCN) with CIDR 10.0.0.0/16
- Public subnet with CIDR 10.0.0.0/24
- Internet Gateway for public internet access
- Security list allowing SSH (port 22) from anywhere
- Public IP assigned to the instance

## Troubleshooting

### Cannot connect via SSH

1. Verify the instance is running:
   ```bash
   terraform output ip
   ```

2. Check security list allows SSH from your IP
3. Verify the private key permissions:
   ```bash
   chmod 600 privatekey.pem
   ```

### Terraform apply fails

1. Verify your OCI credentials are configured correctly
2. Check that the compartment OCID is valid
3. Ensure you have sufficient quotas for the requested resources
4. Try a different availability domain if resources are not available

### Resource quota exceeded

If you encounter quota errors, you can:
- Request a quota increase in the OCI console
- Try a different region or availability domain
- Use a smaller instance shape

## Cost Considerations

Always-Free Tier eligible resources:
- VM.Standard.A1.Flex: Up to 4 OCPUs and 24 GB memory (Arm-based)
- VM.Standard.E2.1.Micro: 1 OCPU and 1 GB memory

Note: The default configuration (VM.Standard.E4.Flex with 8 OCPUs) is NOT part of the Always-Free tier and will incur costs.

Remember to destroy resources when not in use to avoid charges:
```bash
terraform destroy
```
