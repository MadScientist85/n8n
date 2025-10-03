// @ts-check

import path from 'path';
import { $, fs } from 'zx';

/**
 * Get infrastructure directory based on cloud provider
 * @param {string} cloudProvider - 'azure' or 'oci'
 * @returns {object} Paths object with infraCodeDir and terraformStateFile
 */
function getInfraPaths(cloudProvider = 'azure') {
	const infraDir = cloudProvider === 'oci' ? 'infra-oci' : 'infra';
	return {
		infraCodeDir: path.resolve(infraDir),
		terraformStateFile: path.join(path.resolve(infraDir), 'terraform.tfstate'),
	};
}

export class TerraformClient {
	constructor({ isVerbose = false, cloudProvider = 'azure' }) {
		this.isVerbose = isVerbose;
		this.cloudProvider = cloudProvider;
		this.paths = getInfraPaths(cloudProvider);
		this.$$ = $({
			cwd: this.paths.infraCodeDir,
			verbose: isVerbose,
		});
	}

	/**
	 * Provisions the environment
	 */
	async provisionEnvironment() {
		console.log('Provisioning cloud environment...');

		await this.$$`terraform init`;
		await this.$$`terraform apply -input=false -auto-approve`;
	}

	/**
	 * @typedef {Object} BenchmarkEnv
	 * @property {string} vmName
	 * @property {string} ip
	 * @property {string} sshUsername
	 * @property {string} sshPrivateKeyPath
	 *
	 * @returns {Promise<BenchmarkEnv>}
	 */
	async getTerraformOutputs() {
		const privateKeyName = await this.extractPrivateKey();

		return {
			ip: await this.getTerraformOutput('ip'),
			sshUsername: await this.getTerraformOutput('ssh_username'),
			sshPrivateKeyPath: path.join(this.paths.infraCodeDir, privateKeyName),
			vmName: await this.getTerraformOutput('vm_name'),
		};
	}

	hasTerraformState() {
		return fs.existsSync(this.paths.terraformStateFile);
	}

	async destroyEnvironment() {
		console.log('Destroying cloud environment...');

		await this.$$`terraform destroy -input=false -auto-approve`;
	}

	async getTerraformOutput(key) {
		const output = await this.$$`terraform output -raw ${key}`;
		return output.stdout.trim();
	}

	async extractPrivateKey() {
		await this.$$`terraform output -raw ssh_private_key > privatekey.pem`;
		await this.$$`chmod 600 privatekey.pem`;

		return 'privatekey.pem';
	}
}
