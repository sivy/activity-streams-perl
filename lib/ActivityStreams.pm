#!/usr/bin/env perl

package ActivityStreams;

use ActivityStreams::Parser::Atom;
use ActivityStreams::Parser::JSON;
use ActivityStreams::Parser::RSS;

use constant ACTIVITY_NAMESPACE_URI => "http://activitystrea.ms/spec/1.0";
use constant ACTIVITY_NAMESPACE     => XML::Atom::Namespace->new( 'activity' => ACTIVITY_NAMESPACE_URI, );
use constant POST_VERB_URI          => "http://activitystrea.ms/schema/1.0/post";

my $PARSERS = {
    'application/atom+xml'    => 'ActivityStreams::Parser::Atom',
    'application/stream+json' => 'ActivityStreams::Parser::JSON',
    'application/rss+xml'     => 'ActivityStreams::Parser::RSS'
};

sub parser_for_type {
    my $content_type = shift;
    my $class = $PARSERS->{$content_type} or die "Unsupported content type!";
    return $class->new;
}
