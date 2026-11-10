# Better Stack Oracle Cloud integration

This Terraform stack sends metrics and logs from an Oracle Cloud Infrastructure tenancy to [Better Stack](https://betterstack.com).

## How it works

The stack runs in OCI Resource Manager inside your tenancy. Connector Hub reads **metrics** from OCI Monitoring and **logs** from OCI Logging. It sends them in batches to a forwarder Function. The Function compresses each batch and sends it to Better Stack over HTTPS.

Better Stack never connects to your tenancy. Data leaves your tenancy only through the Function. The only secret that the stack keeps in your tenancy is the Better Stack source token, in the configuration of the Function.

## Quick start

Before you start, sign in to the **home region** of your tenancy. Use a user who can create compartments and policies in the root compartment.

1. [Create an Oracle Cloud source in Better Stack](https://telemetry.betterstack.com/team/0/sources/new?platform=oracle_cloud).
2. On the **Ingest** tab of the source, click **Deploy to Oracle Cloud**.
3. Accept the Oracle Terms of Use and click **Next**.
4. Paste the **Source token** of your source and click **Next**. The **Ingesting host** is already filled in.
5. Make sure that **Run apply** is selected, then click **Create**.

The stack creates a compartment with the name `betterstack`. If your tenancy already has a compartment with this name, remove or rename it first.

The stack sends metrics and logs from the home region only.

## What the stack creates

- A `betterstack` compartment for all the resources below.
- A Function application for the forwarder. It runs in a VCN with a private subnet. A NAT gateway lets the Function reach Better Stack.
- One Connector Hub for logs, and one or more Connector Hubs for metrics. Each Connector Hub takes up to 5 compartments and 50 metric namespaces. A large tenancy can need a higher Connector Hub service limit.
- A policy that lets the Connector Hubs read metrics and logs, and call the Function.

When the stack runs, it finds the compartments that have metrics in the selected namespaces. After you add compartments or use new services, apply the stack again.

## Uninstall

1. Go to **Developer Services → Resource Manager → Stacks** and select the Better Stack stack.
2. Click **Destroy**.

This takes about 15 minutes. Most of this time goes to removing the `betterstack` compartment.

## License

[MIT](LICENSE)
