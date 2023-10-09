#!/opt/perl/bin/perl
##########################################################
# ForumScript.co.uk 30/08/2006
# 1999-2006 ForumScript.co.uk
# Script Updated for ForumScript.co.uk by Babelnotes.be
##########################################################
# Instructions: http://www.ForumScript.co.uk/instructions/
# FAQ:          http://www.ForumScript.co.uk/faq/
##########################################################
my $ScriptName          = "boards.cgi";
my $Password            = "nlf3jtVTD";
my $ForumData           = './BBSs/data.txt';
my $template            = './BBSs/template.html';
my $token               = '@#@#@';
##########################################################
# Table Settings
my $TableBorder           = '#000000';
my $TableHeadColor        = '#000000';
my $MessageViewTableWidth = '100%';
my $CellSpacing           = '1';
my $CellPadding           = '3';
my $MessTitleFont         = "sans-serif";
my $MessTitleFontsize     = 2;
my $MessTitleFontcolor    = "#FFFFFF";
##########################################################
# Font Settings
my $MessFont              = "sans-serif";
my $MessFontsize          = 2;
my $MessThreadFontSize    = 2;
my $MessFontcolor         = "#000000";
##########################################################
# Cell Colours
my $MainPageColorDark     = '#FFEAD5';
my $MainPageColorLight    = '#F0FFF0';
my $ThreadPageColorDark   = '#FFEAD5';
my $ThreadPageColorLight  = '#F0FFF0';
##########################################################
# Reply and Thread link Format
my $BottomFont            = "sans-serif";
my $BottomFontSize        = "2";
my $BottomFontColor       = "#000000";
##########################################################
# Message Form Settings
my $MaxLengthMessage      = 4000;
my $ROWS                  = 20;
my $COLS                  = 60;
my $MaxNameChars          = 30;
my $MaxSubjectChars       = 58;
##########################################################
# Miscellaneous Settings
my $language              = "EN";
my $MaxMessagesPerThread  = 100;
my $WrapIE                ='SOFT';
my $Wrap                  = 0;
##################################################################################
# ForumScript.co.uk ее 1999 - 2006 Copyright                                      #
# The scripts are available for private and commercial use.                      #
# You can use the scripts in any website you build.                              #
# It is prohibited to sell the scripts in any format to anybody.                 #
# The scripts may only be distributed by ForumScript.co.uk                       #
# The redistribution of modified versions of the scripts is prohibited.          #
# ForumScript.co.uk accepts no responsibility or liability                       #
# whatsoever for any damages however caused when using our services or scripts.  #
# By downloading and using this script you agree to the terms and conditions.    #
##################################################################################

$DefaulPassword="";
open (TEMPLATE, "< $template") or die print "$MESS{'IO_ERROR'} ($template)";
@templ = <TEMPLATE>;
close (TEMPLATE);
$token_len = length($token);
$tmpl_cont = join('', @templ);  $tmpl_len = length($tmpl_cont);
$forpos = index($tmpl_cont, $token);
$header = substr($tmpl_cont, 0, $forpos);
$footer = substr($tmpl_cont, $forpos+$token_len , $tmpl_len - $forpos -1);


use Digest::MD5 qw(md5_base64);
#######################################################################

language();

if ($ENV{'REQUEST_METHOD'} eq 'GET') { $buffer = $ENV{'QUERY_STRING'} }
else { read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'}) }

$delimiter = '\|';
@querylist = split(m'&', $buffer);
for $i (@querylist) {
	($key,$value) = split(/=/, $i);
	$value =~ tr/+/ /; 
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	$value =~ s/\</\&lt\;/gi; 
	$value =~ s/\>/\&gt\;/gi;
        $value =~ s/<!--(.|\n)*-->//g;
	$value =~ s/<([^>]|\n)*>//g;
        $value =~ s/\r//g;  
	$value =~ s/$delimiter/I/g;   # changed.  check for problems

	if ($key eq "onderwerp") {$value =~ s/[%=&\"\'\+\*\^\$\(\)\[\]\{\}\|\\\#]/_/eg }
	$in{$key} = $value;
}

print "Content-type: text/html\n\n";

if ($in{'todo'} eq "Preview") { Preview() }
if ($in{'admin'} eq "1") { &Pass }
elsif ($in{'todo'} eq "NieuwOnderwerp") { NieuwOnderwerp() }
elsif ($in{'todo'} eq "PostingPlaatsen") { PostingPlaatsen() }
elsif ($in{'todo'} eq "BekijkOnderwerp") { BekijkOnderwerp() }
elsif ($in{'todo'} eq "Bijdrage") { Bijdrage() }
elsif ($in{'todo'} eq "EditBijdrage") { EditBijdrage() }
elsif ($in{'todo'} eq "EditBijdrageOK") { if ($Password eq $in{'TheWord'}) { &EditBijdrageOK } }
elsif ($in{'todo'} eq "EditBijdrageSave") { EditBijdrageSave() }
elsif ($in{'todo'} eq "DeleteBijdrage") { DeleteBijdrage() }
elsif ($in{'todo'} eq "DeleteBijdrageOK") { if ($Password eq $in{'TheWord'}) { &DeleteBijdrageOK } }
elsif ($in{'todo'} eq "VerwijderDiscussie") { &VerwijderDiscussie}
elsif ($in{'todo'} eq "VerwijderDiscussieOK") { if ($Password eq $in{'TheWord'}) { &VerwijderDiscussieOK } }
else { PrintOnderwerpen() }

############################## HELPER SUBS ############################

sub WrapLongLines
{
  ($input) = @_;

  if ($Wrap) 
  {
    my @ber = split(/<br>/, $input);
    my $line;
    my $part;
    my @bericht;
    foreach $line(@ber)
    {
        while (length($line) > $COLS+2)
        {
          $part = substr($line, 0, $COLS+2);
          $part .= '<BR>';
          push(@bericht, $part);
          $line = substr($line, $COLS+2);
        }
        $line .= '<BR>';
        push (@bericht, $line);
    }
    $message = join('', @bericht);
  }
  else
  {
    $message = $input;
  }
  
  return $message;
}

#######################################################################


sub Preview {

        $NumPreviews = 6;
	open (DBASE, $ForumData) || die print "$MESS{'IO_ERROR'} (error 1)";  
		@DBASE=reverse<DBASE>;
	close (DBASE);
                                                          
	foreach $_ (@DBASE) {
		($ONDERWERP,$DATUM,$NAAM,$BERICHT)=split(/$delimiter/);
		if (length($ONDERWERP) > 2) {
			if ($telhes{$ONDERWERP}) {	$telhes{$ONDERWERP} += 1 }
			if (!$telhes{$ONDERWERP}) { $telhes{$ONDERWERP} = 1 }
		}
	}

	print <<EOF;
		<table cellspacing=\"$CellSpacing\" cellpadding=\"$CellPadding\">
                <tr> 
		<td><font face="$MessTitleFont" size="$MessTitleFontsize" color="$MessTitleFontcolor">$MESS{'Thread'}</td>
		<td><font face="$MessTitleFont" size="$MessTitleFontsize" color="$MessTitleFontcolor">$MESS{'LastBy'}</td>
		<td><font face="$MessTitleFont" size="$MessTitleFontsize" color="$MessTitleFontcolor">$MESS{'Messages'}</td>
		<td><font face="$MessTitleFont" size="$MessTitleFontsize" color="$MessTitleFontcolor">$MESS{'Date'}</td>
		</tr>
EOF
        my $raster = $ThreadPageColorLight;
	foreach $_ (@DBASE) 
        {
	  ($ONDERWERP,$DATUM,$NAAM,$BERICHT)=split(/$delimiter/);
	  if (length($ONDERWERP) > 2 && !$donehes{$ONDERWERP} && $tel<$NumPreviews)
          {
	    $tel++;
	    if ($raster eq "$ThreadPageColorLight") { $raster = "$ThreadPageColorDark" } 
            else {$raster = "$ThreadPageColorLight";}

   	    $LinkONDERWERP = $ONDERWERP;
	    $LinkONDERWERP =~ s/ /\%20/ig;
            print <<EOF;
	      <tr> 
	      <td valign="TOP" bgcolor="$raster"><font face="$MessFont" size="$MessFontsize" color="$MessFontcolor"><a href="$ScriptName?onderwerp=$LinkONDERWERP&todo=BekijkOnderwerp">
	           <font face="$MessFont" size="$MessFontsize" color="$MessFontcolor">$ONDERWERP</a>&nbsp;</td>
 	      <td valign="TOP" bgcolor="$raster"><font face="$MessFont" size="$MessFontsize" color="$MessFontcolor">&nbsp;<B>$NAAM</B>&nbsp;</td>
 	      <td valign="TOP" bgcolor="$raster"><font face="$MessFont" size="$MessFontsize" color="$MessFontcolor">&nbsp;<B>$telhes{$ONDERWERP}</B>&nbsp;</td>
	      <td valign="TOP" bgcolor="$raster"><font face="$MessFont" size="$MessFontsize" color="$MessFontcolor">&nbsp;$DATUM&nbsp;</td>
	      </tr>
EOF
            $donehes{$ONDERWERP} = 1;
          }
	}
	exit;
}


sub VerwijderDiscussie {

	PrintKop();
	print <<EOF;
		<H4>$MESS{'RemoveThread'}: "$in{'onderwerp'}"</H4>
		$MESS{'Password'}: 
		<FORM METHOD=POST ACTION="$ScriptName">
		<INPUT TYPE="password" NAME="TheWord" value="$DefaulPassword" style="margin\: 0px">
		<input type="submit" value=" DELETE " style="margin: 0px\; margin-left\: 10px">
		<input type="hidden" name="todo" value="VerwijderDiscussieOK">
		<input type="hidden" name="onderwerp" value="$in{'onderwerp'}">
		</FORM>
EOF
	PrintStaart();
}

#######################################################################

sub VerwijderDiscussieOK {

	open (DBASE, $ForumData) || die print "$MESS{'IO_ERROR'} (error 1)";  
		@DBASE=<DBASE>;
	close (DBASE);

	open (DBASE, ">$ForumData") || die print "$MESS{'IO_ERROR'} (error 1)";  
	foreach $_ (@DBASE) {
		($ONDERWERP,$DATUM,$NAAM,$BERICHT)=split(/$delimiter/);
		if ($in{'onderwerp'} eq $ONDERWERP) { }
			else {	print DBASE $_; }
	}
	close (DBASE);

        print <<EOF;
	  <html><head>
          <meta http-equiv=\"refresh\" content=\"0; url=$ScriptName\">
	  </head></html>
EOF

}
#######################################################################
sub EditBijdrage {

	PrintKop();
	print <<EOF;
		<H4>$MESS{'Password'}</H4>
		<FORM METHOD=POST ACTION="$ScriptName">
		<INPUT TYPE="password" NAME="TheWord" value="$DefaulPassword" style="margin\: 0px">
		<input type="submit" value=" EDIT " style="margin: 0px\; margin-left\: 10px">
		<input type="hidden" name="todo" value="EditBijdrageOK">
		<input type="hidden" name="onderwerp" value="$in{'onderwerp'}">
		<input type="hidden" name="datum" value="$in{'datum'}">
                <input type="hidden" name="instance" value="$in{'instance'}">
		</FORM>
EOF
	PrintStaart();
}

#######################################################################

sub EditBijdrageOK {

	PrintKop();

	open (DBASE, $ForumData) || die print "$MESS{'IO_ERROR'} (error 1)";  
		@DBASE=<DBASE>;
	close (DBASE);

        my %instances;
        my $key;

	foreach $_ (@DBASE) {
		($ONDERWERP,$DATUM,$NAAM,$BERICHT)=split(/$delimiter/);
                $key = $ONDERWERP.$NAAM;
                $instances{$key} += 1;
		if (($in{'onderwerp'} eq $ONDERWERP) && ($in{'datum'} eq $DATUM) && ($in{'instance'} == $instances{$key})) {
			$BERICHT =~ s/<BR>/\n/gi; 
			my $hash = md5_base64($in{'TheWord'}.$in{'onderwerp'}.$in{'instance'});
		    print <<EOF;

			<FORM METHOD=POST>
			<TABLE  border=0 cellpadding=$CellPadding style="background:$ColorDark">
			<TR><TD colspan=2>
			<input type="text" name="naam" value="$NAAM">
			</TD></TR>
			<TR><TD colspan=2>
			<TEXTAREA NAME="bericht" ROWS="$ROWS" COLS="$COLS" WRAP="$WrapIE">$BERICHT</TEXTAREA>
			<BR>
			&nbsp;<input type="submit" value="$MESS{'SavePage'}">

			<INPUT TYPE="hidden" name="todo" value="EditBijdrageSave">
			<INPUT TYPE="hidden" name="onderwerp" value="$in{'onderwerp'}">
			<INPUT TYPE="hidden" name="datum" value="$in{'datum'}">
                        <INPUT TYPE="hidden" name="instance" value="$in{'instance'}">
                        <input type="hidden" name="hash" value="$hash">
			<BR>
			&nbsp;
			
			</TD></TR>
			</TABLE>
			</FORM>
EOF
		}
	}
	PrintStaart();

}

#######################################################################

sub EditBijdrageSave {
	error("not correct request") if $in{'hash'} ne md5_base64($Password.$in{'onderwerp'}.$in{'instance'});


	$in{'bericht'} =~ s/\r//gi; 
	$in{'bericht'} =~ s/\n/<BR>/gi; 

	open (DBASE, $ForumData) || die print "$MESS{'IO_ERROR'} (error 1)";  
		@DBASE=<DBASE>;
	close (DBASE);

        my %instances;
        my $key;

	open (DBASE, ">$ForumData") || die print "$MESS{'IO_ERROR'} (error 1)";  
	foreach $_ (@DBASE) {
		($ONDERWERP,$DATUM,$NAAM,$BERICHT)=split(/$delimiter/);
                $key = $ONDERWERP.$NAAM;
                $instances{$key} += 1;
		if (($in{'onderwerp'} eq $ONDERWERP) && ($in{'datum'} eq $DATUM) && ($in{'instance'} == $instances{$key}))
                {
                  # wrap long lines

                  my $message = WrapLongLines($in{'bericht'});

                  # print to database
		  print DBASE "$ONDERWERP|$DATUM|$in{'naam'}|$message\n";
		}
		else {	
			print DBASE $_; 
		}
	}
	close (DBASE);

        print <<EOF;
	  <html><head>
	  <meta http-equiv=\"refresh\" content=\"0; url=$ScriptName?onderwerp=$in{'onderwerp'}&todo=BekijkOnderwerp\">
	  </head></html>
EOF
}

#######################################################################

sub DeleteBijdrage {

	PrintKop();
	print <<EOF;
		<H4>$MESS{'Remove'}: "$in{'onderwerp'}" van "$in{'naam'}"</H4>
		$MESS{'Password'}: 
		<FORM METHOD=POST ACTION="$ScriptName">
		<INPUT TYPE="password" NAME="TheWord" value="$DefaulPassword" style="margin\: 0px">
		<input type="submit" value=" EDIT " style="margin: 0px\; margin-left\: 10px">
		<input type="hidden" name="todo" value="DeleteBijdrageOK">
		<input type="hidden" name="onderwerp" value="$in{'onderwerp'}">
		<input type="hidden" name="datum" value="$in{'datum'}">
		<input type="hidden" name="lengte" value="$in{'lengte'}">
                <input type="hidden" name="instance" value="$in{'instance'}">
		</FORM>
EOF
	PrintStaart();
}

#######################################################################

sub DeleteBijdrageOK {

	open (DBASE, $ForumData) || die print "$MESS{'IO_ERROR'} (error 1)";  
		@DBASE=<DBASE>;
	close (DBASE);

        my %instances; # See how sub BekijkOnderwerp works.
        my $key;

	open (DBASE, ">$ForumData") || die print "$MESS{'IO_ERROR'} (error 1)";  
	foreach $_ (@DBASE) {
		($ONDERWERP,$DATUM,$NAAM,$BERICHT)=split(/$delimiter/);

                $key = $ONDERWERP.$NAAM;
                $instances{$key} += 1;
		
                if (($in{'onderwerp'} eq $ONDERWERP) && ($in{'datum'} eq $DATUM) && ($in{'instance'} == $instances{$key})) { }
			else {	print DBASE $_; }
	}
	close (DBASE);

        print <<EOF;
	  <html><head>
	  <meta http-equiv=\"refresh\" content=\"0; url=$ScriptName?onderwerp=$in{'onderwerp'}&todo=BekijkOnderwerp\">
	  </head></html>
EOF
}
#######################################################################
sub PrintOnderwerpen {
	PrintKop();

	open (DBASE, "< $ForumData") || die print "$MESS{'IO_ERROR'} (error 1)";  
		@DBASE=reverse<DBASE>;
	close (DBASE);

	print <<EOF;
                <table style=\"background-color: $TableBorder; width: $MessageViewTableWidth\" cellspacing=$CellSpacing cellpadding=$CellPadding>
		<tr bgcolor=$TableHeadColor> 
		<td><b><font face="$MessTitleFont" size="$MessTitleFontsize" color="$MessTitleFontcolor">$MESS{'Thread'}</td></b>
		<td><b><font face="$MessTitleFont" size="$MessTitleFontsize" color="$MessTitleFontcolor">$MESS{'LastBy'}</td></b>
		<td><b><font face="$MessTitleFont" size="$MessTitleFontsize" color="$MessTitleFontcolor">$MESS{'Messages'}</td></b>
                <td><b><font face="$MessTitleFont" size="$MessTitleFontsize" color="$MessTitleFontcolor">&nbsp;</td></b>
		</tr>
EOF
                                                       
#eerst tellen                                           
	foreach $_ (@DBASE) {
		($ONDERWERP,$DATUM,$NAAM,$BERICHT)=split($delimiter);
		if (length($ONDERWERP) > 2) {
			if ($telhes{$ONDERWERP}) {	$telhes{$ONDERWERP} += 1 }
			if (!$telhes{$ONDERWERP}) { $telhes{$ONDERWERP} = 1 }
		}
	}

#print uniek
        my $raster = $MainPageColorLight;
	foreach $_ (@DBASE) {
		($ONDERWERP,$DATUM,$NAAM,$BERICHT)=split($delimiter);
		if (length($ONDERWERP) > 2 && !$donehes{$ONDERWERP}) {
			if ($raster eq "$MainPageColorLight") { $raster = "$MainPageColorDark" } 
			else {$raster = "$MainPageColorLight";}
			$LinkONDERWERP = $ONDERWERP;
			$LinkONDERWERP =~ s/ /\%20/ig;
			print <<EOF;
				<tr> 
				 <td valign="TOP" bgcolor="$raster"><font face="$MessFont" size="$MessFontsize" color="$MessFontcolor"><a href="$ScriptName?onderwerp=$LinkONDERWERP&todo=BekijkOnderwerp">
				<font face="$MessFont" size="$MessFontsize"><b>$ONDERWERP</b>
				</a>&nbsp;</td>
 				<td valign="TOP" bgcolor="$raster"><font face="$MessFont" size="$MessFontsize" color="$MessFontcolor"><B>$NAAM</B>&nbsp;</td>
 				<td valign="TOP" bgcolor="$raster"><font face="$MessFont" size="$MessFontsize" color="$MessFontcolor"><B>$telhes{$ONDERWERP}</B></td>
				<td valign="TOP" bgcolor="$raster"><font face="$MessFont" size="$MessFontsize" color="$MessFontcolor"><a href="$ScriptName?onderwerp=$LinkONDERWERP&todo=VerwijderDiscussie" Title="$MESS{'RemoveThread'}"><font size="$MessFontsize"><B>x</B></font></A>&nbsp;</td>
			</tr>
EOF
			$donehes{$ONDERWERP} = 1;
		}
	}

	print <<EOF;
		</td></tr></table>
		<BR>
		<form method="get" action="$ScriptName">
		<input type="hidden" name="todo" value="NieuwOnderwerp">
		<input style="margin-top: 10px" type="submit" value="$MESS{'NewThread'}">
		</form>

EOF
	PrintStaart();
}

#######################################################################
sub BekijkOnderwerp {

	open (DBASE, $ForumData) || die print "$MESS{'IO_ERROR'} (error 1)";  
		@DBASE=<DBASE>;
	close (DBASE);

	PrintKop();
	$teller = 1;

        my %instances;  # keeps a count of messages with same title and user name (see also sub DeleteBijdrage)
        my $key;        # concat of title and user name, will be the key to the instances hash.

	foreach $_ (@DBASE) {
		($ONDERWERP,$DATUM,$NAAM,$BERICHT)=split(/$delimiter/);
	
		if ($in{'onderwerp'} eq $ONDERWERP) {
			
			$teller += 1;
			$BERICHT =~ s/\&lt\;br\&gt\;/\<BR\>/gi; 
			$LinkONDERWERP = $ONDERWERP;
			$LinkONDERWERP =~ s/ /\%20/ig;
			$LinkDATUM = $DATUM;
			$LinkDATUM =~ s/ /\%20/ig;
			if ($teller > 2) { $ONDERWERP = "Re : $ONDERWERP" }

                        $key = $LinkONDERWERP.$NAAM;
                        $instance{$key} += 1; 

			$AantalBerichten += 1;
			print <<EOF;
				<table style="background-color: $TableBorder; width: $MessageViewTableWidth" border="0" cellspacing=$CellSpacing cellpadding=$CellPadding>
					<tr> 
					<td bgcolor=$TableHeadColor><font face="$MessTitleFont" size="$MessTitleFontsize" color="$MessTitleFontcolor"><B>$ONDERWERP - </B>($NAAM)</td>
					<td bgcolor=$TableHeadColor> 
					  <div align="right"><font face="$MessTitleFont" size="$MessTitleFontsize" color="$MessTitleFontcolor">$DATUM &nbsp;<a href="$ScriptName?onderwerp=$LinkONDERWERP&naam=$NAAM&datum=$LinkDATUM&todo=DeleteBijdrage&instance=$instance{$key}" Title="$MESS{'RemoveMessage'}"><B>x</B></A>
						&nbsp;<a href="$ScriptName?onderwerp=$LinkONDERWERP&naam=$NAAM&datum=$LinkDATUM&todo=EditBijdrage&instance=$instance{$key}" Title="$MESS{'EditMessage'}"><B>e</B></A>&nbsp;</font></div>
					</td>
				  </tr>

				  <tr> 
					<td colspan="2" bgcolor="$ThreadPageColorLight"><font face="$MessFont" size="$MessThreadFontSize" color="$MessFontcolor">$BERICHT</td>
				  </tr>
				  <tr>
					<td colspan="2" align="right" bgcolor="$ThreadPageColorDark"> 
					  <font face="$BottomFont" size="$BottomFontSize" color="$BottomFontColor">
						<a href="#reply">$MESS{'Reply'}</a> - 
						<a href="$ScriptName">$MESS{'AllThreads'}</a>
						</font>
					</td>
				  </tr>
				</table>
                                <br>
EOF
		}
	}

	print <<EOF;
		
		<a name="reply"></a>
		<font face="$MessFont" size="$MessThreadFontSize" color="$MessFontcolor">$MESS{'Reply'}
EOF
	
	if ($AantalBerichten < $MaxMessagesPerThread) {
	   print <<EOF;
		  <form name="form1" method="post" action="$ScriptName">
  		  <input type="hidden" name="todo" value="Bijdrage">
		  <input type="hidden" name="onderwerp" value="$in{'onderwerp'}">
		  <TABLE border=0>
		  <TR>
			<TD><font face="$MessFont" size="$MessThreadFontSize" color="$MessFontcolor">$MESS{'Name'}:</TD>
			<TD><input type="text" name="naam" value="" size="$MaxNameChars" maxlength="$MaxNameChars"></TD>
		  </TR>
		  <TR>
			<td valign="TOP"><font face="$MessFont" size="$MessThreadFontSize" color="$MessFontcolor">$MESS{'Message'}: </TD>
			<TD><textarea name="bericht" cols=$COLS rows=$ROWS wrap=$WrapIE></textarea></TD>
		  </TR>
		  <TR>
			<TD></TD>
			<TD> <input type="submit" name="Submit" value=" $MESS{'PostMessage'} "></TD>
		  </TR>
		  </TABLE>
		  </form>
EOF
	} 
	else { print  $MESS{'NoMore'} }

	
	PrintStaart();
}


#######################################################################
sub Bijdrage {

	if (length($in{'bericht'}) > $MaxLengthMessage) {
		PrintKop();
		print <<EOF;
		$MESS{'MessTooLarge'}<BR>
		<FORM>
			<INPUT TYPE="Button" VALUE="$MESS{'GoBack'}" Onclick="javascript:history.go(-1)">
		</FORM>
EOF
		PrintStaart();
		exit;
	} 

	$in{'bericht'} =~ s/\r//gi;
	$in{'bericht'} =~ s/\n/<br>/gi;

	MaakDatum();


	if ($in{'onderwerp'} && $in{'naam'} && $in{'bericht'}) 
        {           
          my $message = WrapLongLines($in{'bericht'});

	  open (OUT, ">>$ForumData");
	  print OUT ("$in{'onderwerp'}|$Datum|$in{'naam'}|$message|IP $ENV{'REMOTE_ADDR'}\n");
	  close OUT;
	}

        print <<EOF;
	  <html><head>
	  <meta http-equiv=\"refresh\" content=\"0; url=$ScriptName?onderwerp=$in{'onderwerp'}&todo=BekijkOnderwerp\">
	  </head></html>
EOF

}
#######################################################################
sub NieuwOnderwerp {
	PrintKop();
	print <<EOF;
		<form method="post" action="$ScriptName">
		  <table width="60%" border="0" cellspacing=$CellSpacing cellpadding=$CellPadding>
		  <TR>
			<TD><font face="$MessFont" size="$MessThreadFontSize" color="$MessFontcolor">$MESS{'Name'}:</TD>
			<TD><input type="text" name="naam" value="" size="$MaxNameChars" maxlength="$MaxNameChars"></TD>
		  </TR>
		  <TR>
			<TD><font face="$MessFont" size="$MessThreadFontSize" color="$MessFontcolor">$MESS{'Subject'}:</TD>
			<TD><input type="text" name="onderwerp" value="" size="$MaxSubjectChars" maxlength="$MaxSubjectChars"></TD>
		  </TR>
		  <TR>
			<td valign="TOP"><font face="$MessFont" size="$MessThreadFontSize" color="$MessFontcolor">$MESS{'Message'}:</TD>
			<TD><textarea name="bericht" cols="$COLS" rows="$ROWS" WRAP="$WrapIE"></textarea></TD>
		  </TR>
		  <TR>
			<TD></TD>
			<TD> <input type="submit" class="mybutton" name="Submit" value=" $MESS{'StartThread'} "></TD>
		  </table>
		<input type="hidden" name="todo" value="PostingPlaatsen">
		</form>

EOF
	PrintStaart();
}

#######################################################################
sub PostingPlaatsen {

	# even een string met bestaande onderwerpen maken
		$onderwerpen = $delimiter;
		open (DBASE,$ForumData) || die print "$MESS{'IO_ERROR'} (error 1)";  
			@DBASE=<DBASE>;
		close (DBASE);
		foreach $_ (@DBASE) {
			($ONDERWERP,$DATUM,$NAAM,$BERICHT)=split(/$delimiter/);
                        my $temp = $delimiter.$ONDERWERP.$delimiter;
			if ($onderwerpen !~ /$temp/) { $onderwerpen = $onderwerpen.$ONDERWERP.$delimiter }
		}

        my $temp = $delimiter.$in{'onderwerp'}.$delimiter;
	if ($onderwerpen =~ /$temp/) {
		PrintKop();
		print <<EOF;
		$MESS{'Thread'} "$in{'onderwerp'}" $MESS{'alreadyexists'}.<BR>
		<FORM>
			<INPUT TYPE="Button" VALUE="$MESS{'GoBack'}" Onclick="javascript:history.go(-1)">
		</FORM>
EOF
		PrintStaart();
	} 

	if (length($in{'bericht'}) > $MaxLengthMessage) {
		PrintKop();
		print <<EOF;
		$MESS{'MessTooLarge'}<BR>
		<FORM>
			<INPUT TYPE="Button" VALUE="$MESS{'GoBack'}" Onclick="javascript:history.go(-1)">
		</FORM>
EOF
		PrintStaart();
	} 
	
	else {
		$in{'bericht'} =~ s/\r//gi;
		$in{'bericht'} =~ s/\n/<br>/gi;

		MaakDatum();

		if ($in{'onderwerp'} && $in{'naam'} && $in{'bericht'})
                {
                  # wrap long lines
                  my $message = WrapLongLines($in{'bericht'});
		  # write to database	
                  open (OUT, ">>$ForumData");
	          print OUT ("$in{'onderwerp'}|$Datum|$in{'naam'}|$message|IP $ENV{'REMOTE_ADDR'}\n");
		  close OUT;
		}

                print <<EOF;
		<html><head>
		<meta http-equiv=\"refresh\" content=\"0; url=$ScriptName\">
		</head></html>
EOF
	}
}

#######################################################################
sub MaakDatum {

	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	if ($sec < 10)  { $sec = "0$sec";   }
	if ($min < 10)  { $min = "0$min";   }
	if ($hour < 10) { $hour = "0$hour"; }
	if ($mday < 10) { $mday = "0$mday"; }
	$year = $year + 1900;
	$mon = $mon + 1;
	if ($mon < 10)  { $mon = "0$mon";  }
	$Datum = "$mday-$mon-$year $hour\:$min";
}

#######################################################################
sub PrintKop {
	print $header;
}

#######################################################################
sub PrintStaart {
	print $footer;
}

#######################################################################

sub language() {
  if ($language eq 'DU') {
	%MESS = (
		 'AllThreads' => 'Alle onderwerpen',
		 'alreadyexists' => 'bestaat al',
		 'Date' => 'Datum',
		 'EditMessage' => 'Bewerk bericht',
		 'GoBack' => 'Ga Terug',
		 'LastBy' => 'Laatste',
		 'Message' => 'Bericht',
		 'Messages' => 'Berichten',
		 'MessTooLarge' => 'Uw bericht is te lang.<BR>',
		 'MIO_ERROR' => 'ERROR - Can\'t open directory or file',
		 'Name' => 'Naam',
		 'NewThread' => 'Nieuw Onderwerp',
		 'NoMore' => 'Maximum aantal berichten bereikt<BR>',
		 'Password' => 'Geef wachtwoord',
		 'PostMessage' => 'Plaats bericht',
		 'Remove' => 'Verwijder',
		 'RemoveMessage' => 'Verwijder bericht',
		 'RemoveThread' => 'Verwijder discussie',
		 'RemoveThread' => 'Verwijder onderwerp',
		 'Reply' => 'Reageren',
		 'SavePage' => 'Bewaar Pagina',
		 'StartThread' => 'Start Discussie',
		 'Subject' => 'Onderwerp',
		 'Thread' => 'Onderwerp',
	);
  }
  else { # defaults to English
	%MESS = ('MIO_ERROR' => 'ERROR - Can\'t open directory or file',
		 'AllThreads' => 'All threads',
		 'alreadyexists' => 'already exists',
		 'Date' => 'Date',
		 'EditMessage' => 'Edit Message',
		 'GoBack' => 'Go back',
		 'LastBy' => 'Last',
		 'Message' => 'Message',
		 'Messages' => 'Messages',
		 'MessTooLarge' => 'Your posting is too large.<BR>',
		 'MIO_ERROR' => 'ERROR - Can\'t open directory or file',
		 'Name' => 'Name',
		 'NewThread' => 'New Thread',
		 'NoMore' => 'Maximum  number of messages reached.<BR>',
		 'Password' => 'Password',
		 'PostMessage' => 'Post Message',
		 'Remove' => 'Remove',
		 'RemoveMessage' => 'Remove Message',
		 'RemoveThread' => 'Remove Thread',
		 'RemoveThread' => 'Remove Thread',
		 'Reply' => 'Reply',
		 'SavePage' => 'SavePage',
		 'StartThread' => 'StartThread',
		 'Subject' => 'Subject',
		 'Thread' => 'Thread',
	);
  }
}
##################################################################################
# ForumScript.co.uk ее 1999 - 2006 Copyright                                      #
# The scripts are available for private and commercial use.                      #
# You can use the scripts in any website you build.                              #
# It is prohibited to sell the scripts in any format to anybody.                 #
# The scripts may only be distributed by ForumScript.co.uk                       #
# The redistribution of modified versions of the scripts is prohibited.          #
# ForumScript.co.uk accepts no responsibility or liability                       #
# whatsoever for any damages however caused when using our services or scripts.  #
# By downloading and using this script you agree to the terms and conditions.    #
##################################################################################
