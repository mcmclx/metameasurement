# This needs to be run for the first time
# Note down the following two values
# Number of loops for 100% CPUness: 376 (-c flag)
# Number of loops for 100% Memory-ness: 47 (-m flag)

if [[ ! -r calib_results.txt ]]; then
    echo "No calibration data found; running calibration"
    CALIBRATE=1
fi

if [[ $CALIBRATE -eq "1" ]]; then
    make -C ./wilee
    echo "Calibrating wilee..."
    ./wilee/wileE --calibrate | tee calib_results.txt
fi

CPUMEMOPTS=`fgrep -v '#' calib_results.txt | perl -pe 's/\n/ /'`
# echo "opts: $CPUMEMOPTS"

ACTION=$1
if [[ -z $ACTION ]]; then
    echo "Usage: $0 <action>, where action=c, m, d, or n (cpu, mem, disk, network)"
    exit
fi

WAIT="-w3"
ONOFF="-s2 -e4"
CORES="-x2"

if [[ $ACTION == "c" ]]; then
    # -C is maximum CPUness
    python3 loadmeta.py $ONOFF $WAIT $CPUMEMOPTS -C 1.0 -M 0.0 $CORES
elif [[ $ACTION == "m" ]]; then
    # -M is maximum RAMness
    python3 loadmeta.py $ONOFF $WAIT $CPUMEMOPTS -C 0.0 -M 1.0 $CORES
elif [[ $ACTION == "d" ]]; then
    # run this for disk load
    python3 loadmeta.py $ONOFF $WAIT -D -d 1000 -f /tmp/XXX
    rm -f /tmp/XXX
elif [[ $ACTION == "n" ]]; then
    # run this for network load
    # remember to start iPerf server with "iperf3 -s"
    python3 loadmeta.py $ONOFF $WAIT -N -n 2 -i "127.0.0.1"
else 
    echo "Invalid action $ACTION"
    echo "Specify c (cpu), m (mem), d (disk), or n (network)"
fi

killall wileE  #kill any runaway wileE processes
