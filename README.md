# Better Stack Oracle Cloud integration

Terraform stack that connects an Oracle Cloud Infrastructure tenancy to [Better Stack](https://betterstack.com) for metric and log forwarding.

## How it works

The stack runs in OCI Resource Manager inside your tenancy. Connector Hub reads **metrics** from OCI Monitoring and **logs** from OCI Logging, batches them and passes each batch to a forwarder Function, which compresses it and sends it to Better Stack over HTTPS.

Better Stack never connects to your tenancy. Data only leaves through the Function, and the only secret stored in your tenancy is the Better Stack source token, kept in the Function's configuration.

## Quick start

[Create a new Oracle Cloud source in Better Stack](https://telemetry.betterstack.com/team/0/sources/new?platform=oracle_cloud). Its **Ingest** tab has a **Deploy to Oracle Cloud** button that opens this stack in Resource Manager. Paste the source's **Ingesting host** and **Source token** into the stack form, make sure **Run apply** is selected, and click **Create**.

Sign in to your tenancy's **home region** as a user who can create compartments and policies in the root compartment. The stack forwards metrics and logs from the home region. It creates a compartment named `betterstack`, so remove or rename any existing compartment with that name first.

## What gets deployed

- A `betterstack` compartment that holds every resource below.
- A Function application running the forwarder, in a VCN with a private subnet and a NAT gateway so the Function can reach Better Stack.
- A Connector Hub for logs, and one or more Connector Hubs for metrics. Each takes up to 5 compartments and 50 metric namespaces, so a large tenancy may need a higher Connector Hub service limit.
- A policy that lets the connectors read metrics and logs, and invoke the Function.

The stack looks up which compartments have metrics in the selected namespaces when it runs. Apply the stack again after you add compartments or start using new services.

## Uninstall

Go to **Developer Services → Resource Manager → Stacks**, select the Better Stack stack, and click **Destroy**.

## License

[MIT](LICENSE)
