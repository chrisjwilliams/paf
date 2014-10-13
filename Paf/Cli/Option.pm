#
# Base class for all Cli options
#
# Required Methods:
# run($arg_array_ref)

package Paf::Cli::Option;
use strict;
1;

sub new {
    my $class=shift;
    my $self={};
    $self->{name}=shift;

    bless $self, $class;
    return $self;
}

sub name {
    my $self=shift;
    return $self->{name};
}

sub help {
    die "no help provided";
}
