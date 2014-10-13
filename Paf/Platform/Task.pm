# -----------------------------------------------
# Paf::Platform::Task
# -----------------------------------------------
# Description: 
#   Specify and execute tasks on the specifed host
#
#
# -----------------------------------------------
# Copyright Chris Williams 2008 - 2014
# -----------------------------------------------

package Paf::Platform::Task;
use Paf::Platform::Report;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;

	my $self={};
	bless $self, $class;

    $self->{platform}=shift||die ("must specify platform");;
    @{$self->{steps}}=();

	return $self;
}

sub add {
    my $self=shift;
    push @{$self->{steps}}, @_;
}

sub execute {
    my $self=shift;
    my $report=shift;

    my $rv;
    foreach my $step ( @{$self->{steps}} ) {
        $report->new_context($step);
        eval { $self->{platform}->execute($step, $report); };
        if(@_) {
            $report->error(1, "@_");
        }
        last, if($report->has_failed());
    }
    $report->close_context();

    return $report;
}

# -- private methods -------------------------

