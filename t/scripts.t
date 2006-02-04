#!perl -- -*- mode: cperl -*-

my $Id = q$Id: bap.t 26 2003-02-16 19:01:03Z k $;

my @s;
opendir my $dh, "scripts" or die "Could not opendir scripts: $!";
for my $d (readdir $dh) {
  next unless $d =~ /^\w/;
  next if $d =~ /~$/;
  push @s, $d;
}

print "1..", scalar @s * 3, "\n";

for my $s (1..@s) {
  my $ok = $s * 3 - 2;
  my $script = "scripts/$s[$s-1]";
  my $ret = system $^X, "-cw", $script;
  print "not " if $ret;
  print "ok $ok # $script:-c:$ret\n";
  $ret = system $^X, "-w", $script, "--h";
  $ok++;
  print "#\n";
  print "not " if $ret;
  print "ok $ok # $script:--h:$ret\n";
  $ret = `$^X -w $script --h`;
  $ok++;
  print "#\n";
  print "not " unless $ret =~ /[\s\[]--h(elp)?\b/;
  print "ok $ok # $script:h~:$ret\n";
}

__END__

