package Paf::Configuration::Config;
use strict;
1;

sub new {
    my $class=shift;
    my $self={};
    $self->{file}=shift;
    $self->{node}=shift;

    bless $self, $class;

    return $self;
}
