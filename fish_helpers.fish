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
    /home/rodrigo/Android/Sdk/emulator/emulator -avd default -gpu host
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

    set request_body "{
      \"temperature\": 1.1,
      \"model\": \"grok-2\",
      \"prompt\": \"$message\",
      \"max_tokens\": 512 
    }"

    # curl -sX POST "https://api.deepseek.com/beta/completions" \
    curl -sX POST "https://api.x.ai/v1/completions" \
        -H "Authorization: Bearer $X_API_KEY" \
        -H "Content-Type: application/json" \
        -d $request_body | jq '.choices[0].text'
end

function yank_repo -d "Copy a repo for quick llm query"
    #Filter files by query
    set files (find . | grep $argv[1])
    set FILES_PATH /tmp/files
    touch $FILES_PATH
    for i in $files
        if test -f $i
            set file_type (file --brief $i)
            echo "$file_type" | grep -q "ASCII text"
            if test $status -eq 0
                echo $i >>$FILES_PATH
                cat $i >>$FILES_PATH
            end
        end
    end
    cat $FILES_PATH | wl-copy
    rm $FILES_PATH
end
