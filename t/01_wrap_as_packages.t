#!/usr/bin/perl -w

my $r;

use strict;

BEGIN { $| = 1; print "1..2\n"; }

use lib 't/lib'; use a;
use Sub::WrapPackages (
    packages => [qw(a)],
    pre => sub {
        $r .= join(", ", @_);
    },
    post => sub {
        $r .= ref($_[1]) =~ /^ARRAY/ ? join(', ', @{$_[1]}) : $_[1];
    }
);

my $test = 0;

$r .= a::a_scalar(1..3);

print 'not ' unless($r eq 'a::a_scalar, 1, 2, 3in sub a_scalarin sub a_scalar');
print 'ok '.(++$test)." returning scalar in scalar context\n";

$r = '';
my @r = a::a_list(4,6,8);

print 'not ' unless(join('', @r) eq 'insuba_list' && $r eq 'a::a_list, 4, 6, 8in, sub, a_list');
print 'ok '.(++$test)." returning array in array context\n";

