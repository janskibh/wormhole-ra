#!/bin/bash
# tunnel.sh: Launch autossh with tunnel redirections defined in tunnel.conf

# Path to the configuration file
CONFIG_FILE="/etc/wormhole-ra/tunnel.conf"

# Check if the configuration file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: configuration file '$CONFIG_FILE' not found."
    exit 1
fi

# Initialize variables for SSH parameters and tunnel redirections
SSH_USER=""
SSH_HOST=""
SSH_OPTIONS=""
REDIRECT_OPTIONS=""

current_section=""

# Read the configuration file
while IFS= read -r line || [[ -n "$line" ]]; do
    # Trim leading and trailing whitespace
    trimmed_line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    
    # Skip empty lines or comments
    if [[ -z "$trimmed_line" || "$trimmed_line" =~ ^# ]]; then
        continue
    fi

    # Check if the line is a section header
    if [[ "$trimmed_line" =~ ^\[(.*)\]$ ]]; then
        current_section="${BASH_REMATCH[1]}"
        continue
    fi

    # Process lines based on the current section
    if [[ "$current_section" == "ssh" ]]; then
        # Expect format key=value
        key=$(echo "$trimmed_line" | cut -d '=' -f1)
        value=$(echo "$trimmed_line" | cut -d '=' -f2-)
        case "$key" in
            SSH_USER)
                SSH_USER="$value"
                ;;
            SSH_HOST)
                SSH_HOST="$value"
                ;;
            SSH_OPTIONS)
                SSH_OPTIONS="$value"
                ;;
        esac
    elif [[ "$current_section" == "tunnels" ]]; then
        # Each non-comment line in [tunnels] is a redirection
        REDIRECT_OPTIONS+=" -R $trimmed_line"
    fi
done < "$CONFIG_FILE"

# Verify that the required SSH configuration variables are set
if [[ -z "$SSH_USER" || -z "$SSH_HOST" || -z "$SSH_OPTIONS" ]]; then
    echo "Error: Incomplete SSH configuration in '$CONFIG_FILE'. Please check the [ssh] section."
    exit 1
fi

# Display a summary of the command to be executed
echo "Starting autossh with the following options:"
echo "  SSH Options: $SSH_OPTIONS"
echo "  Tunnel Redirections: $REDIRECT_OPTIONS"
echo "  SSH Destination: ${SSH_USER}@${SSH_HOST}"
echo ""

# Launch autossh in the background and wait for its termination
autossh $SSH_OPTIONS $REDIRECT_OPTIONS ${SSH_USER}@${SSH_HOST} & wait
