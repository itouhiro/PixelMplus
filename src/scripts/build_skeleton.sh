#!/bin/sh
# vim:set ts=8 sts=2 sw=2 tw=0:
#
# Last Change: 24-Jan-2005.
# Maintainer:  MURAOKA Taro <koron@tka.att.ne.jp>

files_r="bdf.d/mplus_f12r.bdf bdf.d/mplus_f12r_jisx0201.bdf bdf.d/mplus_j12r.bdf"
files_b="bdf.d/mplus_f12b.bdf bdf.d/mplus_f12b_jisx0201.bdf bdf.d/mplus_j12b.bdf"

script="scripts/bdf2eps.pl"
#copyright="Copyright (C) 2004 M+ Font Project"
opts="-h 1083 -sc 83.34 -fb mplus_skeleton"

perl $script $opts -fw r -o work.d/skeleton-r $files_r
#perl $script $opts -fw b -o work.d/skeleton-b $files_b
