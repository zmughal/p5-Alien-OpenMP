package Alien::OpenMP;

use strict;
use warnings;
use Config ();

our $VERSION = '1.0';

# __PACKAGE__ hash ref containing table of flag used
# by each specified 'ccname'

our $omp_flags = {
    gcc => '-fopenmp',
};

sub cflags {
    my $cn = $Config::Config{ccname};

    # OpenMP pragmas live behind source code comments
    if ( not defined $omp_flags->{$cn} ) {
      require ExtUtils::MakeMaker;
      ExtUtils::MakeMaker::os_unsupported();
    }

    return $omp_flags->{$cn};
}

sub lddlflags {

    # we can reuse cflags for gcc/gomp; hopefully this will
    # remain the case for all supported compilers

    return cflags;
}

1;

__END__

=head1 NAME

Alien::OpenMP - Encapsulate system info for OpenMP

=head1 SYNOPSIS

    use Alien::OpenMP;
    say Alien::OpenMP->cflags;    # e.g. -fopenmp if gcc 
    say Alien::OpenMP->lddlflags; # e.g. -fopenmp if gcc 

=head1 DESCRIPTION

This module encapsulates the knowledge required to compile OpenMP programs
C<$Config{ccname}>. C<C>, C<Fortran>, and C<C++> programs annotated
with declarative OpenMP pragmas will still compile if the compiler (and
linker if this is a separate process) is not passed the appropriate flag
to enable OpenMP support. This is because all pragmas are hidden behind
full line comments (with the addition of OpenMP specific C<sentinels>,
as they are called).

All compilers require OpenMP to be explicitly activated during compilation;
for example, GCC's implementation, C<GOMP>, is invoked by the C<-fopenmp>
flag.

Most major compilers support OpenMP, including: GCC, Intel, IBM,
Portland Group, NAG, and those compilers created using LLVM. GCC's OpenMP
implementation, C<GOMP>, is available in all modern versions. Unfortunately,
while OpenMP is a well supported standard; compilers are not required to
use the same commandline switch to activate support. All compilers that
support OpenMP use slightly different ways of invoking it.

=head2 Compilers Supported by this module

At this time, the following compilers are supported:

=over 4

=item C<gcc>

C<-fopenmp> enables OpenMP support in via compiler and linker:

    gcc -fopenmp ./my-openmp.c -o my-openmp.x

=back

=head2 Note On Compiler Support

If used for an unsupported compiler, C<ExtUtils::MakeMaker::os_unsupported> is
invoked, which results an exception propagating from this method being raised
with the value of C<qq{OS unsupported\n}> (note the new line).

This module assumes that the compiler in question is the same one used to
build C<perl>. Since the vast majority of C<perl>s are building using C<gcc>,
initial support is targeting it. However, like C<perl>, many other compilers
may be used.

Adding support for a new compiler should be straightforward; while C<pull
requests are welcome>, you may request updated support through the prescribed
bug tracker.

=head1 METHODS

=over 3

=item C<cflags>

Returns flag used by a supported compiler to enable OpenMP. If not support,
an empty string is provided since by definition all OpenMP programs must compile
because OpenMP pramgas are annotations hidden behind source code comments.

Example, GCC uses, C<-fopenmp>.

=item C<lddlflags>

Returns the flag used by the linker to enable OpenMP. This is usually the same
as what is returned by C<cflags>.

Example, GCC uses, C<-fopenmp>, for this as well.

=back

=head1 AUTHOR

OODLER 577 <oodler@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 by oodler577

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.30.0 or,
at your option, any later version of Perl 5 you may have available.

=head1 SEE ALSO

L<PDL>, L<OpenMP::Environment>,
L<https://gcc.gnu.org/onlinedocs/libgomp/index.html>.
