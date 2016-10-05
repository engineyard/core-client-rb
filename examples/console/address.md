# IP Addresses

It's advised for each operation to capture the request via an *<operation>_prov_req* variable, which will hold the operation's status.  The snippets below just wait for the request to finish (or timeout in 300sec), but the progress can be tracked issuing `<operation>_prov_req.reload` regularly.

-

<a name="list-addresses-on-an-account"></a>
### List IPs addresses allocated to an account

```
addresses
```

-

<a name="provision-new-address"></a>
### Provision a new IP address on the account

```
new_address_specs = {:provider_id => "23952", :location => "us-east-1"}
address_prov_req = addresses.create(new_eip_specs)
address_prov_req.ready!(300)
```

-

<a name="attach-address-to-instance"></a>
### Attach an address to an instance

```
addresses
address = addresses.first(ip_address: "111.222.333.444")
attach_prov_req = address.attach(servers.first(provisioned_id: "i-aabbccdd"))
attach_prov_req.ready!(300)
```

-

<a name="detach-address-from-instance"></a>
### Detach an address from an instance

```
addresses
eip = addresses.first(ip_address: "111.222.333.444")
detach_prov_req = eip.detach
detach_prov_req.ready!(300)
```

-


