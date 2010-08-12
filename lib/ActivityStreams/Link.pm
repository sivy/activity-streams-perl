package ActivityStreams::Link;

use strict;
use warnings;

use Any::Moose;

# use Data::Dumper;

has [qw(rel href hreflang title type length)] => ( is => "rw" );

sub to_hash_ref {
    my $self = shift;
    my $h    = {};
    for my $f (qw(rel href hreflang title type length)) {
        if ( $self->$f ) {
            $h->{$f} = $self->$f;
        }
    }
    return $h;
}

__PACKAGE__->meta->make_immutable;

# =====
# http://activitystrea.ms/head/json-activity.html#medialink
package ActivityStreams::MediaLink;

use Any::Moose;

has [qw(url media_type width height duration)] => ( is => "rw" );

sub init_from_link {
    my $self = shift;
    my ($link) = @_;

    $self->url( $link->href );
    $self->media_type( $link->type );
}

__PACKAGE__->meta->make_immutable;

# =====
# http://activitystrea.ms/head/json-activity.html#actionlink
package ActivityStreams::ActionLink;

use Any::Moose;

extends 'ActivityStreams::Link';

has [qw(url caption)] => ( is => "rw" );

__PACKAGE__->meta->make_immutable;

1;
