# -----------------------------------------------
# Paf::DataStore::DirStoreUid
# -----------------------------------------------
# Description: 
#
#
#
# -----------------------------------------------
# Copyright Chris Williams 2013-2014
# -----------------------------------------------

package Paf::DataStore::DirStoreUid;
use parent "Paf::DataStore::Uid";
use strict;
1;

# -- initialisation

sub new {
    my $class=shift;
    my $self=$class->SUPER::new(@_);
    return $self;
}

# -- private methods -------------------------

