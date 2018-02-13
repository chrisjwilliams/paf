#!/usr/bin/perl -I .. -w
#
# Perl tester executable example
# Will pick up tests defined in any modules of the form
# test_NAME.pm
# each module must have a tests() method to instruct the launcher
# of the methods to call for each test
#
use FindBin;
use lib "$FindBin::RealBin/../..";

use strict;
use TestSuite::TestLaunch;

my $tests=TestSuite::TestLaunch->new($FindBin::RealBin);
exit $tests->run(@ARGV);
