#
# Verbose.pm
#
# Originally Written by Christopher Williams 1996
#
# Description
# -----------
# Simple logging facility
#
# Interface
# ---------
# new()		: A new ActiveDoc object
# verbose(string)	: Print string in verbosity mode
# verbosity(0|1)	: verbosity off|on 

package Paf::tilities::Verbose;
require 5.004;

sub new {
	my $class=shift;
	$self={};
	bless $self, $class;
	$self->verbose("New ".ref($self)." Created");
	return $self;
}

sub verbosity {
	my $self=shift;
	if ( @_ ) {
	   $self->{verbose}=shift;
	}
	else {
	  my $id="VERBOSE_".ref($self);
	  if ( defined $ENV{$id} ) {
	     return $ENV{$id};
	  }
	}
	$self->{verbose};
}

sub verbose {
	my $self=shift;
	my $string=shift;

	if ( $self->verbosity() ) {
	  print ">".ref($self)."($self) : \n->".$string."\n";
	}
}

sub error {
	my $self=shift;
	my $string=shift;

	print $string."\n";
	exit 1;
}
