# -----------------------------------------------
# Paf::Platform::TaskSeries
# -----------------------------------------------
# Description: 
#    Run and maintain the current status of a set
# of related tasks in series.
#
#
# -----------------------------------------------
# Copyright Chris Williams 2008-2014
# -----------------------------------------------

package Paf::Platform::TaskSeries;
use Paf::Platform::Report;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;
	my $self={};
	bless $self, $class;
	return $self;
}

sub add_task {
    my $self=shift;
    my $name=shift;
    my $task=shift;

    push @{$self->{task_list}}, $name;
    $self->{tasks}{$name}=$task;
}

sub task_reset {
    my $self=shift;
    my $name=shift;

    delete $self->{reports}{$name};
    my @task_list=@{$self->{task_list}};
    while(@task_list) {
        my $key=shift @task_list;
        last, if( $key eq $name );
    }
    foreach my $key (@task_list) {
        delete $self->{reports}{$key};
    }
}

sub report {
    my $self=shift;
    my $name=shift;

    return $self->{reports}{$name};
}

sub has_completed {
    my $self=shift;
    foreach my $key ( @{$self->{task_list}} ) {
        return 0, if(! defined $self->{reports}{$key} || $self->{reports}{$key}->has_failed() );
    }
    return 1;
}

sub execute {
    my $self=shift;


    foreach my $key ( @{$self->{task_list}} ) {
        if(! defined $self->{reports}{$key} || $self->{reports}{$key}->has_failed() ) {
            # -- task needs to be executed
            $self->{reports}{$key}=new Paf::Platform::Report();
            my $task=$self->{tasks}{$key};
            my $report=$task->execute($self->{reports}{$key});
            if($report->has_failed()) {
                return $report;
            }
        }
    }
}

sub store_reports {
    my $self=shift;
    my $root=shift;

    foreach my $key ( @{$self->{task_list}} ) {
        my $task_node=$root->new_child( "Task", { name=>"$key" } );
        if( defined $self->report($key) ) {
            $self->report($key)->store($task_node->new_child("Report"));
        }
    }
}

sub restore_reports {
    my $self=shift;
    my $node=shift;

    foreach my $task_node ( $node->search(Paf::Configuration::NodeFilter->new("Task") ) ) {
        my $key=$task_node->meta()->{name};
        next, if ( ! defined $key || $key eq "");
        my $report=new Paf::Platform::Report;
        $report->restore($task_node->get_child(Paf::Configuration::NodeFilter->new("Report")));
        $self->{reports}{$key}=$report;
    }
}

# -- private methods -------------------------

