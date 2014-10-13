# -----------------------------------------------
# Paf::Configuration::XmlParser
# -----------------------------------------------
# Description: 
#   Parse an input stream into XML Nodes (DOM)
#
#
# -----------------------------------------------
# Copyright Chris Williams 1996-2003
# -----------------------------------------------

package Paf::Configuration::XmlParser;
use Paf::Configuration::Node;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;

	my $self={};
    $self->{be_verbose}=0;
	bless $self, $class;

	return $self;
}

sub be_verbose {
    my $self=shift;
    $self->{be_verbose}=1;
}

sub verbose {
    my $self=shift;
    if( $self->{be_verbose} ) {
        foreach my $msg ( @_ ) {
            print $msg, "\n";
        }
    }
}

sub parse {
    my $self=shift;
    my $stream=shift;

    my $root=shift||Paf::Configuration::Node->new();
    my $current_node=$root;
    my $context="";
    my $linecount=0;
    my $name;
    my $saved="";
    while(<$stream>) {
        ++$linecount;
        my $charpos=0;
        my $buffer=$_;
        my $char;
        while( defined ($char=substr($buffer,$charpos,1)) && $charpos++ < length $buffer ) {
            $self->verbose("context=$context char=$char saved=$saved\n");
            # -- outside any context
            if($context eq "") {
                next, if $char=~/\s/;
                if($char eq '<') {
                    $context="tag";
                    next;
                }
                print STDERR "illegal character '$char' on line ", $linecount, ":", $charpos+1,"\n";
                return undef;
            }

            # -- inside tag content
            if($context eq "content") {
                if($char eq "\\") {
                    $context = "escaped";
                    next;
                }
                if($char eq "\n") {
                    (my $content)=$saved=~/^\s*(.*)\s*$/; # trim any whitespace off the front/back
                    $current_node->add_content($content);
                    $saved="";
                    next;
                }
                if($char eq '<') {
                    $context="tag";
                    if($saved ne "") { 
                        (my $content)=$saved=~/^\s*(.*)\s*$/; # trim any whitespace off the front/back
                        $current_node->add_content($content);
                        $saved="";
                    }
                    next;
                }
                $saved.=$char;
                next;
            }

            if($context eq "escaped") {
                $saved.=$char;
                $context = "content";
                next;
            }

            # -- tag content
            if($context eq "tag") {
                if($char eq '<') {
                    print STDERR "illegal character '$char' on line ", $linecount, ":", $charpos+1,"\n";
                    return undef;
                }
                if($char eq "/" && $saved eq "") {
                    $context = "endtag";
                    next;
                }
                if($char eq ">" || $char eq " ") {
                    if($saved eq "") {
                        print STDERR "illegal tag ending on line ", $linecount, ":", $charpos+1,"\n";
                        return undef;
                    }
                    my $node;
                    if( $saved=~/\s*(.*)\/\s*$/ ) {
                        # reduced syntax
                        $node=new Paf::Configuration::Node($1);
                        $current_node->add_children($node);
                        $context="content";
                    }
                    else {
                        $node=new Paf::Configuration::Node($saved);
                        $current_node->add_children($node);
                        $current_node=$node;
                        $context="content";
                    }
                    $saved="";
                    $context = "tag_n", if($char eq " ");
                    next;
                }
                next, if $char=~/\s/;
                $saved.=$char;
                next;
            }

            # -- tag params
            if($context eq "tag_n") {
                if($char eq ">") {
                    if(substr($saved, -1) eq "/") {
                        $current_node=$current_node->parent();
                        $context="";
                    }
                    else {
                        $context="content";
                    }
                    $saved="";
                    next;
                }
                if($char eq "=") {
                    if($saved eq "" ) {
                        print STDERR "illegal tag parameter name ", $linecount, ":", $charpos+1,"\n";
                        return undef;
                    }
                    $name=$saved;
                    $saved="";
                    $context="tag_val";
                    next;
                }
                next, if $char=~/\s/;
                $saved.=$char;
                next;
            }

            # -- tag parmaeter value
            if($context eq "tag_val") {
                next, if ($saved eq "" && $char=~/\s/);
                if($char eq '"') {
                    $context="quote";
                    next;
                }
                if($char=~/[\s>]/) {
                    # param end
                    my $node=$current_node;
                    if($char eq ">") {
                        if(substr($saved, -1) eq "/") {
                            chop $saved;
                            $current_node=$current_node->parent();
                            $context="";
                        }
                        else {
                            $context="content";
                        }
                    }
                    else {
                        $context="tag_n";
                    }
                
                    $node->add_meta($name, $saved);
                    $saved="";
                    next;
                }
                $saved.=$char;
                next;
            }

            # -- tag quote
            if($context eq "quote") {
                if($char eq '"') {
                    $context="tag_val";
                    next;
                }
                $saved.=$char;
                next;
            }
                
            # -- endtag content
            if($context eq "endtag") {
                if($char eq '<') {
                    print STDERR "illegal character '$char' on line ", $linecount, ":", $charpos+1,"\n";
                    return undef;
                }
                if($char eq ">") {
                    if($saved ne $current_node->name()) {
                        print STDERR "expecting </", $current_node->name(), "> got </", $saved , "> on line ", $linecount, ":", $charpos+1,"\n";
                        return undef;
                    }
                    $current_node=$current_node->parent();
                    $context="content";
                    $saved="";
                    next;
                }
                next, if $char=~/\s/;
                $saved.=$char;
                next;
            }
        }
    }
    if( $current_node ne $root) {
        print STDERR "reached end of document: expecting </", $current_node->name(), "> on line ", $linecount, "\n";
        return undef;
    }
    return $root;
}

# -- private methods -------------------------
