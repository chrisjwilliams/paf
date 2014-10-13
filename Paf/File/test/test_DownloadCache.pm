# ----------------------------------
# class test_DownloadCache
# Description:
#
#-----------------------------------
# Methods:
# new() :
#-----------------------------------


package test_DownloadCache;
use strict;
use FileHandle;
use Paf::File::DownloadCache;
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
    return qw( test_filename test_get_file );
}

sub test_filename {
    my $self=shift;

    my $dir=$self->{tmpdir}."/cache";
    my $cache=Paf::File::DownloadCache->new($dir);

    # -- incomplete
    my $url="http://";
    my $filename;
    
    eval { $filename=$cache->_filename($url); };
    if( ! $@ ) {
        die("expecting throw, got $filename");
    }

    # -- complete single level
    $url="http://someplace.org/fred.txt";
    $filename=$cache->_filename($url);
    my $expected=$dir."/fred.txt";
    die("expecting $expected, got $filename"), unless $expected eq $filename;

    # -- complete dual level
    $url="http://someplace.org/some_location/fred.txt";
    $filename=$cache->_filename($url);
    $expected=$dir."/some_location/fred.txt";
    die("expecting $expected, got $filename"), unless $expected eq $filename;
}

sub test_get_file {
    my $self=shift;
    my $dir=$self->{tmpdir}."/cache";
    my $cache=Paf::File::DownloadCache->new($dir);
    die("expecting cache dir to exist"), unless -d $dir;

    # -- create a file to download
    my $testfile=$self->{tmpdir}."/testfile";
    $self->_touch($testfile);

    # -- good url
    my $url="file:$testfile";
    my $filename=$cache->get($url);
    die("expecting file in cache got undef"), unless $filename;
    die("expecting file in cache got $filename"), unless $filename=~/^$dir/;
    die("expecting file $filename to exist in cache"), unless -f $filename;

    # -- remove good url
    $cache->remove($url);
    die("not expecting file $filename in cache"), if -f $filename;
}

sub _touch {
    my $self=shift;
    my $file=shift;
    my $fh=FileHandle->new(">".$file) or die("error creating file $file : $!");
    print $fh "Filename: $file\n";
    $fh->close();
    return $file;
}
