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
    /home/rodrigo/Android/Sdk/emulator/emulator -avd Weak_API_27
end

function zypper_autoremove -d "Autoremove unused deps"
    zypper rm (zypper pa --unneeded --orphaned | awk '{print $5}' | grep -vP 'Name|^$')
end
