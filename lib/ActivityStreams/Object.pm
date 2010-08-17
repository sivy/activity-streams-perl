### =====================
# http://activitystrea.ms/head/json-activity.html#object
package ActivityStreams::Object;

use strict;
use warnings;

use Moose;
use MooseX::Types::Moose qw (ArrayRef);

use Data::Dumper;

has [qw(id name url summary content time object_type)] => ( is => "rw", isa => "Str" );
has 'image' => ( is => "rw", isa => 'ActivityStreams::MediaLink' );

# ids
has [qw (upstream_duplicate_ids downstream_duplicate_ids)] => ( is => "rw", isa => ArrayRef, auto_deref => 1 );

# objects
has 'author' => ( is => "rw", isa => 'ActivityStreams::Object' );
has [qw (in_reply_to_object attached_objects reply_objects)] =>
    ( is => "rw", isa => ArrayRef ['ActivityStreams::Object'], auto_deref => 1 );

# activities
has 'reaction_activities' => ( is => "rw", isa => ArrayRef ['ActivityStreams::Activity'], auto_deref => 1 );

# links
has 'links'        => ( is => "rw", isa => ArrayRef ['ActivityStreams::Link'],       auto_deref => 1 );
has 'action_links' => ( is => "rw", isa => ArrayRef ['ActivityStreams::ActionLink'], auto_deref => 1 );

sub get_links_by_rel {
    my $self = shift;
    my ($rel) = @_;
    return map { $_->rel eq $rel ? ($_) : () } $self->links;
}

sub to_hash_ref {
    my $self = shift;
    my $h    = {};

    for my $f (qw(id name url object_type summary image in_reply_to_object time)) {
        if ( $self->$f ) {
            $h->{$f} = $self->$f;
        }
    }

    if ( $self->author ) {
        $h->{author} = $self->author->to_hash_ref;
    }

    if ( $self->links ) {
        $h->{links} = [];
        for my $l ( $self->links ) {
            push @{ $h->{links} }, $l->to_hash_ref;
        }
    }
    return $h;
}

__PACKAGE__->meta->make_immutable;

1;
