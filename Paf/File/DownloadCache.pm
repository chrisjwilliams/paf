# -----------------------------------------------
# Paf::File::DownloadCache
# -----------------------------------------------
# Description: 
#   Mainatain a directory location for the download of
#   files.
#
#
# -----------------------------------------------
# Copyright Chris Williams 2003
# -----------------------------------------------

package Paf::File::DownloadCache;
use File::Basename;
use File::Path;
use LWP::UserAgent;
use FileHandle;
use warnings;
use strict;
1;

# -- initialisation

sub new {
	my $class=shift;
    my $location=shift || die "cache requires a location";

    if( ! -d $location ) {
        mkdir $location or die "unable to make dir $location";
    }

	my $self={};
	bless $self, $class;
    $self->{location}=$location;
    
    $self->{agent}=LWP::UserAgent->new();

    # -- default turn of ssl verification
    # $self->{agent}->ssl_opts( { verify_hostname => 0, SSL_verify_mode => 0x00 } );

	return $self;
}

sub agent {
    my $self=shift;
    return $self->{agent};
}

sub get {
    my $self=shift;
    my $uri=shift;
    my $filename=$self->_filename($uri, shift);;

    (my $f, my $dirname)=fileparse($filename);

    File::Path::mkpath $dirname or die "unable to make directory $dirname: $!";

    if( ! -f $filename ) {
        # -- download the uri resource (modified from https://metacpan.org/pod/lwpcook)
        my $bytes_received=0;
        my $expected_length;
        my $req=HTTP::Request->new( GET => $uri );

        my $fh=FileHandle->new(">".$filename) or die ("unable to write to file $filename: $!");
        print "Downloading ", substr($uri, 0,76), "...\n";
        my $response=$self->{agent}->request( $req, 
            sub {
                my($chunk, $res) = @_;
                $bytes_received += length($chunk);
                unless (defined $expected_length) {
                    $expected_length = $res->content_length || 0;
                 }
                 if ($expected_length) {
                    _progress_bar($bytes_received, $expected_length)
                 }
                 print $fh $chunk;
            }
        );
        if( ! $response->is_success() ) {
            print STDERR "failed to download '$uri' : ", $response->status_line, "\n";
            return undef;
        }
    }
    return $filename;
}

sub remove {
    my $self=shift;
    my $uri=shift;
    my $filename=$self->_filename($uri, @_);;

    if( -f $filename ) {
        unlink $filename;
    }
}

# -- private methods -------------------------

sub _filename {
    my $self=shift;
    my $uri=shift || die ("empty uri");;
    my $filename=shift;

    if( ! defined $filename ) {
        # -- determine filename from uri
        my $ul=new URI($uri);
        $filename=$ul->path;
        if( ! defined $filename || $filename eq "" ) {
            die ("DownloadCache: could not determine a suitable file for $uri");
        }
    }
    $filename=$self->{location}."$filename";
}

# wget-style. routine by tachyon
# at http://tachyon.perlmonk.org/
sub _progress_bar {
    my ( $got, $total, $width, $char ) = @_;
    $width ||= 25; $char ||= '=';
    my $num_width = length $total;
    my $bar = sprintf "|%-${width}s| Got %${num_width}s bytes of %s (%.2f%%)\r", 
        $char x (($width-1)*$got/$total). '>', 
        $got, $total, 100*$got/+$total;
    print $bar;
}
