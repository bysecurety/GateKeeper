#!/bin/bash
###########
###########Value Generation

#Clear the seq file
echo "" > seq.txt

#Secret
#Sequence
sequence1=$((1024 + $RANDOM % 32767))
sequence2=$((1024 + $RANDOM % 32767))
sequence3=$((1024 + $RANDOM % 32767))

port_sequence=($sequence1, $sequence2, $sequence3)

usr=$(/usr/bin/whoami)

seq_used(){
    
    port_used=$(sudo netstat -tulpan | grep ":$1") 
    echo $port_used

}

num=1

for port in "${port_sequence[@]}"; do
    

    if [ "seq_used '$port'" == "" ];
        then 

            echo "Seq"$num $port >> /home/$usr/seq.txt

            #Firewall rule
            sudo ufw allow $port/tcp 

        else

            port=$((1024 + $RANDOM % 32767))
            echo "Seq"$num $port >> /home/$usr/seq.txt

            #Firewall rule
            sudo ufw allow $port/tcp    

    fi

        num=$((num + 1))

done


#SSH Port (Floating SSH compatible)
ssh_port=$(sudo netstat -tulpan | grep sshd | cut -d ":" -f 2 | cut -d " " -f 1 | head -1)
echo "SSHPort "$ssh_port >> /home/$usr/seq.txt
