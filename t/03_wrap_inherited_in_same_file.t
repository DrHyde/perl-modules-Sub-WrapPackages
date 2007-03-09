#!perl

use strict;
use Test::More tests => 2;

use lib 't/lib';
use Banana;

use Sub::WrapPackages (
    packages    => [qw(Banana)],
    post         => sub {
        ok "Called $_[0]\n";
    },
    wrap_inherited => 1,
);

Banana->peel;
Banana->eat;
