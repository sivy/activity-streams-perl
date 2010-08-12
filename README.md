# Activity Streams Parser/Generator

Goal: Refactor this into a format-agnostic parser/generator.

Architecture:

* Standalone objects for Activity, Object, Link, Person
** ActivityStreams::Activity
** ActivityStreams::Object (used for target, object)
** ActivityStreams::Object::Person (extends Object and adds email address, used for actor)
* "pluggable" parsers for Atom, JSON (load by content-type?)
** ActivityStreams::Parser::Atom
** ActivityStreams::Parser::JSON (Sir Not-implemented-yet)
