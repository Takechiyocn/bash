#!/bin/sh
#
# msinfo.sh           This shell script displays the boot sector of the
#                     given partition.
#
# Author:             Rahul U. Joshi
#
# Modifications       Removed the use of expr and replaced it by the let
#                     command.
#
# ------------------------------------------------------------------------
# This program is a free software, you can redistribute it and/or modify
# it under the eterms of the GNU General Public Liscence as published by
# the Free Software Foundation; either version 2 or (at your option) any
# later version.
#
# This program is being distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY without even the implied warranty of
# MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public Liscence for more details.
# -------------------------------------------------------------------------


# check for command line arguments
if [ $# -ne 1 ]; then
   echo "Usage: msinfo <partition name>"
   exit 1
fi

# check whether the input name is a block device
if [ ! -b $1 ]; then
   echo "msinfo: $1 is not a block device"
   exit 1
fi

# create two temporary files for use
TMPFILE=`mktemp -q /tmp/$0.XXXXXX`
if [ $? -ne 0 ]; then
    echo "msinfo: Can't create temp file, exiting..."
    exit 1
fi

TXTFILE=`mktemp -q /tmp/$0.XXXXXX`
if [ $? -ne 0 ]; then
   echo "msinfo: Can't create temp file, exiting..."
   rm -f $TMPFILE
   exit 1
fi

backtitle="`printf "%78s" "msinfo, Information about FAT16 filesystem -- Rahul Joshi"`"

dialog --title "Boot sector of $1" --backtitle "$back_title" \
       --infobox "\nAnalysing boot sector for $1\nPlease wait..."  14 60

# truncate TXTFILE to zero length
echo > $TXTFILE

# get Formatting DOS version
dd 2>/dev/null if=$1  bs=1 count=8 skip=3 | dd 2>/dev/null of=$TMPFILE
printf >>$TXTFILE "%30s : %s\n" "Formatting DOS version" "`cat $TMPFILE`"


# get file system
dd 2>/dev/null if=$1  bs=1 count=8 skip=54 | dd 2>/dev/null of=$TMPFILE
printf >>$TXTFILE "%30s : %s\n" "Filesystem" "`cat $TMPFILE`"

# check if filesystem in a FAT16
if [ "`cat $TMPFILE`" != "FAT16   " ]; then
  dialog --title "Boot sector of $1" --backtitle "$back_title" \
         --infobox  "\nCan't find a FAT16 filesystem on $1"  14 60
  exit 2
fi

# get volume label in boot sector
dd 2>/dev/null if=$1  bs=1 count=11 skip=43 | dd 2>/dev/null of=$TMPFILE
printf >>$TXTFILE "%30s : %s\n" "Volume label in boot sector" "`cat $TMPFILE`"


# get Sector size
dd 2>/dev/null if=$1  bs=1 count=2 skip=11| od -An -tdS | dd 2>/dev/null of=$TMPFILE
printf >>$TXTFILE "%30s : %d\n" "Sector size" `cat $TMPFILE`
sector_size=`cat $TMPFILE`


# get Reserved sectors
dd 2>/dev/null if=$1  bs=1 count=2 skip=14| od -An -tdS | dd 2>/dev/null of=$TMPFILE
printf >>$TXTFILE "%30s : %d\n" " Reserved sectors" `cat $TMPFILE`
reserved_sectors=`cat $TMPFILE`


# get FAT sectors
dd 2>/dev/null if=$1  bs=1 count=1 skip=16| od -An -tdS | dd 2>/dev/null of=$TMPFILE
fat_count=`cat $TMPFILE`

dd 2>/dev/null if=$1  bs=1 count=2 skip=22| od -An -tdS | dd 2>/dev/null of=$TMPFILE
sectors_per_fat=`cat $TMPFILE`

# calculate the no of sectors allocated for FAT's
let fat_sectors=fat_count*sectors_per_fat

printf >>$TXTFILE "%30s : %u (%u x %u) \n" "FAT sectors" "$fat_sectors" \
        "$fat_count" "$sectors_per_fat"


# get root directory sectors
dd 2>/dev/null if=$1  bs=1 count=2 skip=17| od -An -tdS | dd 2>/dev/null of=$TMPFILE
root_sectors=`cat $TMPFILE`

# calculate the no of sectors allocated for root directory
let root_sectors=root_sectors*32/sector_size

printf >>$TXTFILE "%30s : %u\n" "Root directory sectors" "$root_sectors"


# get Total special sectors
let total=reserved_sectors+fat_sectors+root_sectors
printf >>$TXTFILE "%30s : %u\n" "Total special sectors" "$total"


# display the information
dialog --title "Boot sector of $1"  --backtitle "$back_title"  --msgbox "`cat
$TXTFILE`" 14 60

# delete temporary files
rm -f $TMPFILE
rm -f $TXTFILE

# end of msinfo.sh
