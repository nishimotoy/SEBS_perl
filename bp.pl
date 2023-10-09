#!/opt/perl/bin/perl
# Burden Sharing :: Brazilian Proposal

# 使い方  perl bp.pl inputfile outputfile
# perl bp.pl ./bp/pathgraph-emission_B2_2010_475_test_test.txt ./bp/emission_B2_2010_475_test_test_BP_0097.txt

#==========
#  構成
#==========
#     
#     +-- here / CRF_BP.bat  		このファイル、ブラジル計算の本体
#			|
#			+--  bp /	設定ファイル
#			|			pathgraph-emission_B2_2010_475_test_test.txt	入力：Global Path入力ファイル
#			|			past_pop.txt			1900-2200人口ファイル
#			|			past_emission.txt		1900-スタート年の排出量ファイル（6ガス合算）
#			|			past_contribution.txt	1900-スタート年の寄与ファイル（6ガス合算）
#			|			CRF.txt					CRF関数（allowance行の値を使う）
#			|			CRF.txt					CRF関数（allowance行の値を使う）
#			|			emission_B2_2010_ghg_temp_***_BP_0097.txt		出力：地域別排出量出力ファイル（最後にoption指定）
#			|			contribution_B2_2010_ghg_temp_***_BP_0097.txt	地域別寄与出力ファイル
#			|			gap_B2_2010_ghg_temp_***_BP_0097.txt			最終年における一人あたり寄与の最大国と最小国の比
#			+ 

#=============
#  設定
#=============
$n = 1;
$preind_year = 1900;		# 排出期間開始年
$final_year  = 2200;		# 排出期間最終年
$latest_year = 2010;		# 許容量算出のスタート年（決定排出量の最終年）
$allowance_flag = 1;		# $latest_year後の排出量をallowanceとして書き出すか。1=書き出す, 0=しない

# my $inputfile = './bp/pathgraph-emission_B2_2010_475_test_test.txt';	# $ARG[0]
# my $outputfile = './bp/emission_B2_2010_475_test_test_BP_0097.txt';		# $ARG[1], 最後に$b*1000
my $inputfile = $ARGV[0];
my $outputfile = $ARGV[1];					#最後に$b*1000

my $pastpopfile = './bp/past_pop.txt';
my $pastcontrfile = './bp/past_contribution.txt';
my $pastemifile = './bp/past_emission.txt';
#my $allowancefile = "./bp/allowance.txt";
my $CRFfile = "./bp/CRF.txt";
# $outputfile, $pastpopfile, $pastemifile, $pastcontrfile における国の並び順は揃えること

#my @split = split(/_/, $outputfile, 2);
#my $contrfile = join('_', './bp/contribution' ,$split[1] );
#my $gapfile = join('_', './bp/gap' ,$split[1] );
my $contrfile = $outputfile;
$contrfile =~ s/emission_/contribution_/;
my $gapfile = $outputfile;
$gapfile =~ s/emission_/gap_/;
my $allowancefile = $outputfile;
$allowancefile =~ s/emission_/allowance_/;

#my ( $emi, $scenario, $start_year, $ghg, $temp, $temp_speed, $bs, $option ) = split(/_/, $outputfile);	# $ARGV[1]
my @tmparray = split(/_/,$outputfile);
$option = $tmparray[$#tmparray];
$option =~ s/\.output.txt//;
$option =~ s/\.txt//;
my $b = $option/1000;

#print "$b\n";

#=============
#  past contribution 読込
#=============

open (IN, "$pastcontrfile") or die "Can't open: $pastcontrfile: $!";
my $line = <IN>;
chomp ($line);
my @country = split(/\t/, $line);	# 国No.はここで定義
@country = (@country, 'World');
# print "@country\n";
my %past_contribution;
while  (<IN>)  {
	chomp;
	s/\s*\t\s*/\t/ig;
	my @for_hash = split(/\t/, $_, 2);
	$past_contribution{$for_hash[0]} = $for_hash[1];
	# print "$for_hash[0] : $for_hash[1] : $past_contribution{$for_hash[0]}\n";
}
close(IN);

#=============
#  人口読込
#=============

open (IN, "$pastpopfile") or die "Can't open: $pastpopfile: $!";
my $line = <IN>;
chomp ($line);
my @pop_country = split(/\t/, $line);	# 国No., past_contribution
# ここで、国の並び順が一致しているかチェック
my %population;
while  (<IN>)  {
	chomp;
	s/\s*\t\s*/\t/ig;
	my @for_hash = split(/\t/, $_, 2);
	$population{$for_hash[0]} = $for_hash[1];
}
close(IN);

#=============
#  過去排出量読込、スタート年の排出量 $latest_emission
#=============

open (IN, "$pastemifile") or die "Can't open: $pastemifile: $!";
my $line = <IN>;
chomp ($line);
# my @emi_country = split(/\t/, $line);	# 国No.
# ここで、国の並び順が一致しているかチェック
my %past_emission;
while  (<IN>) {
	chomp;
	s/\s*\t\s*/\t/ig;
	my @for_hash = split(/\t/, $_, 2);
	$past_emission{$for_hash[0]} = $for_hash[1];
}
close(IN);

# スタート年のemission
@latest_emission = split(/\t/, $past_emission{$latest_year});
@latest_emission = ($latest_year, @latest_emission, 0);
foreach (1..$#country-1) {
	$latest_emission[$#country] += $latest_emission[$_]; 
}

#=============
#  Global path 読込
#=============

open (IN, "$inputfile") or die "Can't open: $inputfile: $!";
my @pathyear;
my @pathemission;
while  (<IN>)  {
	chomp;
	if (/^Path\s*\t/) {
		@pathyear = split (/\t/);
	} elsif (/^Pathway\s*\t/) {
		@pathemission = split (/\t/);
	}
}
close(IN);

# パスから年をkeyとするハッシュ %path, %emi_rateを作成
my %path;
my %emi_rate;
$pathemission[0] = 1;	# $emi_rate{$pathyear[1]} を算出するためのDummy
foreach (1..$#pathyear) {
	$path{$pathyear[$_]} = $pathemission[$_];
	$emi_rate{$pathyear[$_-1]} = $pathemission[$_]/$pathemission[$_-1]-1;
}
$emi_rate{$pathyear[$#pathyear]} = 0;

# 排出量、寄与出力ファイル準備

open (EM, ">$outputfile") or die "Can't open: $outputfile: $!";
open (CO, ">$contrfile") or die "Can't open: $contrfile: $!";
open (AL, ">$allowancefile") or die "Can't open: $allowancefile: $!";
foreach (1..$#country-1) {
	print EM "\t$country[$_]";
	print CO "\t$country[$_]";
	print AL "\t$country[$_]";
}
print EM "\n";
print CO "\n";
print AL "\n";
close(AL);

#============================
#  ここから寄与評価年でloop
#============================

for ( $eval_year=$preind_year; $eval_year<=$final_year; $eval_year=$eval_year+10 ) {

	if ( $eval_year>=$latest_year and $emi_rate_world ne '' ) { 
		$emi_rate_world = $emi_rate{$eval_year}; 
	} 
	if ( $emi_rate_world eq '' ) { $emi_rate_world=0; }	# path設定区間外は変化率=0

	#=============
	# 寄与評価年のデータ準備
	#=============

	# 人口データ
	@pop = split(/\t/, $population{$eval_year});
	@pop = ($eval_year, @pop, 0);
	foreach (1..$#country-1) {
		$pop[$_] = $pop[$_] * 1000;		# 人口の単位が異なる
		$pop[$#country] += $pop[$_]; 
	}

	# スタート年以前の排出分に由来する評価年の寄与
	@past_contr = split(/\t/, $past_contribution{$eval_year});
	@past_contr = ($eval_year, @past_contr, 0);
	foreach (1..$#country-1) {
		$past_contr[$#country] += $past_contr[$_]; 
	}

	# 評価年のemission
	if ( $eval_year <= $latest_year ) {
		@eval_emi = split(/\t/, $past_emission{$eval_year});
		@eval_emi = ($eval_year, @eval_emi, 0);
		foreach (1..$#country-1) {
			$eval_emi[$#country] += $eval_emi[$_]; 
		}
	} else {
		@eval_emi = ();
	}

	#==============================
	#  過去の寄与算出（排出量×CRF係数）
	#==============================

	# 確認用出力
	foreach (1..$#country) { 			# 国でloop
		$contribution[$_] = $past_contr[$_]; 						# 累積寄与（全ガス）
		$contr_per_pop[$_] = $contribution[$_]/$pop[$_]; 			# 一人あたり累積寄与（全ガス）
		$contr_by_gas[$_] = $past_contr[$_]; 						# dummy 累積寄与（ガス別）
		$contr_by_gas_per_pop[$_] = $contr_by_gas[$_]/$pop[$_]; 	# 一人あたり累積寄与（ガス別）
		$emission_accumulated[$_] += $eval_emi[$_]; 				# 累積排出量（Mt-CO2e）
		$emi_per_pop[$_] = $emission_accumulated[$_]/$pop[$_]; 		# 一人あたり累積排出量（Mt-CO2e）

		$emission_eval[$_] = $eval_emi[$_]; 						# 評価年の排出量（全ガス、Mt-CO2e）
		$emi_eval_per_pop[$_] = $emission_eval[$_]/$pop[$_] ; 		# 一人あたり排出量（全ガス、Mt-CO2e）
	}

	#=======================
	#  allowance 処理
	#=======================

	# allowance loop
		$eval_gas = 'allowance';				# $eval_gas : 評価中のガス
		foreach (1..$#country) { $contr_by_gas[$_]=0; $contr_by_gas_per_pop[$_]=0; }
		@adjust1990 = 0;

		#=======================
		#  CRF関数のハッシュ化
		#=======================

		# 年(tau)をkeyとしたハッシュを作成
		open (IN2, $CRFfile) or die "Can't open: $!";
		while  (<IN2>)  {
			if (/^CRFyear\s*\t/) {
				s/\n//;
				@CRFyear	= split (/\t/);
			}
			if (/^$eval_gas\s*\t/) {
				s/\n//;
				@CRFvalue	= split (/\t/);
				foreach (1..$#CRFyear) {
					$CRF{"$CRFyear[$_]"} = $CRFvalue[$_];
				}
			}
		}
		close(IN2);

		#=======================
		#  排出量をファイル読込、調整
		#=======================

		open (IN, "$allowancefile") or die "Can't open: $!";
		<IN>;
		while  (<IN>)  {
			chomp;
			@line =  split(/\t/);

			# CRF関数のkeyとなる年$year（寄与計算式中のtau）を算出
			# $line[0]:emission_year, $line[1..$#line]:emission
			my $tauyear = $eval_year - $line[0];
			my $emissionyear = $line[0];

			# 1990年排出量調整係数を取得する、排出量を調整、世界全体の排出量を算出する
			# SEBSでは不要
			if ( /^adjust1990/ ) { 	# 1990年排出量調整係数を取得
				@adjust1990 = @line;
				# next; 
			} else {
				foreach (1..$#country-1) { 
					# 注意！文字列型で比較している
					# print "\$adjust1990[$_] : $adjust1990[$_]\n"; 
					if ( $adjust1990[$_] eq "" or $adjust1990[$_] == 0 ) { $adjust1990[$_] = 1; }
					# print "\$adjust1990[$_] : $adjust1990[$_]\n"; 
					$line[$_] = $line[$_] * $adjust1990[$_];
					$line[$#country] += $line[$_];
				}
			}

			#==============================
			# 10年スパンを1年スパンに補間
			#==============================
			# emission(allowance)ファイルの期 ～ 前の期の9年分を補間する
			for ( my $i=1; $i<11; ++$i ) {

					#==============================
					#  排出年に対応したCRF係数
					#==============================
					# emission_year に対応した CRF係数を返す、10年スパンのデータから補間
					foreach (1..$#CRFyear) {
						if ( $tauyear == $CRFyear[$_] ) { 
							$CRFtauyear = $CRF{$CRFyear[$_]};
							$CRFtauyear_next = $CRF{$CRFyear[$_+1]};
							last;
						}
					}

					#==============================
					#  寄与算出（排出量×CRF係数）
					#==============================
					foreach (1..$#country) { 			# 国でloop
						# if ( $i == 0 ) { $CRFcoefficient = $CRFtauyear; }
						$CRFcoefficient = $CRFtauyear_next**((10-$i)/10) * $CRFtauyear**($i/10);
						$emi[$_] = $latest_emission[$_]**((10-$i)/10) * $line[$_]**($i/10);

						$year_contr = $emi[$_]*$CRFcoefficient;					# emission×CRF係数
						$contribution[$_] += $year_contr; 						# 累積寄与（全ガス）
						$contr_per_pop[$_] = $contribution[$_]/$pop[$_]; 		# 一人あたり累積寄与（全ガス）
						$contr_by_gas[$_] += $year_contr; 						# 累積寄与（ガス別）
						$contr_by_gas_per_pop[$_] = $contr_by_gas[$_]/$pop[$_]; # 一人あたり累積寄与（ガス別）
						$emission_accumulated[$_] += $emi[$_]; 					# 累積排出量（Mt-CO2e）
						$emi_per_pop[$_] = $emission_accumulated[$_]/$pop[$_]; 	# 一人あたり累積排出量（Mt-CO2e）
					}
			}							# for 10年処理 end

			if ( $emissionyear == $eval_year ) { 
				foreach (1..$#country) { 
					$emission_eval[$_] = $emi[$_]; 						# 評価年の排出量（全ガス、Mt-CO2e）
					$emi_eval_per_pop[$_] = $emission_eval[$_]/$pop[$_] ; 	# 一人あたり排出量（全ガス、Mt-CO2e）
				}
			}
			$latest_emission[0] = $emissionyear;
			$latest_emission[$#country] = 0;
			foreach (1..$#country-1) { 			# 国でloop
				$latest_emission[$_] = $line[$_];
				$latest_emission[$#country] += $latest_emission[$_];
			}
		}				# while <IN> end
		close(IN);

		# 寄与、排出量を出力
		print EM "$eval_year";
		print CO "$eval_year";
			foreach (1..$#country-1) {
				print EM "\t$emission_eval[$_]";
				print CO "\t" . ($contribution[$_]/10000000);
			}
			print EM "\n";
			print CO "\n";

	#=====================
	#  次期の排出量算出
	#=====================

	$contri_world	= $contribution[$#country];
	$emi_world	= $emission_eval[$#country];
	$pop_world	= $pop[$#country];

	#	寄与から次期（10年後）排出量(temp)を算出
	foreach (1..$#country) { 
		$contri_index[$_]  = - ( ($contr_per_pop[$_]**$n) - ($contr_per_pop[$#country]**$n) );
		$emi_rate_temp[$_] = $emi_rate_world - $b * ( ($contr_per_pop[$_] - $contr_per_pop[$#country])**$n );
		$emi_next_temp[$_] = $emission_eval[$_] * ( 1 + $emi_rate_temp[$_] );
		# $emi_next_temp[$_] = $emission_eval[$_] + ( abs($emission_eval[$_]) * $emi_rate_temp[$_] );

		# 排出量がマイナスになったら、排出量=0とする
        if ( $emi_next_temp[$_] < 0 ) { $emi_next_temp[$_] = 0; }

	}

	#	各国排出量(temp)の和を世界全体の排出量に一致させるための係数導入
	$emi_next_temp_sum = 0;
	foreach (1..$#country-1) { $emi_next_temp_sum += $emi_next_temp[$_]; }
	unless ( $emi_next_temp_sum == "" ) { 
		$fitting_coefficient = $emi_next_temp[$#country] / $emi_next_temp_sum;
	}
	foreach (1..$#country-1) { $emi_next[$_] = $emi_next_temp[$_] * $fitting_coefficient; }
	$emi_next[$#country] = $emi_next_temp[$#country];

	foreach (1..$#country) { 
		unless ( "$emission_eval[$_]-1" == "" ) { 
			$emi_rate[$_] = $emi_next[$_]/$emission_eval[$_]-1;
		}
	}

	#=================================
	#  $latest_year後の排出量を出力
	#=================================

	#	2010年以降の排出量をEDGAR_allowance.txtに書き出す

	if ( $allowance_flag==1 and $eval_year >= $latest_year-1 and $eval_year < $final_year ) {
		open (AL, ">>$allowancefile") or die "Can't open: $!";

		# $eval_yearについて
			$nextyear = $eval_year+10;
			print AL "$nextyear";
			# print EM "$nextyear";
			foreach (1..$#country-1) {
				# $em[$_] = ($emission_eval[$_]**((10-$i)/10)) * ($emi_next[$_]**($i/10));
				print AL "\t$emi_next[$_]";
				# print EM "\t$emi_next[$_]";
			}
			print AL "\n";
			# print EM "\n";
		close(AL);
	}
}	# $eval_year loop end
close(CO);
close(EM);

# final year max/min
my $min = $contr_per_pop[1];
my $max = $contr_per_pop[1];
foreach (1..$#country-1) {
	if ( $contr_per_pop[$_] > $max ) { $max = $contr_per_pop[$_]; }
	if ( $contr_per_pop[$_] < $min ) { $min = $contr_per_pop[$_]; }
	# print "$_ : $contr_per_pop[$_] : $min : $max\n";
}
my $gap = $max/$min;
open (GAP, ">$gapfile") or die "Can't open: $!";
print GAP "$gap\n";
close(GAP);

__END__
