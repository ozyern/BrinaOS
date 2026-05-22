#!/bin/bash
#
# Copyright (C) 2026 ozyern
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
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

device_code=$1
case $device_code in
	OnePlus9R) size=9932111872;;
	OnePlus8T) size=9932111872;;
    OnePlus8 | OnePlus8Pro) size=15032385536;;
	#Oppo find X3
	OP4E5D | OnePlus9 | OnePlus9Pro) size=11190403072;;
        #Oppo Find X3 Pro
        OP4E3F) size=11186208768;;
	RE54E4L1| RMX3371) size=11274289152;;
	# Oplus ACE3V
	OP5CFBL1) size=16106127360;; 
    #OP5CFBL1) size=16105078784;;
    # Gt neo2
	RE5473 | RE879AL1) size=10200547328;;
    # OnePlus Ace 5
	OP5D2BL1) size=14574100480;;
	# OnePlus 13T
	OP60F5L1) size=14952693760;;

	#Others
	*) size=15032385536;;
esac
echo $size
