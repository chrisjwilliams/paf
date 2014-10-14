# ----------------------------------
# class test_TaskSeries
# Description:
#    Unit tests for the TaskSeries class
#-----------------------------------

package test_TaskSeries;
use Paf::Platform::TaskSeries;
use Paf::Platform::TestHost;
use Paf::Platform::Task;
use Paf::Configuration::Node;
use Carp;
use warnings;
use strict;
1;

sub new {
    my $class=shift;
    my $self={};
    bless $self, $class;
    return $self;
}

sub tests {
    return qw(test_execute);
}

sub test_execute {
    my $self=shift;

    my $platform_1=new Paf::Platform::TestHost;

    # -- setup three different tasks
    my $task_1=new Paf::Platform::Task($platform_1);
    my $cmd_1="cmd_1";
    $task_1->add($cmd_1);
    my $task_2=new Paf::Platform::Task($platform_1);
    my $cmd_2="cmd_2";
    $task_2->add($cmd_2);
    my $task_3=new Paf::Platform::Task($platform_1);
    my $cmd_3="cmd_3";
    $task_3->add($cmd_3);

    my $ts=Paf::Platform::TaskSeries->new();
    $ts->add_task("task_1", $task_1); 
    $ts->add_task("task_2", $task_2); 
    $ts->add_task("task_3", $task_3); 

    my $expected=join(",",$cmd_1,$cmd_2, $cmd_3);

    die("not expecting has_completed"), if $ts->has_completed();
    $ts->execute();

    # - check all cmds have been executed in the correct order
    my $cmds=join(",",$platform_1->executed_commands());
    die("expecting $expected, got $cmds"), unless $expected eq $cmds;

    die("expecting has_completed"), unless $ts->has_completed();

    # -- reset a task
    $ts->task_reset("task_2");
    die("not expecting has_completed"), if $ts->has_completed();

    $ts->execute();
    die("expecting $expected, got $cmds"), unless $expected eq $cmds;

    $expected=join(",",$cmd_2, $cmd_3); # should rerun task and its following dependent tasks
    $cmds=join(",",$platform_1->executed_commands());
    die("expecting $expected, got $cmds"), unless $expected eq $cmds;

    # cause a task to fail
    $ts->task_reset("task_3");
    $platform_1->error(3, "some very nasty error\n");
    $ts->execute();
    $expected=$cmd_3; # should rerun task and its following dependent tasks
    die("not expecting has_completed"), if $ts->has_completed();

    # check the report is as expected
    my $report=$ts->report("task_3");
    die("expecting a report for task_3, got undef"), unless $report;
    die("expecting has_failed"), unless $report->has_failed();

    # store/restore method
    my $node=new Paf::Configuration::Node("Wibble");
    $ts->store_reports($node);
    my $ts2=Paf::Platform::TaskSeries->new();
    $ts2->restore_reports($node);

    my $restored_fail=$ts2->report("task_3");
    die("expecting a report for task_3, got undef"), unless $restored_fail;
    die("expecting restored report for task_3"), unless $restored_fail->equal($ts->report("task_3"));;

}

sub create_report {
    my $self=shift;
    
    my $report=Paf::Platform::Report->new();
    for(my $i=0; $i < 3; ++$i) {
        print { $report->output_stream() } "STDOUT", $i, "\n";
        print { $report->error_stream() } "STDERR",$i, "\n";
        $report->new_context("context_".$i);
    }
    $report->error(2);
    $report->close_context();
    return $report;
}

