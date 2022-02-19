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
# CURSE
# C : 2022/02/17
# M : 2022/02/18
# D : Terminal colors and cursor manipulating functions.

# colors
RED='\x1b[31m'; export RED
GRN='\x1b[30m\x1b[42m'; export GRN
YLW='\x1b[30m\x1b[43m'; export YLW
DIM='\x1b[2m'; export DIM
OFF='\x1b[0m'; export OFF

locate() {
  # move cursor position.
  local y x
  y="$1"; x="$2"
  printf '\x1b[%d;%dH' $((y)) $((x))
}

lecho() {
  # move cursor position and print text.
  local y x text
  y="$1"; x="$2"; text="$3"
  locate $((y)) $((x))
  printf "%s" "$text"
}

clrscr() {
  # clear the screen.
  printf '\x1b[2J\x1b[H'
}

clrtoeol() {
  # clear from current position to the end of the line.
  printf '\x1b[K'
}

clrtoeos() {
  # clear from current position to the end of the screen.
  printf '\x1b[0J'
}

clrline() {
  # clear line at current position.
  printf '\x1b[2K'
}

hidecursor() {
  # hide cursor.
  printf '\x1b[?25l'
}

showcursor() {
  # show cursor.
  printf '\x1b[?25h'
}

savecursor() {
  # save cursor position.
  printf '\x1b[s'
}

restorecursor() {
  # restore previously saved cursor position.
  printf '\x1b[u'
}

