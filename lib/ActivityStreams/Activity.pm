package ActivityStreams::Activity;

use strict;
use warnings;
use Data::Dumper;

use Any::Moose;

has [qw(actor object target)]          => ( is => "rw" );
has [qw(verb time generator icon_url)] => ( is => "rw", isa => 'Str' );
has [qw(service_provider)]             => ( is => "rw", isa => "HashRef" );
has [qw(links)]                        => ( is => "rw", isa => "ArrayRef" );

sub to_string {
    my $self = shift;
    my ($indent_times) = @_;
    $indent_times ||= 0;
    my $in = ( $indent_times * 4 );

    my $output = " " x $in . "{\n";

    for my $f (qw(actor object target)) {
        if ( $self->$f ) {
            $output .= " " x $in . "$f: ";
            $output .= $self->$f->to_string( $indent_times + 1 );
            $output .= " " x $in . "\n";
        }
    }

    for my $f (qw(verb time generator icon_url)) {
        if ( $self->$f ) {
            $output .= " " x $in . "$f: " . $self->$f . "\n";
        }
    }

    if ( @{ $self->links } ) {
        $output .= " " x $in . "links: [\n";
        for my $l ( @{ $self->links } ) {
            $output .= $l->to_string( $indent_times + 1 ) . "\n";
        }
        $output .= " " x $in . "]\n";
    }
    $output .= " " x $in . "}\n";
    return $output;
}

__PACKAGE__->meta->make_immutable;

1;
