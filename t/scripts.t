#!perl -- -*- mode: cperl -*-

my $Id = q$Id: bap.t 26 2003-02-16 19:01:03Z k $;

my @s;
opendir my $dh, "scripts" or die "Could not opendir scripts: $!";
for my $d (readdir $dh) {
  next unless $d =~ /^\w/;
  next if $d =~ /~$/;
  push @s, $d;
}

print "1..", scalar @s, "\n";

for my $s (1..@s) {
  my $ret = system $^X, "-cw", "scripts/$s[$s-1]";
  print "not " if $ret;
  print "ok $s # $ret\n";
}

__END__

