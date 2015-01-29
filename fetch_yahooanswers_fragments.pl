#!/usr/bin/perl

use WWW::Mechanize;
use DBI;

my $db_user_name = '';
my $db_password = '';
my $dsn = 'DBI:mysql:db:127.0.0.1';
my %attr = (
	PrintError => 1,
	RaiseError => 0
);
my $dbh = DBI->connect($dsn, $db_user_name, $db_password,\%attr);
my $sthA=$dbh->prepare("insert ignore into fragments values(0,?,'UNUSED')");

my @urls=(
	'http://answers.yahoo.com/;_ylt=Au6.Mc6Xquqhvp_44oTfapfj1KIX;_ylv=3?link=popular#yan-questions',
	'http://answers.yahoo.com/;_ylt=AhRjPsnstWiTPw7fSf1zfEjj1KIX;_ylv=3?link=recent#yan-questions'
);

my $web = new WWW::Mechanize;
$web->cookie_jar($cookie_jar);

foreach my $url (@urls)
{
	$web->get($url);
	my $content=$web->content;
	while ($content=~m|<h3><a href="/question/[^"]+">(.*?)</a></h3>|g)
	{
		my $msg=$1;
		$msg=~s|&.*;||g;
		$msg=~s|#.*;||g;
		$msg=~s|\.\.\.||g;
		next if $msg eq "";
		$sthA->execute($msg);
	}
}

1;
