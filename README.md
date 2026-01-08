 # nix-podman-quadlet-collection


A library of rootless Podman services for NixOS. 


## Model

All services here follow a model

* **Rootless:** Services run as a dedicated system user by default. However, the homeManagerModule can be imported separately to run under your own user account

* **Locked:** If folders are created, they have `0700` permissions. It is possible also to create your own folders.

  


## Generic Debugging Pattern

If using system user


**systemctl:**

`sudo systemctl --machine=<USER>@.host --user status <SERVICE>.service`


**journalctl:**

`sudo -u <USER> DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u <USER>)/bus journalctl --user -u <SERVICE>.service -f`


---

## Service Index

Each service has its own `README.md` with specifics of them

* [appflowy](./appflowy/README.md)
* [caddy](./caddy/README.md)
* [chia](./chia/README.md)
* [mmx](./mmx/README.md)
* [nicehash](./nicehash/README.md)
* [sshServerJohannes](./sshServerJohannes/README.md)
* [testServer](./testServer/README.md)


## Usage:


### 1. Add to your Flake inputs

   

   

```

{

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";


    home-manager = {

      url = "github:nix-community/home-manager/release-25.11";

      inputs.nixpkgs.follows = "nixpkgs";

    };


    nix-podman-quadlet-collection = {

      url = "github:juiveli/nix-podman-quadlet-collection";

      inputs.nixpkgs.follows = "nixpkgs";

      inputs.home-manager.follows = "home-manager";

      inputs.quadlet-nix.follows = "quadlet-nix"; # Optional

    };


    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

  };

}


```




### 2. in config, you have options


#### Option A: Import everything:

`imports = [nix-podman-quadlet-collection.nixosModules.quadlet-collection] ` for all, or if you want specific, then:


#### Option B: Import a specific service:

`imports = [nix-podman-quadlet-collection.nixosModules.<containersFolderName>.nixosModules.service] `


#### Option C: Use with homeManager

if you want to use homeManagerModule instead, please check each services own documentation page


### 3. in config, activate the module after importing

Refer to each services manual page


For example:


```

    services.nix-podman-chia-service = {

        enable = true;

        homeStateVersion = "25.11";

    };

``` 
