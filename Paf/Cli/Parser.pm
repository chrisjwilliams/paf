package Paf::Cli::Parser;
use Carp;
use strict;
1;

sub new
{
    my $class=shift;
    my $self={};
    bless $self, $class;
    my $top_cli=shift || carp "Paf::Cli::Parser object called without an application specific CLI object";

    $self->{cli}=new CliWrapper($top_cli);

    return $self;
}

sub parse
{
    my $self=shift;
    return $self->_parse_cmd($self->{cli}, @_);
}

sub _parse_cmd
{
    my $self=shift;
    my $cli=shift;
    my @args=@_;

    # -- parse options --
    while ( defined $args[0] && $args[0]=~/^-(.*)/ ) {
        my $arg=$1;
        shift @args;
        if( $arg eq "help" )
        {
            $self->help();
            return 0;
        }
        my $found=0;
        foreach my $opt ( $cli->options() )
        {
            if($opt->name() eq $arg) {
                $found=1;
                my $rv=$opt->run(\@args);
                return $rv, if($rv != 0);
            }
        }
        if( $found == 0 )
        {
            print "unknown option: $arg\n";
            $cli->usage();
            return 1;
        }
    }

    # -- parse commands --
    if( ! defined $args[0] )
    {
        if( $cli->commands() ) {
            print "no command specified\n";
            $cli->usage();
            return 1;
        }
        else {
            return $cli->run();
        }
    }
    else {
        if( $args[0] eq "help" )
        {
            $cli->help();
            return 0;
        }
        if( $cli->commands() )
        {
            foreach my $cmd ( $cli->commands() ) {
                if($args[0] eq $cmd->name())
                {
                    shift @args;
                    return $self->_parse_cmd($cmd, @args);
                }
            }
        }
        else {
            return $cli->run(@args);
        }
    }
    $cli->usage();
    return 1;
}

package CliWrapper;
use parent "Paf::Cli::Command";

sub new {
    my $class=shift;
    my $self={};
    bless $self, $class;
    $self->{cli}=shift || die "no cli passed";
    $self->{cli}->{parent}=$self;

    return $self;
}

sub name {
    return $FindBin::Script;
}

sub commands
{
    my $self=shift;
    return $self->{cli}->commands();
}

sub options
{
    my $self=shift;
    return $self->{cli}->options();
}

sub run {
    my $self=shift;
    return $self->{cli}->run();
}

sub synopsis {
    my $self=shift;
    return $self->{cli}->synopsis();
}

