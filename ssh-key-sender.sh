#!/bin/bash
home="$HOME"

read -p "Enter Config File Path from Home (Blank for Default): " configpath
if [[ -z "$configpath" ]]; then
    path="$home/.ssh/config"
else
    path="$home/$configpath"
fi

read -p "Enter PUBLIC Key File Path from Home (Blank for .ssh/id_rsa.pub): " keyfilepath
if [[ -z "$keyfilepath" ]]; then
    keypath="$home/.ssh/id_rsa.pub"
else
    keypath="$home/$keyfilepath"
fi

read -p "Do you have sshpass installed and want to use it (y/n): " sshpass
if [[ "$sshpass" == "y" ]]; then
    read -s -p "Enter common password for machines: " password
else
    password=""
fi

# path="$home/.ssh/config.d/vms"
# keypath="$home/.ssh/id_rsa.pub"
# password="aaa"

hosts=()
hostnames=()
users=()
ports=()

# Read the config file line by line
while IFS= read -r line; do
    # Check if the line starts with "Host "
    current_port="22"
    if [[ $line =~ ^Host[[:space:]]+(.*)$ ]]; then
        # Extract the hostname
        current_host="${BASH_REMATCH[1]}"
        hosts+=("$current_host")
        # Reset hostname, user, and port variables for the new host entry
        current_hostname=""
        current_user=""
        ports+=("22")

        #Indented
    elif [[ $line =~ ^[[:space:]]+HostName[[:space:]]+(.*)$ ]]; then
        # Extract the HostName
        current_hostname="${BASH_REMATCH[1]}"
        hostnames+=("$current_hostname")
    elif [[ $line =~ ^[[:space:]]+User[[:space:]]+(.*)$ ]]; then
        # Extract the User
        current_user="${BASH_REMATCH[1]}"
        users+=("$current_user")
    elif [[ $line =~ ^[[:space:]]+Port[[:space:]]+(.*)$ ]]; then
        # Extract the Port
        last_index=$((${#ports[@]} - 1))
        ports[$last_index]="${BASH_REMATCH[1]}"

        #No Indented
    elif [[ $line =~ ^HostName[[:space:]]+(.*)$ ]]; then
        # Extract the HostName
        current_hostname="${BASH_REMATCH[1]}"
        hostnames+=("$current_hostname")
    elif [[ $line =~ ^User[[:space:]]+(.*)$ ]]; then
        # Extract the User
        current_user="${BASH_REMATCH[1]}"
        users+=("$current_user")
    elif [[ $line =~ ^Port[[:space:]]+(.*)$ ]]; then
        # Extract the Port
        last_index=$((${#ports[@]} - 1))
        ports[$last_index]="${BASH_REMATCH[1]}"
    fi

done <"$path"

echo
echo
echo "--------------------------------------------------"
if [[ -n "$password" ]]; then

    for i in "${!hosts[@]}"; do
        echo "Copying Key to ${hosts[$i]}"

        # Capture the output and exit status of ssh-copy-id
        output=$(echo sshpass -p "$password" ssh-copy-id -i "$keypath" -o StrictHostKeyChecking=no -p "${ports[$i]}" "${users[$i]}@${hostnames[$i]}" 2>&1)
        exit_status=$?

        if [[ $exit_status -ne 0 && $output == *"Permission denied"* ]]; then
            echo
            echo "**************************************************"
            echo "Error with password $password - Try manual password entry below or use ^c to escape"
            echo "**************************************************"
            echo
            ssh-copy-id -i $keypath -p ${ports[$i]} ${users[$i]}"@"${hostnames[$i]}
        elif [[ $exit_status -ne 0 ]]; then
            echo
            echo "**************************************************"
            echo "Error copying key to ${hosts[$i]}: $output"
            echo "**************************************************"
            echo
        else
            echo "Key copied successfully to ${hosts[$i]}"
        fi
        echo "--------------------------------------------------"

    done
else
    # Copy the file to each host's .ssh directory
    for i in "${!hosts[@]}"; do
        echo "Copying Key to ${hosts[$i]}"
        output=$(ssh-copy-id -i $keypath -p ${ports[$i]} ${users[$i]}"@"${hostnames[$i]})
        exit_status=$?
        if [[ $exit_status -ne 0 ]]; then
            echo
            echo "**************************************************"
            echo "Error copying key to ${hosts[$i]}: $output"
            echo "**************************************************"
            echo
        else
            echo "Key copied successfully to ${hosts[$i]}"
        fi
        echo "--------------------------------------------------"

    done
fi
