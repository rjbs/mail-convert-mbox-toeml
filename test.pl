# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 1 };
use Mail::Convert::Mbox::ToEml;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

#my $MBX=Mail::Convert::Mbox::ToEml->new("D:/mail/PO and Portal", "D:/Download/Entwicklung/Delphi/out1");
#my $ret=$MBX->CreateEML();