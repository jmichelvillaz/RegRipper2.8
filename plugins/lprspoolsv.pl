#-----------------------------------------------------------
#   lprspoolsv.pl
#   Get information about printers on a printer server; 
#
# copyright 2016 jmvz@protonmail.ch
#-----------------------------------------------------------
package lprspoolsv;
use strict;

my %config = (hive          => "SOFTWARE",
              osmask        => 22,
              hasShortDescr => 1,
              hasDescr      => 0,
              hasRefs       => 0,
              version       => 20160518);

sub getConfig{return %config}

sub getShortDescr {
	return "Get spoolsv's printers, port, location, driver";	
}
sub getDescr{}
sub getRefs {}
sub getHive {return $config{hive};}
sub getVersion {return $config{version};}

my $VERSION = getVersion();

sub pluginmain {
	my $class = shift;
	my $hive = shift;
	::logMsg("Launching lprspoolsv v.".$VERSION);
	::rptMsg("lprspoolsv v.".$VERSION); # banner
    ::rptMsg("(".getHive().") ".getShortDescr()."\n"); # banner
	my $reg = Parse::Win32Registry->new($hive);
	my $root_key = $reg->get_root_key;

	# my $key_path = "ControlSet001\\Control\\Print";
	my $key_path = "Microsoft\\Windows NT\\CurrentVersion\\Print\\Printers";
	my $key;
	if ($key = $root_key->get_subkey($key_path)) {
		::rptMsg($key_path);
		::rptMsg("LastWrite Time: ".gmtime($key->get_timestamp()));
		::rptMsg("");
		::rptMsg("Name;Port;Location;Driver");
		# my @vals = $key->get_list_of_values();
		my @keys = $key->get_list_of_subkeys();
		if (scalar(@keys) > 0) {
			foreach my $k (@keys) {
				my $port;
				my $loc;
				my $drv;
				eval {
					$port = $k->get_value("Port")->get_data();
					$loc  = $k->get_value("Location")->get_data();
					$drv  = $k->get_value("Printer Driver")->get_data();
					::rptMsg($k->get_name().";".$port.";".$loc.";".$drv);
				}
			}
		}
		else {
			::rptMsg($key_path." has no values.");
		}
		::rptMsg("");
		
	}
	else {
		::rptMsg($key_path." not found.");
	}
}
1;
