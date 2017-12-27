#!/usr/bin/env perl6

# use Grammar::Tracer;

grammar MiniC {
  token TOP {
    <externalDeclaration>+
  }

  # ====================
  # MiniC Syntax
  # ====================
  token externalDeclaration {
    | <functionDeclaration>
    | <functionDefinition>
    | <variableDefinition>
  }

  token functionDeclaration {
    | <INT> <IDENTIFIER> <LPAREN> [<variableDeclaration>+ % <COMMA>]? <RPAREN> <SEMI>
  }

  token functionDefinition {
    | <INT> <IDENTIFIER> <LPAREN> [<variableDeclaration>+ % <COMMA>]? <RPAREN> <block>
  }

  token variableDefinition {
    | <variableDeclaration> <SEMI>
  }

  token variableDeclaration {
    | <INT> <IDENTIFIER> <LBRACK> <INTEGER> <RBRACK>
    | <INT> <IDENTIFIER>
  }

  token block {
    | <LBRACE> <statement>* <RBRACE>
  }

  token statement {
    | <block>
    | <ifStatement>
    | <whileStatement>
    | <returnStatement>
    | <variableDefinition>
    | <expression> <SEMI>
    | <SEMI>
  }

  token ifStatement {
    | <IF> <LPAREN> <expression> <RPAREN> <statement> [<ELSE> <statement>]?
  }

  token whileStatement {
    | <WHILE> <LPAREN> <expression> <RPAREN> <statement>
  }

  token returnStatement {
    | <RETURN> <expression> <SEMI>
  }

  token expression {
    | <assignmentExpression>
  }

  token assignmentExpression {
    | <IDENTIFIER> <LBRACK> <expression> <RBRACK> <ASSIGN> <assignmentExpression>
    | <IDENTIFIER> <ASSIGN> <assignmentExpression>
    | <logicOrExpression>
  }

  token logicOrExpression {
    | <logicAndExpression>+ % (<OR>)
  }

  token logicAndExpression {
    | <equalityExpression>+ % (<AND>)
  }

  token equalityExpression {
    | <relationalExpression>+ % (<EQ>|<NE>)
  }

  token relationalExpression {
    | <additiveExpression>+ % (<LT>|<GT>)
  }

  token additiveExpression {
    | <multiplicativeExpression>+ % (<ADD>|<SUB>)
  }

  token multiplicativeExpression {
    | <unaryExpression>+ % (<MUL>|<DIV>|<MOD>)
  }

  token unaryExpression {
    | (<NEG>|<NOT>) <unaryExpression>
    | <postfixExpression>
  }

  token postfixExpression {
    | <IDENTIFIER> <LBRACK> <expression> <RBRACK>
    | <IDENTIFIER> <LPAREN> [<expression>+ % <COMMA>]? <RPAREN>
    | <primaryExpression>
  }

  token primaryExpression {
    | <LPAREN> <expression> <RPAREN>
    | <IDENTIFIER>
    | <INTEGER>
  }

  # ====================
  # Basic Tokens
  # ====================
  token _DEBUG_BASIC_TOKEN {
    [
    |<IF>|<ELSE>|<WHILE>|<RETURN>|<INT>
    |<SEMI>|<COMMA>
    |<LPAREN>|<RPAREN>
    |<LBRACE>|<RBRACE>
    |<LBRACK>|<RBRACK>
    |<IDENTIFIER>
    |<INTEGER>
    |<ASSIGN>
    |<OR>|<AND>
    |<EQ>|<NE>
    |<LT>|<GT>
    |<ADD>|<SUB>
    |<MUL>|<DIV>|<MOD>
    |<NEG>|<NOT>
    ]+
  }
  token IF     { 'if'<DELIM> }
  token ELSE   { 'else'<DELIM> }
  token WHILE  { 'while'<DELIM> }
  token RETURN { 'return'<DELIM> }
  token INT    { 'int'<DELIM> }
  token SEMI   { ';'<DELIM> }
  token COMMA  { ','<DELIM> }
  token LPAREN { '('<DELIM> }
  token RPAREN { ')'<DELIM> }
  token LBRACK { '['<DELIM> }
  token RBRACK { ']'<DELIM> }
  token LBRACE { '{'<DELIM> }
  token RBRACE { '}'<DELIM> }
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
  token IDENTIFIER { <[_A..Za..z]><[_A..Za..z0..9]>*<DELIM> { make $/.Str.chop } }
  token INTEGER { \d+<DELIM> { make $/.Str.chop } }
  token DELIM { '$' }
}

MiniC.parse($*IN.slurp).say;
# dd MiniC.new._RESERVED_WORD;
# say 'int$'.match(/<MiniC::_RESERVED_WORD>/)
