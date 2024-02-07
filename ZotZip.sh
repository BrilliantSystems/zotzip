#!/bin/bash
ver="0.1.0 Alpha"

RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[4;35m'
MENU='\033[0;4m'
NC='\033[0m'

function draw_line {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

function update_last_run {
    curdate=$(date)
    echo -e "ZotZip last attempted a download on:\n$curdate" > "lastrun.txt"
    echo "Updated lastrun file."
}

function display_last_run {
    while IFS= read -r line
    do
        echo -e "${GREEN} $line ${NC}"
    done < "/home/john/Music/Zotify Music/lastrun.txt"
}

function search {
    zotify --download-format mp3 --download-quality very_high --skip-existing 1 --skip-previously-downloaded 1 -s
    update_last_run
}

function url {
    zotify --download-format mp3 --download-quality very_high --skip-existing 1 --skip-previously-downloaded 1 $1
    update_last_run
}

function liked {
    zotify --download-format mp3 --download-quality very_high --skip-existing 1 --skip-previously-downloaded 1 -l
    update_last_run
}

function main_menu {
    clear
    echo -e "${GREEN}Zotify Zip${NC}"
    echo -e "${PURPLE}By VectorLog${NC}"
    echo -e $ver
    draw_line
    display_last_run
    draw_line
    echo Main Menu:
    echo -e "${RED}1)${NC} ${MENU}Download From URL(s)${NC}"
    echo -e "${RED}2)${NC} ${MENU}Search For Song/Artist/Album${NC}"
    echo -e "${RED}3)${NC} ${MENU}Download Liked Songs${NC}"
    echo -e "${RED}4/Q)${NC} ${MENU}Quit${NC}"

    menufinished=0
    while [[ $menufinished -ne 1 ]] ; do

        read -p "Selection: " menu

        if [ $menu -eq 1 ];
            then
            menufinished=1
            url="runonce" #this allows the URL prompt to run at least once.
            while [[ $url != "" ]] ; do
                read -p "URL [Empty line quits]: " url
                if [[ $url != "" ]];
                    then
                    echo "Attempting to Download $url"
                    url "$url"
                fi
            done
            echo "Quitting..."
        fi

        if [ $menu -eq 2 ];
            then
            menufinished=1
            echo "Starting Zotify Search Prompt..."
            search
        fi

        if [ $menu -eq 3 ];
            then
            menufinished=1
            echo "Downloading Liked..."
            liked
            exit
        fi
        if [ $menu -eq 4 -o $menu == "q" -o $menu == "Q"];
            then
            menufinished=1
            echo "Quitting..."
            exit
        fi
    done
}

main_menu
