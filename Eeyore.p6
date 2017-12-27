#!/usr/bin/env perl6

# use Grammar::Tracer;

# ====================
# Tokenizer and Parser
#   Build Quadruple
# ====================

grammar Eeyore {
  token TOP {
    <externalDeclaration>+
  }
  token externalDeclaration {
    # | <functionDefinition>
    # | <variableDefinition>
    .
  }


  # ====================
  # Basic Tokens
  # ====================
  token _DEBUG_BASIC_TOKEN {
    [
    |<IF>|<GOTO>|<END>|<RETURN>|<CALL>|<PARAM>|<VAR>
    |<LBRACK>|<RBRACK>|<COLON>
    |<ASSIGN>
    |<OR>|<AND>
    |<EQ>|<NE>
    |<LT>|<GT>
    |<ADD>|<SUB>
    |<MUL>|<DIV>|<MOD>
    |<NEG>|<NOT>
    |<FUNCTION>|<VARIABLE>|<LABEL>
    |<INTEGER>|<NEWLINE>
    ]+
  }
  token IF     { 'if'<DELIM> }
  token GOTO   { 'goto'<DELIM> }
  token END    { 'end'<DELIM> }
  token RETURN { 'return'<DELIM> }
  token CALL   { 'call'<DELIM> }
  token PARAM  { 'param'<DELIM> }
  token VAR    { 'var'<DELIM>}
  token LBRACK { '['<DELIM> }
  token RBRACK { ']'<DELIM> }
  token COLON  { ':'<DELIM> }
  token ASSIGN { '='<DELIM> { make '=' } }
  token OR     { '|'<DELIM>'|'<DELIM> { make '||' } }
  token AND    { '&'<DELIM>'&'<DELIM> { make '&&' } }
  token EQ     { '='<DELIM>'='<DELIM> { make '==' } }
  token NE     { '!'<DELIM>'='<DELIM> { make '!=' } }
  token LT     { '<'<DELIM> { make '<' } }
  token GT     { '>'<DELIM> { make '>' } }
  token ADD    { '+'<DELIM> { make '+' } }
  token SUB    { '-'<DELIM> { make '-' } }
  token MUL    { '*'<DELIM> { make '*' } }
  token DIV    { '/'<DELIM> { make '/' } }
  token MOD    { '%'<DELIM> { make '%' } }
  token NEG    { '-'<DELIM> { make '-' } }
  token NOT    { '!'<DELIM> { make '!' } }
  token FUNCTION { (f_<[_A..Za..z]><[_A..Za..z0..9]>*) <DELIM> { make $0.Str } }
  token VARIABLE { (<[tpg]><[0..9]>+) <DELIM> { make $0.Str } }
  token LABEL    { (l<[0..9]>+) <DELIM> { make $0.Str } }
  token INTEGER  { (\-?<[0..9]>+) <DELIM> { make $0.Str } }
  token NEWLINE  { \n <DELIM> }
  token DELIM { " "? }
}

Eeyore.parse($*IN.slurp, rule => '_DEBUG_BASIC_TOKEN').say;
