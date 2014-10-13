# ----------------------------------
# class test_XmlParser
# Description:
#
#-----------------------------------
# Methods:
# new() :
#-----------------------------------


package test_XmlParser;
use strict;
use FileHandle;
use Paf::Configuration::XmlParser;
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
    return qw(test_parse_tag_not_closed test_parse_simple test_meta test_parse_multi_children_at_same_level test_no_root test_offset test_content test_parse_reduced_syntax);
}

sub test_parse_tag_not_closed {
    my $self=shift;

    my $xml="<a><b></b>";
    my $node=$self->run_parser($xml);
    die("expecting parse error"), if $node;
    
}

sub test_parse_simple {
    my $self=shift;

    my $xml="<a><b></b></a>";
    my $node=$self->run_parser($xml);
    die("not expecting parse error"), unless $node;
    ($node)=$node->children();

    my $name=$node->name();
    die("expecting node name 'a', got $name"), if( $name ne 'a');
    (my $node2)=$node->children();
    $name=$node2->name();
    die("expecting node name 'b', got $name"), if( $name ne 'b');
}

sub test_parse_reduced_syntax {
    my $self=shift;

    my $xml="<a><b/></a>";
    my $node=$self->run_parser($xml);
    die("not expecting parse error"), unless $node;
    ($node)=$node->children();

    my $name=$node->name();
    die("expecting node name 'a', got $name"), if( $name ne 'a');
    (my $node2)=$node->children();
    $name=$node2->name();
    die("expecting node name 'b', got $name"), if( $name ne 'b');
}

sub test_content {
    my $self=shift;

    # -- with content
    my $xml="<a>a_content_1<b>b_content_1\nb_content_2\n</b>a_content=\"2\"</a>";
    my $node=$self->run_parser($xml);
    ($node)=$node->children();
    my $content=join(",",@{$node->content()});
    my $expected_content="a_content_1,a_content=\"2\"";
    die("expecting content $expected_content, got $content"), if( $content ne $expected_content);

    (my $node2)=$node->children();
    $content=join(",",@{$node2->content()});
    $expected_content="b_content_1,b_content_2";
    die("expecting content $expected_content, got $content"), if( $content ne $expected_content);
}

sub test_offset {
    my $self=shift;

    my $xml=" <a>\n <b>\n </b>\n </a>";
    my $node=$self->run_parser($xml);
    die("not expecting parse error"), unless $node;
    ($node)=$node->children();

    my $name=$node->name();
    die("expecting node name 'a', got $name"), if( $name ne 'a');
    (my $node2)=$node->children();
    $name=$node2->name();
    die("expecting node name 'b', got $name"), if( $name ne 'b');
}

sub test_no_root {
    my $self=shift;
    my $xml="<a></a><b></b><c><d></d></c>";
    my $node=$self->run_parser($xml);
    die("not expecting parse error"), unless $node;
    my $name=$node->name();
    die("not expecting node name ,  got $name"), if($name);

    (my $node2, my $node3, my $node4)=$node->children();
    $name=$node2->name();
    die("expecting node name 'a', got $name"), if( $name ne 'a');
    $name=$node3->name();
    die("expecting node name 'b', got $name"), if( $name ne 'b');
    $name=$node4->name();
    die("expecting node name 'c', got $name"), if( $name ne 'c');
}

sub test_parse_multi_children_at_same_level {
    my $self=shift;
    my $xml="<a><b></b><c><d></d></c></a>";
    my $node=$self->run_parser($xml);
    ($node)=$node->children();
    die("not expecting parse error"), unless $node;

    my $name=$node->name();
    die("expecting node name 'a', got $name"), if( $name ne 'a');
    (my $node2, my $node3)=$node->children();
    $name=$node2->name();
    die("expecting node name 'b', got $name"), if( $name ne 'b');
    $name=$node3->name();
    die("expecting node name 'c', got $name"), if( $name ne 'c');
}

sub test_meta {
    my $self=shift;

    my $xml='<a var1="1.0.avalue" ><b var1="value1" var2="value2"/></a>';
    my $node=$self->run_parser($xml);
    die("not expecting parse error"), unless $node;
    ($node)=$node->children();

    my $name=$node->name();
    die("expecting node name 'a', got $name"), if( $name ne 'a');
    my $val=$node->meta()->{var1};
    die("expecting value '1.0.avalue', got $val"), if( $val ne '1.0.avalue');

    (my $node2)=$node->children();
    $name=$node2->name();
    die("expecting node name 'b', got $name"), if( $name ne 'b');

    $val=$node2->meta()->{var1};
    die("expecting value 'value1', got $val"), if( $val ne 'value1');
    $val=$node2->meta()->{var2};
    die("expecting value 'value2', got $val"), if( $val ne 'value2');
}

sub run_parser {
    my $self=shift;
    my $xml=shift;

    open( my $stream, '<', \$xml) or die "can't open stream $!\n";;
    my $parser=Paf::Configuration::XmlParser->new();
    return $parser->parse($stream);
}
