# Azure Worker Ingress
This infrastructure deploys the necessary infrastructure and configuration for an Ingress worker in Azure.

The reason why I call this an ingress worker is because it creates a public IP for the VM where it will be running and it should be deployed inside a public network. I.e. a network that can accept connections to this IP from anywhere on the internet.

This will satisfy the condition that basically any client can access it from the internet.

## Public Network requirements
- This module also creates a security group to allow inbound connections on ports 9202 and 9203 as well as outbound in 9201 for connecting to the controller and for updates and internet connection in general.
- (WIP) This security group should also allow connection to Vault for credential retrieval (credential injection).

## Inputs:
