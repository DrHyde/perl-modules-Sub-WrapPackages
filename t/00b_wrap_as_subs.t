#!/usr/bin/perl -w

my $loaded;
my $r;

use strict;

BEGIN { $| = 1; print "1..3\n"; }
END { print "not ok 1\n" unless $loaded; }

use lib 't/lib';
use Sub::WrapPackages (
    subs => [qw(a::a_scalar a::a_list)],
    pre => sub {
        $r .= join(", ", @_);
    },
    post => sub {
        $r .= ref($_[1]) =~ /^ARRAY/ ? join(', ', @{$_[1]}) : $_[1];
    }
);
use a; # load after Sub::WrapPackages

$loaded=1;
my $test = 0;
print "ok ".(++$test)." compile and wrap subs\n";

$r .= a::a_scalar(1..3);

print 'not ' unless($r eq 'a::a_scalar, 1, 2, 3in sub a_scalarin sub a_scalar');
print 'ok '.(++$test)." returning scalar in scalar context\n";

$r = '';
my @r = a::a_list(4,6,8);

print 'not ' unless(join('', @r) eq 'insuba_list' && $r eq 'a::a_list, 4, 6, 8in, sub, a_list');
print 'ok '.(++$test)." returning array in array context\n";

