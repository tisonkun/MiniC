#!/usr/bin/env perl6

my token comment {
  | '//'.*?\n\s*
  | '/*'.*?'*/'\s*
}

my token whiteSpace {
  <!ww> \s* <comment>*
}

$*IN.slurp.subst(/<whiteSpace>/, '$', :g)
          .subst(/\$+/, '$', :g)
          .subst(/^\$/, '').print
