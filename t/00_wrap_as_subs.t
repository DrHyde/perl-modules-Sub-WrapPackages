#!/usr/bin/perl -w

my $pre;
my $post;

use strict;

use Test::More tests => 6;

use lib 't/lib'; use a;
use Sub::WrapPackages (
    subs => [qw(a::a_scalar a::a_list)],
    pre => sub {
        $pre .= join(", ", @_);
    },
    post => sub {
        $post .= join(", ", @_);
        # $post .= 'a::a_scalar'.(ref($_[1]) =~ /^ARRAY/ ? join(', ', @{$_[1]}) : $_[1]);
    }
);

my $r = a::a_scalar(1..3);

is($pre, 'a::a_scalar, 1, 2, 3',
    'pre-wrapper works in scalar context');
is($post, 'a::a_scalar, in sub a_scalar',
    'post-wrapper works in scalar context');
is($r, 'in sub a_scalar',
    'return scalar in scalar context');

$pre = $post = '';
my @r = a::a_list(4,6,8);

is($pre, 'a::a_list, 4, 6, 8',
    'pre-wrapper works in list context');
is($post, 'a::a_list, in, sub, a_list',
    'post-wrapper works in list context');
is(join(', ', @r), 'in, sub, a_list',
    'return list in list context');

