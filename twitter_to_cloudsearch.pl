#!/usr/bin/perl

use JSON;
use Date::Parse;
use POSIX;

my $id=1;
print "[\n";
while (<STDIN>) {
	chomp;
	my %obj=();
	my $ref=decode_json($_);
	$time = str2time($$ref{created_at});
	$obj{fields}{created_at}=POSIX::strftime("%FT%TZ",localtime($time));
	$obj{fields}{source}=$$ref{source};
	$obj{fields}{text}=$$ref{text};
	if ($$ref{possibly_sensitive}) {
		$obj{fields}{possibly_sensitive}='true';
	} else {
		$obj{fields}{possibly_sensitive}='false';
	}
	$obj{fields}{text}=$$ref{text};
	foreach my $k (@{$$ref{entities}{hashtags}}) {
		push(@{$obj{fields}{hashtags}},$$k{text});
	}
	foreach my $k (@{$$ref{entities}{urls}}) {
		push(@{$obj{fields}{urls}},$$k{url});
	}

	$obj{fields}{user}=$$ref{user}{screen_name};
	$obj{fields}{userid}=$$ref{user}{id};
	$obj{id}=$time.$id;
	$obj{type}="add";

	print encode_json(\%obj).",\n";
	$id++;
}
print "]";
