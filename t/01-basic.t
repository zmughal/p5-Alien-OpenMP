use strict;
use warnings;

use Test::More tests => 7;
use FindBin qw/$Bin/;
use lib qq{$Bin/../lib};

use_ok( q{Alien::OpenMP}, q{Can load Alien::OpenMP} );

# no actual constructor exists
my $snoo = bless {}, q{Alien::OpenMP};

can_ok( $snoo, qw/cflags lddlflags/ );

# dev note 1: add a new lexically scoped blockfor each
# 'ccname' that gets added to Alien::OpenMP; please
# don't get fancy and create a loop

# dev note 2: this test is not dependent on the
# environment, see the use of a local'd version of
# %Config::Config below for a hint on how to properly
# add additional tests as compiler support is added to
# this module.

GCC:
{
    my $omp_flag = q{-fopenmp};
    local %Config::Config = ( ccname => q{gcc}, );
    is $snoo->cflags,    $omp_flag, q{Found expected OpenMP compiler switch for gcc.};
    is $snoo->lddlflags, $omp_flag, q{Found expected OpenMP linker switch for gcc.};
    is $snoo->lddlflags, $snoo->cflags, q{cflags and lddlflags are the same.};
}

UNSUPPORTED:
{
    local %Config::Config = ( ccname => q{unsupported xyz}, );
    local $@;
    # force exception for cflags
    my $ok = eval {
      $snoo->cflags;
    };
    chomp $@;
    is $@, q{OS unsupported}, q{clfags - OS Unsupported thrown when exected};
    # reset and force exception for lddlflags
    $@ = undef;
    $ok = eval {
      $snoo->lddlflags;
    };
    chomp $@;
    is $@, q{OS unsupported}, q{lddlflags - OS Unsupported thrown when exected};
}

exit;

__END__
