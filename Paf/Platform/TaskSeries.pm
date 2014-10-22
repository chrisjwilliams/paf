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
use Digest::MD5 qw(md5_base64);
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

sub set_report_factory {
    my $self=shift;
    $self->{report_factory}=shift;
}

sub create_report {
    my $self=shift;
    my $task_name=shift;
    if($self->{report_factory}) {
        return $self->{report_factory}->($task_name);
    }
    return new Paf::Platform::Report();
}

sub execute {
    my $self=shift;
    my $stop_task=shift;
    my $verbose=shift||0;

    foreach my $key ( @{$self->{task_list}} ) {
        if(! defined $self->{reports}{$key} || $self->{reports}{$key}->has_failed() ) {
            # -- task needs to be executed
            $self->{reports}{$key}=$self->create_report($key);
            my $task=$self->{tasks}{$key};
            print "executing task $key", if ( $verbose );
            my $report=$task->execute($self->{reports}{$key});
            if($report->has_failed()) {
                return $report;
            }
        }
        return $self->{reports}{$key}, if( defined $stop_task && $stop_task eq $key );
    }
    return $self->{reports}{${$self->{task_list}}[-1]};;
}

sub store_reports {
    my $self=shift;
    my $root=shift;

    foreach my $key ( @{$self->{task_list}} ) {
        if( defined $self->report($key) ) {
            my $task_node=$root->new_child( "Task", { name => "$key", cmd_md5 => $self->md5_task($key)} );
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
        # only restore if the commands havent changed
        if( ! defined $self->{tasks}{$key} || $task_node->meta()->{cmd_md5} eq $self->md5_task($key) ) {
            my $report=new Paf::Platform::Report;
            $report->restore($task_node->get_child(Paf::Configuration::NodeFilter->new("Report")));
            $self->{reports}{$key}=$report;
        }
    }
}

# -- private methods -------------------------

sub md5_task {
    my $self=shift;
    my $task_name=shift;
    my $compacted="";
    foreach my $l ( @{$self->{tasks}{$task_name}->list()} ) {
        $l=~s/^\s*(.*)\s*/$1/;
        $compacted.=$l;
    }
        
    return md5_base64($compacted);
}
