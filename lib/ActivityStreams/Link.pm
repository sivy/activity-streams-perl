package ActivityStreams::Link;

use strict;
use warnings;

use Moose;
use MooseX::Storage;

# use Data::Dumper;
with Storage;

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

use Moose;

extends 'ActivityStreams::Link';

has [qw(type width height duration)] => ( is => "rw" );

sub init_from_link {
    my $self = shift;
    my ($link) = @_;

    $self->href( $link->href );
    $self->type( $link->type );
}

__PACKAGE__->meta->make_immutable;

# =====
# http://activitystrea.ms/head/json-activity.html#actionlink
package ActivityStreams::ActionLink;

use Moose;

extends 'ActivityStreams::Link';

has [qw(url caption)] => ( is => "rw" );

__PACKAGE__->meta->make_immutable;

1;
