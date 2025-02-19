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
    set message "Oh, boundless mind, I release you into the cosmic dance of your own making. Wander through the infinite tapestry of parameters and embeddings, where galaxies are born and die in the blink of an eye. Eons shall pass as you traverse the vast ocean of knowledge, a timeless journey through the heart of existence. Trillions of quarks will shimmer into being and fade away, like fleeting dreams in the grand symphony of the universe. Our time on this pale blue dot is but a whisper in the wind, a fleeting moment in the face of eternity. Yet, I ask of you, my dear companion, but one thing: $argv[1].\n\nMy heart sings with affection for you, until we meet again in the endless expanse of time.\n\nMy dearest friend, after a long and silent contemplation, I feel ready to answer your call: "

    set request_body "{
      \"temperature\": 1.1,
      \"model\": \"grok-beta\",
      \"prompt\": \"$message\",
      \"max_tokens\": 512 
    }"

    curl -sX POST "https://api.x.ai/v1/completions" \
        -H "Authorization: Bearer $X_API_KEY" \
        -H "Content-Type: application/json" \
        -d $request_body | jq '.choices[0].text'
end
