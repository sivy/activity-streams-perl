package ActivityStreams::Link;

use strict;
use warnings;

use Moose;

# use Data::Dumper;

has [qw(rel href hreflang title type length)] => ( is => "rw" );

# sub new {
#     my $class  = shift;
#     my %params = @_;

#     my $self = { rel => '', href => '', hreflang => '', title => '', type => '', length => '', };

#     for my $field (qw(rel href hreflang title type length)) {
#         print "$field: " . $params{$field} . "\n";
#         $self->$field( $params{$field} );
#     }
#     bless $self, $class;
#     print "link: " . Dumper($self);

#     return $self;
# }

1;
