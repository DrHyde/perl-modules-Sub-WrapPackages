#!perl

use strict;
use Test::More tests => 4;

use lib 't/lib';
use Banana;

use Sub::WrapPackages (
    packages    => [qw(Banana)],
    post         => sub {
        ok(1, "Called $_[0]");
    },
    wrap_inherited => 1,
);

ok(Banana->peel() eq 'ready to eat', "got right response");
ok(Banana->eat() eq 'yum yum', "got right response");
