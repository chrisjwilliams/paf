package test_Command;
use strict;
use Paf::Cli::Command;
use Paf::Cli::TestUtils::TestCommand;
1;

sub new {
    my $class=shift;
    my $self={};
    bless $self, $class;
    
    return $self;
}

sub tests {
    return qw(test_breadcrumb_trail);
}

sub test_breadcrumb_trail {
    my $self=shift;
    
    # single layer - empty name
    my $cmd=Paf::Cli::TestUtils::TestCommand->new();
    my @res=$cmd->breadcrumb_trail();
    die "expecting nothing", if($#res != -1);

    # dual layers
    my $cmd2=Paf::Cli::TestUtils::TestCommand->new("cmd_2");
    $cmd->add_cmds($cmd2);
    @res=$cmd2->breadcrumb_trail();
    die "expecting cmd_2 got $res[0]", if($res[0]->name() ne "cmd_2");
    

    # three layers
    my $cmd3=Paf::Cli::TestUtils::TestCommand->new("cmd_3");
    $cmd2->add_cmds($cmd3);
    @res=$cmd3->breadcrumb_trail();
    die "expecting cmd_2 got $res[0]", if($res[0]->name() ne "cmd_2");
    die "expecting cmd_2 got $res[1]", if($res[1]->name() ne "cmd_3");

    # four layers - missing name in the middle
    my $cmd0=Paf::Cli::TestUtils::TestCommand->new("cmd_0");
    $cmd0->add_cmds($cmd);
    @res=$cmd3->breadcrumb_trail();
    die "expecting cmd_0 got $res[0]", if($res[0]->name() ne "cmd_0");
    die "expecting cmd_2 got $res[1]", if($res[1]->name() ne "cmd_2");
    die "expecting cmd_2 got $res[2]", if($res[2]->name() ne "cmd_3");

}
