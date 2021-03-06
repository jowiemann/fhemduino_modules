##############################################
# $Id: 14_FHEMduino_FA20RF.pm 3818 2014-06-24 $
package main;

use strict;
use warnings;

#####################################
sub
FHEMduino_FA20RF_Initialize($)
{
  my ($hash) = @_;

  # output format is "F4d4efd-12128"
  #                   FAAAAAA-mmmmm"
  #                   0123456789ABC
  $hash->{Match}     = "^F............";
  $hash->{DefFn}     = "FHEMduino_FA20RF_Define";
  $hash->{UndefFn}   = "FHEMduino_FA20RF_Undef";
  $hash->{AttrFn}    = "FHEMduino_FA20RF_Attr";
  $hash->{ParseFn}   = "FHEMduino_FA20RF_Parse";
  $hash->{AttrList}  = "IODev do_not_notify:0,1 showtime:0,1 ignore:0,1 ".$readingFnAttributes;
}


#####################################
sub
FHEMduino_FA20RF_Define($$)
{
  my ($hash, $def) = @_;
  my @a = split("[ \t][ \t]*", $def);

  return "wrong syntax: define <name> FHEMduino_FA20RF FA20RF".int(@a)
		if(int(@a) < 2 || int(@a) > 3);

  $hash->{CODE}    = $a[2];
  $modules{FHEMduino_FA20RF}{defptr}{$a[2]} = $hash;
  $hash->{STATE} = "Defined";

  AssignIoPort($hash);
  return undef;
}

#####################################
sub
FHEMduino_FA20RF_Undef($$)
{
  my ($hash, $name) = @_;
  delete($modules{FHEMduino_FA20RF}{defptr}{$hash->{CODE}}) if($hash && $hash->{CODE});
  return undef;
}

#####################################
sub
FHEMduino_FA20RF_Parse($$)
{
  my ($hash,$msg) = @_;
  my @a = split("", $msg);

  # output format is "F4d4efd-12128"
  #                   FAAAAAA-mmmmm"
  #                   0123456789ABC

  my $deviceCode = $a[1].$a[2].$a[3].$a[4].$a[5].$a[6];
  
  my $def = $modules{FHEMduino_FA20RF}{defptr}{$hash->{NAME} . "." . $deviceCode};
  $def = $modules{FHEMduino_FA20RF}{defptr}{$deviceCode} if(!$def);
  if(!$def) {
    Log3 $hash, 1, "FHEMduino_FA20RF UNDEFINED sensor detected, code $deviceCode";
    return "UNDEFINED FHEMduino_FA20RF FHEMduino_FA20RF $deviceCode";
  }
  
  $hash = $def;
  my $name = $hash->{NAME};
  return "" if(IsIgnored($name));
  
  Log3 $name, 4, "FHEMduino_FA20RF $name ($msg)";  
  
  my $Freq;

  $Freq = $a[8].$a[9].$a[10].$a[11].$a[12];
  
  $hash->{lastReceive} = time();
  $hash->{lastValues}{FREQ} = $Freq;

  Log3 $name, 4, "FHEMduino_FA20RF $name: $Freq:";

  readingsBeginUpdate($hash);
  readingsBulkUpdate($hash, "state", $Freq);
  readingsEndUpdate($hash, 1); # Notify is done by Dispatch

  return $name;
}

sub
FHEMduino_FA20RF_Attr(@)
{
  my @a = @_;

  # Make possible to use the same code for different logical devices when they
  # are received through different physical devices.
  return if($a[0] ne "set" || $a[2] ne "IODev");
  my $hash = $defs{$a[1]};
  my $iohash = $defs{$a[3]};
  my $cde = $hash->{CODE};
  delete($modules{FHEMduino_FA20RF}{defptr}{$cde});
  $modules{FHEMduino_FA20RF}{defptr}{$iohash->{NAME} . "." . $cde} = $hash;
  return undef;
}

1;

=pod
=begin html

<a name="FHEMduino_FA20RF"></a>
<h3>FHEMduino_FA20RF</h3>
<ul>
  The FHEMduino_FA20RF module interprets LogiLink FA20RF type of messages received by the FHEMduino.
  <br><br>

  <a name="FHEMduino_FA20RFdefine"></a>
  <b>Define</b>
  <ul>
    <code>define &lt;name&gt; FHEMduino_FA20RF &lt;code&gt;</code> <br>

    <br>
    &lt;code&gt; is the housecode of the autogenerated address of the FA20RF device and 
	is build by the channelnumber (1 to 3) and an autogenerated address build when including
	the battery (adress will change every time changing the battery).<br>
  </ul>
  <br>

  <a name="FHEMduino_FA20RFset"></a>
  <b>Set</b> <ul>N/A</ul><br>

  <a name="FHEMduino_FA20RFget"></a>
  <b>Get</b> <ul>N/A</ul><br>

  <a name="FHEMduino_FA20RFattr"></a>
  <b>Attributes</b>
  <ul>
    <li><a href="#IODev">IODev (!)</a></li>
    <li><a href="#do_not_notify">do_not_notify</a></li>
    <li><a href="#eventMap">eventMap</a></li>
    <li><a href="#ignore">ignore</a></li>
    <li><a href="#model">model</a> (LogiLink FA20RF)</li>
    <li><a href="#showtime">showtime</a></li>
    <li><a href="#readingFnAttributes">readingFnAttributes</a></li>
  </ul>
  <br>
</ul>

=end html

=begin html_DE

<a name="FHEMduino_FA20RF"></a>
<h3>FHEMduino_FA20RF</h3>
<ul>
  Das FHEMduino_FA20RF module dekodiert vom FHEMduino empfangene Nachrichten des LogiLink FA20RF.
  <br><br>

  <a name="FHEMduino_FA20RFdefine"></a>
  <b>Define</b>
  <ul>
    <code>define &lt;name&gt; FHEMduino_FA20RF &lt;code&gt; </code> <br>

    <br>
    &lt;code&gt; ist der automatisch angelegte Hauscode des FA20RF und besteht aus der
	Kanalnummer (1..3) und einer Zufallsadresse, die durch das Gerät beim einlegen der
	Batterie generiert wird (Die Adresse ändert sich bei jedem Batteriewechsel).<br>
  </ul>
  <br>

  <a name="FHEMduino_FA20RFset"></a>
  <b>Set</b> <ul>N/A</ul><br>

  <a name="FHEMduino_FA20RFget"></a>
  <b>Get</b> <ul>N/A</ul><br>

  <a name="FHEMduino_FA20RFattr"></a>
  <b>Attributes</b>
  <ul>
    <li><a href="#IODev">IODev (!)</a></li>
    <li><a href="#do_not_notify">do_not_notify</a></li>
    <li><a href="#eventMap">eventMap</a></li>
    <li><a href="#ignore">ignore</a></li>
    <li><a href="#model">model</a> (LogiLink FA20RF)</li>
    <li><a href="#showtime">showtime</a></li>
    <li><a href="#readingFnAttributes">readingFnAttributes</a></li>
  </ul>
  <br>
</ul>

=end html_DE
=cut
