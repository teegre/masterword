# shellcheck shell=bash

#  __  __   ____    ____  _____  ____ _____ __    __ ____ _____  ____ 
# |  \/  | / () \  (_ (_`|_   _|| ===|| () )\ \/\/ // () \| () )| _) \
# |_|\/|_|/__/\__\.__)__)  |_|  |____||_|\_\ \_/\_/ \____/|_|\_\|____/
# 
# This file is part of MasterWord.
# Copyright (C) 2022, Stéphane MEYER.
# 
# MasterWord is free software: you can redistribute it and/or modify
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
# Core
# C : 2022/02/15
# M : 2022/02/19
# D : Core functions.


CONFIG_DIR="/home/${USER}/.config/masterword"
DICT="/usr/share/dict/words"
[[ $LANG =~ (.._..)\.+ ]] && LANGUAGE="${BASH_REMATCH[1],,}"

[[ -d $CONFIG_DIR ]] || {
  mkdir "$CONFIG_DIR"
  cp /etc/masterword/fr_fr_wordlist "${CONFIG_DIR}"/ 2> /dev/null
}

declare -a WORDLIST
declare -A SPECIAL
declare -A LETTERS
declare -A POOL
declare -A STATS

# àáâãäåçðèéêëìíîïñòóôõöùúûüýÿ

SPECIAL["À"]="A"
SPECIAL["Á"]="A"
SPECIAL["Â"]="A"
SPECIAL["Ã"]="A"
SPECIAL["Ä"]="A"
SPECIAL["Å"]="A"
SPECIAL["Ç"]="C"
SPECIAL["Ð"]="D"
SPECIAL["È"]="E"
SPECIAL["É"]="E"
SPECIAL["Ê"]="E"
SPECIAL["Ë"]="E"
SPECIAL["Ì"]="I"
SPECIAL["Í"]="I"
SPECIAL["Î"]="I"
SPECIAL["Ï"]="I"
SPECIAL["Ñ"]="N"
SPECIAL["Ò"]="O"
SPECIAL["Ó"]="O"
SPECIAL["Ô"]="O"
SPECIAL["Õ"]="O"
SPECIAL["Ö"]="O"
SPECIAL["Ù"]="U"
SPECIAL["Ú"]="U"
SPECIAL["Û"]="U"
SPECIAL["Ü"]="U"
SPECIAL["Ý"]="Y"
SPECIAL["Ÿ"]="Y"

replace_chars() {
  # remplace les caractères accentués par leur version non accentuée.
  local ENTRY i letter WORD
  ENTRY="$1"
  for ((i=0;i<${#ENTRY};i++)); do
    letter="${ENTRY:$i:1}"
    if [[  $letter =~ [ÀÁÂÃÄÅÇÐÈÉÊËÌÍÎÏÑÒÓÔÕÖÙÚÛÜÝŸ] ]]; then
       WORD+="${SPECIAL["$letter"]}"
     else
       WORD+="$letter"
    fi
  done
  echo "$WORD"
}

reset_letters() {
  for key in "${!LETTERS[@]}"; do
    unset "LETTERS[$key]"
  done
}

do_wordlist() {
  # crée la liste de mots initiale.
  local FILE WORD
  local regex
  # alnum, alpha, ascii, blank, cntrl, digit, graph, lower, print, punct, space, upper, word, xdigit
  regex="[\'[[:space:]][[:cntrl:]][[:punct:]][[:blank:]][[:digit:]][[:xdigit:]]]"
  if [[ -s "${CONFIG_DIR}/${LANGUAGE}_wordlist" ]]; then
    FILE="${CONFIG_DIR}/${LANGUAGE}_wordlist"
    echo "---- Loading word list..."
  else
    FILE="$DICT"
    echo "---- Creating word list..."
  fi
  while read -r WORD; do
    (( ${#WORD} == 5 )) && ! [[ $WORD =~ $regex ]] && {
      if [[ $FILE == "$DICT" ]]; then
        WORD="$(replace_chars "${WORD^^}")"
        echo "$WORD" >> "${CONFIG_DIR}/${LANGUAGE}_wordlist"
      fi
      WORDLIST+=("$WORD")
    }
  done < "$FILE"
  echo "---- Done."
}

reset_pool() {
  # vide le tableau de comptage des lettres.
  local key
  for key in "${!POOL[@]}"; do
    unset "POOL[$key]"
  done
}

count_letters() {
  local ENTRY i
  local L1 L2
  ENTRY="$1"
  reset_pool
  for ((i=0;i<${#SECRET};i++)); do
    L1="${SECRET:$i:1}"
    L2="${ENTRY:$i:1}"
    [[ $L1 != "$L2" ]] && ((POOL["$L1"]+=1))
  done
}

check_word() {
  # vérifie la validité du mot entré par l'utilisateur.
  local ENTRY word
  local regex
  regex="[\'[[:space:]][[:cntrl:]][[:punct:]][[:blank:]][[:digit:]][[:xdigit:]]]"
  ENTRY="${1^^}"
  (( ${#ENTRY} == 5 )) && ! [[ $ENTRY =~ $regex ]] && {
    for word in "${WORDLIST[@]}"; do
      [[ $ENTRY == "${word^^}" ]] && return 0
    done
  }
  return 1
}
  
is_in_word() {
  # vérifie si une lettre est présente dans le mot à deviner.
  local LETTER i
  LETTER="$1"
  for ((i=0;i<${#SECRET};i++)); do
    [[ $LETTER == "${SECRET:$i:1}" ]] && return 0
  done
  return 1
}

proceed_word() {
  # vérifie le mot entré par l'utilsateur.
  local ENTRY i letter w
  ENTRY="${1^^}"

  # [[ $ENTRY == "$SECRET" ]] && return 0

  count_letters "$ENTRY"
  
  restorecursor; clrtoeol

  echo -n "---- "

  for ((i=0;i<${#SECRET};i++)); do
    letter="${ENTRY:$i:1}"
    if [[ $letter == "${SECRET:$i:1}" ]]; then
      echo -ne "${GRN}${letter}${OFF}"
    elif is_in_word "$letter" && [[ ${POOL[$letter]} -gt 0 ]]; then
      echo -ne "${YLW}${letter}${OFF}"
      ((POOL["$letter"]-=1))
    else
      echo -ne "${DIM}${letter}${OFF}"
      is_in_word "$letter" || ((LETTERS["$letter"]=1))
    fi
  done

  echo -n " | "

  for key in "${!LETTERS[@]}"; do
    if ((LETTERS["$key"] == 1)); then
      echo "$key"
    fi
  done | sort | while read -r w; do
    echo -n "$w"
  done
  echo
  [[ $ENTRY == "$SECRET" ]] && return 0
  return 1
}

confirm() {
  # ask user for confirmation.

  local prompt r
  prompt="${1:-"sure?"}"

  printf ".... %s [Y/n]: " "$prompt"
  read -r r
  [[ ${r,,} == "n" ]] && return 1
  return 0
}

load_stats() {
  local l k v
  [[ -s "${CONFIG_DIR}/${LANGUAGE}_stats" ]] && {
    while read -r l; do
      [[ $l =~ (.)\=(.+) ]] && {
        k="${BASH_REMATCH[1]}"
        v="${BASH_REMATCH[2]}"
        ((STATS[$k]="$v"))
      }
    done < "${CONFIG_DIR}/${LANGUAGE}_stats"
  }
}

save_stats() {
  { 
    echo "G=${STATS["G"]}"
    echo "W=${STATS["W"]}"
    echo "L=${STATS["L"]}"
    echo "1=${STATS["1"]}"
    echo "2=${STATS["2"]}"
    echo "3=${STATS["3"]}"
    echo "4=${STATS["4"]}"
    echo "5=${STATS["5"]}"
    echo "6=${STATS["6"]}"
  } > "${CONFIG_DIR}/${LANGUAGE}_stats"
}

print_stats() {
  echo -n  "---- "
  echo -en "${YLW} G ${OFF} → ${STATS[G]:-0} | "
  echo -en "${GRN} V ${OFF} → ${STATS[W]:-0} | "
  echo -e  "${DIM} D ${OFF} → ${STATS[L]:-0}"
  echo -n  "---- "
  echo -en " 1  → ${STATS[1]:-0} | "
  echo -en " 2  → ${STATS[2]:-0} | "
  echo -e  " 3  → ${STATS[3]:-0}"
  echo -n  "---- "
  echo -en " 4  → ${STATS[4]:-0} | "
  echo -en " 5  → ${STATS[5]:-0} | "
  echo -e  " 6  → ${STATS[6]:-0}"
}
