#!/user/bin/perl
use strict;
use warnings;
use autodie;
use File::Copy;   
use constant {
    FROM_DIR => "/home/perl/fromdir",
    TO_DIR   => "/home/perl/todir",
};

use File::Basename qw( fileparse );
use File::Path qw( make_path );
use File::Spec;

#load the types of file extensions into an array
my $filename='fileextensions.csv';
my @array = do {
    open my $fh, "<", $filename
        or die "could not open $filename: $!";
    <$fh>;
};

my @counter = ();
my %count;

#subroutine to get extension
sub Getextension($) {
    my($file) = @_; 
    my ($ext) = $file =~ /(\.[^.]+)$/;
    return substr $ext,1;   
}

#subroutine to get the right target folder for the extension
sub GetTargetFolder($) {
   my($ext) = @_; 
    foreach(@array) {
        #print "$_\n";
        my @values = split(',', $_);
        if ($values[0] eq  $ext) {
            my($foldername)=$values[1];
            chomp $foldername;
            #print "$values[1]\n";
            return $foldername;
        }
    }
   return 'unknown';
}

#subroutine to create directory if it doesnt exist
sub CreateDirIfNotExist($) {
    my($full_path) = @_; 
    my ( $logfile, $directories ) = fileparse $full_path;
    if ( !$logfile ) {
        $logfile = 'logfile.log';
        $full_path = File::Spec->catfile( $full_path, $logfile );
    }

    if ( !-d $directories ) {
        make_path $directories or die "Failed to create path: $directories";
    }
}
 
 
#Opens FROM_DIR, 
opendir my $dir, FROM_DIR;

print "===========================================================================================================\n"; 
print "Moving Files..\n"; 

# Looping through the directory
while (my $file = readdir $dir) {
    next if ($file eq "." or $file eq "..");
    if (! -d $filename) {
    my $folder=GetTargetFolder(Getextension($file));
    $folder =~ tr/\r\n//d;
    #print $file." moves to ".$folder."\n";
    my $from = FROM_DIR . "/" . $file;
    my $to = TO_DIR . "/" .$folder. "/" . $file;
    print "$file --> $folder\n";
    CreateDirIfNotExist("$to"); 
    push @counter,$folder;
    move $from, $to;
    }
}
print "===========================================================================================================\n"; 
print "Summary\n";  
foreach (@counter) {$count{$_}++;}
foreach (keys %count) {print "Number of $_ files is ".$count{$_}."\n";}

