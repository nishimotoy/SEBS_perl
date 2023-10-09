#!/opt/local/bin/perl

use strict;

my $mode = 3; # or "2"

my $obj_s_gr = 0;
# if 1 与えられる成長率の基準年は$base_year
# if 2 与えられる成長率の基準年は最左列の年
my $pop_s_gr = 0;
# if 1 与えられる成長率の基準年は$base_year
# if 2 与えられる成長率の基準年は最左列の年

my $obj_s_percent = 0;
my $pop_s_percent = 0;

my $obj_scenario_file;
my $pop_scenario_file;
my $objpop_base_file;
my $output_data_file;
my $output_f_file;
my $base_year;
my $conv_year;

if (1) {
    $obj_scenario_file = "$ARGV[0]";
    $pop_scenario_file = "$ARGV[1]";
    $objpop_base_file = "$ARGV[2]";

    $output_data_file = "$ARGV[3]";
    $output_f_file = "$ARGV[4]";

    $base_year = "$ARGV[5]";
    $conv_year = "$ARGV[6]";
} else {
    my $inputdir = "input";

    $obj_scenario_file = "$inputdir/BaU_SRES9.txt";
    $pop_scenario_file = "$inputdir/pop_SRES9.txt";
    $objpop_base_file = "$inputdir/cc_obj_pop.txt";

    $output_data_file = "output.txt";
    $output_f_file = "output_f.txt";

    $base_year = 2000;
    $conv_year = 2100;
}



my %obj_scenario; # key: rc, val: ref of array of obj (year).
my %pop_scenario; # key: rc, val: ref of array of pop (year).

#my @scenario_year;
my @cc_year;

my @year;

my @regs;

# rc => Region code, cc => country code.
# data read from $objpop_base_file
my %rc_cc;     # key: rc, val: ref of array of cc.
my %cc_rc;     # key: cc, val: rc.
my %cc_obj;    # key: cc, val: obj.
my %cc_pop;    # key: cc, val: ref of array of pop (year).

my %out_data; # key: cc, vals: ref of array of obj (year).
my %rc_f_obj;
my %rc_f_pop; # used if $mode == 3

my %rc_pop; # used if $mode == 2

MAIN: {
    &read_ccdata($objpop_base_file);
    %obj_scenario = &read_scenario($obj_scenario_file);
    %pop_scenario = &read_scenario($pop_scenario_file) unless $mode == 2;

    &postproc_ccdata;

    if ($mode == 3) {
        &postproc_scenario_3;
    } else {
        &postproc_scenario_2;
    }

    &baseshift_ccdata;

    &is_same_array(\@year,$cc_pop{'year'}) or die "scenario & cc_data's year array doesn't match!\n";
    &has_same_keys(\%obj_scenario, \%rc_cc) or die "region match error between scenario & ccdata!\n";

    if ($mode == 3) {
        &calc_3;
    } else {
        &calc_2;
    }

    &output;
}

###################################################################################
# subroutines which ACCESS global variables
###################################################################################

sub output {
    open OUT, ">$output_data_file" or die "cannot open $output_data_file!\n";
    print OUT "CC\t", join("\t",@year), "\n";

    open OUTF, ">$output_f_file" or die "cannot open $output_f_file!\n";
    print OUTF "RC\tf_obj/pop" if $mode == 2;
    print OUTF "RC\tf_obj" . "\t" . join("\t",@year) if $mode == 3;
    print OUTF "\n";

    foreach my $rc (@regs) {
        my @ccs = @{$rc_cc{$rc}};
        
        foreach my $cc (@ccs) {
            print OUT "$cc\t", join("\t",@{$out_data{$cc}}), "\n";
        }
        print OUTF "$rc\t$rc_f_obj{$rc}" ;
        print OUTF "\t" . join("\t", @{$rc_f_pop{$rc}}) if $mode == 3;
        print OUTF "\n";
    }
    close OUT;
    close OUTF;
}

sub calc_3 {
#    my $base_year_idx = &arrindex(\@year, $base_year); # now = 0.
    my $conv_year_idx = &arrindex(\@year, $conv_year);

    foreach my $rc (@regs) {
        my $ref = $rc_cc{$rc};
        my @ccs = @$ref;
        
        my $obj_sum = 0;
        my $pop_sum_by = 0;
        my $pop_sum_cy = 0;
        foreach my $cc (@ccs) {
            $obj_sum += $cc_obj{$cc};
            $pop_sum_by += $cc_pop{$cc}->[0];
            $pop_sum_cy += $cc_pop{$cc}->[$conv_year_idx];

            my @arr = ($cc_obj{$cc});
            $out_data{$cc} = \@arr;
        }
        $rc_f_obj{$rc} = $obj_sum / $obj_scenario{$rc}->[0];
        $rc_f_pop{$rc}->[0] = $pop_sum_by / $pop_scenario{$rc}->[0];
#        $rc_f_pop{$rc}->[$conv_year_idx] = $pop_sum_cy / $pop_scenario{$rc}->[$conv_year_idx];

#        my $conv_ratio_val = ($obj_scenario{$rc}->[$conv_year_idx]*$rc_f_obj{$rc})/($pop_scenario{$rc}->[$conv_year_idx]*$rc_f_pop{$rc}->[$conv_year_idx]);
        my $conv_ratio_val = ($obj_scenario{$rc}->[$conv_year_idx]*$rc_f_obj{$rc})/($pop_sum_cy);

        for my $t (1..$#year) {
            my %tmp;
            my $obj_sum = 0;

            my $pop_sum = 0;
            foreach my $cc (@ccs) {
                $pop_sum += $cc_pop{$cc}->[$t];
            }
            $rc_f_pop{$rc}->[$t] = $pop_sum / $pop_scenario{$rc}->[$t];

            foreach my $cc (@ccs) {
                if ($year[$t] < $conv_year) {
                    $tmp{$cc} = ( ($year[$t]-$conv_year)/($base_year-$conv_year) * $cc_obj{$cc}/$cc_pop{$cc}->[0] + ($year[$t]-$base_year)/($conv_year-$base_year) * $conv_ratio_val) * $cc_pop{$cc}->[$t];
                    # * $pop_scenario{$rc}->[$t]/$pop_scenario{$rc}->[0]
                } else {
                    $tmp{$cc} = $conv_ratio_val * $cc_pop{$cc}->[$t];
                }
                $obj_sum += $tmp{$cc};
            }

            my $f = $obj_scenario{$rc}->[$t]*$rc_f_obj{$rc}/$obj_sum;

            foreach my $cc (@ccs) {
                my $aref = $out_data{$cc};
                my @arr = @$aref;
                push @arr, ( $tmp{$cc} * $f );
                $out_data{$cc} = \@arr;
            }

# # test: sum in region should coincide with scenario_obj.
#             my $test_sum = 0;
#             foreach my $cc (@ccs) {
#                 $test_sum += $out_data{$cc}->[$t];
#             }
#             print "$rc, $year[$t]: $test_sum ", $rc_f_obj{$rc} * $obj_scenario{$rc}->[$t], "\n";

        }
    }
}

sub calc_2 {
    my $conv_year_idx = &arrindex(\@year, $conv_year);

    foreach my $rc (@regs) {
        my $ref = $rc_cc{$rc};
        my @ccs = @$ref;
        
        my $obj_sum = 0;
        my $pop_sum_by = 0;
        foreach my $cc (@ccs) {
            $obj_sum += $cc_obj{$cc};
            $pop_sum_by += $cc_pop{$cc}->[0];

            my @arr = ($cc_obj{$cc});
            $out_data{$cc} = \@arr;
        }
        $rc_f_obj{$rc} = ($obj_sum/$pop_sum_by) / $obj_scenario{$rc}->[0];
        $rc_pop{$rc}->[0] = $pop_sum_by;

        my $conv_ratio_val = $obj_scenario{$rc}->[$conv_year_idx]*$rc_f_obj{$rc};

        for my $t (1..$#year) {
            my %tmp;
            my $obj_sum = 0;

            my $pop_sum = 0;
            foreach my $cc (@ccs) {
                $pop_sum += $cc_pop{$cc}->[$t];
            }
            $rc_pop{$rc}->[$t] = $pop_sum;

            foreach my $cc (@ccs) {
                if ($year[$t] < $conv_year) {
                    $tmp{$cc} = ( ($year[$t]-$conv_year)/($base_year-$conv_year) * $cc_obj{$cc}/$cc_pop{$cc}->[0] + ($year[$t]-$base_year)/($conv_year-$base_year) * $conv_ratio_val) * $cc_pop{$cc}->[$t];
                } else {
                    $tmp{$cc} = $conv_ratio_val * $cc_pop{$cc}->[$t];
                }
                $obj_sum += $tmp{$cc};
            }

#            my $f = $obj_scenario{$rc}->[$t]*$rc_f_obj{$rc}*$pop_sum/$obj_sum;
            my $f = 1;

            foreach my $cc (@ccs) {
                my $aref = $out_data{$cc};
                my @arr = @$aref;
                push @arr, ( $tmp{$cc} * $f );
                $out_data{$cc} = \@arr;
            }
        }
    }
}

sub postproc_ccdata {
    &has_same_length_subarray(\%cc_pop) or die "cc_pop may have some missing values\n";
    @regs = keys(%rc_cc);

    %cc_pop = %{interp_data(\%cc_pop)};

    my @y_cc = @{$cc_pop{'year'}};
    &arrindex(\@y_cc, $base_year) >= 0 or die "base year doesnt contained in scenario_obj.\n";
    &arrindex(\@y_cc, $conv_year) >= 0 or die "convergence year doesnt contained in scenario_obj.\n";

}

sub baseshift_ccdata {
    while ($cc_pop{'year'}->[0] != $base_year) {
        shift_hash (\%cc_pop);
    }
}

sub read_ccdata {
    my $datafile = $_[0];

    open IN, $datafile;
    my $line = <IN>;
    my @data = <IN>;
    close IN;

    chomp $line;
    my ($cc, $rc, $obj, @data_year) = split /\t/, $line;

    @cc_year = @data_year;
    
    $cc_pop{'year'} = \@data_year;

    foreach $line (@data) {
        chomp $line;
        my ($cc, $rc, $obj, @pop) = split /\t/, $line;

        if ($cc_rc{$cc}) {
            die "cc:$cc appears more than once!\n";
        }

        unless ($cc =~ /^[ ]*$/) {
            $cc_rc{$cc} = $rc;
            $cc_obj{$cc} = $obj;
            $cc_pop{$cc} = \@pop;
            if (my $ref = $rc_cc{$rc}) {
                my @ccarr = @$ref;
                unshift @ccarr, $cc;
                $rc_cc{$rc} = \@ccarr;
            } else {
                my @ccarr = ($cc);
                $rc_cc{$rc} = \@ccarr;
            }
        }
    }
#     print join(" ",keys(%rc_cc)),"\n";
#     my $rc = (keys(%rc_cc))[1];
#     my $t = $rc_cc{$rc};
#     my @arr = @$t;
#     print "$rc: ",join(" ",@arr), "\n";
}

sub postproc_scenario_3 {
    if ($obj_s_gr>0) {
        %obj_scenario = %{&percent_hash (\%obj_scenario) } if $obj_s_percent > 0;

        my %rc_obj = %{&regional_sum(\%cc_obj)};
        %obj_scenario = %{&rate_unit_to_baseyear (\%obj_scenario)} if $obj_s_gr == 2;
        %obj_scenario = %{&growth_rate_conversion (\%obj_scenario, \%rc_obj)};
    }

    if ($pop_s_gr>0) {
        %pop_scenario = %{&percent_hash (\%pop_scenario) } if $pop_s_percent > 0;

        my %rc_pop0 = %{&regional_sum(&hash_idx(\%cc_pop, &arrindex(\@cc_year,$base_year) ))};
        %pop_scenario = %{&rate_unit_to_baseyear (\%pop_scenario) } if $pop_s_gr == 2 ;
        %pop_scenario = %{&growth_rate_conversion (\%pop_scenario, \%rc_pop0)};
    }

    &has_same_keys(\%obj_scenario, \%pop_scenario) or die "region match error!\n";
    &has_same_length_subarray(\%obj_scenario) or die "obj_scenario may have some missing values\n";
    &has_same_length_subarray(\%pop_scenario) or die "pop_scenario may have some missing values\n";

    %obj_scenario = %{interp_data(\%obj_scenario)};
    %pop_scenario = %{interp_data(\%pop_scenario)};

    my @y_obj = @{$obj_scenario{'year'}};
    &arrindex(\@y_obj, $base_year) >= 0 or die "base year doesnt contained in scenario_obj.\n";
    &arrindex(\@y_obj, $conv_year) >= 0 or die "convergence year doesnt contained in scenario_obj.\n";
    my @y_pop = @{$pop_scenario{'year'}};
    &arrindex(\@y_pop, $base_year) >= 0 or die "base year doesnt contained in scenario_pop.\n";
    &arrindex(\@y_pop, $conv_year) >= 0 or die "convergence year doesnt contained in scenario_pop.\n";

    while ($obj_scenario{'year'}->[0] != $base_year) {
        shift_hash (\%obj_scenario);
    }
    while ($pop_scenario{'year'}->[0] != $base_year) {
        shift_hash (\%pop_scenario);
    }

    @y_obj = @{$obj_scenario{'year'}};
    @y_pop = @{$pop_scenario{'year'}};
    &is_same_array(\@y_obj,\@y_pop) or die "obj_scenario & pop_scenario's year array doesn't match!\n";
    @year = @y_obj;

    delete $obj_scenario{'year'};
    delete $pop_scenario{'year'};
}

sub postproc_scenario_2 {
    if ($obj_s_gr>0) {
        %obj_scenario = %{&percent_hash (\%obj_scenario) } if $obj_s_percent > 0;

        my %rc_obj = %{&regional_weighted_avg(\%cc_obj,&hash_idx (\%cc_pop, &arrindex(\@cc_year,$base_year) ))};
        %obj_scenario = %{&rate_unit_to_baseyear (\%obj_scenario)} if $obj_s_gr == 2;
        %obj_scenario = %{&growth_rate_conversion (\%obj_scenario, \%rc_obj)};
    }

    &has_same_length_subarray(\%obj_scenario) or die "obj_scenario may have some missing values\n";
    %obj_scenario = %{interp_data(\%obj_scenario)};
    my @y_obj = @{$obj_scenario{'year'}};
    &arrindex(\@y_obj, $base_year) >= 0 or die "base year doesnt contained in scenario_obj.\n";
    &arrindex(\@y_obj, $conv_year) >= 0 or die "convergence year doesnt contained in scenario_obj.\n";
    while ($obj_scenario{'year'}->[0] != $base_year) {
        shift_hash (\%obj_scenario);
    }
    @y_obj = @{$obj_scenario{'year'}};
    @year = @y_obj;
    delete $obj_scenario{'year'};
}

# sub show_data {
#     foreach (keys(%obj_scenario)) {
#         my $t = $obj_scenario{$_};
#         print $_, " ", join(" ", @$t), "\n";
#     }
#     print "\n", join(" ", keys(%obj_scenario)), "\n\n";
#     foreach (keys(%pop_scenario)) {
#         my $t = $pop_scenario{$_};
#         print $_, " ", join(" ", @$t), "\n";
#     }
#     print "\n", join(" ", keys(%pop_scenario)), "\n\n";
# }

sub rate_unit_to_baseyear {
    my %h = %{$_[0]};
    my @yarr = @{$h{'year'}};
    delete $h{'year'};
    my $idx=0;
    while ($yarr[$idx]<$base_year) {
        $idx++;
    }
    my $a = 0; $b = 1;
    if ($yarr[$idx] != $base_year) {
        $a = ($yarr[$idx]-$base_year)/($yarr[$idx]-$yarr[$idx-1]);
        $b = ($base_year-$yarr[$idx-1])/($yarr[$idx]-$yarr[$idx-1]);
    }
    foreach my $key (keys(%h)) {
        my @arr = @{$h{$key}};
        my $s = $arr[$idx-1] * $a + $arr[$idx] * $b;
        foreach my $i (1..$#arr) {
            $arr[$i] /= $s;
        }
        $h{$key} = \@arr;
    }
    $h{'year'} = \@yarr;
    return \%h;
}

###################################################################################
# subroutines which DO NOT access global variables
###################################################################################

sub shift_hash {
    my %hash = %{$_[0]};
    
    foreach my $key (keys(%hash)) {
        shift @{$hash{$key}};
    }
}

sub percent_hash {
    my %hash = %{$_[0]};
    my @yarr = @{$hash{'year'}};
    my $s = $#yarr;
    delete $hash{'year'};
    foreach my $key (keys(%hash)) {
        foreach my $i (0..$s) {
            $hash{$key}->[$i] /= 100;
        }
    }
    $hash{'year'} = \@yarr;
    return \%hash;
}

sub growth_rate_conversion {
    my %hash = %{$_[0]};
    my %r = %{$_[1]};

    my @yarr = @{$hash{'year'}};
    delete $hash{'year'};

    my $s = $#yarr;
    foreach my $key (keys(%hash)) {
        foreach my $i (1..$s) {
            $hash{$key}->[$i] *= $r{$key};
        }
    }

    $hash{'year'} = \@yarr;

    return \%hash;
}

sub read_scenario {
    my $scenario_file = $_[0];
    my %hash;

    open IN, $scenario_file or die "Cannot open $scenario_file !\n";
    my @tmp = <IN>;
    close IN;

    my $line = shift @tmp;
    chomp $line;
    my @l = split /\t/, $line;
    shift @l;
    foreach my $i (0..$#l) {
        $l[$i] =~ s/ //g;
        $l[$i] =~ s/\r//g;
    }
    $hash{'year'} = \@l;

    foreach my $line (@tmp) {
        chomp $line;
        my @l = split /\t/, $line;
        my $rc = shift @l;
        $hash{$rc} = \@l unless $rc =~ /^[ ]*$/;
    }

    return %hash;
}


sub has_same_keys {
    my %hash1 = %{$_[0]};
    my %hash2 = %{$_[1]};

    my @keys1 = sort(keys(%hash1));
    my @keys2 = sort(keys(%hash2));

    &is_same_array(\@keys1,\@keys2) or return 0; # false
    return 1; # true
}

sub is_same_array {
    my @arr1 = @{$_[0]};
    my @arr2 = @{$_[1]};

    if ($#arr1 != $#arr2) {
        return 0; # false
    }

    my $err = 0;
    for (my $i=0; $i<=$#arr1; $i++) {
        $err ++ if $arr1[$i] ne $arr2[$i];
    }
    if ($err > 0) {
        return 0; # false
    }
    return 1; # true
}

sub has_same_length_subarray {
    my %hash = %{$_[0]};
    my @keys = keys(%hash);

    my $l = $#{$hash{$keys[0]}};

    my $err = 0;
    for (my $i=1; $i<=$#keys; $i++) {
        $err++ if $l != $#{$hash{$keys[$i]}};
    }
    return $err>0 ? 0 : 1;
}

sub arrindex {
  my @arr = @{$_[0]};
  my $val = $_[1];

  foreach my $i (0..$#arr) {
    if ($arr[$i] eq $val) {
      return $i;
    }
  }
  return -1;
}

sub interp_data {
  my %h1 = %{$_[0]};
  my %hash = %h1;

  my $interval = 5;

  my @y = @{$hash{'year'}};
  my @y_full;
  my @cur_index;

  my $prev_y = $y[0] - $interval;
  my $j = 0;
  foreach my $i (0..$#y) {
      if ($y[$i] > $prev_y+$interval) {
          for (my $s=$prev_y+$interval;$s<$y[$i];$s+=$interval) {
              push (@y_full, $s);
              $j++;
          }
      }
      push (@cur_index, $j);
      push (@y_full, $y[$i]);
      $j++;
      $prev_y = $y[$i];
  }

#   print "@y\n";
#   print "@y_full\n";
#   print "@cur_index\n";

  delete ($hash{'year'});

  foreach my $key (keys(%hash)) {
    my @orig = @{$hash{$key}};
    my @tmp;

    my $s = 0;
    foreach my $i (0..$#y_full) {
        if ($cur_index[$s] == $i) {
            push (@tmp, $orig[$s] );
            $s++;
        } else {
            my $val = ($orig[$s] - $orig[$s-1])/($y[$s]-$y[$s-1])*( $y_full[$i] - $y[$s-1] ) + $orig[$s-1];
            push (@tmp, $val);
        }
    }

    $hash{$key} = \@tmp;
#     print "$key @tmp\n";
  }

  $hash{'year'} = \@y_full;

  return \%hash;
}

sub regional_sum {
    my %hash = %{$_[0]};
    
    my %result;
    foreach my $key (keys(%hash)) {
        $result{$cc_rc{$key}} += $hash{$key};
    }

    return \%result;
}

sub regional_weighted_avg {
    my %hash = %{$_[0]};
    my %wgt = %{$_[1]};
    
    my %out;
    my %wgtsum;
    foreach my $key (keys(%hash)) {
        $out{$cc_rc{$key}} += $hash{$key} * $wgt{$key};
        $wgtsum{$cc_rc{$key}} += $wgt{$key};
    }
    foreach my $key (keys(%out)) {
        $out{$key} /= $wgtsum{$key};
    }

    return \%out;
}

sub hash_idx {
    my %hash = %{$_[0]};
    my $idx = $_[1];
    my %out;
    foreach my $key (keys(%hash)) {
        $out{$key} = $hash{$key}->[$idx];
    }
    return \%out;
}


# Local Variables:
# coding: euc-jp
# End:
