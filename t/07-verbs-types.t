#!/usr/bin/env perl
use lib qw(lib ../lib);

use strict;
use warnings;
use Carp::Always;

use Test::More qw(no_plan);

use ActivityStreams::Types qw(VERBS TYPES);

diag explain VERBS();
diag explain TYPES();

is( ref VERBS(), 'HASH', 'VERBS is a hashref' );
is( ref TYPES(), 'HASH', 'TYPES is a hashref' );
