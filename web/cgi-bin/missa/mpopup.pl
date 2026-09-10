#!/usr/bin/perl
use utf8;

#áéíóöõúüûÁÉ
# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office   popup
package main;

#1;
#use warnings;
#use strict "refs";
#use strict "subs";
#use warnings FATAL=>qw(all);

use POSIX;
use FindBin qw($Bin);
use CGI;
use CGI::Cookie;
use CGI::Carp qw(fatalsToBrowser);
use File::Basename;
use Time::Local;

#use DateTime;
$error = '';
$debug = '';
$q = new CGI;
our $missa = 1;

use lib "$Bin/..";
use DivinumOfficium::LanguageTextTools qw(prayer translate load_languages_data);

#*** collect standard items
require "$Bin/../DivinumOfficium/SetupString.pl";
require "$Bin/../horas/horascommon.pl";
require "$Bin/../DivinumOfficium/dialogcommon.pl";
require "$Bin/../horas/webdia.pl";
require "$Bin/../DivinumOfficium/setup.pl";
require "$Bin/ordo.pl";
require "$Bin/propers.pl";

#require "$Bin/ordocommon.pl";
binmode(STDOUT, ':encoding(utf-8)');

#*** get parameters
getini('missa');    #files, colors

$setupsave = strictparam('setup');
loadsetup($setupsave);

if (!$setupsave) {
  getcookies('missap', 'parameters');
  getcookies('missago', 'general');
}

set_runtime_options('general');       #$expand, $version, $lang2
set_runtime_options('parameters');    # priest, lang1 ... etc

$popup = strictparam('popup');
$background = ($whitebground) ? ' class="contrastbg"' : '';
$only = ($lang1 && $lang1 =~ /$lang2/) ? 1 : 0;
$title = "$popup";
$title =~ s/[\$\&]//;

#$tlang = ($lang1 !~ /Latin/) ? $lang1 : $lang2;
$text = gettext($popup, $lang1);
$t = length($text);
$width = ($t > 300) ? 600 : 400;
$height = ($t > 300) ? $screenheight - 100 : 3 * $screenheight / 4;

load_languages_data($lang1, $lang2, $langfb, $version, $missa);

my $basedir = our $datafolder;

my $devotion_sections2 = {};
my $devotion_sections2 = setupstring_parse_file($basedir ."/English/Commune/Devotions.txt");
my $devotion_sections1 = {};
my $devotion_sections1 = setupstring_parse_file($basedir ."/Latin/Commune/Devotions.txt");

#*** generate HTML
# prints the requested item from prayers hash as popup
htmlHead($title, 'setsize()');
print "<H2 ALIGN=CENTER id='H2_Litanies'><FONT COLOR=MAROON><B><I>Litanies</I></B></FONT></H2>\n";
#my @script1 = ($text);
#my @script2 = (gettext($popup, $lang2));
#print_content($lang1, \@script1, $lang2, \@script2);
print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "Litany of The Saints", ("LitanyOfTheSaints"));
print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "Litany of The Most Precious Blood", ("LitanyOfTheMostPreciousBlood"));
print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "Litany of The Sacred Heart", ("LitanyOfTheSacredHeart"));
#print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "Litany of The Most Holy Name of Jesus", ("LitanyOfTheMostHolyNameOfJesus"));
#print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "Litany of The Blessed Virgin", ("LitanyOfTheBlessedVirgin"));
#print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "Litany of St. Joseph", ("LitanyOfStJoseph"));
#Litany of Our Lady of the Seven Sorrows
#Litany of the Holy Ghost
#Litany of the Holy Face of Jesus
#Litany of St. Michael the Archangel
#Litany of Humility


print "<H2 ALIGN=CENTER id='H2_EssentialPrayers'><FONT COLOR=MAROON><B><I>Essential Prayers</I></B></FONT></H2>\n";
print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "The Angelus", ("Angelus"));
print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "The Regina Caeli", ("ReginaCaeli"));
print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "St. Michael (Short)", ("StMichaelShort"));
print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "St. Michael (Full)", ("StMichaelLong"));
print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "Athanasian Creed", ("AthanasianCreed"));
print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "Apostles Creed", ("ApostlesCreed"));
print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "Nicene Creed", ("NiceneCreed"));
print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "Profession of the Tridentine Faith", ("PiusIVCreed"));

#Morning Prayers
#Evening Prayers
#Prayer before any work & Prayer after work
#Antiphons to the Blessed Virgin
#Prayers to St. Joseph
#Adoration and Divine Praises

print_baptism($lang1, $devotion_sections1, $lang2, $devotion_sections2);

print "<P ALIGN=CENTER><A HREF=# onclick=\"window.close()\">Close</A></P>";
htmlEnd();

sub print_baptism {
  my ($lang1, $sections_lang1 ,$lang2, $sections_lang2) = @_;
  print "<p><H2 ALIGN=CENTER id='H2_RiteBaptism'><FONT COLOR=MAROON><B><I>Rite of Baptism</I></B></FONT></H2></p>\n";
  print "<p><H4 ALIGN=CENTER>Part I: Outside the Church</H4></p>\n";
  print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "", ("BaptismPart1Questioning","BaptismPart1Exsufflation","BaptismPart1SignOfTheCross","BaptismPart1ImpositionOfHands","BaptismPart1ImpositionOfSalt"));

  print "<p><H4 ALIGN=CENTER>Part II: Admission into the Church Building</H4></p>\n";
  print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "", ("BaptismPart2Exorcism","BaptismPart2SignOfTheCross","BaptismPart2ImpositionOfHands","BaptismPart2AdmissionChurch","BaptismPart2CredoAndPater"));

  print "<p><H4 ALIGN=CENTER>Part III: In the Nave of the Church</H4></p>\n";
  print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "", ("BaptismPart3SolemnExorcism","BaptismPart3Ephpheta","BaptismPart3RenunciationOfSatan","BaptismPart3Annointing"));

  print "<p><H4 ALIGN=CENTER>Part IV: At the Font</H4></p>\n";
  print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "", ("BaptismPart4ProfessionOfFaith","BaptismPart4MatterAndForm","BaptismPart4AnnointingWithChrism","BaptismPart4WhiteLinenCloth","BaptismPart4LightedCandle","BaptismPart4WordsOfGoodWill"));

  print "<p>Thus ends the Rite of Baptism. If the newly baptized one is an adult, the Rite of Confirmation typically immediately follows. Then, if this all takes place during a Mass, he is given his First Holy Communion after the Consecration.</p>\n";
  print "<p>One's Baptismal candle should be kept so it may be used during one's wedding and funeral. It should be stored with the Sick Call set so that it might be used, too, for one's Unction (if one's baptismal candle becomes unusable or is lost, another blessed candle may be used, such as one blessed at Candlemas).</p>\n";
}

sub print_prayer {
  my ($lang1, $sections_lang1 ,$lang2, $sections_lang2, $title, @keys) = @_;

  if ($title ne '' and exists(${$sections_lang1}{$keys[0]}) and exists(${$sections_lang2}{$keys[0]})) {
    print "<H3 ID='$keys[0]'>$title</H3>\n";
  }
  foreach my $item (@keys) {
    if (exists(${$sections_lang1}{$item}) and exists(${$sections_lang2}{$item})) {
      my @script1 = ();
      my @script2 = ();
      my $str1 = ${$sections_lang1}{$item};
      my $str2 = ${$sections_lang2}{$item};
      $str1 =  resolve_refs($str1, $lang1);
      $str2 =  resolve_refs($str2, $lang2);

      push(@script1, "\n");
      push(@script1, split('_', $str1));
      push(@script2, "\n");
      push(@script2, split('_', $str2));

      print_content($lang1, \@script1, $lang2, \@script2, 1);
    }
  }
}

#*** javascript functions
sub horasjs {
  "function setsize() { window.resizeTo($width, $height); }";
}

sub gettext {
  my $popup = shift;
  my $lang = shift;
  my $text = '';
  my %popup_files = (
    Ante => 'Ante.txt',
    Communio => 'Communio.txt',
    Post => 'Post.txt',
  );

#print STDERR " : popup $popup \n";
  # File must be one of those explicitly permitted.
  my $fname = $popup_files{$popup} or return 'Invalid filename.';
  $fname = checkfile($lang, "Ordo/$fname");
  $text = join("\n", do_read($fname)) or return "Cannot open $datafolder/$lang/Ordo/$fname.txt";
  #$text =~ s/[#!].*?\n//g unless $rubrics;
  $text =~ s/#/!/g;
  $text = resolve_refs($text, $lang);
  return $text;
}

sub horasjsend() {

  # Gregorian Chant (GABC) functionality:
  # Empty but necessary function to mask the corresponding one from horasjs.pl!
}
