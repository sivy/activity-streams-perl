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

# POST
my $activity       = $entries[0];
my $photo_activity = $entries[1];
my $fav_activity   = $entries[2];

# diag explain $activity;

is( $activity->title, ' markpasc posted an entry ',              'Activity title parsed correctly' );
is( $activity->verb,  'http://activitystrea.ms/schema/1.0/post', 'Activity verb parsed correctly' );
is( $activity->time,  '2010-08-09T04:53:39Z',                    'Activity time parsed correctly' );

# actor
my $actor = $activity->actor;

is( ref $actor, 'ActivityStreams::Object', 'Activity actor is an ActivityStreams::Object' );

is( $actor->name, 'markpasc', 'Actor name parsed correctly' );
is( $actor->object_type, 'http://activitystrea.ms/schema/1.0/person', 'Actor object_type parsed correctly' );

is( $actor->url, 'http://profile.typepad.com/markpasc',         'Actor url parsed correctly' );
is( $actor->id,  'tag:api.typepad.com,2009:6p00d83451ce6b69e2', 'Actor id parsed correctly' );

is( ref $actor->image, 'ActivityStreams::MediaLink', 'Actor image MediaLink parsed correctly' );

# actor links
is( length $actor->get_links_by_rel('alternate'), 1, 'Actor "alternate" links parsed' );

my $alt = ( $actor->get_links_by_rel('alternate') )[0];
is( $alt->href, 'http://profile.typepad.com/markpasc', 'Actor "alternate" link href parsed correctly' );
is( $alt->type, 'text/html', 'Actor "alternate" link type parsed correctly' );

is( length $activity->actor->get_links_by_rel('preview'), 1, 'Actor "preview" link parsed' );

my $preview = ( $activity->actor->get_links_by_rel('preview') )[0];
is( $preview->href,
    'http://up3.typepad.com/6a00d83451ce6b69e20133f2e40bfd970b-75si',
    'Actor "preview" link href parsed correctly'
);
is( $preview->type, 'image/jpeg', 'Actor "preview" link type parsed correctly' );

# object
is( ref $activity->object, 'ActivityStreams::Object', 'Activity object is an ActivityStreams::Object' );

my $object = $activity->object;

# diag explain $object;

is( ref $object->author, 'ActivityStreams::Object', 'Object author is an ActivityStreams::Object' );

# target
is( ref $activity->target, 'ActivityStreams::Object', 'Activity target is an ActivityStreams::Object' );
