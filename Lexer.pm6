#!/usr/bin/env perl6

unit module Lexer;

my token comment {
  | '//'.*?\n\s*
  | '/*'.*?'*/'\s*
}

my token whiteSpace {
  <!ww> \s* <comment>*
}

our $TOKENS is export =
  $*IN.slurp.subst(/<whiteSpace>/, '$', :g)
            .subst(/\$+/, '$', :g)
            .subst(/^\$/, '')
            ;
