use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'Sub::WrapPackages',
    VERSION_FROM => 'lib/Sub/WrapPackages.pm',
    PREREQ_PM    => {
        'Sub::Prototype' => 0.02,
    }
);

package MY;
sub test {
    my $text = shift->SUPER::test(@_);
    $text =~ s/\t(.*test_harness)/\tHARNESS_OPTIONS=j8 $1/;
    $text;
}
