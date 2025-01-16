# Downloading git repo directly to /etc/nixos

### Init git (most likely need to run with super user priviledges, as in sudo for example)


cd /etc/nixos

git init

git remote add origin git@github.com:juiveli/nixOsConfig.git

git fetch origin

git checkout -b main --track origin/main --force

### Then rebuild your nixOs###

sudo nixos-rebuild switch --flake /etc/nixos#**profile-name**

***so for example where profile-name is replaced*** 

sudo nixos-rebuild switch --flake /etc/nixos#nixos-test


### Options for profiles are

nixos-test

main-pc

## To update

cd /etc/nixos

sudo git pull

sudo nixos-rebuild switch

# Developing

In order to run different profiles, you need to copy your hardware-configuration files to profiles

First make sure that you do not accidentally push that change by telling git to ignore that file

***Run following command:***

git update-index --no-assume-unchanged ./profiles/**profile-name**/hardware-configuration.nix

***so for example where profile-name is replaced*** 

git update-index --no-assume-unchanged ./profiles/nixos-test/hardware-configuration.nix
