#!/usr/bin/env perl
use lib qw(lib ../lib);

use strict;
use warnings;
use Carp::Always;

use Test::More qw(no_plan);

use ActivityStreams;

my $parser = ActivityStreams::parser_for_type('application/atom+xml');

ok( ActivityStreams::parser_for_type('application/atom+xml')->isa('ActivityStreams::Parser::Atom'),
    'parser returns Atom parser for application/atom+xml' );
ok( ActivityStreams::parser_for_type('application/rss+xml')->isa('ActivityStreams::Parser::RSS'),
    'parser returns RSS parser for application/rss+xml' );
ok( ActivityStreams::parser_for_type('application/stream+json')->isa('ActivityStreams::Parser::JSON'),
    'parser returns JSON parser for application/stream+json' );

# my $feed_uri = 'http://monkinetic.status.net/api/statuses/user_timeline/1.atom';
# my $feed_uri = 'http://profile.typepad.com/markpasc/activity/atom.xml';
my $feed_uri = 'activities.atom';
$parser = ActivityStreams::parser_for_type('application/atom+xml');

my @entries = $parser->parse_feed($feed_uri);

# diag explain @entries;
