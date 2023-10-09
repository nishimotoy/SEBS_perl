#!/opt/perl/bin/perl
# Burden Sharing :: Brazilian Proposal

# �g����  perl bp.pl inputfile outputfile
# perl bp.pl ./bp/pathgraph-emission_B2_2010_475_test_test.txt ./bp/emission_B2_2010_475_test_test_BP_0097.txt

#==========
#  �\��
#==========
#     
#     +-- here / CRF_BP.bat  		���̃t�@�C���A�u���W���v�Z�̖{��
#			|
#			+--  bp /	�ݒ�t�@�C��
#			|			pathgraph-emission_B2_2010_475_test_test.txt	���́FGlobal Path���̓t�@�C��
#			|			past_pop.txt			1900-2200�l���t�@�C��
#			|			past_emission.txt		1900-�X�^�[�g�N�̔r�o�ʃt�@�C���i6�K�X���Z�j
#			|			past_contribution.txt	1900-�X�^�[�g�N�̊�^�t�@�C���i6�K�X���Z�j
#			|			CRF.txt					CRF�֐��iallowance�s�̒l���g���j
#			|			CRF.txt					CRF�֐��iallowance�s�̒l���g���j
#			|			emission_B2_2010_ghg_temp_***_BP_0097.txt		�o�́F�n��ʔr�o�ʏo�̓t�@�C���i�Ō��option�w��j
#			|			contribution_B2_2010_ghg_temp_***_BP_0097.txt	�n��ʊ�^�o�̓t�@�C��
#			|			gap_B2_2010_ghg_temp_***_BP_0097.txt			�ŏI�N�ɂ������l�������^�̍ő卑�ƍŏ����̔�
#			+ 

#=============
#  �ݒ�
#=============
$n = 1;
$preind_year = 1900;		# �r�o���ԊJ�n�N
$final_year  = 2200;		# �r�o���ԍŏI�N
$latest_year = 2010;		# ���e�ʎZ�o�̃X�^�[�g�N�i����r�o�ʂ̍ŏI�N�j
$allowance_flag = 1;		# $latest_year��̔r�o�ʂ�allowance�Ƃ��ď����o�����B1=�����o��, 0=���Ȃ�

# my $inputfile = './bp/pathgraph-emission_B2_2010_475_test_test.txt';	# $ARG[0]
# my $outputfile = './bp/emission_B2_2010_475_test_test_BP_0097.txt';		# $ARG[1], �Ō��$b*1000
my $inputfile = $ARGV[0];
my $outputfile = $ARGV[1];					#�Ō��$b*1000

my $pastpopfile = './bp/past_pop.txt';
my $pastcontrfile = './bp/past_contribution.txt';
my $pastemifile = './bp/past_emission.txt';
#my $allowancefile = "./bp/allowance.txt";
my $CRFfile = "./bp/CRF.txt";
# $outputfile, $pastpopfile, $pastemifile, $pastcontrfile �ɂ����鍑�̕��я��͑����邱��

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
#  past contribution �Ǎ�
#=============

open (IN, "$pastcontrfile") or die "Can't open: $pastcontrfile: $!";
my $line = <IN>;
chomp ($line);
my @country = split(/\t/, $line);	# ��No.�͂����Œ�`
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
#  �l���Ǎ�
#=============

open (IN, "$pastpopfile") or die "Can't open: $pastpopfile: $!";
my $line = <IN>;
chomp ($line);
my @pop_country = split(/\t/, $line);	# ��No., past_contribution
# �����ŁA���̕��я�����v���Ă��邩�`�F�b�N
my %population;
while  (<IN>)  {
	chomp;
	s/\s*\t\s*/\t/ig;
	my @for_hash = split(/\t/, $_, 2);
	$population{$for_hash[0]} = $for_hash[1];
}
close(IN);

#=============
#  �ߋ��r�o�ʓǍ��A�X�^�[�g�N�̔r�o�� $latest_emission
#=============

open (IN, "$pastemifile") or die "Can't open: $pastemifile: $!";
my $line = <IN>;
chomp ($line);
# my @emi_country = split(/\t/, $line);	# ��No.
# �����ŁA���̕��я�����v���Ă��邩�`�F�b�N
my %past_emission;
while  (<IN>) {
	chomp;
	s/\s*\t\s*/\t/ig;
	my @for_hash = split(/\t/, $_, 2);
	$past_emission{$for_hash[0]} = $for_hash[1];
}
close(IN);

# �X�^�[�g�N��emission
@latest_emission = split(/\t/, $past_emission{$latest_year});
@latest_emission = ($latest_year, @latest_emission, 0);
foreach (1..$#country-1) {
	$latest_emission[$#country] += $latest_emission[$_]; 
}

#=============
#  Global path �Ǎ�
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

# �p�X����N��key�Ƃ���n�b�V�� %path, %emi_rate���쐬
my %path;
my %emi_rate;
$pathemission[0] = 1;	# $emi_rate{$pathyear[1]} ���Z�o���邽�߂�Dummy
foreach (1..$#pathyear) {
	$path{$pathyear[$_]} = $pathemission[$_];
	$emi_rate{$pathyear[$_-1]} = $pathemission[$_]/$pathemission[$_-1]-1;
}
$emi_rate{$pathyear[$#pathyear]} = 0;

# �r�o�ʁA��^�o�̓t�@�C������

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
#  ���������^�]���N��loop
#============================

for ( $eval_year=$preind_year; $eval_year<=$final_year; $eval_year=$eval_year+10 ) {

	if ( $eval_year>=$latest_year and $emi_rate_world ne '' ) { 
		$emi_rate_world = $emi_rate{$eval_year}; 
	} 
	if ( $emi_rate_world eq '' ) { $emi_rate_world=0; }	# path�ݒ��ԊO�͕ω���=0

	#=============
	# ��^�]���N�̃f�[�^����
	#=============

	# �l���f�[�^
	@pop = split(/\t/, $population{$eval_year});
	@pop = ($eval_year, @pop, 0);
	foreach (1..$#country-1) {
		$pop[$_] = $pop[$_] * 1000;		# �l���̒P�ʂ��قȂ�
		$pop[$#country] += $pop[$_]; 
	}

	# �X�^�[�g�N�ȑO�̔r�o���ɗR������]���N�̊�^
	@past_contr = split(/\t/, $past_contribution{$eval_year});
	@past_contr = ($eval_year, @past_contr, 0);
	foreach (1..$#country-1) {
		$past_contr[$#country] += $past_contr[$_]; 
	}

	# �]���N��emission
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
	#  �ߋ��̊�^�Z�o�i�r�o�ʁ~CRF�W���j
	#==============================

	# �m�F�p�o��
	foreach (1..$#country) { 			# ����loop
		$contribution[$_] = $past_contr[$_]; 						# �ݐϊ�^�i�S�K�X�j
		$contr_per_pop[$_] = $contribution[$_]/$pop[$_]; 			# ��l������ݐϊ�^�i�S�K�X�j
		$contr_by_gas[$_] = $past_contr[$_]; 						# dummy �ݐϊ�^�i�K�X�ʁj
		$contr_by_gas_per_pop[$_] = $contr_by_gas[$_]/$pop[$_]; 	# ��l������ݐϊ�^�i�K�X�ʁj
		$emission_accumulated[$_] += $eval_emi[$_]; 				# �ݐϔr�o�ʁiMt-CO2e�j
		$emi_per_pop[$_] = $emission_accumulated[$_]/$pop[$_]; 		# ��l������ݐϔr�o�ʁiMt-CO2e�j

		$emission_eval[$_] = $eval_emi[$_]; 						# �]���N�̔r�o�ʁi�S�K�X�AMt-CO2e�j
		$emi_eval_per_pop[$_] = $emission_eval[$_]/$pop[$_] ; 		# ��l������r�o�ʁi�S�K�X�AMt-CO2e�j
	}

	#=======================
	#  allowance ����
	#=======================

	# allowance loop
		$eval_gas = 'allowance';				# $eval_gas : �]�����̃K�X
		foreach (1..$#country) { $contr_by_gas[$_]=0; $contr_by_gas_per_pop[$_]=0; }
		@adjust1990 = 0;

		#=======================
		#  CRF�֐��̃n�b�V����
		#=======================

		# �N(tau)��key�Ƃ����n�b�V�����쐬
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
		#  �r�o�ʂ��t�@�C���Ǎ��A����
		#=======================

		open (IN, "$allowancefile") or die "Can't open: $!";
		<IN>;
		while  (<IN>)  {
			chomp;
			@line =  split(/\t/);

			# CRF�֐���key�ƂȂ�N$year�i��^�v�Z������tau�j���Z�o
			# $line[0]:emission_year, $line[1..$#line]:emission
			my $tauyear = $eval_year - $line[0];
			my $emissionyear = $line[0];

			# 1990�N�r�o�ʒ����W�����擾����A�r�o�ʂ𒲐��A���E�S�̂̔r�o�ʂ��Z�o����
			# SEBS�ł͕s�v
			if ( /^adjust1990/ ) { 	# 1990�N�r�o�ʒ����W�����擾
				@adjust1990 = @line;
				# next; 
			} else {
				foreach (1..$#country-1) { 
					# ���ӁI������^�Ŕ�r���Ă���
					# print "\$adjust1990[$_] : $adjust1990[$_]\n"; 
					if ( $adjust1990[$_] eq "" or $adjust1990[$_] == 0 ) { $adjust1990[$_] = 1; }
					# print "\$adjust1990[$_] : $adjust1990[$_]\n"; 
					$line[$_] = $line[$_] * $adjust1990[$_];
					$line[$#country] += $line[$_];
				}
			}

			#==============================
			# 10�N�X�p����1�N�X�p���ɕ��
			#==============================
			# emission(allowance)�t�@�C���̊� �` �O�̊���9�N�����Ԃ���
			for ( my $i=1; $i<11; ++$i ) {

					#==============================
					#  �r�o�N�ɑΉ�����CRF�W��
					#==============================
					# emission_year �ɑΉ����� CRF�W����Ԃ��A10�N�X�p���̃f�[�^������
					foreach (1..$#CRFyear) {
						if ( $tauyear == $CRFyear[$_] ) { 
							$CRFtauyear = $CRF{$CRFyear[$_]};
							$CRFtauyear_next = $CRF{$CRFyear[$_+1]};
							last;
						}
					}

					#==============================
					#  ��^�Z�o�i�r�o�ʁ~CRF�W���j
					#==============================
					foreach (1..$#country) { 			# ����loop
						# if ( $i == 0 ) { $CRFcoefficient = $CRFtauyear; }
						$CRFcoefficient = $CRFtauyear_next**((10-$i)/10) * $CRFtauyear**($i/10);
						$emi[$_] = $latest_emission[$_]**((10-$i)/10) * $line[$_]**($i/10);

						$year_contr = $emi[$_]*$CRFcoefficient;					# emission�~CRF�W��
						$contribution[$_] += $year_contr; 						# �ݐϊ�^�i�S�K�X�j
						$contr_per_pop[$_] = $contribution[$_]/$pop[$_]; 		# ��l������ݐϊ�^�i�S�K�X�j
						$contr_by_gas[$_] += $year_contr; 						# �ݐϊ�^�i�K�X�ʁj
						$contr_by_gas_per_pop[$_] = $contr_by_gas[$_]/$pop[$_]; # ��l������ݐϊ�^�i�K�X�ʁj
						$emission_accumulated[$_] += $emi[$_]; 					# �ݐϔr�o�ʁiMt-CO2e�j
						$emi_per_pop[$_] = $emission_accumulated[$_]/$pop[$_]; 	# ��l������ݐϔr�o�ʁiMt-CO2e�j
					}
			}							# for 10�N���� end

			if ( $emissionyear == $eval_year ) { 
				foreach (1..$#country) { 
					$emission_eval[$_] = $emi[$_]; 						# �]���N�̔r�o�ʁi�S�K�X�AMt-CO2e�j
					$emi_eval_per_pop[$_] = $emission_eval[$_]/$pop[$_] ; 	# ��l������r�o�ʁi�S�K�X�AMt-CO2e�j
				}
			}
			$latest_emission[0] = $emissionyear;
			$latest_emission[$#country] = 0;
			foreach (1..$#country-1) { 			# ����loop
				$latest_emission[$_] = $line[$_];
				$latest_emission[$#country] += $latest_emission[$_];
			}
		}				# while <IN> end
		close(IN);

		# ��^�A�r�o�ʂ��o��
		print EM "$eval_year";
		print CO "$eval_year";
			foreach (1..$#country-1) {
				print EM "\t$emission_eval[$_]";
				print CO "\t" . ($contribution[$_]/10000000);
			}
			print EM "\n";
			print CO "\n";

	#=====================
	#  �����̔r�o�ʎZ�o
	#=====================

	$contri_world	= $contribution[$#country];
	$emi_world	= $emission_eval[$#country];
	$pop_world	= $pop[$#country];

	#	��^���玟���i10�N��j�r�o��(temp)���Z�o
	foreach (1..$#country) { 
		$contri_index[$_]  = - ( ($contr_per_pop[$_]**$n) - ($contr_per_pop[$#country]**$n) );
		$emi_rate_temp[$_] = $emi_rate_world - $b * ( ($contr_per_pop[$_] - $contr_per_pop[$#country])**$n );
		$emi_next_temp[$_] = $emission_eval[$_] * ( 1 + $emi_rate_temp[$_] );
		# $emi_next_temp[$_] = $emission_eval[$_] + ( abs($emission_eval[$_]) * $emi_rate_temp[$_] );

		# �r�o�ʂ��}�C�i�X�ɂȂ�����A�r�o��=0�Ƃ���
        if ( $emi_next_temp[$_] < 0 ) { $emi_next_temp[$_] = 0; }

	}

	#	�e���r�o��(temp)�̘a�𐢊E�S�̂̔r�o�ʂɈ�v�����邽�߂̌W������
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
	#  $latest_year��̔r�o�ʂ��o��
	#=================================

	#	2010�N�ȍ~�̔r�o�ʂ�EDGAR_allowance.txt�ɏ����o��

	if ( $allowance_flag==1 and $eval_year >= $latest_year-1 and $eval_year < $final_year ) {
		open (AL, ">>$allowancefile") or die "Can't open: $!";

		# $eval_year�ɂ���
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
