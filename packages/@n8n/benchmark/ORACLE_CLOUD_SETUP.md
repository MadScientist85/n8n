# Quick Start: Deploy n8n Benchmarking to Oracle Cloud

This guide provides step-by-step instructions for deploying the n8n benchmark infrastructure to Oracle Cloud Infrastructure (OCI).

## Prerequisites

Before you begin, ensure you have:

1. **Oracle Cloud Account**: Active OCI account with a compartment created
2. **OCI CLI**: Installed and configured ([Installation Guide](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm))
3. **Terraform**: Version 1.8.5 or higher ([Download](https://www.terraform.io/downloads.html))
4. **Node.js**: Version 22.16 or higher
5. **pnpm**: Package manager

## Step 1: Configure OCI Credentials

### Option A: Using OCI CLI Configuration

Run the configuration wizard:

```bash
oci setup config
```

This creates `~/.oci/config` with your credentials.

### Option B: Using Environment Variables

```bash
export OCI_TENANCY_OCID="ocid1.tenancy.oc1..aaaaaaaa..."
export OCI_USER_OCID="ocid1.user.oc1..aaaaaaaa..."
export OCI_FINGERPRINT="aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99"
export OCI_PRIVATE_KEY_PATH="~/.oci/oci_api_key.pem"
export OCI_REGION="us-ashburn-1"
```

## Step 2: Configure Terraform

Navigate to the benchmark package:

```bash
cd packages/@n8n/benchmark
```

Copy and edit the Terraform variables:

```bash
cp infra-oci/terraform.tfvars.example infra-oci/terraform.tfvars
```

Edit `infra-oci/terraform.tfvars` and set your compartment OCID:

```hcl
compartment_ocid = "ocid1.compartment.oc1..aaaaaaaa..."

# Optional: customize region, instance shape, resources
# region = "us-ashburn-1"
# instance_shape = "VM.Standard.E4.Flex"
# instance_ocpus = 8
# instance_memory_in_gbs = 32
```

To find your compartment OCID:

```bash
oci iam compartment list --all
```

## Step 3: Provision Infrastructure

From the benchmark package directory:

```bash
pnpm provision-cloud-env --cloud-provider=oci
```

This will:
- Initialize Terraform
- Create a Virtual Cloud Network (VCN)
- Launch a compute instance
- Configure networking and security
- Set up SSH access

The provisioning takes approximately 5-10 minutes.

## Step 4: Verify Deployment

Check the outputs:

```bash
cd infra-oci
terraform output
```

You should see:
- `ip`: Public IP address of the instance
- `ssh_username`: SSH username (benchmark)
- `vm_name`: Name of the VM

## Step 5: Run Benchmarks

From the benchmark package root:

```bash
# Run all benchmark scenarios
pnpm benchmark-in-cloud --cloud-provider=oci

# Run specific benchmark scenario
pnpm benchmark --env cloud --cloud-provider=oci single-webhook

# Run with custom parameters
pnpm benchmark --env cloud --cloud-provider=oci --vus=10 --duration=2m
```

## Step 6: Connect to Instance (Optional)

To SSH into the instance for debugging:

```bash
cd infra-oci

# Extract private key
terraform output -raw ssh_private_key > privatekey.pem
chmod 600 privatekey.pem

# Connect
ssh -i privatekey.pem benchmark@$(terraform output -raw ip)
```

## Step 7: Clean Up

When finished, destroy all resources:

```bash
pnpm destroy-cloud-env --cloud-provider=oci
```

⚠️ **Important**: Always destroy resources when not in use to avoid charges.

## Customizing the Instance

Edit `infra-oci/terraform.tfvars` to customize:

### Use Always-Free Tier (Arm-based)

```hcl
instance_shape = "VM.Standard.A1.Flex"
instance_ocpus = 4
instance_memory_in_gbs = 24
```

### Use More Powerful Instance

```hcl
instance_shape = "VM.Standard.E4.Flex"
instance_ocpus = 16
instance_memory_in_gbs = 64
instance_boot_volume_size_in_gbs = 200
```

### Use Different Region

```hcl
region = "eu-frankfurt-1"  # or any other OCI region
```

After making changes, run:

```bash
pnpm provision-cloud-env --cloud-provider=oci
```

## Common Issues

### Authentication Errors

**Error**: "Service error:NotAuthenticated"

**Solution**: Verify your OCI credentials:
```bash
oci iam region list  # Test if credentials work
```

### Quota Exceeded

**Error**: "Out of capacity" or "Service limit exceeded"

**Solutions**:
1. Request quota increase in OCI Console
2. Try different region or availability domain
3. Use smaller instance shape

### Cannot SSH to Instance

**Solutions**:
1. Verify instance is running: `terraform output ip`
2. Check private key permissions: `chmod 600 privatekey.pem`
3. Wait 1-2 minutes for cloud-init to complete
4. Check security list allows SSH from your IP

### Terraform State Issues

If Terraform state is lost or corrupted:

1. Manual cleanup from OCI Console
2. Remove state file: `rm infra-oci/terraform.tfstate*`
3. Re-provision: `pnpm provision-cloud-env --cloud-provider=oci`

## Cost Considerations

### Always-Free Tier Eligible

- VM.Standard.A1.Flex: Up to 4 OCPUs, 24 GB RAM (Arm-based)
- VM.Standard.E2.1.Micro: 1 OCPU, 1 GB RAM (x86)

### Pay-as-You-Go Pricing

The default configuration (VM.Standard.E4.Flex, 8 OCPUs, 32 GB) is **not** free tier eligible.

Approximate costs (pay-as-you-go):
- VM.Standard.E4.Flex (8 OCPU, 32 GB): ~$0.20/hour
- Storage (100 GB boot volume): ~$0.03/day

💡 **Tip**: Always destroy resources after use to minimize costs.

## Additional Resources

- [OCI Documentation](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [Detailed OCI Setup Guide](./infra-oci/README.md)
- [Benchmark Tool Documentation](./README.md)
- [Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)

## Support

For issues or questions:
1. Check the [detailed OCI README](./infra-oci/README.md)
2. Review Terraform logs with `--debug` flag
3. Check OCI Console for resource status
4. Open an issue on GitHub

---

**Quick Commands Reference**

```bash
# Provision
pnpm provision-cloud-env --cloud-provider=oci

# Run benchmarks
pnpm benchmark-in-cloud --cloud-provider=oci

# Destroy
pnpm destroy-cloud-env --cloud-provider=oci

# SSH to instance
ssh -i infra-oci/privatekey.pem benchmark@<IP>
```
