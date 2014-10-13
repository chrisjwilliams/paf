# ----------------------------------
# class test_NodeFilter
# Description:
#
#-----------------------------------
# Methods:
# new() :
#-----------------------------------


package test_NodeFilter;
use strict;
use FileHandle;
use Paf::Configuration::NodeFilter;
1;

sub new {
    my $class=shift;
    my $self={};
    bless $self, $class;
    return $self;
}

sub tests {
    return qw(test_name_filter test_param_filter);
}

sub test_name_filter {
    my $self=shift;

    my $name="test_name";
    my $node=Paf::Configuration::Node->new($name);

    my $filter=new Paf::Configuration::NodeFilter($name);
    die("expecting to pass"), unless $filter->filter($node);

    $filter=new Paf::Configuration::NodeFilter($name, {});
    die("expecting to pass"), unless $filter->filter($node);

    my $non_matching_filter=new Paf::Configuration::NodeFilter("bad_".$name);
    die("not expecting to pass"), if $non_matching_filter->filter($node);

    $non_matching_filter=new Paf::Configuration::NodeFilter("bad_".$name, {});
    die("not expecting to pass"), if $non_matching_filter->filter($node);
}

sub test_param_filter {
    my $self=shift;

    my $name="test_name";
    my $node=Paf::Configuration::Node->new($name);

    my $param = { a => "b" };

    # -- filter with undef for name
    my $filter=new Paf::Configuration::NodeFilter(undef, $param);
    die("not expecting to pass"), if $filter->filter($node);

    $node=Paf::Configuration::Node->new($name, $param);
    die("expecting to pass"), unless $filter->filter($node);

    $node=Paf::Configuration::Node->new($name, { a => 'c'} );
    die("not expecting to pass"), if $filter->filter($node);

    # -- filter with empty string for name
    $filter=new Paf::Configuration::NodeFilter("", $param);
    die("not expecting to pass"), if $filter->filter($node);

    # -- filter with correct name, incorrect params
    $filter=new Paf::Configuration::NodeFilter($name, $param);
    die("not expecting to pass"), if $filter->filter($node);
}
