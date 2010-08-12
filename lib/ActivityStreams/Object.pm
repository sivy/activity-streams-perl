# =====
# http://activitystrea.ms/head/json-activity.html#object
package ActivityStreams::Object;

use strict;
use warnings;

use Any::Moose;
use Data::Dumper;

has [qw(id name url summary object_type time)] => ( is => "rw" );
has [qw(image in_reply_to_object)] => ( is => "rw", isa => "Ref" );
has [
    qw ( attached_objects reply_objects reaction_activities action_links upstream_duplicate_ids downstream_duplicate_ids links)
] => ( is => "rw", isa => 'ArrayRef' );

sub get_links_by_rel {
    my $self = shift;
    my ($rel) = @_;

    return map { $_->rel eq $rel ? ($_) : () } @{ $self->links };
}

sub to_hash_ref {
    my $self = shift;
    my $h    = {};

    for my $f (qw(id name url object_type summary image in_reply_to_object time)) {
        if ( $self->$f ) {
            $h->{$f} = $self->$f;
        }
    }

    if ( @{ $self->links } ) {
        $h->{links} = [];
        for my $l ( @{ $self->links } ) {
            push @{ $h->{links} }, $l->to_hash_ref;
        }
    }
    return $h;
}

__PACKAGE__->meta->make_immutable;

package ActivityStreams::Object::Person;

use Any::Moose;

extends 'ActivityStreams::Object';

has 'email' => ( is => "rw", isa => "Str" );

__PACKAGE__->meta->make_immutable;

1;
