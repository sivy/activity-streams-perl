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

diag "--- Atom parsing: verb: post, object: article";

my $feed_uri = 't/data/001-article.atom';
$parser = ActivityStreams::parser_for_type('application/atom+xml');

my @entries = $parser->parse_feed($feed_uri);

# diag explain @entries;

# POST
my $activity = $entries[0];

is( ref $activity, 'ActivityStreams::Activity', 'Activity created from feed' );

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

# diag explain $object;

# object
my $object = $activity->object;

is( ref $object,   'ActivityStreams::Object', 'Activity object is an ActivityStreams::Object' );
is( $object->name, 'TV: Studio 60',           'Object name is parsed correctly' );
is( $object->id, 'tag:api.typepad.com,2009:6a00d83451ce6b69e20133f2f032de970b', 'Object id is parsed correctly' );
is( $object->object_type, 'http://activitystrea.ms/schema/1.0/article', 'Object object-type is parsed correctly' );
is( $object->time,        '2010-08-09T04:53:38Z',                       'Object time is parsed correctly' );
is( $object->content,     'content',                                    'Object content is parsed correctly' );
is( $object->summary,     'content',                                    'Object summary is parsed correctly' );
is( $object->url, 'http://markpasc.typepad.com/blog/2010/08/tv-studio-60.html', 'Object url is parsed correctly' );

is( ref $object->author, 'ActivityStreams::Object', 'Object author is an ActivityStreams::Object' );
is( $object->author->name, 'markpasc', 'Object author name parsed correctly' );
is( $object->author->id,  'tag:api.typepad.com,2009:6p00d83451ce6b69e2', 'Object author id parsed correctly' );
is( $object->author->url, 'http://profile.typepad.com/markpasc',         'Object author url parsed correctly' );

# target
my $target = $activity->target;
is( ref $target, 'ActivityStreams::Object', 'Activity target is an ActivityStreams::Object' );
is( $target->name, 'markpasc', 'Target name parsed correctly' );
is( $target->object_type, 'http://activitystrea.ms/schema/1.0/blog', 'Target object-type parsed correctly' );

diag "--- Atom parsing: verb: post, object: photo";

$feed_uri = 't/data/002-photo.atom';
$parser   = ActivityStreams::parser_for_type('application/atom+xml');

@entries = $parser->parse_feed($feed_uri);

my $photo_activity = $entries[0];

is( ref $photo_activity, 'ActivityStreams::Activity', 'Photo Activity created from feed' );

is( $photo_activity->title, ' markpasc posted a photo ',               'Photo Activity title parsed correctly' );
is( $photo_activity->verb,  'http://activitystrea.ms/schema/1.0/post', 'Photo Activity verb parsed correctly' );
is( $photo_activity->time,  '2010-07-27T17:35:02Z',                    'Photo Activity time parsed correctly' );

# object
$object = $photo_activity->object;

is( ref $object, 'ActivityStreams::Object', 'Photo Activity object is an ActivityStreams::Object' );
is( $object->name, 'a face', 'Object name is parsed correctly' );
is( $object->id, 'tag:api.typepad.com,2009:6a00d83451ce6b69e2013485bd5366970c', 'Object id is parsed correctly' );
is( $object->object_type,
    'http://activitystrea.ms/schema/1.0/photo',
    'Photo Activity Object object-type is parsed correctly'
);
is( $object->time,    '2010-07-27T17:35:02Z', 'Photo Activity Object time is parsed correctly' );
is( $object->content, ' ',                    'Photo Activity Object content is parsed correctly' );
is( $object->summary, ' ',                    'Photo Activity Object summary is parsed correctly' );

my $preview = ( $object->get_links_by_rel('preview') )[0];
is( $preview->href,
    'http://a6.typepad.com/6a00d83451ce6b69e2013485bd5366970c-150si',
    'Photo Activity Object "preview" link href parsed correctly'
);
is( $preview->type, 'image/jpeg', 'Photo Activity Object "preview" link type parsed correctly' );

is( ref $object->author, 'ActivityStreams::Object', 'Photo Activity Object author is an ActivityStreams::Object' );
is( $object->author->name, 'markpasc', 'Photo Activity Object author name parsed correctly' );
is( $object->author->id,
    'tag:api.typepad.com,2009:6p00d83451ce6b69e2',
    'Photo Activity Object author id parsed correctly'
);
is( $object->author->url,
    'http://profile.typepad.com/markpasc',
    'Photo Activity Object author url parsed correctly'
);
