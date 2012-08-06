#!/usr/bin/perl
use Code::TidyAll::Util qw(dirname mkpath read_file tempdir_simple write_file);
use Code::TidyAll;
use Test::More;
use Capture::Tiny qw(capture_merged);

my $root_dir = tempdir_simple('Code-TidyAll-XXXX');

sub make {
    my ( $file, $content ) = @_;
    $file = "$root_dir/$file";
    mkpath( dirname($file), 0, 0775 );
    write_file( $file, $content );
}

make(
    "lib/Foo.pm",
    'package Foo;
  use strict;

method foo   {
 print "hi\n";
}

method bar   ($x)   {
 print "$x\n";
}


method baz   ($y, $z)   {
 print "$y, $z\n";
}

1;
'
);

my $ct = Code::TidyAll->new(
    root_dir => $root_dir,
    plugins  => {
        PerlTidy                             => { select => '**/*.{pl,pm}' },
        'Perl::IgnoreMethodSignaturesSimple' => { select => '**/*.{pl,pm}' },
    }
);

my $output;
$output = capture_merged { $ct->process_all() };
is( $output, "[tidied]  lib/Foo.pm\n" );
is(
    read_file("$root_dir/lib/Foo.pm"),
    'package Foo;
use strict;

method foo () {
    print "hi\n";
}

method bar ($x) {
    print "$x\n";
}

method baz ($y, $z) {
    print "$y, $z\n";
}

1;
'
);

done_testing();
