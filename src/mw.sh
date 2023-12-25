#! /usr/bin/env bash

#  __  __   ____    ____  _____  ____ _____ __    __ ____ _____  ____ 
# |  \/  | / () \  (_ (_`|_   _|| ===|| () )\ \/\/ // () \| () )| _) \
# |_|\/|_|/__/\__\.__)__)  |_|  |____||_|\_\ \_/\_/ \____/|_|\_\|____/
# 
# Copyright (C) 2022, Stéphane MEYER.
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>
#
# MasterWord
# C : 2022/02/14
# M : 2023/12/25
# D : Main program

# shellcheck source=/usr/lib/masterword/core.sh
source "/usr/lib/masterword/core.sh"
# shellcheck source=/usr/lib/masterword/curse.sh
source "/usr/lib/masterword/curse.sh"

clear

echo "MasterWord: Now Loading..."

do_wordlist
((COUNT="${#WORDLIST[@]}"))
((COUNT == 0)) && { echo -e "${RED}No word found!${OFF}"; exit 1; }
echo "Found $((COUNT)) words."
load_stats
sleep 1.5

# game loop
CONTINUE=1

while [[ $CONTINUE ]]; do
  clear

  L="${LANG:0:2}"
  L="${L^^}"
  echo ' |\/| _. __|_ _ ._ \    /_ .__|'
  echo " |  |(_|_> |_(/_|   \/\/(_)|(_| $L"
  unset L
  echo "────────────────────────────────────────"
  print_stats
  echo "────────────────────────────────────────"
  echo -e " ${GRN} A ${OFF} → !"
  echo -e " ${YLW} A ${OFF} → ?"
  echo -e " ${DIM} A ${OFF} → x"
  echo "────────────────────────────────────────"

  SECRET="${WORDLIST[((RANDOM%COUNT))]}"
  TRIAL=1
  reset_letters
  while ((TRIAL<7)); do
    savecursor
    clrtoeol
    read -re -p "$((TRIAL))/6 → " entry
    [[ $entry ]] || { restorecursor; continue; }
    while ! check_word "$entry"; do
      restorecursor
      clrtoeos
      echo -e "${RED}$((TRIAL))/6 → ${entry}${OFF} | 👎"
      sleep 1
      restorecursor
      clrtoeol
      read -re -p "$((TRIAL))/6 → " entry
      [[ $entry ]] || { restorecursor; continue; }
    done
    proceed_word "$entry" && {
      echo "────────────────────────────────────────"
      case $TRIAL in
        1) echo -ne "${GRN} PERFECT! ${OFF}" ;;
        2) echo -ne "${YLW} AWESOME! ${OFF}" ;;
        3) echo -ne "${RED} GREAT! ${OFF}" ;;
        4) echo -n " You win!" ;;
        5) echo -n " It's a victory!" ;;
        6) echo -n " That was close..."
      esac
      clrtoeol
      echo
      confirm " Continue?" || unset CONTINUE
      ((STATS["$TRIAL"]+=1))
      ((STATS["G"]+=1))
      ((STATS["W"]+=1))
      break
    }
    ((TRIAL++))
  done

  ((TRIAL==7)) && {
    echo -ne "    $RED→ $SECRET $OFF"; clrtoeol
    echo
    echo "────────────────────────────────────────"
    echo " You lose..."
    confirm " Continue?" || unset CONTINUE
    ((STATS["G"]+=1))
    ((STATS["L"]+=1))
  }
  save_stats
done

echo "────────────────────────────────────────"
echo " Game Over."
