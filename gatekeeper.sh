#!/bin/bash
#############
#############
#GateKeeper by Securety
#Version 1.0
#Author: Christian Goeschel Ndjomouo
#Working Directory: /usr/local/bin/
#MIT License

#VARIABLE IMPORT

usr=$(/usr/bin/whoami)
source <(grep -E '^\w+=' /home/$usr/secret.sh)

#Sequence variables
seq1=$(cat seq.txt | grep Seq1 | cut -d " " -f 2)
seq2=$(cat seq.txt | grep Seq2 | cut -d " " -f 2)
seq3=$(cat seq.txt | grep Seq3 | cut -d " " -f 2)
SSHport=$(cat seq.txt | grep SSHPort | cut -d " " -f 2)

#Port sequence
sequence_order=($seq1 $seq2 $seq3)


echo "" > knock_catch.txt


###Port listening
while :
    do
        
        #Listening for the first port in the sequence - Stage 1
        timeout 1s nc -lv -p $seq1 -n 2>&1 | tee knock_catch.txt 

        #Saves the output from the incoming traffic to a file to extract the IP address of the current knocking session
        contact=$(cat knock_catch.txt | grep "received" | cut -d " " -f 2)

        #Actual IP address of the knocking host
        ip=$(cat knock_catch.txt | grep "received" | cut -d " " -f 4)

        
    
    if [ "$contact" == "received" ]
    then
        

        echo "Stage 1"
        echo "" > knock_catch.txt

        #Listening for second port in the sequence - Stage 2
        timeout 3s nc -lv -p $seq2 -n 2>&1 | tee knock_catch.txt 

        #IP of the host that knocked on the second IP
        ip2=$(cat knock_catch.txt | grep "received" | cut -d " " -f 4) 

        #IP2 has to be the same as IP1 otherwise the sequence would not have been 
        #respected and a potential intrusion could occur from another host
        if [ "$ip2" == "$ip" ]
        then

            echo "" > knock_catch.txt
            echo "Stage 2"

            #SListening for the third port in the sequence - Stage 3
            timeout 3s nc -lv -p $seq3 -n 2>&1 | tee knock_catch.txt 
            
            #Getting the IP from the knocking host
            ip3=$(cat knock_catch.txt | grep "received" | cut -d " " -f 4)
            
            
            #Compare the IP to the first one recorded
            if [ "$ip3" == "$ip" ]
            then

                #Knocking sequence has been completed and the hosts IP will be added to the firewall allow rule
                echo "Stage 3 - Success!"

                #IPtables update to open the SSH Port for the knocking host
                #sudo iptables -I INPUT -s $ip -p tcp --dport $SSHport -j ACCEPT

                
                sudo ufw insert 1 allow from $ip proto tcp to any port $SSHport

                #Deleting the current knocking sequence ports from the firewall to prevent a replay attack
                sudo ufw delete allow $seq1/tcp
                sudo ufw delete allow $seq2/tcp
                sudo ufw delete allow $seq3/tcp
                
                #New Sequence generation
                echo "" > knock_catch.txt
                source secret.sh 
            
                
                #Breaking the loop and 
                break
        
            fi

    
        fi


    fi
        
        

done


  

   
