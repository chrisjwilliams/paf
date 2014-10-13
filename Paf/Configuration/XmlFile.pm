# -----------------------------------------------
# Paf::Configuration::XmlFile
# -----------------------------------------------
# Description: 
#   Read/Write a file interpreting it as an XML like document
#   Note newlines are not ignored inside a tag context
#
# -----------------------------------------------
# Copyright Chris Williams 2003
# -----------------------------------------------

package Paf::Configuration::XmlFile;
use Paf::Configuration::XmlWriter;
use Paf::Configuration::XmlParser;
use FileHandle;
use Carp;
use warnings;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;

	my $self={};
	bless $self, $class;
    $self->{filename}=shift|| die "expecting a filename";
    $self->{root}=Paf::Configuration::Node->new();
    $self->{writer}=Paf::Configuration::XmlWriter->new();
    $self->{parser}=Paf::Configuration::XmlParser->new();
    $self->be_verbose(@_);

    $self->reload();

	return $self;
}

sub be_verbose {
    my $self=shift;
    if( defined $_[0] ) {
        $self->{be_verbose}=shift;
        $self->{parser}->be_verbose(@_);
    }
}

sub verbose {
    my $self=shift;
    if( $self->{be_verbose} ) {
        foreach my $msg ( @_ ) {
            print $msg, "\n";
        }
    }
}

sub save {
    my $self=shift;
    my $filename=shift||$self->{filename};

    my $fh=FileHandle->new(">".$filename) or die "unable to open $filename : $!";
    $self->verbose("saving to $filename");
    $self->{writer}->write($self->{root}, $fh);
}

sub reload {
    my $self=shift;

    $self->{root}->reset();
    if( -f $self->{filename} ) {
        my $filename=$self->{filename};
        $self->verbose("reading from $filename");
        my $fh=FileHandle->new("<".$filename) or die "unable to open $filename : $!";
        my $node=$self->{parser}->parse($fh, $self->{root});
        if( !defined $node ) {
            carp "parse error in $filename\n"
        }
    }
}

sub root {
    my $self=shift;
    return $self->{root};
}

# -- private methods -------------------------

