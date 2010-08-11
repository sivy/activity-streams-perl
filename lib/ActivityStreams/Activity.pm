package ActivityStreams::Activity;

use strict;
use warnings;

use Moose;

has [qw(actor object target)]          => ( is => "rw", isa => 'Ref' );
has [qw(verb time generator icon_url)] => ( is => "rw", isa => 'Str' );
has [qw(service_provider)]             => ( is => "rw", isa => "HashRef" );
has [qw(links)]                        => ( is => "rw", isa => "ArrayRef" );

# sub new {
#     my $class = shift;

# my $self = {
#     actor            => '',
#     object           => '',
#     target           => '',
#         verb             => '',
#         time             => '',
#         generator        => '',
#         icon_url         => '',
#         service_provider => '',
#         links            => [],
#     };
#     bless $self, $class;
#     return $self;
# }

1;
