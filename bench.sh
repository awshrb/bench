#!/bin/bash

sysinfo () {
        # Removing existing bench.log, if any
        rm -rf $HOME/bench.log

        # Reading CPU model
        cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
        # Reading amount of CPU cores
        cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
        # Reading CPU frequency in MHz
        freq=$( awk -F: ' /cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
        # Reading total memory in MB
        tram=$( free -m | awk 'NR==2 {print $2}' )
        # Reading Swap in MB
        vram=$( free -m | awk 'NR==3 {print $2}' )

        # Reading system uptime
        up=$( uptime | awk '{ $1=$2=$(NF-6)=$(NF-5)=$(NF-4)=$(NF-3)=$(NF-2)=$(NF-1)=$NF=""; print }' | sed 's/^[ \t]*//;s/[ \t]*$//' )

        # Reading operating system and version
        opsy=$( cat /etc/os-release | grep PRETTY_NAME | tr -d '"' | sed -e "s/^PRETTY_NAME=//" ) 

        # Reading Architecture
        arch=$( uname -m ) 
        # Reading Architecture in Bit
        lbit=$( getconf LONG_BIT )

        # Reading Hostname
        hn=$( hostname ) 
        # Reading Kernel
        kern=$( uname -r )

        # Date of benchmark
        bdates=$( date )

        echo '' | tee -a $HOME/bench.log
        echo "Benchmark started on $bdates" | tee -a $HOME/bench.log
        echo "Full benchmark log: $HOME/bench.log" | tee -a $HOME/bench.log
        echo "" | tee -a $HOME/bench.log

        # Output of results
        echo "System Info" | tee -a $HOME/bench.log
        echo "-----------" | tee -a $HOME/bench.log
        echo "Processor : $cname" | tee -a $HOME/bench.log
        echo "CPU Cores : $cores @ $freq MHz" | tee -a $HOME/bench.log
        echo "Memory    : $tram MiB" | tee -a $HOME/bench.log
        echo "Swap      : $vram MiB" | tee -a $HOME/bench.log
        echo "Uptime    : $up" | tee -a $HOME/bench.log
        echo "" | tee -a $HOME/bench.log
        echo "OS        : $opsy" | tee -a $HOME/bench.log
        echo "Arch      : $arch ($lbit Bit)" | tee -a $HOME/bench.log
        echo "Kernel    : $kern" | tee -a $HOME/bench.log
        echo "Hostname  : $hn" | tee -a $HOME/bench.log
        echo "" | tee -a $HOME/bench.log
        echo "" | tee -a $HOME/bench.log
}
disktest () {
        echo "Buffered Sequential Write Speed" | tee -a $HOME/bench.log
        echo "-------------------------------" | tee -a $HOME/bench.log

        # Measuring disk speed with DD
        io=$( ( dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
        io2=$( ( dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
        io3=$( ( dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//' )

        # Calculating avg I/O
        ioraw=$( echo $io | awk 'NR==1 {print $1}' )
        ioraw2=$( echo $io2 | awk 'NR==1 {print $1}' )
        ioraw3=$( echo $io3 | awk 'NR==1 {print $1}' )
        ioall=$( awk 'BEGIN{print '$ioraw' + '$ioraw2' + '$ioraw3'}' )
        ioavg=$( awk 'BEGIN{print '$ioall'/3}' )

        # Output of DD result
        echo "I/O (1st run)     : $io" | tee -a $HOME/bench.log
        echo "I/O (2nd run)     : $io2" | tee -a $HOME/bench.log
        echo "I/O (3rd run)     : $io3" | tee -a $HOME/bench.log
        echo "Average I/O       : $ioavg MB/s" | tee -a $HOME/bench.log

        echo "" | tee -a $HOME/bench.log
}
help () {
        echo ""
        echo "bench.sh - VPS Benchmarking Script"
        echo ""
        echo "Usage: sh bench.sh <option>"
        echo ""
        echo "-s              : Displays system information."
        echo "-d               : Runs a disk test."
        echo ""
}
case $1 in
        '-s')
                sysinfo;;
        '-d')
                disktest;;
        '-h' )
                help;;
        *)
                sysinfo; disktest;;
esac
