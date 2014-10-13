# -----------------------------------------------
# Paf::Configuration::Version
# -----------------------------------------------
# Description: 
#    Version management for API's
#
# -----------------------------------------------
# Copyright Chris Williams 1996-2014
# -----------------------------------------------

package Paf::Configuration::Version;
use parent Paf::Utilities::Verbose;
use FindBin;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;

	my $self={};
	bless $self, $class;

    $self->{vcs}=shift || die "No VCS provided";;
    $self->{install_top}=$FindBin::Bin;

	return $self;
}

sub current_version {
    my $self=shift;
    if(!defined $self->{version})
    {
        $self->{version}=$FindBin::Bin;
    }
    return $self->{version};
}

sub install {
    my $self=shift;
	my $version=shift;

    my $install_dir=$self->{install_top}."/".$version;
    if ( ! -d $install_dir ) {
        return $self->{vcs}->checkout( $version, $install_dir );
    }
    return 0;
}

sub switch_version {
    my $self=shift;
	my $version=shift;

	if ( defined $version ) {
	  if ( $version ne $thisversion ) {
         # first try to use the correct version
         my $exe = $self->{script};
         if ( ! -e $exe ) {
            # attempt to install the required eersion
            $self->install($version);
         }
         if ( -e $exe ) {
              $self->verbose("Spawning version $version");
              my $rv=system($exe, @_)/256;
              exit $rv;
          }
          else { # if not then simply warn
              print "********** Warning : version inconsistent ************\n";
              print "This version: $thisversion; Required version: $version\n";
              print "******************************************************\n";
              print "\n";
          }
      }
    }
}

# -- private methods -------------------------

