#!/bin/bash

source /venv/main/bin/activate
FORGE_DIR=${WORKSPACE}/stable-diffusion-webui-forge

# Packages are installed after nodes so we can fix them...

APT_PACKAGES=(
    #"package-1"
    #"package-2"
)

PIP_PACKAGES=(

)

EXTENSIONS=(
    "https://github.com/Bing-su/adetailer.git" 
    "https://github.com/BlafKing/sd-civitai-browser-plus.git" 
    "https://github.com/zanllp/sd-webui-infinite-image-browsing.git"
)

CHECKPOINT_MODELS=(
    "https://civitai.com/api/download/models/2219949?type=Model&format=SafeTensor&size=pruned&fp=fp8" # RealDream
    "https://civitai.com/api/download/models/897489?type=Model&format=SafeTensor&size=pruned&fp=fp16" # Afrodite
)

TEXTENCODER_MODELS=(
    "https://civitai.com/api/download/models/787954?type=Model&format=SafeTensor&size=full&fp=fp16" # t5-xxl fp16
)

UNET_MODELS=(
)

LORA_MODELS=(
)

VAE_MODELS=(
)

ESRGAN_MODELS=(
)

CONTROLNET_MODELS=(
)

### DO NOT EDIT BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING ###

function provisioning_start() {
    provisioning_print_header

    # Validate tokens early and warn if missing/invalid (non-fatal)
    if ! provisioning_has_valid_civitai_token; then
        printf "Warning: CIVITAI_TOKEN is missing or invalid; private/hidden downloads may fail.\n" >&2
    fi

    provisioning_get_apt_packages
    provisioning_get_extensions
    provisioning_get_pip_packages
    provisioning_get_files \
        "${FORGE_DIR}/models/Stable-diffusion" \
        "${CHECKPOINT_MODELS[@]}"

    provisioning_get_files \
        "${FORGE_DIR}/models/text_encoder" \
        "${TEXTENCODER_MODELS[@]}"


    # Avoid git errors because we run as root but files are owned by 'user'
    export GIT_CONFIG_GLOBAL=/tmp/temporary-git-config
    git config --file $GIT_CONFIG_GLOBAL --add safe.directory '*'
    
    # Start and exit because webui will probably require a restart
    cd "${FORGE_DIR}"
    LD_PRELOAD=libtcmalloc_minimal.so.4 \
        python launch.py \
            --skip-python-version-check \
            --no-download-sd-model \
            --do-not-download-clip \
            --no-half \
            --port 11404 \
            --exit

    provisioning_print_end
}

function provisioning_get_apt_packages() {
    if [[ -n $APT_PACKAGES ]]; then
            sudo $APT_INSTALL ${APT_PACKAGES[@]}
    fi
}

function provisioning_get_pip_packages() {
    if [[ -n $PIP_PACKAGES ]]; then
            pip install --no-cache-dir ${PIP_PACKAGES[@]}
    fi
}

function provisioning_get_extensions() {
    for repo in "${EXTENSIONS[@]}"; do
        dir="${repo##*/}"
        path="${FORGE_DIR}/extensions/${dir}"
        if [[ ! -d $path ]]; then
            printf "Downloading extension: %s...\n" "${repo}"
            git clone "${repo}" "${path}" --recursive
        fi
    done
}

function provisioning_get_files() {
    if [[ -z $2 ]]; then return 1; fi
    
    dir="$1"
    mkdir -p "$dir"
    shift
    arr=("$@")
    printf "Downloading %s model(s) to %s...\n" "${#arr[@]}" "$dir"
    for url in "${arr[@]}"; do
        printf "Downloading: %s\n" "${url}"
        provisioning_download "${url}" "${dir}"
        printf "\n"
    done
}

function provisioning_print_header() {
    printf "\n##############################################\n#                                            #\n#          Provisioning container            #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"
}

function provisioning_print_end() {
    printf "\nProvisioning complete:  Application will start now\n\n"
}

function provisioning_has_valid_hf_token() {
    [[ -n "$HF_TOKEN" ]] || return 1
    url="https://huggingface.co/api/whoami-v2"

    response=$(curl -o /dev/null -s -w "%{http_code}" -X GET "$url" \
        -H "Authorization: Bearer $HF_TOKEN" \
        -H "Content-Type: application/json")

    # Check if the token is valid
    if [ "$response" -eq 200 ]; then
        return 0
    else
        return 1
    fi
}

function provisioning_has_valid_civitai_token() {
    [[ -n "$CIVITAI_TOKEN" ]] || return 1
    url="https://civitai.com/api/v1/models?hidden=1&limit=1"

    response=$(curl -o /dev/null -s -w "%{http_code}" -X GET "$url" \
        -H "Authorization: Bearer $CIVITAI_TOKEN" \
        -H "Content-Type: application/json" \
        -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124 Safari/537.36")

    # Check if the token is valid
    if [ "$response" -eq 200 ]; then
        return 0
    else
        return 1
    fi
}

# Download from $1 URL to $2 file path
function provisioning_download() {
    local url="$1"
    local dest_dir="$2"

    # Browser-like UA helps with some CDNs/Cloudflare
    local ua="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124 Safari/537.36"

    local auth_token=""
    local is_hf=0
    local is_civitai=0

    if [[ -n $HF_TOKEN && $url =~ ^https://([a-zA-Z0-9_-]+\.)?huggingface\.co(/|$|\?) ]]; then
        auth_token="$HF_TOKEN"; is_hf=1
    elif [[ -n $CIVITAI_TOKEN && $url =~ ^https://([a-zA-Z0-9_-]+\.)?civitai\.com(/|$|\?) ]]; then
        auth_token="$CIVITAI_TOKEN"; is_civitai=1
        # Civitai download endpoints often ignore Authorization headers; append token query param too
        if [[ $url == *\?* ]]; then
            url="${url}&token=${CIVITAI_TOKEN}"
        else
            url="${url}?token=${CIVITAI_TOKEN}"
        fi
    fi

    # Common wget flags
    local wget_flags=(
        -qnc
        --content-disposition
        --show-progress
        --tries=3
        --waitretry=2
        -e "dotbytes=${3:-4M}"
        --user-agent="$ua"
        -P "$dest_dir"
    )

    if [[ -n $auth_token ]]; then
        wget --header="Authorization: Bearer $auth_token" "${wget_flags[@]}" "$url"
    else
        wget "${wget_flags[@]}" "$url"
    fi
}

# Allow user to disable provisioning if they started with a script they didn't want
if [[ ! -f /.noprovisioning ]]; then
    provisioning_start
fi
