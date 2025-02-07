# Wormhole Remote Access

WRA is a remote access utility based on SSH tunneling, it allows you to create an access to ressources in your local network from the internet without creating port redirections on the firewall.

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

Add redirections in `/etc/wormhole-ra/tunnel.conf`

If you have any troubles, please report them to bellon@ieee.org.
If you have questions, you can contact me on Discord -> @jan.mp4

Enjoy !
