package Paf::Configuration::Manager;
use Paf::File::DirIterator;
use Paf::Configuration::Config;
use Paf::Configuration::Uid;
use strict;
1;

sub new {
    my $class=shift;
    my $self={};
    $self->{factory}=shift;
    $self->{path}=shift;

    bless $self, $class;
    return $self;
}

sub list {
    my $self=shift;
    my $extension=shift || "";

    my @uids=();
    for($self->{path}->paths()) {
        my $it=File::DirIterator->new($_);
        while( my $file=$it->next() ) {
            if( $extension eq "" || $file=~/^(.+)\.$extension$/ ) {
                push @uids, $1;
            }
        }
    }
    return @uids;
}

sub get {
    my $self=shift;
    my $uid=shift;

    my @files=$self->{path}->find($uid);
    return undef, if($#files == 0);

    # return the first match	
    $self->{factory}->create(new Paf::Configuration::Config($files[0]));
    
}
