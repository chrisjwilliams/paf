# -----------------------------------------------
# Paf::Cli::App
# -----------------------------------------------
# Description: 
#   The main Application object for command line interface
#   Provides basic command line parsing and configuration file 
#   management
#
#   To use, you will need to provide the names of two classes:
#   1) A Configuration class that takes an optional filename in its constructor
#   2) An object inheriting from Paf::Cli::Command that takes an instance of the Configuration class in its constructor
#
#   The second object will allow you to define your entire command line interface
#
# -----------------------------------------------
# Copyright Chris Williams 2014
# -----------------------------------------------

package Paf::Cli::App;
use warnings;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;

	my $self={};
	bless $self, $class;

    $self->{config_type}=shift;
    $self->{cli_type}=shift;

	return $self;
}

sub parse {
    my $self=shift;

    if( ! defined $self->{parser} ) {

        # -- find alternative config file options
        my @args=@_;
        my $config_file;
        my @filtered=();
        while($args[0]=~/--/) 
        {
            my $arg=shift @args;
            if($arg eq "--config") {
                # -- filter out the config option from the main parse
                $config_file=shift @args;
                if( !defined $config_file ) {
                    print STDERR "configuration file not specified after --config\n";
                    return 1;
                }
                if( ! -e $config_file ) {
                    print STDERR "configuration specified with --config does not exist\n";
                    return 1;
                }
                last;
            }
            else {
                # save for the main parse
                push @filtered, $arg;
            }
        }
        push @filtered, @args;
        
        # -- setup the required objects
        $self->_setup($config_file);

        # -- now we can parse
        return $self->{parser}->parse(@filtered);
    }
}

# -- private methods -------------------------

sub _setup {
    my $self=shift;

    my $config=$self->{config_type}->new(shift);
    my $cli_interface=$self->{cli_type}->new($config);
    $self->{parser}=Paf::Cli::Parser->new($cli_interface);
}

