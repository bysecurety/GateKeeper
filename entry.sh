#!/bin/bash

#Import the sequence
seq1=$(cat seq.txt | grep Seq1 | cut -d " " -f 2)
seq2=$(cat seq.txt | grep Seq2 | cut -d " " -f 2)
seq3=$(cat seq.txt | grep Seq3 | cut -d " " -f 2)
SSHport=$(cat seq.txt | grep SSHPort | cut -d " " -f 2)

# Define the sequence of ports to knock
port_sequence=($seq1, $seq2, $seq3)

# Define the target IP address
target_ip="54.39.22.16"

# Define the waiting time between port knocks (in seconds)
knock_delay=2

# Function to perform a port knock
function knock_port {
    local port=$1
    nc -z "$target_ip" "$port"
    sleep "$knock_delay"
}

# Perform the port knocking sequence
for port in "${port_sequence[@]}"; do
    knock_port "$port"
done


# After the sequence, perform the actual connection to the SSH port and fetch the newly generated Port sequence securely over the SSH channel
ssh ubuntu@"$target_ip" -p $SSHport
