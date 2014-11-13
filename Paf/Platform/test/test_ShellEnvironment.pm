# ----------------------------------
# class test_ShellEnvironment
# Description:
#    Unit tests for the ShellEnvironment class
#-----------------------------------

package test_ShellEnvironment;
use Paf::Platform::ShellEnvironment;
use Carp;
use warnings;
use strict;
1;

sub new {
    my $class=shift;
    my $self={};
    bless $self, $class;
    return $self;
}

sub tests {
    return qw(test_env);
}

sub test_env {
    my $self=shift;

    my $e1_name="Test_EnvironemntVariableName1";
    my $e1_value="Test_EnvironemntValue1";
    my $e1_value_2="some_new_value";
    my $e2_name="Test_EnvironemntVariableName2";
    my $e2_value="Test_EnvironemntValue2";

    # empty env passed
    {
        my $hash =  {};
        my $e = new Paf::Platform::ShellEnvironment( $hash );
        die("not expecting defined env variable $e1_name"), if defined $ENV{$e1_name};
    }
    die("not expecting defined env variable $e1_name"), if defined $ENV{$e1_name};

    # env passed
    {
        my $hash = { $e1_name => $e1_value };
        my $e = new Paf::Platform::ShellEnvironment( $hash );
        die("expecting defined env variable $e1_name"), unless defined $ENV{$e1_name};
        die("expecting env variable $e1_name == $e1_value got ", $ENV{$e1_name}), unless $ENV{$e1_name} eq $e1_value;
    }
    die("not expecting defined env variable $e1_name"), if defined $ENV{$e1_name};

    # envreferencing env passed
    {
        $ENV{$e1_name}=$e1_value;
        my $hash = { $e1_name => $e1_value_2."\${$e1_name}" };
        my $e = new Paf::Platform::ShellEnvironment( $hash );
        die("expecting defined env variable $e1_name"), unless defined $ENV{$e1_name};
        die("expecting env variable $e1_name == $e1_value_2$e1_value got ", $ENV{$e1_name}), unless $ENV{$e1_name} eq $e1_value_2.$e1_value;
    }
    die("expecting defined env variable $e1_name"), unless defined $ENV{$e1_name};
    die("expecting env variable $e1_name == $e1_value got ", $ENV{$e1_name}), unless $ENV{$e1_name} eq $e1_value;
    delete $ENV{$e1_name};

    # stacked envs
    {
        my $hash1 = { $e1_name => $e1_value };
        my $hash2 = { $e2_name => $e2_value };
        my $hash3 = { $e1_name => $e1_value_2, $e2_name => $e2_value };
        my $e = new Paf::Platform::ShellEnvironment( $hash1 );
        {
            my $e = new Paf::Platform::ShellEnvironment( $hash2 );
            die("expecting defined env variable $e1_name"), unless defined $ENV{$e1_name};
            die("expecting env variable $e1_name == $e1_value"), unless $ENV{$e1_name} eq $e1_value;
            die("expecting defined env variable $e2_name"), unless defined $ENV{$e2_name};
            die("expecting env variable $e2_name == $e2_value"), unless $ENV{$e2_name} eq $e2_value;
            {
                my $e = new Paf::Platform::ShellEnvironment( $hash3 );
                die("expecting defined env variable $e1_name"), unless defined $ENV{$e1_name};
                die("expecting env variable $e1_name == $e1_value_2"), unless $ENV{$e1_name} eq $e1_value_2;
                die("expecting defined env variable $e2_name"), unless defined $ENV{$e2_name};
                die("expecting env variable $e2_name == $e2_value"), unless $ENV{$e2_name} eq $e2_value;
            }
        }
    }
    die("not expecting defined env variable $e1_name"), if defined $ENV{$e1_name};
    die("not expecting defined env variable $e1_name"), if defined $ENV{$e2_name};
    
}
