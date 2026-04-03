#!/usr/bin/env sh
filePath=$1
iteration=0
maxRetries=5

echo "Comskip launched under user $(whoami) for file $filePath"

while [ "$iteration" -lt "$maxRetries" ]; do
    /usr/bin/env comskip --ini="/comskip/comskip.ini" "$filePath"
    comskipReturn=$?
    echo "Comskip returned: $comskipReturn"
    if [ "$comskipReturn" -eq "0" ]; then
        # map the type from 0 -> 3 for jellyfin.
        sed -Ei 's/([0-9]+\.[0-9]+[[:space:]]+[0-9]+\.[0-9]+)[[:space:]]+0$/\1 3/' "${filePath%.*}".edl

        tmpOutputFile="${filePath%.*}.tmp"
        outputFile="${filePath%.*}.mkv"

        # Detect hardware acceleration availability
        echo "Checking for hardware acceleration..."
        /usr/bin/env ffmpeg -f lavfi -i testsrc=duration=1:size=320x240:rate=1 -c:v h264_qsv -f null - >/dev/null 2>&1
        qsv_available=$?
        if [ "$qsv_available" -eq 0 ]; then
            echo "QSV hardware acceleration available, using h264_qsv encoder"
            encoder="h264_qsv"
            hwaccel_flags="-hwaccel qsv -hwaccel_output_format qsv"
            quality_param="-global_quality 23"
            deint_filter_name="deinterlace_qsv"
        else
            /usr/bin/env ffmpeg -f lavfi -i testsrc=duration=1:size=320x240:rate=1 -c:v h264_nvenc -f null - >/dev/null 2>&1
            nvenc_available=$?
            if [ "$nvenc_available" -eq 0 ]; then
                echo "NVIDIA NVENC hardware acceleration available, using h264_nvenc encoder"
                encoder="h264_nvenc"
                hwaccel_flags=""
                quality_param="-cq 23"
                deint_filter_name="yadif=0:-1:0"
            else
                echo "No hardware acceleration available, falling back to software libx264 encoder"
                encoder="libx264"
                hwaccel_flags=""
                quality_param="-crf 23"
                deint_filter_name="yadif=0:-1:0"
            fi
        fi

        field_order=$(/usr/bin/env ffprobe -v error -select_streams v:0 -show_entries stream=field_order -of default=nokey=1:noprint_wrappers=1 "$filePath" 2>/dev/null)
        if [ -n "$field_order" ] && [ "$field_order" != "progressive" ]; then
            echo "Detected interlaced source (field_order=$field_order); enabling deinterlace filter."
            deint_filter="$deint_filter_name"
        else
            echo "Source is progressive or unknown field order ($field_order); no deinterlace filter."
            deint_filter=""
        fi

        echo "Re-encoding '$filePath' to '$tmpOutputFile' with $encoder encoder"
        if [ -n "$deint_filter" ]; then
            /usr/bin/env ffmpeg -hide_banner -loglevel info -y \
                "$hwaccel_flags" \
                -err_detect ignore_err -fflags +discardcorrupt \
                -i "$filePath" \
                -vf "$deint_filter" \
                -c:v $encoder -preset fast "$quality_param" \
                -c:a copy -c:s copy \
                -f matroska "$tmpOutputFile"
        else
            /usr/bin/env ffmpeg -hide_banner -loglevel info -y \
                "$hwaccel_flags" \
                -err_detect ignore_err -fflags +discardcorrupt \
                -i "$filePath" \
                -c:v $encoder -preset fast "$quality_param" -pix_fmt yuv420p \
                -c:a copy -c:s copy \
                -f matroska "$tmpOutputFile"
        fi
        ffmpegReturn=$?
        echo "FFmpeg returned: $ffmpegReturn"

        if [ "$ffmpegReturn" -ne 0 ]; then
            echo "Re-encoding failed, keeping original file"
            rm -rf "$tmpOutputFile"
            exit 1
        fi

        echo "Re-encoding succeeded, removing original file '$filePath'"
        # Clean up associated files
        rm -f "${filePath%.*}.txt" "${filePath%.*}.log"
        rm -f "$filePath"
        mv "$tmpOutputFile" "$outputFile"
        exit 0
    fi
    iteration=$((iteration+1))
done

echo "Comskip failed with error code $comskipReturn"
exit 1

