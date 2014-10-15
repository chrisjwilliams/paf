# -----------------------------------------------
# Paf::Platform::Report
# -----------------------------------------------
# Description: 
#  Maianitain status information and messages
#
#
# -----------------------------------------------
# Copyright Chris Williams 2008 - 2014
# -----------------------------------------------

package Paf::Platform::Report;
use IO::Tee;
use Paf::Configuration::IniFile;
use Paf::Configuration::NodeFilter;
use Carp;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;

	my $self={};
	bless $self, $class;
    $self->reset();

    # -- where to send console output
    $self->{out}=shift;
    if(! defined $self->{out}) {
        $self->{out}=\*STDOUT;
    }

    # -- map stderr onto our output as well as a local variable
    $self->{error_msg}="";
    open my $fh, '>',  \$self->{error_msg} || die ("unable to open error stream $!");;
    $self->{error_stream}=IO::Tee->new($self->{out}, $fh);
    if( !defined $self->{error_stream} ) {
        die "unable to create error stream\n";
    }

	return $self;
}

# -- construction phase methods

sub output_stream {
    my $self=shift;
    return $self->{out};
}

sub error_stream {
    my $self=shift;
    return $self->{error_stream};
}

sub reset {
    my $self=shift;
    @{$self->{failed}}=();
    @{$self->{executed}}=();
    $self->{current_context}={ cmd => "", result => 0 };
    @{$self->{executed}}=$self->{current_context};
}

sub new_context {
    my $self=shift;
    my $cmd=shift||"unknown";

    $self->close_context();

    $self->{current_context}={ cmd => "$cmd",
                               result => 0 };
    push @{$self->{executed}}, $self->{current_context};
}

sub close_context {
    my $self=shift;

    # -- save stderr to the existing context before updating
    if( $self->{error_msg} ne "" ) {
        my $context=$self->current_context();
        foreach my $line ( split(/\n/, $self->{error_msg} ) ) {
            chomp $line;
            push @{$context->{stderr}}, $line;
        }
        $self->{error_msg}="";
    }
}

#
# indicate that an error has happened
#
sub error {
    my $self=shift;
    my $code=shift||1;
    my $msg=shift;

    my $current_context=$self->current_context();
    $current_context->{result}=$code;
    if( $msg && $msg ne "") {
        push @{$current_context->{stderr}}, $msg;
    }

    push @{$self->{failed}}, $#{$self->{executed}}; 
}

# -- reporting methods

sub has_failed {
    my $self=shift;
    return scalar @{$self->{failed}} > 0;
}

sub current_context {
    my $self=shift;
    return $self->{current_context};
}

sub return_value {
    my $self=shift;
    return $self->current_context()->{result};
}

sub error_messages {
    my $self=shift;
    my $context=shift||$self->current_context();

    my @out;
    if( defined $context->{stderr} ) {
        push @out, @{$context->{stderr}};
    }
    return @out;
}

sub failed {
    my $self=shift;

    my @failed=();
    foreach my $index ( @{$self->{failed}} ) {
        push @failed, $self->{executed}[$index];
    }
    return @failed;
}

sub print {
    my $self=shift;
    my $fh=shift||\*STDOUT;
    my @contexts=@_||@{$self->{executed}};

    foreach my $context ( @contexts ) {
        print $fh $context->{cmd}, "\n";
        
        if($context->{result}) {
            print $fh "\tError: returned value ", $context->{result}, "\n"; 
            foreach my $error ( $self->error_messages($context) ) {
                print $fh "\t", $error,"\n";
            }
        }
    }
}

sub equal {
    my $self=shift;
    my $other=shift;

    return 0, if(scalar @{$self->{executed}} != scalar @{$other->{executed}});
    return 0, if(scalar @{$self->{failed}} != scalar @{$other->{failed}});
    for( my $index = 0; $index <= $#{$self->{executed}}; $index++ ) {
        my $keys=join("",keys %{$self->{executed}[$index]});
        my $other_keys=join("",keys %{$other->{executed}[$index]});
        return 0, if( $keys ne $other_keys);
        foreach my $key ( keys %{$self->{executed}[$index]} ) {
            my $val=$self->{executed}[$index]->{$key};
            my $other_val=$self->{executed}[$index]->{$key};
            next, if $val eq $other_val;
            return 0, if( join("",$val) ne join("",$other_val));
        }
    }
    return 1;
}

# -- persistency

#
# store into a provided Node object
#
sub store {
    my $self=shift;
    my $root=shift||die "no Node provided";

    for( my $index=0; $index <= $#{$self->{executed}}; $index++ ) {
        my $context=$self->{executed}[$index];
        my $cmd=$context->{cmd};
        my $context_node=$root->new_child("context", { cmd => $cmd } );

        foreach my $key ( keys %$context ) {
            next, if $key eq "cmd";
            my $val=$context->{$key};
            if(ref($val) eq "ARRAY" ) {
                my $node=$context_node->new_child("array", { index => $index, name => $key });
                $node->add_content(@$val);
                next;
            }
            my $node=$context_node->new_child("var", { name => $key, value => $context->{$key} });
        }
    }
}

# restore from a Node object
sub restore {
    my $self=shift;
    my $node=shift||return;

    foreach my $section ( $node->search(new Paf::Configuration::NodeFilter("context")) ) {
        my $cmd=$section->meta()->{"cmd"};
        $self->new_context($cmd), if ($cmd ne "");
        foreach my $var ( $section->search(new Paf::Configuration::NodeFilter("var")) ) {
            my $name=$var->meta()->{name};
            my $value=$var->meta()->{value};
            $self->{current_context}->{$name}=$value;
            if( $name eq "result" && $value ne "0" ) {
                push @{$self->{failed}}, $#{$self->{executed}}; 
            }
        }
        foreach my $array_node ( $section->search(new Paf::Configuration::NodeFilter("array")) ) {
            my $index=$array_node->meta()->{index};
            my $name=$array_node->meta()->{name};
            @{$self->{executed}[$index]->{$name}}=@{$array_node->content()};
        }
    }
}

sub serialize {
    my $self=shift;
    my $fh=shift;

    my $writer=Paf::Configuration::XmlWriter->new();
    my $node=Paf::Configuration::Node->new("Report");
    $self->store($node);
    $writer->write($node, $fh);
    $writer->write($node);
}

sub deserialize {
    my $self=shift;
    my $fh=shift;

    require Paf::Configuration::XmlParser;
    my $reader=Paf::Configuration::XmlParser->new();
    my $node=$reader->parse($fh);
    $node=$node->get_child(new Paf::Configuration::NodeFilter("Report")), if(! defined $node->name());
    Paf::Configuration::XmlWriter::dump($node);
    $self->restore($node);
}
