package Mail::Convert::Mbox::ToEml;

use 5.006;
use strict;
use warnings;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Mail::Convert::Mbox::ToEml ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);
our $VERSION = '0.02';


# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

sub new
{
	my $class = shift;
	my $self = {
		InFile=>shift || undef,
		OutDir=>shift || undef,
		isError=>0,
		Error=>undef
		};
	bless $self, $class;
	if(!$self->{InFile} || !$self->{OutDir}) { return; }
	if(!-e $self->{InFile}) { print "file does not exist!\n"; return; }
	if(!-d $self->{OutDir}) { print "output directory is not a directory!\n"; return; }
	if(!-e $self->{OutDir}) { print "output directory does not exist!\n"; return; }
	
	return $self;
	
}

sub CreateEML
{
	my $self=shift;
	my $infile=shift||$self->{InFile};
	my $outDir=shift||$self->{OutDir};
	if($infile) { 
		$self->{InFile}=$infile; 
		if(!-e $self->{InFile}) { print "file does not exist!\n"; return; }
	}
	if($outDir) { 
		$self->{OutDir}=$outDir; 
		if(!-d $self->{OutDir}) { print "output directory is not a directory!\n"; return; }
		if(!-e $self->{OutDir}) { print "output directory does not exist!\n"; return; }
	}
	
	$self->Parse();
	return 1;
}

sub Parse
{
	my $self=shift;
	my @currmail=();
	my $counter=0;
	my $mailcounter=1;
	open(FH, $self->{InFile});
	binmode FH;
	while(<FH>)
	{
		if($_ !~ /^From -/)
		{
			$currmail[$counter] =$_;
			$counter++;
		} else
		{
			
			if(@currmail) {
				$self->WriteToFile($mailcounter,\@currmail);
				$counter=0;
				$mailcounter++;
				undef @currmail;
			}
		}
	}
	$self->WriteToFile($mailcounter,\@currmail) if @currmail;
	close FH;
	return 1;
}

# The subject will be used to generate the file name
sub WriteToFile
{
	my $self=shift;
	my $mailcount=shift;
	my $tmp=shift;
	my @mail=@{$tmp};
	my $subject;
	my $x0d=chr(hex('0x0d'));
	my @temp=grep(/subject:/i, @mail);
	if(@temp != 0) {
		$subject=(split(/subject:/i, $temp[0]))[1];
		
		chomp $subject;
		# remove characters which can not be used in a file name
		$subject =~ s/^\s+//;
		$subject =~ s/\"//g;
		$subject =~ s/\// /g;
		$subject =~ s/\/\//_/g;
		$subject =~ s/\\/_/g;
		$subject =~ s/:/_/g;
		$subject =~ s/'//g;
		$subject =~ s/\?//g;
		$subject =~ s/\<//g;
		$subject =~ s/\>//g;
		$subject =~ s/\|//g;
		$subject =~ s/\*//g;
		$subject =~ s/$x0d$//i;
		
	} else
	{
		$subject="No Subject";
	}
	@mail=$self->checkLines(\@mail);
	my $file = $self->{OutDir} . "/" . $subject . "_" . $mailcount . "_" . GetCurrentTime() . ".eml";
	print "writeing | $subject | to file\n";
	if(open(FHOUT, ">$file")) {
		binmode FHOUT;
		print FHOUT @mail;
		close FHOUT;
		return 1;
	} else {
		print "can not open $file for writeing! $!\n";
		return;
	}
}

# function to check if there are EOF characters and if the from: is correct
# EOF characters are removed.
sub checkLines
{
	my $self=shift;
	my $tmp=shift;
	my @newmail=();
	my $count=0;
	my @mail=@{$tmp};
	my $attachment=0;
	my $attach="Content-Type: application";
	my $attach1="Content-Disposition: attachment";
	my $EOF=chr(hex('0x1A'));
	my $ToVal;
	my @TVal=grep /^To:/i, @mail;
	if($TVal[0]) {
		$ToVal=(split(/:/,$TVal[0]))[1];
		$ToVal=~ s/^\s+//;
	}
	
	foreach (@mail)
	{
		if($_=~/^from:/i)
		{
			$tmp=(split(/from:/i, $_))[1];	# correct the From: line, insert the mail address in To:
			if(length($tmp) <= 2) {
				$_ = "From: " . $ToVal if $ToVal;
			}
			if($_ =~ /^>from/i || $_ =~ /^>from:/i)	# correct the From: line
			{
				$_ = substr($_, 1, length($_)-1);
			}
		}
		if($_ =~ /^$attach/ || $_ =~ /^$attach1/) { $attachment=1; }
		$_ =~ s/$EOF//g if $attachment==1;	# removes EOF's in the line
		push(@newmail, $_);
		$count++;
	}
	return @newmail;
}

sub GetCurrentTime
{
	#my $self=shift;
	return time;
}

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Mail::Convert::Mbox::ToEml - Perl extension to convert Mbox files (from Mozilla and Co) to
Outlook Express eml files.

=head1 SYNOPSIS

  use Mail::Convert::Mbox::ToEml;
  my $EML=Mail::Convert::Mbox::ToEml->new($file, $outdir);
  my $ret=$EML->CreateEML();

=head1 DESCRIPTION

Mail::Convert::Mbox::ToEml is a module to convert Mbox mail folder which used by Mozilla and co.
to single Outlook Express .eml files.

=head1 FUNCTIONS

=over 4

=item new()

The constructor. 
$EML=Mail::Convert::Mbox::ToEml->new($file, $outdir);
The two arguments are:
$file is the MBox file to convert.
$outdir is the directory where the single eml files are stored.

=item CreateEML()

This function do the convertion and writes the .eml file.
The two optional arguments are:
$file is the MBox file to convert.
$outdir is the directory where the single eml files are stored.

The return value is undef if the file or the ouput directory does not exist and 1 on success.
If there was an error to create the eml file it will be printed out and continuewith the next message.

=back

=head1 CREDITS

Many thank's to Ivan from Broobles.com (http://www.broobles.com/imapsize/) the author of the usefull
IMAPSize program for his help and tips to develop this module.


=head2 EXPORT

None by default.


=head1 AUTHOR

Reinhard Pagitsch, E<lt>rpirpag@gmx.atE<gt>

=head1 SEE ALSO

L<perl>.

=cut
