# =====
# http://activitystrea.ms/head/json-activity.html#activity
package ActivityStreams::Activity;

use strict;
use warnings;
use Data::Dumper;

use Any::Moose;

has [qw(actor object target service_provider generator)] => ( is => "rw", isa => "Ref" );
has [qw(id title verb body time icon_url)]               => ( is => "rw", isa => "Str" );
has [qw(links)]                                          => ( is => "rw", isa => "ArrayRef" );

sub get_links_by_rel {
    my $self = shift;
    my ($rel) = @_;

    return map { $_->rel eq $rel ? ($_) : () } @{ $self->links };
}

sub to_hash_ref {
    my $self = shift;
    my $h    = {};
    for my $f (qw(actor object target)) {
        if ( $self->$f ) {
            $h->{$f} = ( $self->$f )->to_hash_ref;
        }
    }

    for my $f (qw(id title verb time generator icon_url)) {
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

1;
