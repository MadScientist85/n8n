#!/usr/bin/env zx
/**
 * Provisions the cloud benchmark environment
 *
 * NOTE: Must be run in the root of the package.
 */
// @ts-check
import { which, minimist } from 'zx';
import { TerraformClient } from './clients/terraform-client.mjs';

const args = minimist(process.argv.slice(3), {
	boolean: ['debug'],
	string: ['cloud-provider'],
	default: {
		'cloud-provider': 'azure',
	},
});

const isVerbose = !!args.debug;
const cloudProvider = args['cloud-provider'];

export async function provision() {
	await ensureDependencies(cloudProvider);

	const terraformClient = new TerraformClient({
		isVerbose,
		cloudProvider,
	});

	await terraformClient.provisionEnvironment();
}

async function ensureDependencies(cloudProvider) {
	await which('terraform');
	
	// Check for cloud-specific CLI tools
	if (cloudProvider === 'oci') {
		try {
			await which('oci');
		} catch (error) {
			console.warn('Warning: OCI CLI not found. Make sure OCI credentials are configured via ~/.oci/config or environment variables.');
		}
	} else if (cloudProvider === 'azure') {
		await which('az');
	}
}

provision().catch((error) => {
	console.error('An error occurred while provisioning cloud env:');
	console.error(error);

	process.exit(1);
});
