# -----------------------------------------------
# Paf::DataStore::DirStore
# -----------------------------------------------
# Description: 
#
#
#
# -----------------------------------------------
# Copyright Chris Williams 2003
# -----------------------------------------------

package Paf::DataStore::DirStore;
use parent "Paf::DataStore::DataStore";
use Paf::DataStore::DirStoreUid;
use Paf::DataStore::UidIterator;
use Paf::File::DirectoryContent;
use Carp;
use strict;
1;

# -- initialisation

sub new {
    my $class=shift;
    my $location=shift || carp ("DirStore constructed without a location");;
    my $self=$class->SUPER::new($location);
    
    $self->{dir}=$location;;
    push @{$self->{schema}}, @_;

    bless $self, $class;
    return $self;
}

sub find {
    my $self=shift;
    my $query=shift;

    # -- map the query to the local schema and generate the directory list to search
    my @paths=($self->{dir});
    foreach my $node ( @{$self->{schema}} ) {
        my @dirs=();
        if( defined $query->{$node} )
        {
            foreach my $path (@paths) {
                my $dir=$path."/".$query->{$node};
                if( -e $dir ) {
                    push @dirs, $path."/".$query->{$node};
                }
            }
        }
        else {
            # -- no restrictions so take all options
            foreach my $path (@paths) {
                if( -d $path ) {
                    my $content=new Paf::File::DirectoryContent($path, 1);
                    foreach my $node ( $content->dirs(), $content->files() )
                    {
                        push @dirs, $path."/".$node;
                    }
                }
            }
        }
        @paths=@dirs;
    }

    # -- we now have a list of nodes (dirs or files) in our directory tree corresponding to the schema.
    my @uids=();
    foreach my $path ( @paths )
    {
        next, if $path eq $self->{dir};
        # workout the object identification keys 
        my $key={};
        my @parts=split("/", $path);
        foreach my $node ( reverse @{$self->{schema}} ) {
            $key->{$node}=pop @parts;
        }
        
        push @uids, new Paf::DataStore::DirStoreUid($self->id(), $key);
    }

    return new Paf::DataStore::UidIterator(@uids);
}

sub add {
    my $self=shift;
    my $id=shift;

    # verify id is complete
    my @paths=();
    foreach my $node ( @{$self->{schema}} ) {
        carp ("missing \"$node\" in identifier"), if( ! defined $id->{$node} );
        push @paths, $id->{$node};
    }

    # create the index entry
    my $path=$self->{dir};
    foreach my $dir ( @paths )
    {
        $path.="/".$dir;
        mkdir $path || die "unable to create directory $path : $!";
    }
    my $uid=new Paf::DataStore::DirStoreUid($self->id(), $id);
    return $uid;
}

sub get {
    my $self=shift;
    my $uid=shift;
    if($uid->store_id() eq $self->{id})
    {
        my $path=$self->{dir};
        foreach my $node ( @{$self->{schema}} ) {
            my $dir=$uid->value($node);
            return undef, if( !defined $dir );
            $path.="/".$dir;
        }
        return $path;
    }
    return undef;
}

# -- private methods -------------------------

