package test_OptionalArgument;
use strict;
use Paf::Cli::OptionalArgument;
1;

sub new {
    my $class=shift;
    my $self={};
    bless $self, $class;
    
    return $self;
}

sub tests {
    return qw(test_name_synopsis);
}

sub test_name_synopsis {
    my $self=shift;
    
    # single layer - empty name
    my $arg=Paf::Cli::OptionalArgument->new("test_argument", "some stuff", "2nd line");

    my $name=$arg->name();
    die( "got $name" ) , unless( $name eq "test_argument");

    my $synopsis=join(",",  $arg->synopsis());
    die( "got $synopsis" ) , unless( $synopsis eq "some stuff,2nd line");

    die("expecting optional"), unless $arg->optional();
}
