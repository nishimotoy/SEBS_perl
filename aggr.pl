#!/opt/perl/bin/perl
#!/opt/local/bin/perl

#
#  aggr.pl
#
# Last updated $Date: 2007-12-03 15:02:00 JST$

use strict;
use POSIX;

my $selfexec;
if ( "$^O" eq "darwin" ) {
  $selfexec = '/opt/local/bin/perl aggr.pl';
} elsif ( "$^O" eq "freebsd" ) {
  $selfexec = '/opt/perl/bin/perl aggr.pl';
} else {
  $selfexec = '/usr/bin/perl aggr.pl';
}

my $sortcol;
if ( $ARGV[0] eq "-f" ) {
  $sortcol = 0;
  shift @ARGV;
} elsif ( $ARGV[0] eq "-l" ) {
  $sortcol = 8;
  shift @ARGV;
} elsif ( $ARGV[0] eq "-n" ) {
  $sortcol = -1;
  shift @ARGV;
} else {
  $sortcol = 0;
}

my $infile="$ARGV[0]";
my $outfile="$ARGV[1]";
my $region="$ARGV[2]";
my $denom="$ARGV[3]";

my $codedb = 'code.txt';
my $denomdatadir = './var/data';
my $denomfile = "${denomdatadir}/${denom}_${region}.txt";

my @regionarr = ( 'CC', 'SRES9', 'SRES4', 'EDGAR13', 'Major18', 'AIM21', 'AnnexB' );
my @denomarr = ( '', 'GDP', 'pop', 'BaU', '90', 'flag' );

my $normalizer = 1;

my $outputformat = "%f";

# hash: �񥳡��� => �ϰ�
my %cchash;
# �ϰ�
my @ccindex;

# ǯ
my @yindex;
# hash: �ϰ� => �ǡ���
my %datahash;

# ʬ��Υǡ���
my %denomdatahash;

#################################################
# Main

MAIN: {
  my $rcheck = &arrindex (\@regionarr, $region);
  my $dcheck = &arrindex (\@denomarr, $denom);

  $rcheck == -1 && do { die "Bad region specification!"; last MAIN;  };
  $dcheck == -1 && do { die "Bad denominator specification!"; last MAIN;  };

  &readdb();

  &aggregate();

  if ($dcheck == arrindex(\@denomarr, 'flag')) {
    &cutcolumn();
    $outputformat = "%d";
  }
  unless ( $dcheck == 0 or $dcheck == arrindex(\@denomarr, 'flag') ) {
    if ( $denom eq "BaU" or $denom eq "90" ) {
      $normalizer = 100;
    }
    &readdenomdata();
    &divdata();
  }

  open(FILE, ">$outfile" ) or die "Cannot open $outfile!\n";
  select(FILE);
  &outputdhash();
  select(STDOUT);
  close(FILE);

#  my @total = calctot ();
#  print "@total\n";
}


#################################################

# ����������Ǥΰ��֤��֤�. ���Ĥ���ʤ����-1. ����ϻ����Ϥ�.
# �Ȥ߹��ߴؿ���̵���Τ�?
sub arrindex {
  my $aref = $_[0];
  my $val = $_[1];

  my @arr = @$aref;
  my $i;

  foreach $i (0..$#arr) {
    if ($arr[$i] eq $val) {
      return $i;
    }
  }
  return -1;
}

# ��������Ǥ򥽡���, ʣ���������Ǥ�ޤȤ��. ����ϻ����Ϥ�.
sub uniq {
  my $aref = $_[0];
  my @arr = sort(@$aref);
  my @out;

  my $i;
  foreach $i (0..$#arr) {
    if ($arr[$i] ne $out[$#out]) {
      push (@out, $arr[$i]);
    }
  }

  return @out;
}

# �񥳡����б�ɽ���ɤ߹���.
sub readdb {
  open(IN, $codedb) or die "Cannot open code database \"$codedb\"!\n";

  my @tmp;
  my $line = <IN>;
  chomp($line);
  @tmp = split (/\t/, $line);
  my $datacolumn = &arrindex (\@tmp, $region eq "CC"?"Name":$region );

  while (<IN>) {
    chomp;
    @tmp = split (/\t/);
#    print "$tmp[0], $tmp[$datacolumn]\n";
    $cchash{ $tmp[0] } = "$tmp[$datacolumn]";
  }

  close(IN);

  @ccindex = values ( %cchash );
  @ccindex = &uniq ( \@ccindex );
}

# ����Ʊ�Τ����Ǥ��Ȥ��¤Ⱦ�. ����ϻ����Ϥ�. ��������ؤ�reference.
# ������Ȥ߹��ߤǤۤ���.
sub arradd {
  my $aref1 = $_[0];
  my $aref2 = $_[1];

  my @arr1 = @$aref1;
  my @arr2 = @$aref2;

  my $index;
  foreach $index (0 .. $#arr2) {
    $arr1[$index] += $arr2[$index] unless $arr2[$index] eq "" or $arr2[$index] eq "\r" ;
  }

  return \@arr1;
}
sub arrdiv {
  my $aref1 = $_[0];
  my $aref2 = $_[1];

  my @arr1 = @$aref1;
  my @arr2 = @$aref2;

  my $index;
  foreach $index (0 .. $#arr2) {
    unless ($arr2[$index] == 0) {
      $arr1[$index] = $arr1[$index] / $arr2[$index] * $normalizer;
    } else {
      $arr1[$index] = 0;
    }
  }

  return \@arr1;
}

# ���ϥե�����򳫤���­�����򤹤�.
sub aggregate {
#  my @nullarr = (0, 0, 0, 0, 0, 0, 0, 0, 0);
  my @nullarr = ("", "", "", "", "", "", "", "", "");

  my $i;
  foreach $i (0 .. $#ccindex) {
    $datahash{$ccindex[$i]} = [ @nullarr ];
  }

  open(IN, $infile) or die "Cannot open $infile!\n";

  my $line = <IN>;
  chomp($line);
  @yindex = split(/\t/, $line);
  $yindex[0]="Region"; # "CC" -> "Region"

  my @tmp;
  my $cc;

  while ( $line = <IN> ) {
    chomp($line);
    @tmp = split(/\t/, $line);
    $cc = shift @tmp;

    $datahash{$cchash{$cc}} = &arradd ($datahash{ $cchash{$cc} }, \@tmp);
  }

  close(IN);
}

# ��̤ν���
sub outputdhash {
  print join("\t", @yindex), "\n";

  my $key;
  my $a;
  my @arr;
  my @arr1;
  my @arr2;

  my @sortedkeys;
  if ( $sortcol >= 0 ) {
    @sortedkeys = sort {
      our $a, $b;
      $datahash{ $b }->[$sortcol] <=> $datahash{ $a }->[$sortcol]
    } keys %datahash;
  } else {
    @sortedkeys = sort keys %datahash;
  }

  my $tmpr = "%s";
  foreach (0..$#yindex-1) {
    $tmpr = $tmpr . "\t" . $outputformat ;
  }
  $tmpr = $tmpr . "\n";
#  my $tmpr = "%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n";

  foreach $key (@sortedkeys) {
    $a = $datahash{$key};
    @arr = ($key , @$a );
#    print join("\t", @arr), "\n";
    printf ($tmpr, @arr);
  }
}

sub log10 {
  my $n = shift;
  return log($n)/log(10);
}

# ���Ƥ��¤η׻�. ��ǧ��.
sub calctot {
  my @totarr;
  my $key;
  my $a;
  my $t;

  foreach $key (keys %datahash) {
    $a = $datahash{$key};
    $t = &arradd($a, \@totarr);
    @totarr = @$t;
  }

  return @totarr;
}

# "ʬ��"�ǡ������ɤ߹���
sub readdenomdata {
  # �ʤ���к��. �Ƶ��ƤӽФ�.
  unless ( -e $denomfile ) {
    system ("$selfexec -l $denom.txt $denomfile $region");
  }

  open(IN, $denomfile) or die "Cannot open \"$denomfile\"!\n";

  my $r = <IN>;
  my @tmp;

  while (<IN>) {
    chomp;
    @tmp = split (/\t/);
    $r = shift @tmp;
    $denomdatahash{$r} = [@tmp];
  }

  close(IN);
}

# "��껻"
sub divdata {
  my $key;
  foreach $key (keys %datahash) {
    $datahash{$key} = &arrdiv ($datahash{ $key }, $denomdatahash{ $key } );
  }
}

sub cutcolumn {
  my $key = ((keys %datahash)[0]);
  my $aref = $datahash{$key};
  my @arr = @$aref;
  my @tmp;

  my $i = 0;
  while ($i <= $#arr) {
    if ($arr[$i] eq "") {
      foreach (keys %datahash) {
        $aref = $datahash{$_};
        @tmp = @$aref;
        splice @tmp, $i, 1;
        $datahash{$_} = [@tmp];
      }
      splice @arr, $i, 1;
      splice @yindex, $i+1, 1;
    } else {
      $i++;
    }
  }
}

__END__

# Local Variables:
# coding: euc-jp
# End:
