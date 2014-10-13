# -----------------------------------------------
# Paf::Cli::TestUtils::TestCommand
# -----------------------------------------------
# Description: 
#   TestCommand that records the functions that have been called
#
#
# -----------------------------------------------
# Copyright Chris Williams 2014
# -----------------------------------------------

package Paf::Cli::TestUtils::TestCommand;
use parent "Paf::Cli::Command";
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;

	my $self={};
	bless $self, $class;
    $self->{name}=shift || "";
    $self->{run}=0;
    $self->{usage}=0;
    $self->{synopsis}=0;

	return $self;
}

sub name {
    my $self=shift;
    return $self->{name};
}

sub synopsis {
    my $self=shift;
    $self->{synopsis}++;
    return "help for the ".($self->{name})." command";
}

sub run {
    my $self=shift;
    $self->{run}++;
}

sub usage {
    my $self=shift;
    $self->{usage}++;
    return $self->SUPER::usage();
}

# -- private methods -------------------------

