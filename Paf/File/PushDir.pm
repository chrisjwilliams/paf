# -----------------------------------------------
# Paf::File::PushDir
# -----------------------------------------------
# Description: 
#   push and pop directories just like pushd popd
#   will pop on destruction
#
#
# -----------------------------------------------
# Copyright Chris Williams 2003
# -----------------------------------------------

package Paf::File::PushDir;
use Cwd;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;

	my $self={};
	bless $self, $class;

    @{$self->{dirstack}}=();

    if(@_) {
        $self->push(@_);
    }

	return $self;
}

#
# save the current dir on the stack and change to the new dir
#
sub push {
    my $self=shift;
    my $dir=shift;

    push @{$self->{dirstack}}, Cwd::cwd();
    if( -d $dir ) {
        chdir $dir;
    }
}

#
# change to the directory popped off the stack
#
sub pop {
    my $self=shift;
    my $dir=pop @{$self->{dirstack}};
    chdir $dir, if( -d $dir );
    return $dir;
}

# -- private methods -------------------------

sub DESTROY {
    my $self=shift;
    while (@{$self->{dirstack}}) {
        $self->pop();
    }
}
