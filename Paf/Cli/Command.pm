#
# Base class for all Cli commands
#

package Paf::Cli::Command;
use strict;
use Carp;
1;

sub new {
    my $class=shift;
    my $self={};
    @{$self->{cmds}}=();
    @{$self->{opts}}=();

    bless $self, $class;
    return $self;
}

# -- override all methods in this section in inheriting class --
sub name {
    ""; # only the top level command object can have a blank name
}

sub synopsis {
    die "no synopsis provided";
}

sub run {
    return 1;
}


# -- methods -------
sub add_cmds {
    my $self=shift;
    foreach my $cmd ( @_ )
    {
        if(! defined $cmd->name())
        {
            carp "fatal: attempt to add a command without a name";
        }
        if(! defined $cmd->{parent})
        {
            $cmd->{parent}=$self;
        }
        push @{$self->{cmds}}, $cmd;
    }
}

sub add_options {
    my $self=shift;
    push @{$self->{opts}}, @_;
}

sub options {
    my $self=shift;
    if( defined $self->{opts} )
    {
        return @{$self->{opts}};
    }
    return ();
}

sub commands {
    my $self=shift;
    if( defined $self->{cmds} )
    {
        return @{$self->{cmds}};
    }
    return ();
}

sub breadcrumb_trail
{
    my $self=shift;
    my $obj=$self;
    my @trail;
    do {
        if($obj->name() ne "") {
            unshift @trail, $obj;
        }
        $obj=$obj->{parent};
    } while(defined $obj);
    return @trail;
}

sub help {
    my $self=shift;
    print "Synopsis:\n\t";
    print $self->synopsis(), "\n";
    $self->usage();
}

sub usage {
    my $self=shift;

    # -- the command name in its full context
    print "Usage:\n\t";
    foreach my $obj ( $self->breadcrumb_trail() )
    {
        my $cmd_name=$obj->name();
        print " ", $cmd_name;
        print " [".$cmd_name."_options]", if($obj->options());
    }
    print " <command>";
    print "\n";
    print "\nSub Commands:\n";
    print "\thelp\n";
    foreach my $cmd ( $self->commands() )
    {
        print "\t", $cmd->name(), "\n";
    }
    if( $self->options() )
    {
        print "\nOptions:\n";
        foreach my $opt ( $self->options() )
        {
            print "\t-", $opt->name(), "\t", $opt->synopsis(), "\n";
        }
    }
}

sub error {
    my $self=shift;
    my $msg=shift;

    print STDERR "error: ", $msg, "\n";
    $self->usage();
    return 1;
}