# -----------------------------------------------
# Paf::Platform::TestHost
# -----------------------------------------------
# Description: 
#    A Host implementation that simply echos any command to the 
#    stdout. YOu can set an error() to happen with a return value and error msg
#
#
# -----------------------------------------------
# Copyright Chris Williams 2003
# -----------------------------------------------

package Paf::Platform::TestHost;
use Paf::Platform::Host;
@ISA=qw(Paf::Platform::Host);
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;

	my $self=$class->SUPER::new(@_);
    @{$self->{cmds_executed}} = ();
    $self->{error_val}=0;
    $self->{error_msg}="";

	return $self;
}

sub _execute {
    my $self=shift;
    push @{$self->{cmds_executed}}, @_;
    foreach my $cmd ( @_ ) {
        print $cmd,"\n";
    }

    my $return_val=$self->{error_val};
    $self->{error_val}=0;

    if($self->{error_msg} ne "") {
        print STDERR $self->{error_msg};
        $self->{error_msg}="";
    }

    return $return_val;
}

sub executed_commands {
    my $self=shift;
    my @tmp = @{$self->{cmds_executed}};
    @{$self->{cmds_executed}} = ();
    return @tmp;
}
    

sub error {
    my $self=shift;
    $self->{error_val}=shift;
    $self->{error_msg}=shift;
}

sub arch {
    return "test_arch";
}

# -- private methods -------------------------

