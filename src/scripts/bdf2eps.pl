#!/usr/bin/perl
# Time-stamp: <Jun 02 2013>
# Created:  MURAOKA Taro <koron@tka.att.ne.jp>
# Modified: itouhiro

use strict;
use lib "scripts";
use Carp;
use Data::Dumper;
use File::Basename;
use File::Path;
use UCSTable;
use PESGenerator;

my @today = localtime;
my ($YEAR, $MONTH, $DAY) = ($today[5] + 1900, $today[4] + 1, $today[3]);
my ($DEBUG, $VERBOSE) = (0, 0);
my $OUTDIR = "output.d";
my @CELLSIZE = (500, 1000);
my $SCALE = 76;
my ($SCALE_X, $SCALE_Y) = (0, 0);
my @files;
my %generated;

my ($WIDTH, $HEIGHT);
$config::FONT_BASENAME = 'PixelMplus';
$config::FONT_WEIGHT = 'Regular';
$config::FONT_COPYRIGHT = "Copyright (C) $YEAR M+ Font Project";
$config::FONT_VERSION = sprintf("%04d.%02d%02d", $YEAR, $MONTH, $DAY);

# Parse arguments
for (my $i = 0; $i < @ARGV; ++$i) {
    my $c = $ARGV[$i];
    if ($c =~ m/^-/) {
	my $next = $i + 1 < @ARGV;
	if ($c eq "-w" and $next) {
	    $WIDTH = $ARGV[++$i] + 0;
	} elsif ($c eq "-h" and $next) {
	    $HEIGHT = $ARGV[++$i] + 0;
	} elsif ($c eq "-sc" and $next) {
	    $SCALE = $ARGV[++$i] + 0;
	} elsif ($c eq "-o" and $next) {
	    $OUTDIR = $ARGV[++$i];
	} elsif ($c eq "-fb" and $next) {
	    $config::FONT_BASENAME = $ARGV[++$i];
	} elsif ($c eq "-fn" and $next) {
	    $config::FONT_NAME = $ARGV[++$i];
	} elsif ($c eq "-fw" and $next) {
	    $config::FONT_WEIGHT = $ARGV[++$i];
	} elsif ($c eq "-fc" and $next) {
	    $config::FONT_COPYRIGHT = $ARGV[++$i];
	} elsif ($c eq "-v") {
	    ++$VERBOSE;
	} else {
	    printf STDERR "  Ignored option: %s\n", $c;
	}
    } elsif (-f $c and -r _) {
	push @files, $c;
    } else {
	printf STDERR "  Ignored argument: %s\n", $c;
    }
}

if (not defined $config::FONT_NAME) {
    $config::FONT_NAME = sprintf("%s-%s", $config::FONT_BASENAME, $config::FONT_WEIGHT);
    $config::FULL_NAME = sprintf("%s %s", $config::FONT_BASENAME, $config::FONT_WEIGHT);
}
$config::FONT_OUTPUTFILE = sprintf("%s.sfd", $config::FONT_NAME);

mkpath([$OUTDIR], 0, 0755) if not -e $OUTDIR;
$SCALE_X = $SCALE if $SCALE_X <= 0;
$SCALE_Y = $SCALE if $SCALE_Y <= 0;

my $pes = new PESGenerator(
    -basename => $config::FONT_BASENAME,
    -weight => $config::FONT_WEIGHT,
    -fontname => $config::FONT_NAME,
    -fullname => $config::FULL_NAME,
    -copyright => $config::FONT_COPYRIGHT,
    -version => $config::FONT_VERSION,
    #-input_sfd => $input_sfd,
    -output_sfd => $config::FONT_OUTPUTFILE,
    -offset => [0, -200],
    -simplify => 1,
);
for my $f (@files) {
    $WIDTH = 0;
    $HEIGHT = 0;
    printf "Input: %s\n", $f;
    open IN, $f;
    &proc_file($f, \*IN, $pes);
    close IN;
}
$pes->save(sprintf("%s.pe", $config::FONT_NAME));
exit 0;

sub check_header
{
    my $IN = shift;
    my $head = {
	cell_width => 1,
	encode => '',
    };
    # Process header.
    while (<$IN>) {
	if (m/^CHARS\b/) {
	    last;
	} elsif (m/^FONTBOUNDINGBOX\s+(\d+)\s+(\d+)/) {
	    # Calc cell-width
	    my ($w, $h) = ($1, $2);
	    if ($h / $w <= 1.5) {
		$head->{cell_width} = 2;
	    }
	} elsif (m/^FONT\s+(.*)$/) {
	    # Determine encoding
	    my @fn = split m/-/, $1;
	    my $encode = join("-", @fn[13, 14]);
	    if ($encode =~ m/8859-1/i) {
		$encode = "8859-1";
	    } elsif ($encode =~ m/jisx0201/i) {
		$encode = "JISX0201";
	    } elsif ($encode =~ m/jisx0208/i) {
		$encode = "JISX0208";
	    } elsif ($encode =~ m/jisx0213/i) {
		$encode = "JISX0213";
	    }
	    $head->{encode} = $encode;
	}
    }
    return $head;
}

sub proc_startchar
{
    my $ecode = shift;
    my $filename = shift;
    my $IN = shift;;
    my $enc_table = shift;
    # Correct bitmap data
    my @data;
    while (<$IN>) {
	chomp;
	push @data, $_;
	last if m/^ENDCHAR/;
    }
    return '' if eof $IN;
    # Initialize glyph conversion parameters
    my $ucode = $enc_table->get(sprintf("%04X", $ecode));
    if ($ucode == 0) {
	printf("  Skipped: u%04X is not mapped to UNICODE\n",
	    $ecode) if $VERBOSE > 1;
	return '';
    }
    $ucode = sprintf("u%04X", $ucode);
    my $out = join("/", $OUTDIR, substr($ucode, 0, 3), $ucode.".eps");
    if (exists $generated{$out}) {
	printf("  Skipped: u%04X already generated in file %s\n",
	    $ecode, $generated{$out}) if $VERBOSE > 1;
	return '';
    }
    &proc_glyph($out, \@data);
    $generated{$out} = $filename;
    return $out;
}

sub proc_file
{
    my $filename = shift;
    my $IN = shift;
    my $pes = shift;
    my $head = &check_header($IN);
    # Initialize font conversion parameters.
    return if eof $IN or $head->{encode} eq '';
    my $enc_table = new UCSTable($head->{encode});
    $WIDTH = $head->{cell_width} * $CELLSIZE[0];
    $HEIGHT = $CELLSIZE[1];
    printf "  Encoding: %s\n", $head->{encode} if $VERBOSE > 0;
    printf "  Width-Height %d,%d\n", $WIDTH, $HEIGHT if $VERBOSE > 0;
    # Process bitmap data body.
    while (<$IN>) {
	chomp;
	if (m/^STARTCHAR\s+0x([[:xdigit:]]{4})/) {
	    my $r = &proc_startchar(hex($1), $filename, $IN, $enc_table);
	    next if $r eq '';
	    $pes->add($r);
	}
    }
}

sub proc_glyph
{
    my $filename = shift;
    my $data = shift;
    my ($w, $h);
    my @hex;
    my $mode = 0;
    for (@$data) {
	if ($mode == 0) {
	    if (m/^BBX\s+(\d+)\s+(\d+)/) {
		($w, $h) = ($1, $2);
	    } elsif (m/^BITMAP$/) {
		$mode = 1;
	    }
	} else {
	    last if m/^ENDCHAR/;
	    for (m/[[:xdigit:]][[:xdigit:]]/g) {
		push @hex, hex($_);
	    }
	}
    }

    # Assure directory
    my $dirname = dirname($filename);
    mkdir $dirname, 0755 if not -d $dirname;

    open OUT, ">".$filename;
    binmode OUT;
    print OUT <<"END";
%!PS-Adobe-3.0 EPSF-3.0
%%BoundingBox: 0 0 $WIDTH $HEIGHT
/xy_fillbox {
  2 copy translate
  newpath 0 0 moveto 0 1 lineto 1 1 lineto 1 0 lineto closepath fill
  neg exch neg exch translate
} def
$SCALE_X $SCALE_Y scale
END
    my $y;
    for ($y = 0; $y < $h; ++$y) {
	my $d = shift @hex;
	my $cnt = 0;
	my $x = 0;
	for ($x = 0; $x < $w; ++$x) {
	    if ($cnt >= 8) {
		$d = shift @hex;
		$cnt = 0;
	    }
	    if ($d >= 128) {
		printf OUT "%d %d xy_fillbox\n", $x, ($h - $y - 1);
	    }
	    $d = ($d * 2) % 256;
	    ++$cnt;
	}
    }
    close OUT;
}

sub get_mtime
{
    my $path = shift;
    if (-e $path) {
	return (stat $path)[9];
    } else {
	return 0;
    }
}
