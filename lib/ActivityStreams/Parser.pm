#!/usr/bin/env perl

package ActivityStreams::Parser;

my $CONTENT_TYPE = '';

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    return $self;
}

sub content_type {
    return $CONTENT_TYPE;
}

1;
