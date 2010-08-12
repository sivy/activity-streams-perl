#!/usr/bin/env perl

package ActivityStreams::Parser::Atom;

use base qw(ActivityStreams::Parser);

use strict;
use warnings;

use ActivityStreams::Activity;
use ActivityStreams::Object;
use ActivityStreams::Link;

use XML::Atom;
use XML::Atom::Feed;

$XML::Atom::DefaultVersion = "1.0";

my $CONTENT_TYPE = 'application/xml+atom';

use constant ACTIVITY_NAMESPACE_URI => "http://activitystrea.ms/spec/1.0/";
use constant ACTIVITY_NAMESPACE => XML::Atom::Namespace->new( 'activity' => ACTIVITY_NAMESPACE_URI, );

use constant ATOM_NAMESPACE_URI => "http://www.w3.org/2005/Atom";
use constant ATOM_NAMESPACE => XML::Atom::Namespace->new( 'atom' => ATOM_NAMESPACE_URI, );

use constant POST_VERB_URI => "http://actionstrea.ms/schema/1.0/post";

sub parse_feed {
    my $self = shift;
    my ($uri) = @_ or die("No feed URI!");

    my $feed;
    if ( $uri =~ /^http/ ) {
        $uri = URI->new($uri);
    }
    $feed = XML::Atom::Feed->new($uri) or die "Could not parse feed: $uri";

    use Data::Dumper;

    my @entries = map {
        $_->source($feed);
        my $a = _activity_from_entry($_);
        print $a->to_string;
    } $feed->entries;

    return @entries;
}

sub _activity_from_entry {
    my ($entry) = @_;
    print "processing entry: " . $entry->id . "\n";
    my $elem = $entry->elem;

    # {   actor            => '',
    #     object           => '',
    #     target           => '',
    #     verb             => '',
    #     time             => '',
    #     generator        => '',
    #     icon_url         => '',
    #     service_provider => '',
    #     links            => (),
    # }

    my $a = new ActivityStreams::Activity;

    #my $id = $entry->get( ATOM_NAMESPACE_URI, 'id' );
    #$a->{id} = $id;

    my $actor = _object_from_elem( $entry->elem, ATOM_NAMESPACE_URI, 'author' );
    $actor ||= _object_from_elem( $entry->source->elem, ATOM_NAMESPACE_URI, 'author' );
    $a->actor($actor);

    # my $verb = _get_activity_value( $elem, 'verb' );
    my $verb = $entry->get( ACTIVITY_NAMESPACE_URI, 'verb' );
    $a->verb($verb);

    my $time = $entry->get( ATOM_NAMESPACE_URI, 'published' );
    $a->time($time);

    ### objects
    my $object = _object_from_elem( $elem, ACTIVITY_NAMESPACE_URI, 'object' );
    $a->object($object);

    my $target = _object_from_elem( $elem, ACTIVITY_NAMESPACE_URI, 'target' );
    $a->target($target);

    $a->links( [ map { _link_from_link($_) } $entry->link ] );

    return $a;
}

sub _object_from_elem {
    my ( $elem, $ns, $root_elem_name ) = @_;
    use XML::LibXML::XPathContext;
    my $xc = XML::LibXML::XPathContext->new($elem);
    $xc->registerNs( 'prefix', $ns );
    my $o_elem = ( $xc->find( "./prefix:$root_elem_name", $elem )->get_nodelist )[0];
    return unless $o_elem;

    # {   id                       => '',
    #     name                     => '',
    #     url                      => '',
    #     object_type              => '',
    #     summary                  => '',
    #     image                    => '',
    #     in_reply_to_object       => '',
    #     attached_objects         => (),
    #     reply_objects            => (),
    #     reaction_activities      => (),
    #     action_links             => (),
    #     upstream_duplicate_ids   => (),
    #     downstream_duplicate_ids => (),
    #     links                    => (),
    # }

    my $o = new ActivityStreams::Object;
    my $o_obj = XML::Atom::Entry->new( Elem => $o_elem );
    if ( $root_elem_name =~ /object|target/ ) {
        $o->name( $o_obj->get( ATOM_NAMESPACE_URI, 'title' ) );
        $o->summary( $o_obj->get( ATOM_NAMESPACE_URI, 'content' ) || '' );
        $o->time( $o_obj->get( ATOM_NAMESPACE_URI, 'published' ) );

    }
    elsif ( $root_elem_name =~ /actor|author/ ) {
        bless $o, 'ActivityStreams::Object::Person';
        my $o_person = XML::Atom::Person->new( Elem => $o_elem );

        $o->name( $o_person->name   || '' );
        $o->email( $o_person->email || '' );
        $o->url( $o_person->uri     || '' );
    }
    else {
        return;
    }
    $o->links( [ map { _link_from_link($_) } $o_obj->link ] );
    $o->object_type( $o_obj->get( ACTIVITY_NAMESPACE_URI, 'object-type' ) || '' );
    $o->id( $o_obj->get( ATOM_NAMESPACE_URI, 'id' ) );

    return $o;
}

sub _link_from_link {
    my ($link) = @_;
    my $l = ActivityStreams::Link->new(
        rel      => $link->rel,
        href     => $link->href,
        hreflang => $link->hreflang,
        title    => $link->title,
        type     => $link->type,
        length   => $link->length,
    );
    return $l;
}

1;
