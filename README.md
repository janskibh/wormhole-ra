# Wormhole Remote Access

WRA is a remote access utility based on SSH tunneling, it allows you to expose ressources from your local network to the internet without the need of having a box with a public IP.

## Requirements
- A linux server.
- A VPS on the internet with SSH.
  
## Installation

Install git
`sudo apt update && sudo apt install git`

Clone the repo and enter the wormhole-ra directory on your local server.
`git clone https://github.com/janskibh/wormhole-ra && cd wormhole-ra`

Run install.sh
`./install.sh`

Copy the pair of keys printed at the end of the installation and paste them at the end of `/home/<sshuser>/.ssh/authorized_keys` on your VPS.

Change `GatewayPorts` to `yes` in `/etc/ssh/sshd_config` on your VPS.

## Configuration

Define The SSH_USER and SSH_HOST ans add redirections in `/etc/wormhole-ra/tunnel.conf`

When the redirections are created, you can access your ressources at [vps ip]:[public port]

If you have any troubles, please report them to bellon@ieee.org.
If you have questions, you can contact me on Discord -> @jan.mp4

Enjoy !
