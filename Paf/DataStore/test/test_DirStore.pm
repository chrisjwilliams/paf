# ----------------------------------
# class test_SearchPath
# Description:
#    Unit tests for the DirStore class
#-----------------------------------

package test_DirStore;
use Paf::DataStore::DirStore;
use Paf::File::TempDir;
use Paf::File::TempFile;
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
    return qw(test_find_empty_schema test_find_get test_add);
}

sub test_find_empty_schema {
    my $self=shift;
    
    my $tmpdir=Paf::File::TempDir->new();
    my $fs=Paf::DataStore::DirStore->new($tmpdir->dir());

    {
        # there are no nodes available
        my $it=$fs->find();
        die ("expecting no results"), unless $it->last();
    }
    # add some files
    my $tmpfile=Paf::File::TempFile->new($tmpdir->dir());
    {
        # the query has no filter
        my $it=$fs->find();
        die ("expecting no results"), unless $it->last();
    }
    {
        # the query has no schema to match
        my $it=$fs->find( { "something" => "else" } );
        die "expecting no results", unless $it->last();
    }
}

sub test_find_get {
    my $self=shift;
    
    my $tmpdir=Paf::File::TempDir->new();
    my $fs=Paf::DataStore::DirStore->new($tmpdir->dir(), "name", "version");
    my $it=$fs->find();
    die ("expecting no results"), unless $it->last();

    # -- setup a suitable hierarcy
    my $name1="name1";
    my $version1="version1";
    my $name2="name2";
    my $version2="version2";
    
    foreach my $name ( $name1, $name2 ) {
        my $dir=$tmpdir->dir()."/$name/";
        mkdir $dir || die ("$! : unable to make dir ", $dir) ;
        foreach my $version ( $version1, $version2 ) {
            my $leaf_dir=$dir.$version;
            mkdir $leaf_dir || die ("$! : unable to make dir ", $leaf_dir) ;
            my $leaf_content=$leaf_dir."/out_of_filter";
            mkdir $leaf_content || die ("$! : unable to make dir ", $leaf_content) ;
        }
    }

    # -- no filter in find
    $it=$fs->find();
    confess "expecting some results, got none", if $it->last();
    my $count=0;
    while( defined (my $uid=$it->next()) )
    {
        $count++;
        die("expecting store_id"), if ($uid->store_id() ne $fs->id());
        my $expected=$tmpdir->dir()."/".$uid->value("name")."/".$uid->value("version");
        my $path=$fs->get($uid);
        die("expecting $expected got $path"), if($expected ne $path);
    }
    die ("expecting 4 entries, got $count"), if ($count != 4);

    # first level filter in find
    $it=$fs->find( { name => $name1} );
    die "expecting results", if $it->last();
    $count=0;
    while( defined (my $uid=$it->next()) )
    {
        $count++;
        die ("unexpected name"), if( $uid->value("name") ne $name1 );
    }
    die ("expecting 2 entries, got $count"), if ($count != 2);
    
    # second level filter in find
    $it=$fs->find( { version => $version1} );
    die "expecting results", if $it->last();
    $count=0;
    while( defined (my $uid=$it->next()) )
    {
        $count++;
        die ("unexpected version"), if( $uid->value("version") ne $version1 );
    }
    die ("expecting 2 entries, got $count"), if ($count != 2);
    
    # first and second level filters in find
    $it=$fs->find( { name => $name2, version => $version1} );
    die "expecting results", if $it->last();
    $count=0;
    while( defined (my $uid=$it->next()) )
    {
        $count++;
        die ("unexpected version"), if( $uid->value("version") ne $version1 );
        die ("unexpected name"), if( $uid->value("name") ne $name2 );
    }
    die ("expecting 1 entries, got $count"), if ($count != 1);
}

sub test_add
{
    my $self=shift;
    my $tmpdir=Paf::File::TempDir->new();
    my $fs=Paf::DataStore::DirStore->new($tmpdir->dir(), "name", "version");
    
    $fs->add( { name => "a_name", version => "a_version" }, undef );
    my $dir=$tmpdir->dir()."/a_name/a_version";
    die( "directory $dir not created as expected" ), if (! -d $dir );
}
