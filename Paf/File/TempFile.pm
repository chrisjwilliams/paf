# -----------------------------------------------
# Paf::File::TempFile
# -----------------------------------------------
# Description: 
#    Create a temporary file, which will be removed on
# object destruction
#
#
# -----------------------------------------------
# Copyright Chris Williams 2003
# -----------------------------------------------

package Paf::File::TempFile;
use Paf::File::TempDir;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;
	my $self={};
	bless $self, $class;
    my $dir=shift;

    if( ! defined $dir ) {
        $self->{tmpdir}=Paf::File::TempDir->new();
        $dir=$self->{tmpdir}->dir();
    }

    $self->{filename}=$dir."/paf_tmp_$$";

    my $tmp;
    my $count=1;
    do {
        $tmp=$self->{filename}."_$count";
        $count++;
    } while( -e $tmp );
    $self->{filename}=$tmp;

	return $self;
}

sub filename {
    my $self=shift;
    return $self->{filename};
}

# -- private methods -------------------------

sub DESTROY {
    my $self=shift;
    if( -f $self->{filename} )
    {
        unlink( $self->{filename} );
    }
}

