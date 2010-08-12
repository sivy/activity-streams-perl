package ActivityStreams::Object;

use strict;
use warnings;

use Any::Moose;
use Data::Dumper;

has [qw(id name url object_type summary image in_reply_to_object time)] => ( is => "rw" );

has [
    qw ( attached_objects reply_objects reaction_activities action_links upstream_duplicate_ids downstream_duplicate_ids links)
] => ( is => "rw", isa => 'ArrayRef' );

sub to_string {
    my $self = shift;
    my ($indent_times) = @_;
    $indent_times ||= 0;
    my $in = ( $indent_times * 4 );

    my $output = "{\n";
    if ( @{ $self->links } ) {
        $output .= " " x $in . "links: [\n";
        for my $l ( @{ $self->links } ) {
            $output .= $l->to_string( $indent_times + 1 ) . "\n";
        }
        $output .= " " x $in . "]\n";
    }
    for my $f (qw(id name url object_type summary image in_reply_to_object time)) {
        if ( $self->$f ) {
            $output .= " " x $in . "$f: " . $self->$f . "\n";
        }
    }
    $output .= " " x $in . "}\n";
    return $output;
}

__PACKAGE__->meta->make_immutable;

package ActivityStreams::Object::Person;

use Any::Moose;

extends 'ActivityStreams::Object';

has 'email' => ( is => "rw", isa => "Str" );

__PACKAGE__->meta->make_immutable;

1;
