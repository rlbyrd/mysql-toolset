#!/usr/bin/perl --
chdir "/usr/local/cron/update_hosts/";

$header = << 'EOF';
127.0.0.1 localhost

10.62.0.32 dbutils dbutils.infra.vacasa.com crushinator crushinator.infra.vacasa.com


# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts

EOF



system("mv /etc/hosts /etc/hosts.old");

$hosts_to_update=`grep -v "^#" update.dat`;
@hosts=split(/\n/,$hosts_to_update);

foreach (@hosts) {
    $thisline=$_;
    ($cname,$shortname,$fqdn)=split(/\|/,$thisline);
    ($name,$aliases,$addrtype,$length,@addrs) = gethostbyname "$fqdn";
    ($a,$b,$c,$d) =  unpack('C4',$addrs[0]);
    $thisip="$a" . "." . "$b" . "." . "$c" . "." . "$d";
    $newhostlines .= "$thisip	$cname	$shortname	$fqdn\n";
    $egrepline .= "$cname|";
}

chop $egrepline;
$hostfile=`egrep -v "$egrepline" /etc/hosts 2>/dev/null`;

open (DATA,">/etc/newhosts");
print DATA $header;
print DATA $hostfile;
print DATA $newhostlines;
close DATA;

system("/bin/cp /etc/newhosts /etc/hosts");
