#!/usr/bin/env perl6

# use Grammar::Tracer;

unit module Eeyore;

# ====================
# Tokenizer and Parser
#   Build Quadruple
# ====================

our %SYMBOLS is export;
our %FUNCTIONS is export;

grammar Eeyore {
  # ====================
  # Eeyore Syntax
  # ====================
  token TOP { # translateUnit
    <externalDeclaration>+
  }

  token externalDeclaration {
    | <functionDefinition>
    | <variableDeclaration>
  }

  token variableDeclaration {
    | <VAR> <INTEGER> <VARIABLE> <NEWLINE> {
      my %info = %(
        id => $<VARIABLE>.made,
        size => $<INTEGER>.made,
        type => 'Array',
      );
      %SYMBOLS{%info<id>} = %info;
    }
    | <VAR> <VARIABLE> <NEWLINE> {
      my %info = %(
        id => $<VARIABLE>.made,
        type => 'Scalar',
      );
      %SYMBOLS{%info<id>} = %info;
    }
  }

  token functionDefinition {
    | <FUNCTION> :my $*FUNCTION; {
      $*FUNCTION = $<FUNCTION>[0].made;
    } <LBRACK> <INTEGER> <RBRACK> <NEWLINE> {
      %SYMBOLS{$*FUNCTION} = %(
        id => $*FUNCTION,
        type => 'Function',
        nParam => $<INTEGER>.made,
      );
      %FUNCTIONS{$*FUNCTION} = [];
    } <lineStatement>*? <END> <FUNCTION> <NEWLINE>
  }

  token lineStatement {
    | <variableDeclaration>
    | <expression> <NEWLINE>
  }

  token expression {
    | <binaryExpression>
    | <unaryExpression>
    | <directAssignExpression>
    | <ifExpression>
    | <gotoExpression>
    | <labelExpression>
    | <paramExpression>
    | <callExpression>
    | <returnExpression>
  }

  token binaryExpression {
    | <VARIABLE> <ASSIGN> <rightValue> <binaryOp> <rightValue> {
      my %instruction;
      %instruction<id> = %FUNCTIONS{$*FUNCTION}.elems;
      %instruction<type> = 'binary';
      %instruction<op> = $<binaryOp>.made;
      %instruction<def> = $<VARIABLE>.made;
      %instruction<use> = [$<rightValue>[0].made, $<rightValue>[1].made];
      %FUNCTIONS{$*FUNCTION}.push: %instruction;
    }
  }

  token unaryExpression {
    | <VARIABLE> <ASSIGN> <unaryOp> <rightValue> {
      my %instruction;
      %instruction<id> = %FUNCTIONS{$*FUNCTION}.elems;
      %instruction<type> = 'unary';
      %instruction<op> = $<unaryOp>.made;
      %instruction<def> = $<VARIABLE>.made;
      %instruction<use> = [$<rightValue>.made];
      %FUNCTIONS{$*FUNCTION}.push: %instruction;
    }
  }

  token directAssignExpression {
    | <VARIABLE> <LBRACK> <rightValue> <RBRACK> <ASSIGN> <rightValue> {
      my %instruction;
      %instruction<id> = %FUNCTIONS{$*FUNCTION}.elems;
      %instruction<type> = 'arrayScalar';
      %instruction<use> = [$<VARIABLE>[0].made, $<rightValue>[0].made, $<rightValue>[1].made];
      %FUNCTIONS{$*FUNCTION}.push: %instruction;
    }
    | <VARIABLE> <ASSIGN> <VARIABLE> <LBRACK> <rightValue> <RBRACK> {
      my %instruction;
      %instruction<id> = %FUNCTIONS{$*FUNCTION}.elems;
      %instruction<type> = 'scalarArray';
      %instruction<def> = $<VARIABLE>[0].made;
      %instruction<use> = [$<VARIABLE>[1].made, $<rightValue>[0].made];
      %FUNCTIONS{$*FUNCTION}.push: %instruction;
    }
    | <VARIABLE> <ASSIGN> <rightValue> {
      my %instruction;
      %instruction<id> = %FUNCTIONS{$*FUNCTION}.elems;
      %instruction<type> = 'scalarRval';
      %instruction<def> = $<VARIABLE>[0].made;
      %instruction<use> = [$<rightValue>[0].made];
      %FUNCTIONS{$*FUNCTION}.push: %instruction;
    }
  }

  token ifExpression {
    | <IF> <rightValue> <binaryOp> <rightValue> <GOTO> <LABEL> {
      # Assert the form is 'if <VARIABLE> == 0 goto <LABEL>'
      my %instruction;
      %instruction<id> = %FUNCTIONS{$*FUNCTION}.elems;
      %instruction<type> = 'ifFalse';
      %instruction<use> = [$<rightValue>[0].made];
      %instruction<label> = $<LABEL>.made;
      %FUNCTIONS{$*FUNCTION}.push: %instruction;
    }
  }

  token gotoExpression {
    | <GOTO> <LABEL> {
      my %instruction;
      %instruction<id> = %FUNCTIONS{$*FUNCTION}.elems;
      %instruction<type> = 'goto';
      %instruction<label> = $<LABEL>.made;
      %FUNCTIONS{$*FUNCTION}.push: %instruction;
    }
  }

  token labelExpression {
    | <LABEL> <COLON> {
      my %instruction;
      %instruction<id> = %FUNCTIONS{$*FUNCTION}.elems;
      %instruction<type> = 'label';
      %instruction<label> = $<LABEL>.made;
      %FUNCTIONS{$*FUNCTION}.push: %instruction;
      my %info = %(
        id => $<LABEL>.made,
        type => 'Label',
        location => %instruction<id>,
      );
      %SYMBOLS{%info<id>} = %info;
    }
  }

  token paramExpression {
    | <PARAM> <rightValue> {
      my %instruction;
      %instruction<id> = %FUNCTIONS{$*FUNCTION}.elems;
      %instruction<type> = 'param';
      %instruction<use> = [$<rightValue>.made];
      %FUNCTIONS{$*FUNCTION}.push: %instruction;
    }
  }

  token callExpression {
    | <VARIABLE> <ASSIGN> <CALL> <FUNCTION> {
      my %instruction;
      %instruction<id> = %FUNCTIONS{$*FUNCTION}.elems;
      %instruction<type> = 'call';
      %instruction<def> = $<VARIABLE>.made;
      %instruction<function> = $<FUNCTION>.made;
      %FUNCTIONS{$*FUNCTION}.push: %instruction;
    }
  }

  token returnExpression {
    | <RETURN> <rightValue> {
      my %instruction;
      %instruction<id> = %FUNCTIONS{$*FUNCTION}.elems;
      %instruction<type> = 'return';
      %instruction<use> = [$<rightValue>.made];
      %FUNCTIONS{$*FUNCTION}.push: %instruction;
    }
  }

  token unaryOp {
    | <NEG> { make $<NEG>.made; }
    | <NOT> { make $<NOT>.made; }
  }

  token binaryOp {
    | <OR>  { make $<OR>.made; }
    | <AND> { make $<AND>.made; }
    | <EQ>  { make $<EQ>.made; }
    | <NE>  { make $<NE>.made; }
    | <LT>  { make $<LT>.made; }
    | <GT>  { make $<GT>.made; }
    | <ADD> { make $<ADD>.made; }
    | <SUB> { make $<SUB>.made; }
    | <MUL> { make $<MUL>.made; }
    | <DIV> { make $<DIV>.made; }
    | <MOD> { make $<MOD>.made; }
  }

  token rightValue {
    | <VARIABLE> { make $<VARIABLE>.made; }
    | <INTEGER> { make $<INTEGER>.made; }
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

die "Syntax error" unless Eeyore.parse($*IN.slurp);
# say %SYMBOLS.perl;
# say %FUNCTIONS.perl;

# note qq:to/END/;
#   # ====================
#   # SYMBOL TABLE
#   # ====================
#   END
# .note for %SYMBOLS;
# note "";
# for %FUNCTIONS.kv -> $function, @instruction {
#   note qq:to/END/;
#     # ====================
#     # FUNCTION $function
#     # ====================
#     END
#   .note for @instruction;
#   note "";
# }
