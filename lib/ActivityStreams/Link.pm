package ActivityStreams::Link;

use strict;
use warnings;

use Any::Moose;

# use Data::Dumper;

has [qw(rel href hreflang title type length)] => ( is => "rw" );

sub to_string {
    my $self = shift;
    my ($indent_times) = @_;
    $indent_times ||= 0;
    my $in = ( $indent_times * 4 );

    my $output = " " x $in . "{\n";
    for my $f (qw(rel href hreflang title type length)) {
        if ( $self->$f ) {
            $output .= " " x $in . "$f: " . $self->$f . "\n";
        }
    }
    $output .= " " x $in . "}";
    return $output;
}

__PACKAGE__->meta->make_immutable;

1;
