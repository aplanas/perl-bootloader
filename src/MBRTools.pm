#!/usr/bin/perl -w
#
# Set of low level tools for mbr manipulation
#

=head1 NAME

Bootloader::MBRTools - set of low-level functions for mbr manipulation


=head1 PREFACE

This package contains a set of low-level functions for mbr manipulation

=head1 SYNOPSIS

C<< use Bootloader::MBRTools; >>

C<< $value = Bootloader::MBRTools::IsThinkpadMBR ($disk); >>

C<< $value = Bootloader::MBRTools::PatchThinkpadMBR ($disk); >>

=head1 DESCRIPTION

=over 2

=cut


package Bootloader::MBRTools;

use strict;
use base 'Exporter';

our @EXPORT = qw( IsThinkpadMBR PatchThinkpadMBR
);

sub IsThinkpadMBR($) {
  my $disk = shift;
  my $thinkpad_id = "50e46124108ae0e461241038e074f8e2f458c332edb80103ba8000cd13c3be05068a04240cc0e802c3";
  my $mbr = qx{dd status=noxfer if=$disk bs=512 count=1 2>/dev/null | od -v -t x1 -};
  $mbr =~ s/\d{7}//g; #remove address
  $mbr =~ s/\n//g; #remove end lines
  $mbr =~ s/\S//g; #remove whitespace

  return $mbr =~ m/$thinkpad_id/ ;
}

# crc function
sub crc
{
  my $c = 0;
  local $_;

  $c ^= $_ for @{$_[0]};

  return $c;
}

sub PatchThinkpadMBR($) {
  my $disk = shift;
  my $new_mbr = 
   "\x31\xc0\x8e\xd0\x66\xbc\x00\x7c\x00\x00\x8e\xc0\x8e\xd8\x89\xe6" .
   "\x66\xbf\x00\x06\x00\x00\x66\xb9\x00\x01\x00\x00\xf3\xa5\xea\x23" .
   "\x06\x00\x00\x80\xfa\x80\x7c\x05\x80\xfa\x87\x7e\x02\xb2\x80\x88" .
   "\x16\x49\x07\x66\xbf\xbe\x07\x00\x00\x31\xf6\x66\xb9\x04\x00\x00" .
   "\x00\x67\x80\x3f\x80\x75\x07\x85\xf6\x75\x0c\x66\x89\xfe\x83\xc7" .
   "\x10\xe2\xee\x85\xf6\x75\x0b\x66\xbe\x4a\x07\x00\x00\xe9\x8d\x00" .
   "\x00\x00\x8a\x16\x49\x07\x66\x31\xc9\x66\x31\xc0\xb4\x08\xcd\x13" .
   "\xc1\xea\x08\x42\x89\xc8\x83\xe0\x3f\x89\xcb\xc1\xe9\x08\x81\xe3" .
   "\xc0\x00\x00\x00\xc1\xe3\x02\x09\xd9\x41\xf7\xe2\x66\xf7\xe1\x8a" .
   "\x16\x49\x07\x66\x67\x8b\x5e\x08\x66\x39\xc3\x66\x7c\x63\x66\x56" .
   "\x52\x66\xbb\xaa\x55\x00\x00\xb4\x41\xcd\x13\x5a\x66\x5e\x72\x51" .
   "\x66\xb8\x55\xaa\x00\x00\x39\xc3\x75\x47\xf6\xc1\x01\x74\x42\x67" .
   "\x66\xc7\x06\x10\x00\x01\x00\x67\x66\xc7\x46\x04\x00\x7c\x00\x00" .
   "\x67\x66\xc7\x46\x0c\x00\x00\x00\x00\xb6\x05\x56\x52\xb4\x42\xcd" .
   "\x13\x5a\x5e\x73\x45\xfe\xce\x75\xf2\x66\xbe\x76\x07\x00\x00\xac" .
   "\x84\xc0\x74\x0a\xb4\x0e\xb3\x07\x56\xcd\x10\x5e\xeb\xf1\xfb\xeb" .
   "\xfd\x67\x8a\x76\x01\x67\x8b\x4e\x02\x66\xbf\x05\x00\x00\x00\x66" .
   "\xbb\x00\x7c\x00\x00\x66\xb8\x01\x02\x00\x00\x57\x52\x51\xcd\x13" .
   "\x59\x5a\x5f\x73\x05\x4f\x75\xe7\xeb\xbf\x66\xbe\x62\x07\x00\x00" .
   "\x67\xa1\xfe\x7d\x00\x00\x66\xbb\x55\xaa\x00\x00\x39\xc3\x75\xaf" .
   "\x8a\x16\x49\x07\xea\x00\x7c\x00\x00\x80\x49\x6e\x76\x61\x6c\x69" .
   "\x64\x20\x70\x61\x72\x74\x69\x74\x69\x6f\x6e\x20\x74\x61\x62\x6c" .
   "\x65\x00\x4e\x6f\x20\x6f\x70\x65\x72\x61\x74\x69\x6e\x67\x20\x73" .
   "\x79\x73\x74\x65\x6d\x00\x45\x72\x72\x6f\x72\x20\x6c\x6f\x61\x64" .
   "\x69\x6e\x67\x20\x6f\x70\x65\x72\x61\x74\x69\x6e\x67\x20\x73\x79" .
   "\x73\x74\x65\x6d\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" .
   "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" .
   "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00";

  open F,$disk;
  my $mbr_s;
  sysread F,$mbr_s,0x200;
  
  my @mbr = unpack "C512", $mbr_s;

  my $old_mbr_sec = $mbr[7];

  # read original mbr

  seek F, ($old_mbr_sec - 1) << 9, 0 or die "$disk: $!\n";

  my $old_mbr_s;
  sysread F, $old_mbr_s, 0x200;

  my @old_mbr = unpack "C512", $old_mbr_s;


  close F;


  # verify crc

  if($mbr[6] == 0) {
    print STDERR "$disk: orig mbr crc not checked\n" if $mbr[6] == 0;
  }
  else {
    die "$disk: orig mbr crc failure\n" unless crc(\@old_mbr) == $mbr[6];
  }


  # store new mbr & update crc

  substr($old_mbr_s, 0, length $new_mbr) = $new_mbr;

  @old_mbr = unpack "C512", $old_mbr_s;

  $mbr[6] = crc \@old_mbr;

  $mbr_s = pack "C512", @mbr;


  # write it

  open F, "+<$disk";
  syswrite F, $mbr_s, 0x200;
  seek F, ($old_mbr_sec - 1) << 9, 0;
  syswrite F, $old_mbr_s;
  close F;

  return 1;
}

1;