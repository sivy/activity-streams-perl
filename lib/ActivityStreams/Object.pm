package ActivityStreams::Object;

use strict;
use warnings;

use Moose;

has [qw(id name url object_type summary image in_reply_to_object time)] => ( is => "rw" );

has [
    qw ( attached_objects reply_objects reaction_activities action_links upstream_duplicate_ids downstream_duplicate_ids links)
] => ( is => "rw", isa => 'ArrayRef' );

# sub new {
#     my $class = shift;

#     my $self = {
#         id   => '',
#         name => '',
#         url                      => '',
#         object_type              => '',
#         summary                  => '',
#         image                    => '',
#         in_reply_to_object       => '',
#         attached_objects         => [],
#         reply_objects            => [],
#         reaction_activities      => [],
#         action_links             => [],
#         upstream_duplicate_ids   => [],
#         downstream_duplicate_ids => [],
#         links                    => [],
#     };
#     bless $self, $class;
#     return $self;
# }

package ActivityStreams::Object::Person;

use Moose;

extends 'ActivityStreams::Object';

has 'email' => ( is => "rw", isa => "Str" );

1;
