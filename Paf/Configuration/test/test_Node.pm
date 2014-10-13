# ----------------------------------
# class test_Node
# Description:
#
#-----------------------------------
# Methods:
# new() :
#-----------------------------------


package test_Node;
use strict;
use FileHandle;
use Paf::Configuration::Node;
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
    return qw(test_node_init test_search_node);
}

sub test_search_node {
    my $self=shift;

    # -- single node, good filter
    my @filters=( new Paf::Configuration::NodeFilter("test_name") );
    my $root=Paf::Configuration::Node->new("test_name");
    my @found=$root->_search_node($root, @filters);
    die "expected to find an element got @found", if(scalar @found != 1);

    # -- single node, non-matching filter
    @found=$root->_search_node($root,  new Paf::Configuration::NodeFilter("bad_name") );
    die "expected not to find an element", if(@found);

    # -- multi-depth, single level depth matching filter
    my $level1=$root->new_child("level_1");
    @found=$root->_search_node($root, @filters);
    die "expected to find an element", if(scalar @found != 1);

    # -- multi-depth, non-matching name but depth matching filter
    @found=$root->_search_node($root, @filters, new Paf::Configuration::NodeFilter("bad_filter") );
    die "expected not to find an element", if(@found);

    # -- multi-depth, matching level depth matching filter
    push @filters, new Paf::Configuration::NodeFilter("level_1");
    @found=$root->_search_node($root, @filters);
    die "expected to find an element", if(scalar @found != 1);

    # -- multi-depth, matching level depth greater matching filter
    push @filters, new Paf::Configuration::NodeFilter("level_99");
    @found=$root->_search_node($root, @filters);
    die "expected not to find an element", if(@found);

}

sub test_node_init {
    my $node;
    $node=Paf::Configuration::Node->new();
    die("not expecting name, got ", $node->name()), if $node->name();
    die "no children expected", if($node->children());
    die "no meta expected", if(keys %{$node->meta()});

    $node=Paf::Configuration::Node->new("test_name");
    die("expecting test_name, got ", $node->name()), unless "test_name" eq $node->name();
    die "no children expected", if($node->children());
    die "no meta expected", if(keys %{$node->meta()});
    die "no content expected", if(scalar @{$node->content()});

    $node=Paf::Configuration::Node->new("test_name", { a => "b"} );
    die "no children expected", if($node->children());
    die "no content expected", if(scalar @{$node->content()});
    die "meta expected", unless(scalar keys %{$node->meta()} == 1);
    die "meta a expected", unless ($node->meta()->{a} eq "b");

    # -- add content
    $node->add_content("line1");
    my $string=join(",",@{$node->content()});
    die "content expected got $string", unless($string eq "line1");
    $node->add_content("line2\n");
    $string=join(",",@{$node->content()});
    die "content expected got $string", unless($string eq "line1,line2\n");
    $node->clear_content();
    die "no content expected", if(scalar @{$node->content()});
}
