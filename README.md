# Activity Streams Parser/Generator

Goal: Refactor this into a format-agnostic parser/generator.

Architecture:
* Standalone objects for Activity, Verb, Object, Target [, Feed]
* "pluggable" parsers for Atom, JSON (load by content-type?)
* 
