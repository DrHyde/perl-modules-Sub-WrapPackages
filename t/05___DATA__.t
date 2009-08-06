use strict;
use warnings;

use lib 't/lib';

use Test::More tests => 8;

use Sub::WrapPackages (
    packages => [qw(Module::With::Data::Segment)],
    pre      => sub {
        ok(1, "$_[0] pre-wrapper")
    },
    post     => sub {
        ok(1, "$_[0] post-wrapper")
    }
);

use Module::With::Data::Segment;

...
