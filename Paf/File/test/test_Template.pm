# ----------------------------------------
#
# Unit test for the File::Template Class
#
# ----------------------------------------
#

package test_Template;
use Paf::File::Template;
use Paf::File::TempFile;
use File::Sync qw(fsync);
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
    return qw(test_nonExisting test_template);
}

sub test_nonExisting {
    my $self=shift;
    my $file=$self->{tmpdir}."/IamEmpty";
    eval {
        my $tmpl = Paf::File::Template->new($file);
        die("expecting to complain about missing file");
    }
}

sub test_template {
    my $self=shift;
    my $tmp_file=Paf::File::TempFile->new($self->{tmpdir});
    my $file=$tmp_file->filename();
    {
        my $fh=FileHandle->new(">".$file);
        print $fh "line 1\n";
        print $fh "line 2 {{ var1 }}\n";
        print $fh "{{ var2 }} at beginning line 3\n";
        print $fh "and {{ var3 }} middle of line 4\n";
        print $fh "vars {{ var4 }} with {{ var5 }} in line 5\n";
        fsync($fh);
        $fh->close();
    }
    
    my $tmpl = Paf::File::Template->new($file);

    my $output;
    open(my $fh, '>', \$output) or die;
    my $vars= { var1 => "var1"
              , var2 => "var2"
              , var3 => "var3"
              , var4 => "var4"
              , var5 => "var5"
              };
    $tmpl->write($fh, $vars);
    $fh->close();
    die("unexpected output. got:\n \"". $output, "\""), unless $output eq 
        "line 1\nline 2 var1\n".
        "var2 at beginning line 3\nand var3 middle of line 4\n".
        "vars var4 with var5 in line 5\n";

}
