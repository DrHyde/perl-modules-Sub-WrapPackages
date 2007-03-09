use ExtUtils::MakeMaker;
WriteMakefile(
    NAME      => 'Sub::WrapPackages',
    VERSION   => '1.2',
    PREREQ_PM => {
        Hook::LexWrap => 0.20,
    }
);
