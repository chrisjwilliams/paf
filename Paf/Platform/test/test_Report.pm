# ----------------------------------
# class test_Report
# Description:
#    Unit tests for the Report class
#-----------------------------------

package test_Report;
use Paf::Platform::Report;
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
    return qw(test_equal test_serialize);
}

sub test_equal {
    my $self=shift;
    my $report=Paf::Platform::Report->new();
    my $report2=Paf::Platform::Report->new();

    die("expecting equality"), unless( $report->equal($report2) );

    my $report3=$self->create_report();
    my $report4=$self->create_report();

    die("expecting equality"), unless( $report3->equal($report4) );
    print $report->equal($report4),"\n";
    die("not expecting equality"), if( $report->equal($report4) != 0 );
    die("not expecting equality"), if( $report4->equal($report) != 0 );
}

sub test_serialize {
    my $self=shift;

    # empty report 
    {
        my $report=Paf::Platform::Report->new();

        my $buffer="";
        open my $fh, ">", \$buffer;
        $report->serialize($fh);
        $fh->close();

        open my $fh2, "<", \$buffer;
        my $report2=Paf::Platform::Report->new();
        $report2->deserialize($fh2);

        if( ! $report->equal($report2) ) {
            print "buffer=$buffer\n";
            print "Report 1:\n"; 
            $report->print();
            print "\n---- end report 1-------\n";
            print "Report 2:\n"; 
            $report->print(); 
            print "\n---- end report 2-------\n";
            die("reports differ");
        }
    }

    # report with data
    my $report=$self->create_report();
    my $buffer="";
    open my $fh, ">", \$buffer;
    $report->serialize($fh);
    $fh->close();

    open my $fh2, "<", \$buffer;
    my $report2=Paf::Platform::Report->new();
    $report2->deserialize($fh2);

    if( ! $report->equal($report2) ) {
        #print "buffer=$buffer\n";
        print "Report 1:\n"; 
        $report->print();
        print "\n---- end report 1-------\n";
        print "Report 2:\n"; 
        $report->print(); 
        print "\n---- end report 2-------\n";
        $buffer="";
        die("reports differ");
    }

    die("expecting identical reports to report has_failed equally"), unless $report->has_failed() eq $report2->has_failed();

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

