# -----------------------------------------------
# Paf::Configuration::NodeFilter
# -----------------------------------------------
# Description: 
#   Defines a filter for the Node search.
#   You can filter by node name and the value of any
#   meta parameters
#
#
# -----------------------------------------------
# Copyright Chris Williams 2003
# -----------------------------------------------
# new(node_name, parameter_hash)	: new filter object. node_name undef or "" will match all names

package Paf::Configuration::NodeFilter;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;

	my $self={};
	bless $self, $class;
    $self->{name}=shift||"";
    $self->{meta}=shift||{};

	return $self;
}

sub name {
    my $self=shift;
    return $self->{name};
}

sub meta {
    my $self=shift;
    return $self->{meta};
}

sub filter {
    my $self=shift;
    my $node=shift;

    if($node) {
        if( ! $self->{name} || $self->{name} eq "" || (defined $node->name() && $node->name() eq $self->{name}) ) {
            # check the meta matches
            my $meta=$node->meta();
            foreach my $key ( keys %{$self->{meta}} ) {
               return 0, unless (defined $meta->{$key} && $meta->{$key} eq $self->{meta}{$key});
            }
            return 1;
        }
    }
    return 0;
}

# -- private methods -------------------------

