# SRLinux and JunOS EVO EVPN interop lab

Ethernet VPN proposes a unified model for VPNs and cloud-based services, by providing a control plane framework that can deliver any type of VPN services.  This lab provides an interoperability use case between  Nokia SR Linux and Juniper JunOS EVO , in a datacenter context.  

A square fabric architecture will be deployed, as represented below:
 - 3 SR Linux routers 7220 D2L and 2 SR Linux L2 switches 7220 D2L
 - 1 JunOS EVO
 - 2 CE Routers 7750 SR-1
 - 3 PE Routers 7750 SR-1
 - 2 hosts clients and 1 server


<p align="center">
  <img width="900" height="400" src="https://github.com/fullstopdev/srlinux-junos-evo-evpn-lab/assets/161751862/1fc52592-83e9-4070-b56c-0193b825ec7a?raw=true">
</p>




## Requirements 

To deploy this lab you need a server with Docker and Containerlab and Internet connectivity.
You also need SROS 23.10R1+ Image and a valid License file.


### SROS Image

The SROS vSIM image file used is 23.10R1, and is available under Nokia's internal registry. 
If you don't have access to it, then you must get the SROS image and manually import it to CLAB following the instructions at [VRNETLAB](https://containerlab.dev/manual/vrnetlab/#vrnetlab).

The steps are:
```bash
# Clone vrnetlab
git clone https://github.com/hellt/vrnetlab && cd vrnetlab

# Download qcow2 vSIM image from Nokia Support Portal (https://customer.nokia.com/support/s) or get one from your Nokia contacts. 

# Change name to “sros-vm-<VERSION>.qcow2”   ### must start with "sros-vm-"

# Upload it to ‘vrnetlab/sros’ directory (e.g. /home/vrnetlab/sros)

# Run ‘make docker-image’ to start the build process

# Verify existing docker images

docker images | grep -E "srlinux|vr-sros"
```

Note: After import the image, edit the yml file with the correct location.
```bash
# replace this 
      image: registry.srlinux.dev/pub/vr-sros:23.10.R1
# with this:
      image: vrnetlab/vr-sros:23.10.R1
```

### License file

SROS vSIMs require a valid license. You need to get a valid license from Nokia and place it in the "license-23.txt" file.
```bash
# Copy/paste the license to the "license-23.txt" file
cd srlinux-junos-evo-evpn-lab/
vi license-23.txt
# press "i" key for insert mode => paste the license => ctl+x to save and exit 
```



## Clone and deploy the git lab on your server

To deploy this lab, you must clone it to your server with "git clone".

```bash
# change to your working directory
cd /home/user/
# Clone the lab to your server
git clone https://github.com/fullstopdev/srlinux-junos-evo-evpn-lab.git
```





## Deploy the lab setup

Use the comand below to deploy the lab:

•	Note: If you imported the SROS image to docker then first edit the yml file with the correct image location as explained above.

```bash
# deploy a lab
cd srlinux-junos-evo-evpn-lab/
clab deploy --topo nokia-evpn-interop.clab.yaml
```



## Accessing the network elements

Once the lab is deployed, the different SROS nodes can be accessed via SSH through their management IP address, given in the summary displayed after the execution of the deploy command. 
It is also possible to reach those nodes directly via their hostname, defined in the topology file. 

```bash
# List the containers
clab inspect -a
+----+--------------+--------------+-------------------------------------------+-----------------------+---------+-----------------+--------------+
| #  |     Name     | Container ID |                   Image                   |         Kind          |  State  |  IPv4 Address   | IPv6 Address |
+----+--------------+--------------+-------------------------------------------+-----------------------+---------+-----------------+--------------+
|  1 | 7750-CORE-1  | a224dca3cb36 | registry.srlinux.dev/pub/vr-sros:23.10.R1 | vr-sros               | running | 172.50.60.31/24 | N/A          |
|  2 | 7750-CORE-2  | 14243658cf5b | registry.srlinux.dev/pub/vr-sros:23.10.R1 | vr-sros               | running | 172.50.60.32/24 | N/A          |
|  3 | 7750-DCIGW-1 | 27abbae52a3e | registry.srlinux.dev/pub/vr-sros:23.10.R1 | vr-sros               | running | 172.50.60.33/24 | N/A          |
|  4 | 7750-DCIGW-2 | faf75a985c8c | registry.srlinux.dev/pub/vr-sros:23.10.R1 | vr-sros               | running | 172.50.60.34/24 | N/A          |
|  5 | 7750-DCIGW-3 | a01acd6609b1 | registry.srlinux.dev/pub/vr-sros:23.10.R1 | vr-sros               | running | 172.50.60.35/24 | N/A          |
|  6 | L2-SW-1      | 559d4733e2b1 | ghcr.io/nokia/srlinux:23.7.2              | nokia_srlinux         | running | 172.50.60.41/24 | N/A          |
|  7 | L2-SW-2      | 632aa6986890 | ghcr.io/nokia/srlinux:23.7.2              | nokia_srlinux         | running | 172.50.60.42/24 | N/A          |
|  8 | client1      | b66ef3e3ff19 | ghcr.io/hellt/network-multitool           | linux                 | running | 172.50.60.11/24 | N/A          |
|  9 | client2      | f5bd3982a861 | ghcr.io/hellt/network-multitool           | linux                 | running | 172.50.60.12/24 | N/A          |
| 10 | gnmic        | 0c40aa5b9dfe | ghcr.io/openconfig/gnmic:0.29.0           | linux                 | running | 172.50.60.21/24 | N/A          |
| 11 | grafana      | 3ae0a43cbc6c | grafana/grafana:9.5.2                     | linux                 | running | 172.50.60.23/24 | N/A          |
| 12 | prometheus   | 448611540a94 | prom/prometheus:v2.35.0                   | linux                 | running | 172.50.60.22/24 | N/A          |
| 13 | server       | 9ded9d616d1e | ghcr.io/hellt/network-multitool           | linux                 | running | 172.50.60.13/24 | N/A          |
| 14 | srl-1        | b84a060b82c4 | ghcr.io/nokia/srlinux:23.7.2              | nokia_srlinux         | running | 172.50.60.51/24 | N/A          |
| 15 | srl-2        | 921af28abd69 | ghcr.io/nokia/srlinux:23.7.2              | nokia_srlinux         | running | 172.50.60.52/24 | N/A          |
| 16 | srl-3        | 83c42e700da7 | ghcr.io/nokia/srlinux:23.7.2              | nokia_srlinux         | running | 172.50.60.53/24 | N/A          |
| 17 | ssh          | 372659348fc7 | netreplica/graphite:webssh2               | linux                 | running | 172.50.60.2/24  | N/A          |
| 18 | vswitch-1    | 4cd57241d133 | vr-vjunosevolved:23.2R1-S1.8-EVO          | juniper_vjunosevolved | running | 172.50.60.54/24 | N/A          |
+----+--------------+--------------+-------------------------------------------+-----------------------+---------+-----------------+--------------+

# reach a SROS node via SSH(admin/admin)
ssh admin@7750-CORE-1
# reach a Nokia SRLinux  node via SSH (admin/NokiaSrl1!)
ssh admin@srl-1
# reach a Juniper JunOS EVO  node via SSH (admin/admin@123)
ssh admin@vswitch-1
# reach Linux clients via docker
docker exec -it client1 bash
```
Check that you can access all equipments.



## SROS Streaming Telemetry

This lab was enhanced with Streaming Telemetry by adding gNIMc, Prometheus and Grafana.

For details please refer to [SR Linux/SROS Streaming Telemetry Lab](https://github.com/srl-labs/srl-sros-telemetry-lab).




### Telemetry stack

The following stack of software solutions has been chosen for this lab:

| Role                | Software                                            | Port               | Link                               | Credentials        |
| ------------------- | --------------------------------------------------- |------------------- | ---------------------------------- |------------------- |
| Telemetry collector | [gnmic](https://gnmic.openconfig.net)               | 57400              |                                    |                    |
| Time-Series DB      | [prometheus](https://prometheus.io)                 | 9090               | http://localhost:9090/graph        |                    |
| Visualization       | [grafana](https://grafana.com)                      | 3000               | http://localhost:3000              | admin/admin        |






### Access details

If you are accessing from a remote host, then replace localhost by the CLAB Server IP address
* Grafana: <http://localhost:3000>. Built-in user credentials: `admin/admin`
* Prometheus: <http://localhost:9090/graph>
 
## Configuration
### Nokia SRLinux port/lag configuration

```bash
 A:srl-1# /interface ethernet-1/50
--{ + candidate shared default }--[ interface ethernet-1/50 ]--
A:srl-1# info
    description SRL-2-50
    admin-state enable
    vlan-tagging true
    transceiver {
        forward-error-correction rs-528
    }
    ethernet {
        port-speed 100G
        hold-time {
            up 30
        }
    }
    subinterface 1 {
        admin-state enable
        ipv4 {
            admin-state enable
            address 100.64.0.0/31 {
            }
        }
        vlan {
            encap {
                single-tagged {
                    vlan-id 1
                }
            }
        }
A:srl-1# /interface lag1
--{ + candidate shared default }--[ interface lag1 ]--
A:srl-1# info
    admin-state enable
    vlan-tagging true
    subinterface 0 {
        type bridged
        vlan {
            encap {
                untagged {
                }
            }
        }
    }
    subinterface 10 {
        type bridged
        vlan {
            encap {
                single-tagged {
                    vlan-id 10
                }
            }
        }
    }
    lag {
        lag-type lacp
        member-speed 10G
        lacp {
            interval FAST
            lacp-mode ACTIVE
            admin-key 11
            system-id-mac 00:00:00:00:00:11
            system-priority 11
        }
    }

A:srl-1# /interface ethernet-1/1
--{ + candidate shared default }--[ interface ethernet-1/1 ]--
A:srl-1# info
    admin-state enable
    ethernet {
        aggregate-id lag1
        hold-time {
            up 30
        }
    }
 A:srl-1# /interface ethernet-1/50
--{ + candidate shared default }--[ interface ethernet-1/50 ]--
A:srl-1# info
    description SRL-2-50
    admin-state enable
    vlan-tagging true
    transceiver {
        forward-error-correction rs-528
    }
    ethernet {
        port-speed 100G
        hold-time {
            up 30
        }
    }
    subinterface 1 {
        admin-state enable
        ipv4 {
            admin-state enable
            address 100.64.0.0/31 {
            }
        }
        vlan {
            encap {
                single-tagged {
                    vlan-id 1
                }
            }
        }


```

### Juniper JunOS EVO port/lag configuration

```bash
admin@vswitch-1# show interfaces

et-0/0/0 {
    enable;
    flexible-vlan-tagging;
    mtu 9194;
    unit 0 {
        enable;
        vlan-id 1;
        family inet {
            address 100.64.5.1/31;
        }
    }
}
et-0/0/1 {
    enable;
    flexible-vlan-tagging;
    mtu 9194;
    unit 0 {
        enable;
        vlan-id 1;
        family inet {
            address 100.64.5.3/31;
        }
    }
}
admin@vswitch-1# show interfaces

et-0/0/0 {
    enable;
    flexible-vlan-tagging;
    mtu 9194;
    unit 0 {
        enable;
        vlan-id 1;
        family inet {
            address 100.64.5.1/31;
        }
    }
}
et-0/0/1 {
    enable;
    flexible-vlan-tagging;
    mtu 9194;
    unit 0 {
        enable;
        vlan-id 1;
        family inet {
            address 100.64.5.3/31;
        }
    }
}
admin@vswitch-1# show interfaces

et-0/0/2 {
    enable;
    speed 100g;
    ether-options {
        802.3ad ae1;
    }
}
et-0/0/3 {
    speed 100g;
    ether-options {
        802.3ad ae0;
    }
}

ae0 {
    enable;
    flexible-vlan-tagging;
    mtu 9100;
    encapsulation flexible-ethernet-services;
    aggregated-ether-options {
        link-speed 100g;
        lacp {
            active;
            periodic fast;
            system-priority 11;
            system-id 00:00:00:02:00:11;
            admin-key 11;
        }
    }
    unit 10 {
        encapsulation vlan-bridge;
        vlan-id 10;
    }
ae1 {
    description ep-style;
    flexible-vlan-tagging;
    mtu 9100;
    encapsulation flexible-ethernet-services;
    aggregated-ether-options {
        link-speed 100g;
        lacp {
            active;
            periodic fast;
            system-priority 22;
            system-id 00:00:00:02:00:22;
            admin-key 22;
        }
    }
    unit 10 {
        encapsulation vlan-bridge;
        vlan-id 10;
    }
admin@vswitch-1# show interfaces
et-0/0/0 {
    enable;
    flexible-vlan-tagging;
    mtu 9194;
    unit 0 {
        enable;
        vlan-id 1;
        family inet {
            address 100.64.5.1/31;
        }
    }
}

et-0/0/1 {
    enable;
    flexible-vlan-tagging;
    mtu 9194;
    unit 0 {
        enable;
        vlan-id 1;
        family inet {
            address 100.64.5.3/31;
        }
    }
}



```
## Control Plan configuration







