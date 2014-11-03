# -----------------------------------------------
# Paf::Cli::Argument
# -----------------------------------------------
# Description: 
#    describes an argument on the command line
# Usage:
#    new("argument_name", @synopsis_list);
# -----------------------------------------------
# Copyright Chris Williams 2003 - 2014
# -----------------------------------------------

package Paf::Cli::Argument;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;

	my $self={};
	bless $self, $class;
    $self->{name}=shift;
    @{$self->{synopsis}}=@_;

    $self->{optional}=0;
	return $self;
}

sub optional {
    my $self=shift;
    return $self->{optional};
}

sub synopsis {
    my $self=shift;
    return @{$self->{synopsis}};
}

sub name {
    my $self=shift;
    return $self->{name};
}

# -- private methods -------------------------

