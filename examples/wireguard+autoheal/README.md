# Run Wireguard with AutoHeal with docker-compose

AutoHeal is a tool to monitor and restart unhealthy docker containers.

## 1. Fist get the files and prepare your folder:

```bash
git clone --no-checkout https://github.com/infra7ti/docker-wireguard.git
cd docker-wireguard
git reset
git checkout origin/master examples/wireguard+autoheal
mv examples/wireguard+autoheal/* .
rm -rf examples .git

```

## 2. Edit the file compose.override.yml and replace when values starts with  "<" and ends with ">":

```yaml
name: example-wireguard

services:
  autoheal:
    environment:
      AUTOHEAL_CONTAINER_LABEL: example-wireguard-autoheal

  server:
    environment:
      PEERS: "example"
      PEERDNS: "10.51.82.1,1.1.1.1,8.8.8.8"
      INTERNAL_SUBNET: 10.51.82.0
      ALLOWEDIPS: "10.51.82.0/24,192.168.51.0/24,192.168.15.0/24"
      SERVERPORT: 51820
    labels:
      example-wireguard-autoheal: true
    networks:
      default:
        ipv4_address: 192.168.51.82
    ports:
      - 51820:51820/udp

networks:
  default:
    name: example-wireguard
    external: true
```

## 3. Finally start your containers running:

```bash
docker-compose up -d
```
