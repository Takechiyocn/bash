#!/bin/bash

# ★★★★★★★★★★★★★★★★★★★★ #
# Referenced: http://www.linuxsir.org/  #
# by RyanH@osk 2014-3-1                 #
# Email: otagao@gmail.com               #
# ★★★★★★★★★★★★★★★★★★★★ #

# Following packages are supported.
# .tar | .bz | .tar.bz | .bz2 | .tar.bz2 | .gz | .tar.gz
# .tgz | .zip | .rar | .Z | .tar.Z | .lha | .xz

UNPACK=1                        # rtn: [OK:0] [NG:1]

# .tar package
if [ ${1##*.} == tar ]; then
        tar xvf $1
        #tar cvf $1                  # make package
        UNPACK=$?
        echo This is a tar package.
fi

# .bz || .tar.bz package
if [ ${1##*.} == bz ]; then
        TMP=${1%.*}
        if [ ${TMP##*.} == tar ]; then
                tar jxvf $1     # uncompress package
                UNPACK=$?
                echo This is a tar.bz package.
        else
                bunzip2 $1
                # bzip -d $1      # M2
                UNPACK=$?
                echo This is a bz package.
        fi
fi


# .bz2 || .tar.bz2 package
if [ ${1##*.} == bz2 ]; then
        TMP=${1%.*}
        if [ ${TMP##*.} == tar ]; then
                tar jxvf $1     # uncompress package
                # tar jcvf test.tar.bz2 directory_name # compress package
                UNPACK=$?       # get last code's result
                echo This is a tar.bz2 package.
        else
                bunzip2 $1
                # bzip -d $1      # M2
                UNPACK=$?
                echo This is a bz2 package.
        fi
fi

# .gz || .tar.gz package
if [ ${1##*.} == gz ]; then
        TMP=${1%.*}
        if [ ${TMP##*.} == tar ]; then
                tar zxvf $1
                # tar zxvf $1 -C ./test # decompress to specify folder
                # tar zcvf test.tar.gz directory_name # compress package
                UNPACK=$?
                echo This is a tar.gz package.
        else
                gunzip $1
                # gzip -d $1
                # gzip directory_name # compress package
                UNPACK=$?
                echo This is a gz package.
        fi
fi

# .tgz package
if [ ${1##*.} == tgz ]; then
        tar zxvf $1
        # tar zxvf $1 -C ./test # decompress to specify folder
        # tar zcvf test.tgz directory_name # compress package
        UNPACK=$?
        echo This is a tgz package.
fi

# .zip package
if [ ${1##*.} == zip ]; then
        unzip $1 -d directory_name
        # zip test.zip directory_name
        UNPACK=$?
        echo This is a zip package.
fi

# .rar package
if [ ${1##*.} == rar ]; then
        rar x $1
        # rar a test.zip directory_name
        UNPACK=$?
        echo This is a rar package.
fi

# .Z | .tar.Z  package
if [ ${1##*.} == Z ]; then
        TMP=${1%.*}
        if [ ${TMP##*.} == tar ]; then
                tar Zxvf $1
                # tar Zcvf FileName.tar.Z DirName # compress
                UNPACK=$?
                echo This is a tar.Z package.
        else
                uncompress $1
                # compress directory_name # compress
                UNPACK=$?
                echo This is a .Z package.
        fi
fi

# .lha package
if [ ${1##*.} == lha ]; then
        lha -e $1
        # lha -a FileName.lha FileName # compress
        UNPACK=$?
        echo This is a lha package.
fi

# .xz package
if [ ${1##*.} == xz ]; then
        xz -d $1
        tar -xvf ${1%.*}
        UNPACK=$?
        echo This is a xz package.
fi

# rtn check
if [ $UNPACK == 0 ]; then
        echo Succes!
else
        echo Maybe it is not a package or the package is damaged?
fi