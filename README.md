Please see the documentation for the installation !!!


# Installing with OVH :

## Système de raid pour les disques : 

""si soft raid OK (voir lors de l'instalation pour les disques) sinon : ""
https://docs.ovh.com/gb/en/dedicated/using-the-maximum-amount-of-disk-space/

## Setup du network :

Checker la doc : https://docs.ovh.com/gb/en/dedicated/network-bridging/

Voir ces threads : http://community.ovh.com/t/proxmox-6-probleme-reseau-bridge-avec-ip-failover/24832/6


Il faut rajouter cette config sur le proxmox :
``
auto vmbr0
iface vmbr0 inet static
address full.ip.man.server
netmask 255.255.255.255
gateway full.ip.man_server.254
broadcast full.ip.man_server.255

    post-up route add full.ip.man.server dev vmbr0
    post-up route add first.ip.fail.over/32 dev vmbr0
    post-down route del full.ip.man.server dev vmbr0
    post-down route add first.ip.fail.over/32 dev vmbr0

    bridge_ports name_physique_interface_like_eth0
    bridge_stp off
    bridge_fd 0
``
