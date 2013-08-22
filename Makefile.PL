use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'WWW::Codeguard',
    AUTHOR           => q{Rishwanth Yeddula <ryeddula@cpan.org>},
    VERSION_FROM     => 'lib/WWW/Codeguard.pm',
    ABSTRACT_FROM    => 'lib/WWW/Codeguard.pm',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'LWP::UserAgent' => 0,
	'JSON'           => 0,
	'Net::OAuth'     => 0,
	'HTTP::Request'  => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'WWW-Codeguard-*' },
);
