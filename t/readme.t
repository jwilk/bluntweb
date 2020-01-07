#!/usr/bin/env perl

# Copyright © 2020 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

use strict;
use warnings;

use v5.14;

use autodie;
use re '/a';
use FindBin ();
use Test::More tests => 6;

use IPC::System::Simple qw(capture);

my $pdir = "$FindBin::Bin/..";
open(my $fh, '<', "$pdir/README");
while(<$fh>) {
    if (m{^ +\$ bluntweb (\S.*)$}) {
        my $args = $1;
        my $cmdline = "$pdir/bluntweb $args";
        if ($args eq '--help') {
            note("\$ bluntweb $args");
            my $help = capture($cmdline);
            note($help);
            ok(1, "bluntweb $args");
        } elsif ($args =~ /^\w/) {
            $_ = <$fh>;
            m{^ +<opens (https?://\S+)>$} or die;
            my $xurl = $1;
            note("\$ bluntweb $args");
            my $url = do {
                local $ENV{BROWSER} = 'echo';
                capture($cmdline) =~ s/\n\z//r;
            };
            note("$url");
            is($url, $xurl, "bluntweb $args");
        } else {
            die;
        }
    }
}
close($fh);

# vim:ts=4 sts=4 sw=4 et
