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

use constant POST_VERB_URI => "http://activitystrea.ms/schema/1.0/post";

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
        my $a = _activity_from_entry_elem( $_->elem, $feed->elem );
        $a;
    } $feed->entries;

    return @entries;
}

sub _activity_from_entry_elem {
    my ( $entry_elem, $feed_elem ) = @_;

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

    my $title = _find_text_value( $entry_elem, ATOM_NAMESPACE_URI, 'title' );

    #    my $title = $entry->get( ATOM_NAMESPACE_URI, 'title' );
    $a->title($title);

    my $id = _find_text_value( $entry_elem, ATOM_NAMESPACE_URI, 'id' );

    #    my $id = $entry->get( ATOM_NAMESPACE_URI, 'id' );
    $a->id($id);

    # my $verb = _get_activity_value( $elem, 'verb' );
    my $verb = _find_text_value( $entry_elem, ACTIVITY_NAMESPACE_URI, 'verb' );

    # my $verb = $entry->get( ACTIVITY_NAMESPACE_URI, 'verb' );
    $a->verb($verb);

    my $time = _find_text_value( $entry_elem, ATOM_NAMESPACE_URI, 'published' );

    # my $time = $entry->get( ATOM_NAMESPACE_URI, 'published' );
    $a->time($time);

    ### objects

    # actor
    my $ae = $entry_elem->getChildrenByTagNameNS( ATOM_NAMESPACE_URI, 'author' );
    unless ($ae) {
        $ae = $feed_elem->getChildrenByTagNameNS( ATOM_NAMESPACE_URI, 'author' );
    }
    if ($ae) {
        my $author = _object_from_author_elem($ae);
        $a->actor($author) if $author;
    }

    # object
    my $object = _object_from_elem( $entry_elem, ACTIVITY_NAMESPACE_URI, 'object' );
    $a->object($object) if $object;

    # target
    my $target = _object_from_elem( $entry_elem, ACTIVITY_NAMESPACE_URI, 'target' );
    $a->target($target) if $target;

    # links
    my @links = $entry_elem->getChildrenByTagNameNS( ATOM_NAMESPACE_URI, 'link' );

    $a->links( [ map { _link_from_link_elem($_) } @links ] );

    return $a;
}

sub _object_from_elem {
    my ( $elem, $ns, $root_elem_name ) = @_;

    use XML::LibXML::XPathContext;
    my $xc = XML::LibXML::XPathContext->new($elem);
    $xc->registerNs( 'prefix', $ns );
    $xc->registerNs( 'atom',   ATOM_NAMESPACE_URI );

    # $oe is the object element, an XML::LibXML::Element
    my $oe = ( $xc->find( "./prefix:$root_elem_name", $elem )->get_nodelist )[0];

    return unless $oe;

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

    my $ao = new ActivityStreams::Object;

    # my $oe = XML::Atom::Entry->new( Elem => $o_elem );

    #    print "_object_from_elem entry ($root_elem_name): " . Dumper($oe);
    # print Dumper( $te->get_node(0) );

    # get id
    my $id = _find_text_value( $oe, ATOM_NAMESPACE_URI, 'id' );
    $ao->id($id);

    # get title
    my $title = _find_text_value( $oe, ATOM_NAMESPACE_URI, 'title' );
    $ao->name($title) if $title;

    # get content
    my $content = _find_text_value( $oe, ATOM_NAMESPACE_URI, 'content' );
    if ($content) {
        $ao->summary($content);
        $ao->content($content);
    }

    # get author
    my $ae = $oe->getChildrenByTagNameNS( ATOM_NAMESPACE_URI, 'author' );
    if ($ae) {
        my $author = _object_from_author_elem($ae);
        $ao->author($author) if $author;
    }

    my @links = $oe->getChildrenByTagNameNS( ATOM_NAMESPACE_URI, 'link' );

    $ao->links( [ map { _link_from_link_elem($_) } @links ] );

    # dig permalink out of a link@rel
    if ( my $permalink = ( $ao->get_links_by_rel('alternate') )[0] ) {
        if ( $permalink->type eq 'text/html' ) {
            $ao->url( $permalink->href );
        }
    }

    # representational image
    if ( my $image_link = ( $ao->get_links_by_rel('preview') )[0] ) {
        my $ml = new ActivityStreams::MediaLink;
        $ml->init_from_link($image_link);
        $ao->image($ml);
    }

    my $object_type = _find_text_value( $oe, ACTIVITY_NAMESPACE_URI, 'object-type' );
    $ao->name($object_type) if $object_type;

    return $ao;
}

sub _link_from_link_elem {
    my ($elem) = @_;

    my @atts = $elem->attributes();
    my $attr = {};
    map { $attr->{ $_->nodeName } = $_->value || '' } @atts;

    my $l = ActivityStreams::Link->new(
        rel      => $attr->{rel},
        href     => $attr->{href},
        hreflang => $attr->{hreflang},
        title    => $attr->{title},
        type     => $attr->{type},
        length   => $attr->{length},
    );
    return $l;
}

sub _find_text_value {
    my ( $elem, $ns, $name ) = @_;

    $elem = ( ref $elem eq 'XML::LibXML::NodeList' ) ? $elem->get_node(0) : $elem;

    my $tmp_list = $elem->getChildrenByTagNameNS( $ns, $name );

    if ( my $tmp_node = $tmp_list->get_node(0) ) {
        return $tmp_node->textContent;
    }
}

sub _object_from_author_elem {
    my ($author_element) = @_;

    $author_element =
        ( ref $author_element eq 'XML::LibXML::NodeList' ) ? $author_element->get_node(0) : $author_element;

    my $uri  = _find_text_value( $author_element, ATOM_NAMESPACE_URI, 'uri' );
    my $name = _find_text_value( $author_element, ATOM_NAMESPACE_URI, 'name' );
    my $id   = _find_text_value( $author_element, ATOM_NAMESPACE_URI, 'id' );

    my $o = ActivityStreams::Object->new(
        url         => $uri,
        name        => $name,
        id          => $id,
        object_type => 'http://activitystrea.ms/schema/1.0/person',
    );

    my @links = $author_element->getChildrenByTagNameNS( ATOM_NAMESPACE_URI, 'link' );
    $o->links( [ map { _link_from_link_elem($_) } @links ] );

    # representational image
    if ( my $image_link = ( $o->get_links_by_rel('preview') )[0] ) {
        my $ml = new ActivityStreams::MediaLink;
        $ml->init_from_link($image_link);
        $o->image($ml);
    }

    return $o;
}

1;
