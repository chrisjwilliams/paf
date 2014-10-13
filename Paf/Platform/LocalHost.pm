# -----------------------------------------------
# Paf::Platform::LocalHost
# -----------------------------------------------
# Description: 
#   Interface to the local hosts system information
#
#
# -----------------------------------------------
# Copyright Chris Williams 2008-2013
# -----------------------------------------------

package Paf::Platform::LocalHost;
use Paf::Platform::Host;
@ISA=qw(Paf::Platform::Host);
use Config;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;
	my $self=$class->SUPER::new(@_);
	return $self;
}

sub environment
{
    my $self=shift;
    if( ! defined $self->{platform_info} )
    {
        $self->{platform_info}={};
    }
    return $self->{platform_info};
}

sub arch 
{
    return $Config{osname};
}

sub _execute 
{
    my $self=shift;

    return system(@_); 
}

# -- private methods -------------------------

