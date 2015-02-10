use 5.018002;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Paf',
    VERSION_FROM      => 'Paf/Paf.pm', # finds $VERSION
    PREREQ_PM         => { "IO::Tee" => 0, 
                           "Mozilla::CA" => 0, 
                           "LWP::UserAgent" => 0 
                         }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'Paf/Paf.pm', # retrieve abstract from module
       AUTHOR         => 'Chris Williams<chrisjwilliams @ github>') : ()),
);
