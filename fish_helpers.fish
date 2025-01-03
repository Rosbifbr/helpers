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


function tts -d "Text to speech with whisper.cpp"
    set WHISPER_ROOT "/media/rodrigo/3f0623f2-dce1-4893-b3e3-61b6438216a2/whisper.cpp"
    set lang auto
    for arg in $argv
        if string match -q "-l *" $arg
            set lang (string replace -r "^-l " "" $arg)
            break
        end
    end
    $WHISPER_ROOT/build/bin/whisper-stream -m $WHISPER_ROOT/models/ggml-large-v3-turbo-q5_0.bin -t 8 --step 0 --length 10000 -vth 0.6 -l $lang
end


function speech -d "Use TTS function to speak. Then an an LLM to summarize what you said. https://www.gihub.com/rosbifbr/ask_rs is required."
    echo "Summarize the following recording into a coherent message in the language it is written on. Output ONLY the formatted message. No code, no comments. \nExample: Umm.. Uhh. Hey John,.. How are you doing? -> Hey, John. How are you doing?.\nRemember to remove repeated or wrong parts and format the input like a text message." >/tmp/whisper-transcript
    tts >>/tmp/whisper-transcript
    cat /tmp/whisper-transcript | ask
    rm /tmp/whisper-transcript
    ask -c #clear convo
end
