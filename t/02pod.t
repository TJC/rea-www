use strict;
use warnings;
use Test::More;

eval "use Test::Pod 1.14";
plan skip_all => 'Test::Pod 1.14 required' if $@;
plan skip_all => 'Skipping as SKIP_TEST_POD is set.' if $ENV{SKIP_TEST_POD};

all_pod_files_ok();
