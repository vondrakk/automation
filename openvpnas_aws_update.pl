#!/usr/bin/perl

use JSON;
use WWW::Mechanize;
use Net::Netmask;

my $openvpnas_server='';
my $openvpnas_user='';
my $openvpnas_pass='';

my $private_subnets="";
my $server_config_directives="";

my $json = `curl -s https://ip-ranges.amazonaws.com/ip-ranges.json`;
my $ref = decode_json($json);
foreach my $obj (@{$ref->{prefixes}}) {
	#print $$obj{ip_prefix}."\n";
	my $block = Net::Netmask->new2( $$obj{ip_prefix} );
	$server_config_directives.="push \"route ".$$obj{ip_prefix}." ".$block->mask."\"\n";
	$private_subnets.=$$obj{ip_prefix};
}

my $web = WWW::Mechanize->new(ssl_opts => {
    SSL_verify_mode => IO::Socket::SSL::SSL_VERIFY_NONE,
    verify_hostname => 0, 
});
$web->get('https://'.$openvpnas_server.'/');
print $web->content;
$web->form_with_fields(('username','password'));
$web->field('username',$openvpnas_user);
$web->field('password',$openvpnas_pass);
$web->submit();
print $web->content;

$web->get('https://'.$openvpnas_server.'/vpn_settings');
$web->form_with_fields(('vserver_priv_nets'));
$web->field('vserver_priv_nets',$private_subnets);
$web->submit();

$web->get('https://'.$openvpnas_server.'/advanced_vpn');
$web->form_with_fields(('vpn.server.config_text'));
$web->field('vpn.server.config_text',$server_config_directives);
$web->submit();

$web->form_number(1);
$web->click('button');

1;
