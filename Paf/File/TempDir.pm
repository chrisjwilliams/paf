# -----------------------------------------------
# File::TempDir
# -----------------------------------------------
# Description: 
#    Creates a temporary directory on construction
#  which will be destroyed on destruction
#
# -----------------------------------------------
# Copyright Chris Williams 2014
# -----------------------------------------------

package Paf::File::TempDir;
use File::Spec;
use File::Path;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;
	my $self={};
	bless $self, $class;

    my $base_dir=shift || File::Spec->tmpdir();
    $self->{cleanup}=shift || 1;

    $self->{dir}=$base_dir."/paf_tmp_$$";
    my $count=1;

    # -- make a temp directory
    my $tmpdir;
    do {
        $tmpdir=$self->{dir}."_$count";
        $count++;
    } while( -e $tmpdir );
    $self->{dir}=$tmpdir;

    mkdir $self->{dir} or die( "unable to create temporary working dir '".($tmpdir)."' : $!" );

	return $self;
}

sub dir {
    my $self=shift;
    return $self->{dir};
}

# -- private methods -------------------------

sub DESTROY {
    my $self=shift;
    if( -d $self->{dir} )
    {
        if( $self->{cleanup} )
        {
            rmtree( $self->{dir} );
        }
        else {
            print "tmp dir left: ", $self->{dir}, "\n";
        }
    }
}


