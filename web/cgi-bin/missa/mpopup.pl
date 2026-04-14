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

#Litany of the Sacred Heart
#Litany of the Most Holy Name of Jesus
#Litany of the Blessed Virgin (also called Litany of Loretto)
#Litany of St. Joseph

print "<H2 ALIGN=CENTER id='H2_EssentialPrayers'><FONT COLOR=MAROON><B><I>Essential Prayers</I></B></FONT></H2>\n";
print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "The Angelus", ("Angelus"));
print_prayer($lang1, $devotion_sections1, $lang2, $devotion_sections2, "The Regina Caeli", ("ReginaCaeli"));

#Athanasian Creed
#Prayer before any work & Prayer after work
#Antiphons to the Blessed Virgin


print "<P ALIGN=CENTER><A HREF=# onclick=\"window.close()\">Close</A></P>";
htmlEnd();

sub print_prayer {
  my ($lang1, $sections_lang1 ,$lang2, $sections_lang2, $title, @keys) = @_;

  if (exists(${$sections_lang1}{$keys[0]}) and exists(${$sections_lang2}{$keys[0]})) {
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
