use strict;
use warnings;

package Sub::WrapPackages;

use vars qw($VERSION $wildcard_packages);

use Data::Dumper;
use IO::Scalar;

$VERSION = '1.2';
$wildcard_packages = [];

=head1 NAME

Sub::WrapPackages - add pre- and post-execution wrappers around all the
subroutines in packages or around individual subs

=head1 SYNOPSIS

    use Sub::WrapPackages
        packages => [qw(Foo Bar Baz::*)],   # wrap all subs in Foo and Bar
                                            #   and any Baz::* packages
        subs     => [qw(Barf::a, Barf::b)], # wrap these two subs as well
        wrap_inherited => 1,                # and wrap any methods
                                            #   inherited by Foo, Bar, or
                                            #   Baz::*
        pre      => sub {
            print "called $_[0] with params ".
              join(', ', @_[1..$#_])."\n";
        },
        post     => sub {
            print "$_[0] returned $_[1]\n";
        };

=head1 DESCRIPTION

This is mostly a wrapper around Damian Conway's Hook::LexWrap module.
Please go and read the docs for that module now.  The differences are:

=over 4

=item no exporting

We don't export a wrap() function, instead preferring to do all the magic
when you C<use> this module.  We just wrap named subroutines, no references.
I didn't need that functionality so although it's probably available if
you look at the source I haven't tested it.  Patches welcome!

=item the subs and packages arrayrefs

In the synopsis above, you will see two named parameters, C<subs> and
C<packages>.  Any subroutine mentioned in C<subs> will be wrapped.  Any
packages mentioned in C<packages> will have all their subroutines wrapped.

The order in which packages are loaded is not important.

=item wrap_inherited

In conjunction with the C<packages> arrayref, this wraps all calls to
inherited methods made through those packages.  If you call those
methods directly in the superclass then they are not affected.

=item parameters passed to your subs

I threw Damian's ideas out of the window.  Instead, your pre-wrapper will
be passed the wrapped subroutine's name, and all the parameters to be passed
to it.  Who knows what will happen if you modify those params, I don't
need that so haven't tested it.  Patches welcome!

The post-wrapper will be passed the wrapped subroutine's name, and a single
parameter for the return value(s) as in Damian's module.  Figuring out the
difference between returning an array and returning a reference to an array
is left as an exercise for the interested reader.

=back

=head1 BUGS

Wrapped subroutines may cause perl 5.6.1, and maybe other versions, to
segfault when called in void context.  I believe this is a bug in
Hook::LexWrap.

I say "patches welcome" a lot.

AUTOLOAD and DESTROY are not treated as being special.

=head1 FEEDBACK

I like to know who's using my code.  All comments, including constructive
criticism, are welcome.  Please email me.

=head1 SOURCE CODE REPOSITORY

L<http://www.cantrell.org.uk/cgit/cgit.cgi/perlmodules/>

=head1 COPYRIGHT and LICENCE

Copyright 2003-2009 David Cantrell E<lt>F<david@cantrell.org.uk>E<gt>

This software is free-as-in-speech software, and may be used, distributed, and modified under the terms of either the GNU General Public Licence version 2 or the Artistic Licence. It's up to you which one you use. The full text of the licences can be found in the files GPL2.txt and ARTISTIC.txt, respectively.

=head1 THANKS TO

Thanks also to Adam Trickett who thought this was a jolly good idea,
Tom Hukins who prompted me to add support for inherited methods, and Ed
Summers, whose code for figgering out what functions a package contains
I borrowed out of L<Acme::Voodoo>.

Thanks to Tom Hukins for sending in a test case for the situation when
a class and a subclass are both defined in the same file.

=cut

use Hook::LexWrap;

sub import {
    shift;
    _wrapsubs(@_) if(@_);
    unshift @INC,
    sub {
        my($me, $file) = @_;
        local @INC = grep { $_ ne $me } @INC;
        local $/;
        print "magic \@INC called looking for $file\n";
        my @files = grep { -e $_ } map { join('/', $_, $file) } @INC;
        print "Loading $files[0]\n";
        open(my $fh, $files[0]) || die("Can't locate $file in \@INC\n");
        my $module = <$fh>;
        close($fh);
        $module .= q{
            ;print "And now I'm diddling it\n";
            1;
        };
        print $module;
        return IO::Scalar->new(\$module);
    };
}

sub _subs_in_packages {
    my @targets = map { $_.'::' } @_;

    my @subs;
    foreach my $package (@targets) {
        no strict;
        while(my($k, $v) = each(%{$package})) {
            push @subs, $package.$k if(defined(&{$v}));
        }
    }
    return @subs;
}

sub _wrapsubs {
    my %params = @_;

    if(exists($params{packages}) && ref($params{packages}) =~ /^ARRAY/) {
        $wildcard_packages = [@{$wildcard_packages}, grep { /::\*$/ } @{$params{packages}}];
        my $nonwildcard_packages = [grep { $_ !~ /::\*$/ } @{$params{packages}}];
        if($params{wrap_inherited}) {
            foreach my $package (@{$nonwildcard_packages}) {
                # FIXME? does this work with 'use base'
                my @parents = eval '@'.$package.'::ISA';

                # get inherited (but not over-ridden!) subs
                my %subs_in_package = map {
                    s/.*:://; ($_, 1);
                } _subs_in_packages($package);

                my @subs_to_define = grep {
                    !exists($subs_in_package{$_})
                } map { 
                    s/.*:://; $_;
                } _subs_in_packages(@parents);

                # define them in $package using SUPER
                foreach my $sub (@subs_to_define) {
                    no strict;
                    *{$package."::$sub"} = eval "
                        sub {
                            package $package;
                            my \$self = shift;
                            \$self->SUPER::$sub(\@_);
                        };
                    ";
                    eval 'package __PACKAGE__';
                    # push @{$params{subs}}, $package."::$sub";
                }
            }
        }
        push @{$params{subs}}, _subs_in_packages(@{$params{packages}});
    } elsif(exists($params{packages})) {
        die("Bad param 'packages'");
    }

    return undef if(!$params{pre} && !$params{post});

    foreach my $sub (@{$params{subs}}) {
        Hook::LexWrap::wrap($sub, (($params{pre}) ?
            (pre =>  sub { &{$params{pre}}($sub, @_[0..$#_-1]) }) : ()
        ),(($params{post}) ?
            (post => sub { &{$params{post}}($sub, $_[-1]) }) : ()
        ));
    }
}

1;
