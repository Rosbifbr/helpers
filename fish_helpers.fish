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
    /home/rodrigo/Android/Sdk/emulator/emulator -avd Shitty_Phone
end

function deploy_diff -d "Deploy git diff with passed branch to remote"
   set remote_host $argv[1] &&
   set master_branch $argv[2] &&
   set file_list (git diff --name-only origin/$master_branch) &&

   #copy shit
   rsync -R $file_list $remote_host:~/rodrigo
end

function zypper_autoremove -d "Autoremove unused deps"
    zypper rm (zypper pa --unneeded --orphaned | awk '{print $5}' | grep -vP 'Name|^$')
end

function phone_camera -d "Use phone as webcam"
    scrcpy --video-source=camera --camera-size=1920x1080 --camera-facing=back --v4l2-sink=/dev/video0
end
