# -----------------------------------------------
# Paf::Configuration::Node
# -----------------------------------------------
# Description: 
#   A Configuration Node
#
#
# -----------------------------------------------
# Copyright Chris Williams 1996 - 2014
# -----------------------------------------------

package Paf::Configuration::Node;
use Paf::Configuration::NodeFilter;
use Carp;
use warnings;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;

	my $self={};
	bless $self, $class;
    $self->{name}=shift;
    $self->reset();

    $self->{meta}=shift || {};

	return $self;
}

sub name {
    my $self=shift;
    return $self->{name};
}

sub set_name {
    my $self=shift;
    $self->{name}=shift;
}

sub content {
    my $self=shift;
    return $self->{content};
}

sub add_content {
    my $self=shift;
    foreach my $line ( @_ ) {
        next, if (! defined $line || $line eq "");
        push @{$self->{content}}, $line;
    }
}

sub clear_content {
    my $self=shift;
    @{$self->{content}}=();
}

sub meta {
    my $self=shift;
    return $self->{meta};
}

sub parent {
    my $self=shift;
    return $self->{parent};
}

sub children {
    my $self=shift;
    return @{$self->{children}};
}


sub add_meta {
    my $self=shift;
    my $var=shift;
    my $val=shift;

    $self->{meta}{$var}=$val;
}

sub add_children {
    my $self=shift;
    foreach my $child ( @_ ) {
        $child->{parent}=$self;
        push @{$self->{children}}, $child;
    }
}

sub new_child {
    my $self=shift;
    my $name=shift || croak "no name specified";
    my $node=new Paf::Configuration::Node($name, @_);
    $self->add_children( $node );
    return $node;
}

sub reset {
    my $self=shift;
    @{$self->{children}}=();
    $self->{meta}={};
    @{$self->{content}}=();
}

#
# return a list of child nodes that match the search criteria
# The search criteria must be provided as a list of NodeFilters
# that are to be applied at the corresponding depth of child.
#
sub search {
    my $self=shift;
    my @filters=@_; # -- a list of node filters to apply at the corresponding depth

    my @candidates=();
    foreach my $child_node ( @{$self->{children}} ) {
        push @candidates, $self->_search_node($child_node, @filters);
    }
    return @candidates;
}

#
# return the first child node that matches the filter. If none exists
# then a node is created with the same attributes as the filter
#
sub get_child {
    my $self=shift;
    my $filter=shift;
    
    foreach my $child_node ( @{$self->{children}} ) {
        if( $filter->filter($child_node) ) {
            return $child_node;
        }
    }
    # we didn't find anything so create one
    return $self->new_child($filter->name(), $filter->meta());
}

#
# remove a child from the node
#
sub remove_child {
    my $self=shift;
    my $child_node=shift || die "no child node specified";

    @{$self->{children}} = grep { $_ != $child_node } @{$self->{children}};
}

#
#  unhook this node from its parent
#
sub unhook {
    my $self=shift;
    if( $self->{parent} ) {
        $self->{parent}->remove_child($self);
        $self->{parent}=undef;
    }
}

# -- private methods -------------------------
sub _search_node {
    my $self=shift;
    my $node=shift;
    my @filters=@_; # -- a list of node filters to apply at the corresponding depth

    my $filter=shift @filters;
    return $node, if(! $filter);

    my @candidates=();
    if( $filter->filter($node) ) {
        if(@filters) {
            foreach my $child_node ( @{$node->{children}} ) {
                push @candidates, $node->_search_node($child_node, @filters);
            }
        }
        else {
            return $node;
        }
    }
    return @candidates;
}

