# -----------------------------------------------
# Paf::DataStore::UidIterator
# -----------------------------------------------
# Description: 
#    Iterator interface to return the results of find searches
#
#    Override as required, e,g for large distributed data sets. 
#    The default iterator wraps a standard array passed in the constructor
#
# -----------------------------------------------
# Copyright Christopher Williams 2013 - 2014
# -----------------------------------------------

package Paf::DataStore::UidIterator;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;

	my $self={};
	bless $self, $class;
    push @{$self->{data}}, @_;

    $self->{index}=0;
	return $self;
}

sub last {
    my $self=shift;

    if( $self->{index} > $#{$self->{data}} ) {
        return 1;
    }
    return 0;
}

sub next {
    my $self=shift;

    return undef, if($self->last());
    $self->{index}++;
    return $self->{data}[$self->{index} - 1];
}

# -- private methods -------------------------

