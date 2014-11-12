# -----------------------------------------------
# Paf::Platform::ShellEnvironment
# -----------------------------------------------
# Description: 
#    Manage the lifetime of a shell environment
#    On destruction will restore the environment
#
#
# -----------------------------------------------
# Copyright Chris Williams 2003
# -----------------------------------------------
# Interface
# ---------
# new( {hash} )	: new object
#
#

package Paf::Platform::ShellEnvironment;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;

	my $self={};
    $self->{set}=shift||{};
	bless $self, $class;

    # -- make a note of the current values of any vars we are about to change
    foreach my $key ( keys %{$self->{set}} ) {
        if( defined $ENV{$key} ) {
           $self->{saved}{$key}=$ENV{$key}; 
        }
        # set the env variable
        $ENV{$key}=$self->{set}{$key}; 
    }

	return $self;
}

# -- private methods -------------------------

sub _restore {
    my $self=shift;
    foreach my $key ( keys %{$self->{set}} ) {
        if( defined $self->{saved}{$key} ) {
            $ENV{$key}=$self->{saved};
        }
        else {
            delete $ENV{$key};
        }
    }
}

sub DESTROY {
    my $self=shift;
    $self->_restore();
}

