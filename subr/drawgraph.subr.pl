#
#  drawgraph.subr.pl
#
# Last updated $Date: 2007-12-03 14:58:50 JST$

# sub max: return the maximum of all elements of an array or an array of arrays.
sub stackedmax {
    my @arr = @{$_[0]};

    my $smax=0;
    my $l = $#{$arr[0]};

    foreach my $k (0..$l) {
        my $sum=0;
        foreach my $i (0..$#arr) {
            $sum += $arr[$i]->[$k];
        }
        $smax = $sum if $smax < $sum;
    }
    return $smax;
}

sub max {
     my $aref = $_[0];
     my @array = @$aref;

     my $max;
     my $element;

     for $element ( @array ) {
         my $val =  ( ref ($element) eq "ARRAY" ) ? max($element) : $element;
         $max = $val if ($max < $val );
     }

     return $max;
}

# sub rep: rep(1,3) => [1,1,1,1]
sub rep {
     my $elem = $_[0];
     my $num = $_[1];

     my @arr;

     for my $i ( 0 .. $num ) {
         push @arr, $elem;
     }

     return @arr;
}

# sub readdata:
# (example)
#
#  fullyear =   [ 1990, 1995, ... ];
#  array    = [ [    1,    2, ... ],   # USA
#               [    2,    3, ... ],   # Japan
#                  ...               ];
#  legend   = [ "USA", "Japan", ... ];
#
sub readdata {
     my $file = $_[0];
     my $iregex = $_[1];

     open(IN, $file) or die "Cannot open $file!\n";

     my $line = <IN>;
     chomp ($line);
#    my @year = split(/,/,$line);
     my @year = split(/\t/,$line);
     shift @year;

     my @fullyear;
     for (my $i = 0; $i <= ($year[$#year]-$year[0])/($year[1]-$year 
[0]); $i++) {
         push @fullyear, $year[0]+($year[1]-$year[0])*$i;
     }

     my @array;
     my @legend;

     while (<IN>) {
#       print "$_\n";
         chomp;
#        my @data = split (/,/);
         my @data = split (/\t/);
         my $head = shift @data;
#         print "$head\n";
         if ( $head !~ $iregex ) {
             my $modarr_ref = interp_data_undef( \@data,  
\@year, \@fullyear );
             push @array, $modarr_ref;
             push @legend, $head;
         }
     }

     close(IN);

     return (\@fullyear, \@array, \@legend);
}

# sub interp_data_undef:
sub interp_data_undef {
     my @data = @{$_[0]};
     my @current_index = @{$_[1]};
     my @full_index = @{$_[2]};

     my $j = 0;
     for (my $i = 0; $i <= $#full_index; $i++){
         if ( $current_index[$j] == $full_index[$i] ) {
             $j++;
         } else {
             splice(@data, $i, 0, undef);
         }
     }

     return \@data;
}

sub log10 {
     my $n = shift;
     return log($n)/log(10);
}

sub stackedundefarr {
    my @arr = @{$_[0]};
    my $maxdata = $_[1];
    
    my $l = $#{$arr[$#arr]};

    foreach my $k (0..$l) {
        my $sum=0;
        foreach my $i (0..$#arr) {
            my $psum = $sum;
            $sum += $arr[$i]->[$k];
            if ($sum > $maxdata) {
                $arr[$i]->[$k] = $maxdata - $psum;
                $sum = $maxdata;
            }
        }
    }
    return \@arr;
}

sub undefarr {
  my $aref = $_[0];
  my $maxdata = $_[1];
  my @arr = @$aref;

  my @newarr;
  my $i;
  foreach $i (0..$#arr) {
    if ( ref ($arr[$i]) eq "ARRAY" ) {
      $newarr[$i] = undefarr( $arr[$i] , $maxdata);
    } else {
      if ($arr[$i] > $maxdata or $arr[$i] == 0.0) {
        $newarr[$i] = undef;
      } else {
        $newarr[$i] = $arr[$i];
      }
    }
  }
  return \@newarr;
}

sub interp_data {
  my $aref = $_[0];
  my @arr = @$aref;

  my @tmp;

  my $datap;
  my $interval = 0;
  my $i;
  my $j;

  foreach $i (0..$#arr) {
    @tmp = @{$arr[$i]};

#    print "@tmp\n";

    foreach $j (0..$#tmp) {
      unless ($tmp[$j] eq undef) {
        if ($interval > 0) {
          foreach (($j-$interval) .. ($j - 1)) {
            $tmp[$_] = ($tmp[$j] - $datap)/($interval+1)*(1+$_-$j+$interval) + $datap;
          }
        }
#        print "$j, $tmp[$j]\n";
        $datap = $tmp[$j];
        $interval = 0;
      } else {
        $interval++;
      }
    }

    $arr[$i] = [@tmp];
#    print "@tmp\n";
  }

  return \@arr;
}

1;

# Local Variables:
# coding: euc-jp
# End:
