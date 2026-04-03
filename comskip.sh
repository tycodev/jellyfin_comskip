#!/usr/bin/env sh

detect_hardware() {
    echo "Checking for hardware acceleration..."

    # Test QSV
    if /usr/bin/env ffmpeg -f lavfi -i testsrc=duration=1:size=320x240:rate=1 -c:v h264_qsv -f null - >/dev/null 2>&1; then
        echo "QSV hardware acceleration available, using h264_qsv encoder"
        encoder="h264_qsv"
        hwaccel_flags="-hwaccel qsv -hwaccel_output_format qsv"
        quality_param="-global_quality 23"
        deint_filter_name="deinterlace_qsv"
        return
    fi

    # Test NVENC
    if /usr/bin/env ffmpeg -f lavfi -i testsrc=duration=1:size=320x240:rate=1 -c:v h264_nvenc -f null - >/dev/null 2>&1; then
        echo "NVIDIA NVENC hardware acceleration available, using h264_nvenc encoder"
        encoder="h264_nvenc"
        hwaccel_flags=""
        quality_param="-cq 23"
        deint_filter_name="yadif=0:-1:0"
        return
    fi

    # Fallback to software
    echo "No hardware acceleration available, falling back to software libx264 encoder"
    encoder="libx264"
    hwaccel_flags=""
    quality_param="-crf 23"
    deint_filter_name="yadif=0:-1:0"
}

get_deinterlace_filter() {
    field_order=$(/usr/bin/env ffprobe -v error -select_streams v:0 -show_entries stream=field_order -of default=nokey=1:noprint_wrappers=1 "$filePath" 2>/dev/null)

    if [ -n "$field_order" ] && [ "$field_order" != "progressive" ]; then
        echo "Detected interlaced source (field_order=$field_order); enabling deinterlace filter."
        echo "$deint_filter_name"
    else
        echo "Source is progressive or unknown field order ($field_order); no deinterlace filter."
        echo ""
    fi
}

run_ffmpeg() {
    deint_filter=$1
    output_file=$2

    if [ -n "$deint_filter" ]; then
        /usr/bin/env ffmpeg -hide_banner -loglevel info -y \
            "$hwaccel_flags" \
            -err_detect ignore_err -fflags +discardcorrupt \
            -i "$filePath" \
            -vf "$deint_filter" \
            -c:v "$encoder" -preset fast "$quality_param" \
            -c:a copy -c:s copy \
            -f matroska "$output_file"
    else
        /usr/bin/env ffmpeg -hide_banner -loglevel info -y \
            "$hwaccel_flags" \
            -err_detect ignore_err -fflags +discardcorrupt \
            -i "$filePath" \
            -c:v "$encoder" -preset fast "$quality_param" -pix_fmt yuv420p \
            -c:a copy -c:s copy \
            -f matroska "$output_file"
    fi
}

# Main script
filePath=$1
iteration=0
maxRetries=5

echo "Comskip launched under user $(whoami) for file $filePath"

while [ "$iteration" -lt "$maxRetries" ]; do
    /usr/bin/env comskip --ini="/comskip/comskip.ini" "$filePath"
    comskipReturn=$?
    echo "Comskip returned: $comskipReturn"

    if [ "$comskipReturn" -ne "0" ]; then
        iteration=$((iteration+1))
        continue
    fi

    # Comskip succeeded - process the file
    sed 's/\([0-9][0-9]*\.[0-9][0-9]*[[:space:]][0-9][0-9]*\.[0-9][0-9]*\)[[:space:]]0$/\1 3/' "${filePath%.*}".edl > "${filePath%.*}".edl.tmp && mv "${filePath%.*}".edl.tmp "${filePath%.*}".edl

    tmpOutputFile="${filePath%.*}.tmp"
    outputFile="${filePath%.*}.mkv"

    detect_hardware
    deint_filter=$(get_deinterlace_filter)

    echo "Re-encoding '$filePath' to '$tmpOutputFile' with $encoder encoder"
    run_ffmpeg "$deint_filter" "$tmpOutputFile"
    ffmpegReturn=$?

    echo "FFmpeg returned: $ffmpegReturn"
    if [ "$ffmpegReturn" -ne 0 ]; then
        echo "Re-encoding failed, keeping original file"
        rm -f "$tmpOutputFile"
        exit 1
    fi

    # Success - clean up and exit
    echo "Re-encoding succeeded, cleaning up files"
    rm -f "${filePath%.*}.txt" "${filePath%.*}.log"
    rm -f "$filePath"
    mv "$tmpOutputFile" "$outputFile"
    exit 0
done

echo "Comskip failed with error code $comskipReturn"
exit 1

