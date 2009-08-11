#!/usr/bin/perl -w

use strict;
use Test::More tests => 3;
use Data::Dumper;

my $r;

use lib 't/lib'; use b; use c;
use Sub::WrapPackages (
    packages       => [qw(b c)],
    wrap_inherited => 1,
    pre            => sub { $r .= join(", ", @_); },
    post           => sub {
		          $r .= ref($_[1]) =~ /^ARRAY/ ? join(', ', @{$_[1]}) : $_[1];
		      }
);

$r .= b->b_function();

ok($r eq 'b::b_function, bi like piei like pie',
  'when wrapping inherited methods, normal methods are wrapped too');

$r = '';
my @r = b->a_list(4,6,8);
ok(join('', @r) eq 'insuba_list' && $r eq 'b::a_list, b, 4, 6, 8in, sub, a_list', 'Can wrap inherited subs');

$r = '';
@r = c->a_list(4,6,8);
ok(join('', @r) eq 'insuba_list' && $r eq 'b::a_list, b, 4, 6, 8in, sub, a_list', 'Subs inherited from grandparent are wrapped OK') || print "# \@r: ".join('', @r)."\n# \$r: $r\n";

$r = '';
@r = a->a_list(4,6,8);
ok(join('', @r) eq 'insuba_list' && $r eq '', 'And calling the superclass method directly avoids wrapping shenanigans');
