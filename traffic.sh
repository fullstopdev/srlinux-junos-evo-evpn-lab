# SPDX-License-Identifier: BSD-3-Clause

set -eu

display_help() {
    echo "Usage: $0 <start|stop> <1-2|1-3|svr|all>"
    echo "Commands:"
    echo "  start       Start traffic between specified clients or all"
    echo "  stop        Stop traffic between specified clients, server, or all"
    echo "Options:"
    echo "  1-s         Traffic between Client 1 and Remote server"
    echo "  2-s         Traffic between Client 2 and Remote server"
    echo "  1-2         Traffic between Client 1 and Client 2"
    echo "  all         Traffic between all clients"
    exit 1
}

startTraffic1-s() {
    echo "starting traffic between Client 1 and Server"
    docker exec server iperf3 -s -p 5201 -D > iperf3_1.log
    docker exec client1  bash /config/iperf1.sh
}

startTraffic2-s() {
    echo "starting traffic between Client 2 and Server"
    docker exec server iperf3 -s -p 5202 -D > iperf3_2.log
    docker exec client2  bash /config/iperf1.sh
}
startTraffic1-2() {
    echo "starting traffic between Client 2 and Server"
    docker exec client2 iperf3 -s -p 5205 -D > iperf3_2.log
    docker exec client1  bash /config/iperf2.sh
}

startAll() {
    echo "starting traffic on all clients"
    docker exec server iperf3 -s -p 5201 -D > iperf3_1.log
    docker exec server iperf3 -s -p 5202 -D > iperf3_2.log
    docker exec client2 iperf3 -s -p 5205 -D > iperf3_2.log
    docker exec client1 bash /config/iperf1.sh
    docker exec client2 bash /config/iperf1.sh
    docker exec client1  bash /config/iperf2.sh
}

stopTraffic1-s() {
    echo "stopping traffic between clients 1 and 2"
    docker exec client1 pkill iperf3
    docker exec server pkill iperf3

}

stopTraffic2-s() {
    echo "stopping traffic between clients 1 and 3"
    docker exec client2 pkill iperf3
    docker exec server   pkill iperf3
    docker exec server pkill iperf3

}

stopAll() {
    echo "stopping all traffic"
    docker exec client1 pkill iperf3
    echo "Stopped iperf3 on client1"
    docker exec client2 pkill iperf3
    echo "Stopped iperf3 on client2"
    docker exec server pkill iperf3
    echo "Stopped iperf3 on server"
}
stopsvr() {
    echo "stopping server"
    docker exec server pkill iperf3
}

# Check for the correct number of arguments
if [ $# -ne 2 ]; then
    display_help
fi

# start or stop traffic
if [ "$1" == "start" ]; then
    if [ "$2" == "1-s" ]; then
        startTraffic1-s
    elif [ "$2" == "2-s" ]; then
        startTraffic2-s
    elif [ "$2" == "1-2" ]; then
        startTraffic1-2
    elif [ "$2" == "all" ]; then
	startAll
    else
        display_help
    fi
elif [ "$1" == "stop" ]; then
    if [ "$2" == "1-s" ]; then
        stopTraffic1-s
    elif [ "$2" == "2-s" ]; then
        stopTraffic2-s
    elif [ "$2" == "all" ]; then
        stopAll
    else
        display_help
    fi
else
    display_help
fi

