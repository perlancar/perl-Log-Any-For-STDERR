package Log::Any::For::STDERR;

use 5.010;
use strict;
use warnings;
use Log::Any;

# VERSION

our $Prefix = $ENV{LOG_STDERR_PREFIX} // "STDERR: ";

my $orig_stderr;
my $log = Log::Any->get_logger(category => 'STDERR');

sub _handler {
    my $msg = shift;

    $log->warn($Prefix . $msg);
    print $orig_stderr $msg;
}

sub import {
    open($orig_stderr, ">&STDERR") or die "Can't dup STDERR: $!";
    require Tie::STDERR;
    Tie::STDERR->import(\&_handler);
}

sub unimport {
    # Tie::STDERR does not provide unimport, but we can simply untie
    untie *STDERR;
}

1;
# ABSTRACT: (DEPRECATED) Send output of STDERR to Log::Any

=for Pod::Coverage ^(import|unimport)$

=head1 SYNOPSIS

 use Log::Any::For::STDERR;

 warn "Also sent to Log::Any";


=head1 DESCRIPTION

NOTE: This module is deprecated because when using this module, logging with
adapters that log to screen (STDERR) becomes problematic, because the output of
that adapter will then be logged again by this module, and you see the problem
with that :-)

This module will send output of STDERR to Log::Any. Messages are logged at
C<warn> level in category C<STDERR>. Messages produced by warn() and print(),
among others, will be included. But output of external programs (system(),
backtick) are currently not captured because they do not go through PerlIO.
Capturing is currently implemented using L<Tie::STDERR>.


=head1 VARIABLES

C<$Log::Any::For::STDERR::Prefix> (string, default C<"STDERR: ">). Text to
prepend before each output of STDERR.


=head1 ENVIRONMENT

C<LOG_STDERR_PREFIX> - Can be used to set C<$Prefix>.


=head1 FAQ


=head1 SEE ALSO

Of course, L<Log::Any>.

To log other stuffs to Log::Any (besides the normal way of C<< $log->debug() >>
et al, that is), see various other Log::Any::For::* modules.

To capture STDERR there are various ways, including those that utilizes fork and
can capture output of external programs. For example, see L<Capture::Tiny>.

=cut
