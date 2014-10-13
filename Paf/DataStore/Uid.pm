# -----------------------------------------------
# Paf::DataStore::Uid
# -----------------------------------------------
# Description: 
#   The unique identifier for a data objects in a data store
#
#
# -----------------------------------------------
# Copyright Chris Williams 2012-2014
# -----------------------------------------------

package Paf::DataStore::Uid;
use Storable qw(nfreeze thaw);
use URI::Escape;
use Carp;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;

    my $self={};
    if( ref($_[1]) eq "HASH" ) {
        $self->{store_id}=shift;
        $self->{keys}=shift;
        bless $self, $class;
    }
    else {
        if( $_[0] ) {
            # -- assume its a serialized string
            $self=thaw(uri_unescape(shift));
        }
        else {
            carp "no id specified";
        }
    }

	return $self;
}

sub store_id {
    my $self=shift;
    return $self->{store_id};
}

sub value {
    my $self=shift;
    my $name=shift;
    return $self->{keys}{$name};
}

sub serialize {
    my $self=shift;
    my $string=uri_escape(nfreeze $self);
    return $string;
}

# -- private methods -------------------------

