package test_Parser;
use Paf::Cli::Parser;
use Paf::Cli::TestUtils::TestCommand;
use strict;
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
    return qw( test_empty_cmds test_options test_good test_bad_cmd test_option_good_cmd test_good_cmd_option test_help test_help_cmd test_sub_cmd test_help_sub_cmd);
}

sub test_empty_cmds {
    my $self=shift;
    my $api=Paf::Cli::TestUtils::TestCommand->new();
    my $cli=Paf::Cli::Parser->new($api);
    die "not expecting error", if($cli->parse() != 0);
    die "expecting run to of been called", if $api->{run} != 1;
}

sub test_options {
    my $self=shift;
    my $api=Paf::Cli::TestUtils::TestCommand->new();

    my $option=test_option->new("arg_consuming_option", 2);
    my $option2=test_option->new("other_option");
    $api->add_options($option, $option2);
    my $cli=Paf::Cli::Parser->new($api);

    die "not expecting error", if($cli->parse(qw(-arg_consuming_option arg1 arg2 -other_option)) != 0);
    die "expecting arg_consuming_option to of been called", if $option->{run} != 1;
    die "expecting other_option to of been called", if $option2->{run} != 1;
}

sub test_good {
    my $self=shift;
    my $api=Paf::Cli::TestUtils::TestCommand->new();
    my $good=Paf::Cli::TestUtils::TestCommand->new("good");
    $api->add_cmds($good);

    my $cli=Paf::Cli::Parser->new($api);
    die "not expecting error", if($cli->parse("good") != 0);
    die "expecting good to of been called", if $good->{run} != 1;
    die "not expecting top layer run to of been called", if $api->{run} != 0;
}

sub test_option_good_cmd {
    my $self=shift;
    my $api=Paf::Cli::TestUtils::TestCommand->new();
    my $good=Paf::Cli::TestUtils::TestCommand->new("good");
    $api->add_cmds($good);

    my $option=test_option->new("top_option");
    $api->add_options($option);

    my $cli=Paf::Cli::Parser->new($api);
    die "not expecting error", if($cli->parse("-top_option", "good") != 0);
    die "expecting good_option to of been called", if $option->{run} != 1;
    die "expecting good cmd to of been called", if $good->{run} != 1;

    # unknown option
    die "expecting error", if($cli->parse("-unknown_option", "good") == 0);
    die "not expecting good cmd to of been called after a bad option", if $good->{run} != 1;
}

sub test_good_cmd_option {
    my $self=shift;
    my $api=Paf::Cli::TestUtils::TestCommand->new();
    my $good=Paf::Cli::TestUtils::TestCommand->new("good");
    $api->add_cmds($good);

    my $option=test_option->new("good_option");
    $good->add_options($option);

    my $cli=Paf::Cli::Parser->new($api);
    die "not expecting error", if($cli->parse("good", "-good_option" ) != 0);
    die "expecting good_option to of been called", if $option->{run} != 1;
    die "expecting good cmd to of been called", if $good->{run} != 1;

    # unknown option
    die "expecting error", if($cli->parse("good", "-unknown_option") == 0);
    die "not expecting good cmd to of been called after a bad option", if $good->{run} != 1;
}

sub test_bad_cmd {
    my $self=shift;
    my $api=Paf::Cli::TestUtils::TestCommand->new();
    my $good=Paf::Cli::TestUtils::TestCommand->new();
    $api->add_cmds($good);
    my $cli=Paf::Cli::Parser->new($api);
    die "expecting error", if($cli->parse("bad_cmd") == 0);
    die "not expecting good to of been called", if $good->{run} != 0;

    die "expecting error", if($cli->parse("bad_cmd") == 0);
}

sub test_help_cmd {
    my $self=shift;
    my $api=Paf::Cli::TestUtils::TestCommand->new();
    my $good=Paf::Cli::TestUtils::TestCommand->new("good");
    $api->add_cmds($good);

    my $cli=Paf::Cli::Parser->new($api);
    die "not expecting error", if($cli->parse("good", "help") != 0);
    die "expecting synopsis to of been called", if $good->{synopsis} != 1;
}

sub test_help_sub_cmd {
    my $self=shift;
    my $api=Paf::Cli::TestUtils::TestCommand->new();
    my $good=Paf::Cli::TestUtils::TestCommand->new("good");
    my $good_sub=Paf::Cli::TestUtils::TestCommand->new("sub");

    $api->add_cmds($good);
    $good->add_cmds($good_sub);

    my $cli=Paf::Cli::Parser->new($api);
    die "not expecting error", if($cli->parse("good", "sub", "help") != 0);
    die "expecting synopsis to of been called", if $good_sub->{synopsis} != 1;
}

sub test_help {
    my $self=shift;
    my $api=Paf::Cli::TestUtils::TestCommand->new();
    my $good=Paf::Cli::TestUtils::TestCommand->new("good");
    $api->add_cmds($good);

    my $cli=Paf::Cli::Parser->new($api);
    die "not expecting error", if($cli->parse("help") != 0);
    die "expecting synopsis to of been called", if $api->{synopsis} != 1;
    die "not expecting comand specific synopsis to of been called", if $good->{synopsis} != 0;
}

sub test_sub_cmd {
    my $self=shift;

    my $api=Paf::Cli::TestUtils::TestCommand->new();
    my $good=Paf::Cli::TestUtils::TestCommand->new("good");
    my $good_sub=Paf::Cli::TestUtils::TestCommand->new("sub");

    $api->add_cmds($good);
    $good->add_cmds($good_sub);

    # -- call the sub cmd
    my $cli=Paf::Cli::Parser->new($api);
    die "not expecting error", if($cli->parse("good", "sub") != 0);
    die "expecting good suboption to of been called", if $good_sub->{run} != 1;
    die "not expecting good run to of been called", if $good->{run} == 1;
    die "not expecting good synopsis to of been called", if $good->{synopsis} != 0;

    # -- no sub cmd provided
    die "expecting error", if($cli->parse("good") == 0);
    die "not expecting good suboption to of been called", if $good_sub->{run} != 1;
    die "not expecting good run to of been called", if $good->{run} == 1;
    die "expecting good usage to of been called", if $good->{usage} != 1;
}

package test_option;
use parent "Paf::Cli::Option";

sub new {
    my $class=shift;
    my $self={};
    bless $self, $class;
    $self->{name}=shift;
    $self->{consume}=shift||0;
    $self->{run}=0;
    $self->{synopsis}=0;

    return $self;
}

sub name {
    my $self=shift;
    return $self->{name};
}

sub run {
    my $self=shift;
    my $args=shift;
    $self->{run}++;

    # -- consume some args
    my $count=$self->{consume};
    print $self->{name}, " run(@$args)\n";
    while( $count-- > 0 )
    {
        print "arg=", shift @$args, "\n";
    }
}

sub synopsis {
    my $self=shift;
    $self->{synopsis}++;
    return "help for the ".($self->{name})." option";
}
