## Examples and snippets to use with the `ey-core console`

### Getting started

With the _ey-core_ gem comes the `ey-core console` utility which allows to query the CoreAPI interactively.  Below are a series of snippets with commands that will allow actions that normally are done through the EY dashboard, and others which aren't implemented yet but the CoreAPI already supports.

The backend will automatically allow/reject actions based on the api token the console is using.  Upon a successful `ey-core login` said token is written on `$HOME/.ey-core` and picked up from there by the console.  It's a good practice to issue `ey-core whoami` before opening the console to double check that the desired user is logged in.

- Addresses
   - [List addresses allocated to the account](address.md#list-addresses-on-an-account)
   - [Provision a new address](address.md#provision-new-address)
   - [Attach an address to an instance/server](address.md#attach-address-to-instance)
   - [Detach an address from an instance/server](address.md#detach-address-from-instance)

