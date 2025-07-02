# ~/.zsh/functions/aws-scp.zsh

# SCP with AWS SSM Key
function scp_with_ssm_key() {
    local SSH_NAME=""
    local PROFILE_NAME=""
    local USER_NAME=""
    local HOST_NAME=""
    local FILE_TO_COPY=""
    local REMOTE_LOCATION=""

    while getopts ":s:p:u:h:f:l:" opt; do
        case $opt in
            s) SSH_NAME="$OPTARG" ;;
            p) PROFILE_NAME="$OPTARG" ;;
            u) USER_NAME="$OPTARG" ;;
            h) HOST_NAME="$OPTARG" ;;
            f) FILE_TO_COPY="$OPTARG" ;;
            l) REMOTE_LOCATION="$OPTARG" ;;
            \?) echo "Invalid option -$OPTARG" >&2; return 1 ;;
            :) echo "Option -$OPTARG requires an argument." >&2; return 1 ;;
        esac
    done

    if [[ -z "$SSH_NAME" || -z "$PROFILE_NAME" || -z "$USER_NAME" || -z "$HOST_NAME" || -z "$FILE_TO_COPY" || -z "$REMOTE_LOCATION" ]]; then
        echo "Usage: scp_with_ssm_key -s <SSH_NAME> -p <PROFILE_NAME> -u <USER_NAME> -h <HOST_NAME> -f <FILE_TO_COPY> -l <REMOTE_LOCATION>"
        return 1
    fi

    aws ssm get-parameter --name "$SSH_NAME" --with-decryption --query "Parameter.Value" --output text --profile "$PROFILE_NAME" > /tmp/temp_key \
    && chmod 600 /tmp/temp_key \
    && scp -i /tmp/temp_key -o IdentitiesOnly=yes "$FILE_TO_COPY" "$USER_NAME@$HOST_NAME:$REMOTE_LOCATION" \
    && rm /tmp/temp_key
}

