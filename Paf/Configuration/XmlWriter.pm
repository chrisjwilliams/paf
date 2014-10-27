# -----------------------------------------------
# Paf::Configuration::XmlWriter
# -----------------------------------------------
# Description: 
#    Write out a Config::Node represntation tree as an XML document
#
#
# -----------------------------------------------
# Copyright Chris Williams 2003
# -----------------------------------------------

package Paf::Configuration::XmlWriter;
use strict;
1;

# -- initialisation

sub dump {
    my $node=shift;
    my $writer=Paf::Configuration::XmlWriter->new();
    $writer->write($node, \*STDOUT)
}

sub new {
	my $class=shift;

	my $self={};
	bless $self, $class;

    $self->{nl}="\n";
    $self->{indent}=0;

	return $self;
}

sub no_newline_seperator {
    my $self=shift;
    $self->{nl}="";
}

sub write {
    my $self=shift;
    my $node=shift||return;
    my $stream=shift|| \*STDOUT;
    my $indent=shift||0;

    my $space = ' ' x (($self->{nl} eq "")?0:$indent);

    if( $node->name() ) {
        print $stream $space, "<".$node->name();
        foreach my $key ( keys %{$node->meta()} ) {
            print $stream " ", $key, "=", '"', $node->meta()->{$key}, '"';
        }
        if( (scalar @{$node->content()} == 0 && scalar $node->children() == 0 ) ) {
            print $stream "/>", $self->{nl};
            return;
        }
        print $stream ">", $self->{nl};
    }

    # content preserves its newline characters
    if( scalar @{$node->content()} != 0 ) {
        foreach my $line ( @{$node->content()} ) {
            chomp $line;
            print $stream $space, $line, "\n";
        }
    }

    # dump out any children
    foreach my $child ( $node->children() ) {
        if( $node->name() ) {
            $self->write($child, $stream, $indent + 1);
        }
        else {
            $self->write($child, $stream, $indent);
        }
    }

    # end tag
    if( $node->name() ) {
        print $stream $space, "</".$node->name().">", $self->{nl};
    }
    
}

# -- private methods -------------------------

