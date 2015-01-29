#!/usr/bin/perl
use JSON;
my $json=`aws ec2 describe-instances`;
my $ref = decode_json($json);

my %instances=();
foreach my $res (@{$$ref{Reservations}}) {
	foreach my $inst (@{$$res{Instances}}) {
		my $tags=$$inst{Tags};
		my $sg=$$inst{SecurityGroups};
		$instances{$$tags[0]{Value}}{name}=$$tags[0]{Value};
		$instances{$$tags[0]{Value}}{publicip}=$$inst{PublicIpAddress};
		$instances{$$tags[0]{Value}}{privateip}=$$inst{PrivateIpAddress};
		$instances{$$tags[0]{Value}}{zone}=$$inst{Placement}{AvailabilityZone};
		$instances{$$tags[0]{Value}}{sg}=$$sg[0]{GroupName};
		$instances{$$tags[0]{Value}}{type}=$$inst{InstanceType};
	}
}

print "!!AWS Instances:"."\n";
print "|| border=1 width=100%"."\n";
print "||!Name      ||! External IP  ||! Internal IP  ||! Zone  ||! Security Group  ||!       Instance Type||"."\n";
foreach my $k (sort keys %instances) {
print "||".$instances{$k}{name}."||".$instances{$k}{publicip}."||".$instances{$k}{privateip}."||".$instances{$k}{zone}."||".$instances{$k}{sg}."||".$instances{$k}{type}."||"."\n";
}
print "\n";

