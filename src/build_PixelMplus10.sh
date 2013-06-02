#!/bin/sh
# Time-stamp: <Jun 02 2013>
# Created:  MURAOKA Taro <koron@tka.att.ne.jp>
# Modified: itouhiro

files_r="bdf.d/mplus_j10r-iso-W5.bdf bdf.d/mplus_j10r-jisx0201.bdf bdf.d/mplus_j10r.bdf bdf.d/mplus_j10r-jisx0213.bdf"
files_b="bdf.d/mplus_j10b-iso.bdf bdf.d/mplus_j10b-jisx0201.bdf bdf.d/mplus_j10b.bdf bdf.d/mplus_j10b-jisx0213.bdf"

script="scripts/bdf2eps.pl"
# 1000.0 em size / 10px = 100.0
opts="-h 1083 -sc 100.0 -fb PixelMplus10"

perl $script $opts -fw Regular -o work.d/10px $files_r
perl $script $opts -fw Bold -o work.d/10pxb $files_b
