#!/bin/bash
source "zotzip.config" #establish config file variables

function draw_line { #draw horizontal line across screen
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

function update_last_run { #update the lastrun file with current datetime and URL if applicable
    curdate=$(date)
    echo -e "ZotZip last attempted a download on:\n$curdate" > $lastrun_file_loc
    if [ $1 != "" ]
        then
        echo -e "\nThe last attempted URL was ${BLUE}'$@'${NC}" >> $lastrun_file_loc
    fi    
    echo "Updated lastrun file."
}

function display_last_run { #display the contents of the lastrun file
    while IFS= read -r line
    do
        echo -e "${GREEN} $line ${NC}"
    done < $lastrun_file_loc
}

function search { #execute zotify with a search prompt
    zotify --download-format $download_format --download-quality $download_quality --skip-existing $skip_existing -s
    update_last_run
}

function url { #execute zotify to download url, entered at $1
    zotify --download-format $download_format --download-quality $download_quality --skip-existing $skip_existing $@
    update_last_run $1
}

function liked {
    zotify --download-format $download_format --download-quality $download_quality --skip-existing $skip_existing -l
    update_last_run
}

function main_menu {
    clear
    echo -e "${GREEN}ZotZip${NC}"
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
                read -p "URL [Empty line quits, seperate URLs with a space]: " url
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
