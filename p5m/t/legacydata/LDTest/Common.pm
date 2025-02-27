package LDTest::Common;

use File::Temp;
use File::Compare qw();

# This copies DATA contents to a temporary file and returns a handle to 
# that file. DATA is reset and can be read again.
sub copyhandle {
	my $handle = shift;
	my $file = copyhandle_tofile($handle);

	# Open the temp file for reading
	open my $tmp, "$file";
	# And finally return the open handle
	return $tmp;
}
sub copyhandle_tofile {
	my $handle = shift;
	my $start = tell $handle;
	# Get a temp filehandle and the filename
	my ($fh, $filename) = File::Temp::tempfile();

	# Run through the DATA section and copy each line to the temp file
	while (<$handle>) {
		print $fh "$_";
	}

	# Close the temp file
	close $fh or die $!;

	# Reposition filehandle
	seek $handle, $start, 0; 

	return $filename;
}

# The File::Compare implementation returns 1 if there is a difference.
# We want the opposite.
# It also leaves the file handle positions at the EOF, which we also 
# don't want so we fix these things.
sub cmphandles {
	my $h1 = shift;
	my $s1 = tell $h1;
	my $h2 = shift;
	my $s2 = tell $h2;
	my $res = File::Compare::compare($h1,$h2);
	seek $h1, $s1, 0;
	seek $h2, $s2, 0;
	$res?0:1;
}



1;

