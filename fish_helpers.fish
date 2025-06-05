#!/usr/bin/fish
#Misc fish helpers
#Copyright Rodrigo Ourique @ 2024. MIT License

function ff -d "Fuzzy find files"
    set final ".*"
    for elem in $argv
        set final "$final$elem.*"
    end

    #Find file finally
    find . -iregex $final
end

function logcat_search -d "Logcat into app process"
    adb logcat --pid (adb shell ps | grep -Po "^[a-z0-9_]+\s+\K\d+(?=.*$argv)")
end

function android_emulator -d "Run predefined AVD in an Emulator (independent from Android Studio)"
    /home/rodrigo/Android/Sdk/emulator/emulator -avd default -noaudio -metrics-collection -gpu host
end

function deploy_diff -d "Deploy git diff with passed branch to remote"
    set remote_host $argv[1] &&
        set master_branch $argv[2] &&
        set file_list (git diff --name-only origin/$master_branch) &&
        #copy shit
        rsync -R $file_list $remote_host:~/rodrigo
end

function phone_camera -d "Use phone as webcam"
    scrcpy --video-source=camera --camera-size=1920x1080 --camera-facing=back --v4l2-sink=/dev/video0
end

function parse_danfes -d "Parse a collection of SEFAZ fiscal notes for better data aggregation for the stationary bandit (taxes)"
    #stringify PDFs 
    for i in *.pdf
        pdftotext $i
    end
    #pull relevant info
    for i in *.txt
        grep -P -A1 "[0-9]+/[0-9]+/[0-9]+|VLR. TOTAL" $i >parsed-$i
    end
    #aggregate
    cat parsed* >danfe_output
    rm *.txt #clear all
end

function llm_complete -d "Get raw LLM completions"
    set message "$argv"

    # If no arguments are provided, read from stdin
    if test (count $argv) -eq 0
        set message (read -d '')
    end

    set request_body "{
      \"temperature\": 0.9,
      \"model\": \"grok-2\",
      \"prompt\": \"$message\",
      \"max_tokens\": 256
    }"

    # curl -sX POST "https://api.deepseek.com/beta/completions" \
    curl -sX POST "https://api.x.ai/v1/completions" \
        -H "Authorization: Bearer $X_API_KEY" \
        -H "Content-Type: application/json" \
        -d $request_body | yq '.choices[0].text'
end

function yank_repo -d "Dump a repo"
    find . | grep -P $argv[1] >/tmp/file_list

    # Apply exclusion regex if provided
    if test (count $argv) -gt 1
        grep -vP "$argv[2]" /tmp/file_list >/tmp/file_list_filtered
        mv /tmp/file_list_filtered /tmp/file_list
    end

    # Ensure the file is clean or created
    echo -n >/tmp/files

    for i in (cat /tmp/file_list)
        if test -f $i
            set file_type (file --brief $i)
            # Check if file_type contains "text" (more general than just ASCII)
            if echo "$file_type" | grep -iq text
                echo "-------- $i --------" >>/tmp/files
                cat $i >>/tmp/files
                echo "" >>/tmp/files # Add a newline for better separation
            end
        end
    end
    cat /tmp/files
    rm /tmp/files
    rm /tmp/file_list
end
