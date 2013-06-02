#!/bin/sh
# Time-stamp: <Jun 02 2013>
# Created:  MURAOKA Taro <koron@tka.att.ne.jp>
# Modified: itouhiro

files_r="bdf.d/mplus_f12r.bdf bdf.d/mplus_f12r-jisx0201.bdf bdf.d/mplus_j12r.bdf bdf.d/mplus_j12r-jisx0213.bdf"
files_b="bdf.d/mplus_f12b.bdf bdf.d/mplus_f12b-jisx0201.bdf bdf.d/mplus_j12b.bdf bdf.d/mplus_j12b-jisx0213.bdf"

script="scripts/bdf2eps.pl"
# 1000.0 em size / 12 px = 83.33333..
opts="-h 1083 -sc 83.34 -fb PixelMplus12"

perl $script $opts -fw Regular -o work.d/12px $files_r
perl $script $opts -fw Bold -o work.d/12pxb $files_b
