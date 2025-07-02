# ~/.zsh/functions/aws-ssh.zsh

# SSH with AWS SSM Key
function ssh_with_ssm_key() {
    local SSH_NAME=""
    local PROFILE_NAME=""
    local USER_NAME=""
    local HOST_NAME=""

    while getopts ":s:p:u:h:" opt; do
        case $opt in
            s) SSH_NAME="$OPTARG" ;;
            p) PROFILE_NAME="$OPTARG" ;;
            u) USER_NAME="$OPTARG" ;;
            h) HOST_NAME="$OPTARG" ;;
            \?) echo "Invalid option -$OPTARG" >&2; return 1 ;;
            :) echo "Option -$OPTARG requires an argument." >&2; return 1 ;;
        esac
    done

    if [[ -z "$SSH_NAME" || -z "$PROFILE_NAME" || -z "$USER_NAME" || -z "$HOST_NAME" ]]; then
        echo "Usage: ssh_with_ssm_key -s <SSH_NAME> -p <PROFILE_NAME> -u <USER_NAME> -h <HOST_NAME>"
        return 1
    fi

    aws ssm get-parameter --name "$SSH_NAME" --with-decryption --query "Parameter.Value" --output text --profile "$PROFILE_NAME" > /tmp/temp_key \
    && chmod 600 /tmp/temp_key \
    && ssh -v -i /tmp/temp_key -o IdentitiesOnly=yes "$USER_NAME@$HOST_NAME" \
    && rm /tmp/temp_key
}
