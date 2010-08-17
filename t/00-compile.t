#!/usr/bin/env perl
use lib qw(lib ../lib);
use strict;

use Test::More tests => 9;

require_ok('ActivityStreams::Parser');
require_ok('ActivityStreams::Parser::Atom');
require_ok('ActivityStreams::Parser::JSON');
require_ok('ActivityStreams::Parser::RSS');
require_ok('ActivityStreams::Activity');
require_ok('ActivityStreams::Object');
require_ok('ActivityStreams::Link');

1;
