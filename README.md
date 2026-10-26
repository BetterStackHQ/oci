# Better Stack Oracle Cloud integration

Terraform stack that connects an Oracle Cloud Infrastructure tenancy to [Better Stack](https://betterstack.com) for metric and log forwarding.

## How it works

The stack runs in OCI Resource Manager inside your tenancy. Connector Hub reads **metrics** from OCI Monitoring and **logs** from OCI Logging, then passes them to a forwarder Function. The Function batches them and sends them to Better Stack over HTTPS.

Better Stack never connects to your tenancy. Data only leaves through the Function, and the only secret stored in your tenancy is the Better Stack source token.

## Quick start

[Create a new Oracle Cloud source in Better Stack](https://telemetry.betterstack.com/team/t0/sources/new?platform=oci). The source-creation flow hands you a **Deploy to Oracle Cloud** link with every stack variable pre-filled. Click it, review the variables, and click **Create**.

Sign in to your tenancy's home region as a user who can create dynamic groups and policies in the root compartment.

## What gets deployed

- A `betterstack` compartment that holds every resource below.
- In each region you pick, a Function application running the forwarder, a VCN with a private subnet and a NAT gateway so the Function can reach Better Stack, and Connector Hubs for metrics and logs.
- Dynamic groups and policies that let Connector Hub read metrics and logs, and invoke the Function.

## Uninstall

Go to **Developer Services → Resource Manager → Stacks**, select the Better Stack stack, and click **Destroy**.

## License

[MIT](LICENSE)
