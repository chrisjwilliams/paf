# -----------------------------------------------
# Paf::DataStore::DataStore
# -----------------------------------------------
# Description: 
#   base class for all DataStores
#
#
# -----------------------------------------------
# Copyright Chris Williams 2003
# -----------------------------------------------
# Interface
# ---------
# new("uniqued_store_id")    : new object
#

package Paf::DataStore::DataStore;
use strict;
use Carp;
1;

# -- initialisation

sub new {
    my $class=shift;

    my $self={};
    bless $self, $class;
    $self->{id}=shift || carp "Data store needs a unique identifier";

    $self->{id}=$class."_".$self->{id};
    return $self;
}

sub id {
    my $self=shift;
    return $self->{id};
}

# -- private methods -------------------------

