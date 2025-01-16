# Downloading git repo directly to /etc/nixos

### Init git (most likely need to run with super user priviledges, as in sudo for example)


cd /etc/nixos

git init

git remote add origin git@github.com:juiveli/nixOsConfig.git

git fetch origin

git checkout -b main --track origin/main --force

### Then rebuild your nixOs

#replace profile-name with profilenames, so for example sudo nixos-rebuild switch --flake /etc/nixos#nixos-test

sudo nixos-rebuild switch --flake /etc/nixos#profile-name


### Options for profiles are

nixos-test

main-pc

## To update

cd /etc/nixos

sudo git pull

sudo nixos-rebuild switch
