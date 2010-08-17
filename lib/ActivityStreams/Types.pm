#!/usr/bin/env perl

package ActivityStreams::Types;

require Exporter;
@ISA       = qw(Exporter);
@EXPORT_OK = qw(VERBS TYPES);

# placeholder -- enumerators for verbs and object types

my $schema_uri = 'http://activitystrea.ms/schema/1.0/';
my @verbs      = qw(favorite follow like make-friend join play post save share tag update);

my $VERBS = { map { +"$schema_uri$_" => $_ } @verbs };

my @types =
    qw(article audio bookmark comment file folder group list note person photo photo-album place playlist product review service status video);

my $TYPES = { map { +"$schema_uri$_" => $_ } @types };

sub VERBS {$VERBS}
sub TYPES {$TYPES}

1;
