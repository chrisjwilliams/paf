# ----------------------------------------
#
# Unit test for the FileIterator Class
#
# ----------------------------------------
#


package test_DirIterator;
use Paf::File::DirIterator;
use File::Sync qw(sync);
use FileHandle;
use Carp;
use strict;
1;

sub new {
    my $class=shift;
    my $self={};
    bless $self,$class;
    $self->{testConfigDir}=shift;
    $self->{tmpdir}=shift;
    return $self;
}

sub tests
{
    return qw(test_nonExistingDir test_emptyDir test_iterate test_relative);
}

sub test_nonExistingDir {
    my $self=shift;
    my $dir=$self->{tmpdir}."/IdoNotExist";
    my $it=Paf::File::DirIterator->new($dir);
    die "expecting undefined", if ( defined $it->next() );
}

sub test_emptyDir {
    my $self=shift;
    my $dir=$self->{tmpdir}."/IamEmpty";
    mkdir $dir or die "unable to create $dir :$!";
    my $it=Paf::File::DirIterator->new($dir);
    die "expecting undefined", if ( defined $it->next() );
}

sub test_iterate {
    my $self=shift;

    my @files;
    my $dir=$self->{tmpdir}."/IamFull";
    mkdir $dir or die "unable to create $dir :$!";
    push @files, $self->_touch($dir."/somefile1");
    push @files, $self->_touch($dir."/somefile2");
    my $dir2=$self->{tmpdir}."/IamFull/dir2";
    mkdir $dir2  or die "unable to create $dir2 :$!";
    push @files, $self->_touch($dir2."/testfile1");
    push @files, $self->_touch($dir2."/testfile2");
    my $dir3=$self->{tmpdir}."/IamFull/EmptyDir";
    mkdir $dir3  or die "unable to create $dir3 :$!";
    my $dir4=$self->{tmpdir}."/IamFull/dir2/depth_3";
    push @files, $self->_touch($dir."/somefile_at_depth3");
    mkdir $dir4  or die "unable to create $dir4 :$!";
    my $dir5=$self->{tmpdir}."/IamFull/dir2/depth_3/depth_4";
    mkdir $dir5  or die "unable to create $dir5 :$!";
    @files=sort( @files );

    sync();
    my $it=Paf::File::DirIterator->new($dir);
    $self->_testCommon($it, @files );

    print "---------------------\n";
    my $it2=Paf::File::DirIterator->new($dir);
    $it2->includeDirs();
    $self->_testCommon($it2, sort( $dir2, $dir3, $dir4, $dir5, @files ));

    print "---------------------\n";
    my $it3=Paf::File::DirIterator->new($dir);
    $it3->includeDirs();
    $it3->setDepth(2);
    $self->_testCommon($it3, sort( $dir2, $dir3, $dir4, @files ));

    print "---------------------\n";
    my $it4=Paf::File::DirIterator->new($dir);
    $it4->includeDirs();
    $it4->setDepth(0);
    $self->_testCommon($it4, ());
}

sub test_relative {
    my $self=shift;

    my @files;
    my $dir=$self->{tmpdir}."/IamFull/relative";
    mkdir $dir or die "unable to create $dir :$!";
    $self->_touch($dir."/somefile1");
    $self->_touch($dir."/somefile2");
    my $dir2=$self->{tmpdir}."/IamFull/relative/dir2";
    mkdir $dir2  or die "unable to create $dir2 :$!";
    @files=sort( qw(somefile1 somefile2 dir2) );

    sync();
    my $it=Paf::File::DirIterator->new($dir);
    $it->includeDirs();
    $it->relativePath();
    $self->_testCommon($it, @files );
}

sub _testCommon {
    my $self=shift;
    my $it=shift;
    my @files=@_;

    my @rec=();
    my $count=-1;
    my $i;
    while( defined ($i=$it->next()) ) {
        push @rec, $i;
        $count++;
        if( $count > $#files ) {
            confess "more files returned than expected : got @rec";
        }
    }
    confess "not enough files found got : @rec", if ( $#rec != $#files );
    @rec=sort(@rec);
    foreach my $f ( @rec )
    {
        die ( "unexpected file $f - expecting $files[0]" ), if $f ne (shift @files);
    }   
    return @rec;
}

sub _touch {
    my $self=shift;
    my $file=shift;
    my $fh=FileHandle->new(">".$file) or die("error creating file $file : $!");
    print $fh "Filename: $file\n";
    $fh->close();
    return $file;
}
