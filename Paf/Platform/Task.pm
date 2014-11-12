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
use Paf::Platform::ShellEnvironment;
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

sub list {
    my $self=shift;
    return $self->{steps}; # n.b return an array ref
}

sub runtime_environment {
    my $self=shift;
    if(@_) {
        $self->{env}=shift;
    }
    return $self->{env};
}

sub execute {
    my $self=shift;
    my $report=shift;
    my $verbose=shift||0;

    # set runtime environment
    my $runtime_env=new Paf::Platform::ShellEnvironment($self->{env});

    my $rv;
    foreach my $step ( @{$self->{steps}} ) {
        print "$step\n", if ( $verbose );
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

