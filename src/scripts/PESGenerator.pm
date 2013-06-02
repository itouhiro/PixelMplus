# Time-stamp: <Jun 02 2013>
#
# PfaEdit (fontforge) Script Generator
#
# Created:  MURAOKA Taro <koron@tka.att.ne.jp>
# Modified: itouhiro

package PESGenerator;

use Data::Dumper;

sub new
{
    my $class = shift;
    my %param = (
	-offset => [0, 0],
	-descent => 800,
	-ascent => 200,
	-simplify => 0,
	@_,
    );
    my $this = bless {
	basename => $param{'-basename'},
	fontname => $param{'-fontname'},
	fullname => $param{'-fullname'},
	weight => $param{'-weight'},
	copyright => $param{'-copyright'},
	version => $param{'-version'},
	input_sfd => $param{'-input_sfd'},
	output_sfd => $param{'-output_sfd'},
	scratch_build => ($param{'-input_sfd'} ne $param{'-output_sfd'}),
	offset => $param{'-offset'},
	descent => $param{'-descent'},
	ascent => $param{'-ascent'},
	simplify => $param{'-simplify'},
	eps_files => [],
    }, $class;
    return $this;
}

sub add
{
    my $this = shift;
    my $path = shift;
    if (-e $path) {
	push @{$this->{eps_files}}, $path;
	return 1;
    } else {
	return 0;
    }
}

sub save
{
    my $this = shift;
    my $path = shift;
    open OUT, ">$path";
    binmode OUT;
    # Header
    print OUT "#!/usr/local/bin/fontforge -script\n";
    if (0 >= @{$this->{eps_files}}) {
	return 0;
    }
    if ($this->{input_sfd} ne '' and -r $this->{input_sfd}) {
	printf OUT "Open(\"%s\")\n", $this->{input_sfd};
    } else {
	print OUT <<"__EOB__";
New()
Reencode("iso10646-1")
SetCharCnt(65536)
__EOB__
    }
    # Header for scratch
    if ($this->{scratch_build}) {
	print OUT <<"__EOB__";
# For scratch build
SetFontNames("$this->{fontname}", "$this->{basename}", "$this->{fullname}", "$this->{weight}", "$this->{copyright}", "$this->{version}")
__EOB__
    }
    # Set panose (workaround)
    print OUT <<"__EOB__";
panose = Array(10);
panose[0] = 2;  #bFamilyType
panose[1] = 11; #bSerifStyle
__EOB__
    if ($this->{weight} =~ /ld$/){
        # Bold
        # PANOSE: see https://developer.apple.com/fonts/TTRefMan/RM06/Chap6OS2.html
        # SetOS2Value: see https://www.microsoft.com/typography/otspec/os2.htm , readttfos2metrics() in http://fontforge.cvs.sourceforge.net/viewvc/fontforge/fontforge/fontforge/parsettf.c
        print OUT qq|panose[2] = 7; SetOS2Value("Weight",700); |;
    }else{
        # Regular(Book)
        print OUT qq|panose[2] = 5; SetOS2Value("Weight",400);|;
    }
    print OUT <<"__EOB__";
panose[3] = 9; #bProportion
panose[4] = 2; #bContrast
panose[5] = 2; #bStrokeVariation
panose[6] = 3; #bArmStyle
panose[7] = 2; #bLetterform
panose[8] = 2; #bMidline
panose[9] = 7; #bXHeight
i = 0; while (i < 10); SetPanose(i, panose[i]); ++i; endloop
SetOS2Value("IBMFamily", 8 * 256 + 9); #monospace
SetOS2Value("TypoLineGap", 0);
SetOS2Value("HHeadLineGap", 0);
__EOB__
    # Glyphs
    print OUT "# Output glyphs\n";
    for my $eps_file (@{$this->{eps_files}}) {
	if ($eps_file !~ m/\/u([[:xdigit:]]+)\.eps$/) {
	    printf STDERR "Skip: can't get character code: $eps_file\n";
	    next;
	}
	my $code = $1;
	my $width = &_get_width($eps_file);
	if ($width < 0) {
	    printf STDERR "Skip: can't get width: $eps_file\n";
	    next;
	}
	printf OUT "Print(\"Add %s\")\n", $eps_file;
	printf OUT "Select(0x%s)\n", $code;
	printf OUT "Clear()\n";
	printf OUT "Import(\"%s\")\n", $eps_file;
	if ($this->{simplify}) {
	    printf OUT "RemoveOverlap()\n";
	    printf OUT "Simplify()\n";
	}
	printf OUT "Move(%d, %d)\n", $this->{offset}->[0], $this->{offset}->[1];
	printf OUT "SetWidth(%d)\n", $width;
    }
    # Footer
    $output_ttf = $this->{output_sfd};
    $output_ttf =~ s/\.sfd$/.ttf/;
    print OUT <<"__EOB__";
# Save SFD and quit
Generate("$output_ttf", "", 0x84)
Save("$this->{output_sfd}")
Quit()
__EOB__
    close OUT;
    return 1;
}

sub _get_width
{
    my $filename = shift;
    my $width = -1;
    open IN, $filename;
    while (<IN>) {
	chomp;
	if (m/^%%BoundingBox:\s+\d+\s+\d+\s+(\d+)\s+(\d+)/) {
	    $width = $1 + 0;
	    last;
	}
    }
    close IN;
    return $width;
}

1;
