mp3320() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: mp3320 <audio-file>"
        return 1
    fi

    local input="$1"

    if [[ ! -f "$input" ]]; then
        echo "Error: file not found: $input"
        return 1
    fi

    local output="${input%.*}.mp3"

    ffmpeg -i "$input" \
        -codec:a libmp3lame \
        -b:a 320k \
        -map_metadata 0 \
        -id3v2_version 3 \
        "$output"
}

mp3320_all() {
    find . -type f \( -iname '*.wav' -o -iname '*.aif' -o -iname '*.aiff' \) -print0 |
    while IFS= read -r -d '' f; do
        local out="${f%.*}.mp3"

        if [[ -f "$out" ]]; then
            echo "Skipping: $out already exists"
            continue
        fi

        mp3320 "$f"
    done
}

vidmp3() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: vidmp3 <video-file>"
        return 1
    fi

    local input="$1"

    if [[ ! -f "$input" ]]; then
        echo "Error: file not found: $input"
        return 1
    fi

    local output="${input%.*}.mp3"

    ffmpeg -i "$input" \
        -vn \
        -codec:a libmp3lame \
        -b:a 320k \
        -map_metadata 0 \
        -id3v2_version 3 \
        "$output"
}

mp4shrink() {
    if [[ -z "$1" ]]; then
        echo "Usage: mp4shrink <input.mp4> [output.mp4] [crf] [height]"
        return 1
    fi

    local input="$1"
    local output="${2:-${input%.*}_compressed.mp4}"
    local crf="${3:-28}"
    local height="${4:-720}"

    ffmpeg -i "$input" -vf "scale=-2:${height}" -c:v libx264 -crf "$crf" -preset slow -c:a aac -b:a 320k "$output"

    echo "Done: $output"
}
