# -----------------------------------------------
# Paf::Cli::OptionalArgument
# -----------------------------------------------
# Description: 
#    describes an argument on the command line
# Usage:
#    new("argument_name", @synopsis_list);
# -----------------------------------------------
# Copyright Chris Williams 2003 - 2014
# -----------------------------------------------

package Paf::Cli::OptionalArgument;
use parent Paf::Cli::Argument;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;
    my $self=$class->SUPER::new(@_);

    $self->{optional}=1;
	return $self;
}

# -- private methods -------------------------

