# -----------------------------------------------
# Paf::File::Template
# -----------------------------------------------
# Description: 
#   Use a template file to generate output, subsitituting set variables
#   Inside the template variables should be marked with {{ variable_name }}
#
# Interface:
# new(filename) : create a new Template object based on a template file provided
# write(output_filehandle, variable_hash) : write the template to the output_filehandle
#                                           subsitituting values for the vatriable_hash.
#
# -----------------------------------------------
# Copyright Chris Williams 2022
# -----------------------------------------------
package Paf::File::Template;

use FileHandle;
use strict;
1;

sub new {
    my $class=shift;

    my $self={};
    bless $self, $class;
    $self->{template_filename}=shift;
    return $self;
}

sub _line {
    my $self=shift;
    my $line=shift;
    my $vars=shift||die("no vars provided");

    if( $line=~m/(.*?)\{\{\s*(.*?)\s*\}\}(.*)/s ) {
        my $pre=$1;
        my $m=$2;
        if(defined $vars->{$m}) {
            $m=$vars->{$2};
        }
        $line = $pre.$m.$self->_line($3, $vars);
    }
    return $line;
}

sub write {
    my $self=shift;
    my $fh=shift || die("must provide a filehandle to write to");
    my $vars=shift||{};

    my $fin = FileHandle->new("<".$self->{template_filename});
    while( my $line = <$fin> ) {
        print $fh $self->_line($line, $vars);
    }
}
