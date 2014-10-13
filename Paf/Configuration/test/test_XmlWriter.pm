# ----------------------------------
# class test_XmlWriter
# Description:
#
#-----------------------------------
# Methods:
#-----------------------------------


package test_XmlWriter;
use Paf::Configuration::Node;
use Paf::Configuration::XmlWriter;
use strict;
use FileHandle;
1;

sub new {
    my $class=shift;
    my $self={};
    bless $self, $class;
    $self->{testConfigDir}=shift;
    $self->{tmpdir}=shift;
    return $self;
}

sub tests {
    return qw( test_single_named_node test_no_newlines );
}

sub write_node {
    my $self=shift;
    my $writer=shift;
    my $node=shift;
    my $expected=shift;

    my $buffer="";
    open( my $fh, ">", \$buffer ) or die ("unable to open buffer for writing : $!");
    $writer->write($node, $fh);
    if($expected) {
        die("expecting $expected, got '$buffer'"), if($expected ne $buffer);
    }
    return $buffer;
}

sub test_no_newlines {
    my $self=shift;
}

sub test_single_named_node {
    my $self=shift;

    my $node=Paf::Configuration::Node->new("root");
    my $writer=Paf::Configuration::XmlWriter->new();
    my $expected="<root/>\n";
    my $buffer=$self->write_node($writer, $node, $expected);

    # -- meta 
    my $param="a";
    my $value="b";
    $node->meta()->{$param}=$value;
    $expected="<root $param=\"$value\"/>\n";
    $buffer=$self->write_node($writer, $node, $expected);

    # -- content
    my $line1="line1\n";
    my $line2="line2";
    $node->add_content($line1);
    $node->add_content($line2);
    $expected="<root $param=\"$value\">\n$line1$line2\n</root>\n";
    $buffer=$self->write_node($writer, $node, $expected);

    # -- children
    my $wibble=$node->new_child("wibble");
    my $line3="line3";
    $wibble->add_content($line3);
    $expected="<root $param=\"$value\">\n$line1$line2\n <wibble>\n $line3\n </wibble>\n</root>\n";
    $buffer=$self->write_node($writer, $node, $expected);
}

