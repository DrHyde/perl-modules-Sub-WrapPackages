use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'Sub::WrapPackages',
    VERSION_FROM => 'lib/Sub/WrapPackages.pm',
    PREREQ_PM    => {
        # Hook::LexWrap => 0.20,
    }
);

# package MY;
# sub test {
#     my $text = shift->SUPER::test(@_);
#     $text =~ s/\t(.*test_harness)/\tHARNESS_OPTIONS=j8 $1/;
#     $text;
# }
