# -----------------------------------------------
# Paf::Platform::Host
# -----------------------------------------------
# Description: 
#   BAse class for hosts of different types
#
#
# -----------------------------------------------
# Copyright Chris Williams 2008-2014
# -----------------------------------------------

package Paf::Platform::Host;
use Paf::Platform::Report;
use warnings;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;

	my $self={};
	bless $self, $class;

	return $self;
}

sub environment
{
    my $self=shift;
    return {};
}

sub execute {
    my $self=shift;
    my $cmd=shift;
    my $report=shift;
    
    # -- redirect stdout & stderr
    local *STDOUT=$report->output_stream();
    local *STDERR=$report->error_stream();
    #print STDOUT "STDOUT stream\n";
    #print STDERR "STDERR stream\n";

    my $rv=$self->_execute($cmd);
    if($rv!=0) {
        $report->error($rv);
    }

    return $report;
}

# -- private methods -------------------------

