#!/usr/bin/env perl6

# use Grammar::Tracer;

use lib '.';
use Lexer;

# ====================
# Symbol Counter
# ====================

my $counter = class {
  has $!labelCounter = 0;
  has $!globalCounter = 0;
  has $!localCounter = 0;

  method yieldLabel() {
    my $res = "l$!labelCounter";
    $!labelCounter += 1;
    return $res;
  }
  method yieldGlobal() {
    my $res = "g$!globalCounter";
    $!globalCounter += 1;
    return $res;
  }
  method yieldLocal() {
    my $res = "t$!localCounter";
    $!localCounter += 1;
    return $res;
  }
}.new;


# ====================
# Symbol Table
# ====================

class SymbolTable {
  has @!scopes = {}, ;

  method enterScope() {
    @!scopes.push({});
  }

  method leaveScope() {
    @!scopes.pop();
  }


  method declare(Str $var, %info) {
    self!checkReserved($var);
    self!checkDefined($var, %info);
    @!scopes[*-1]{$var} = %info;
  }

  method getInfo(Str $var) {
    for @!scopes.reverse -> %scope {
      return %scope{$var} if defined %scope{$var};
    }

    die qq:to/END/;
      Cannot refer to identifier $var!
        $var has not been defined.
      END
      ;
  }

  # ===============
  # Check declare
  # ===============
  method !checkReserved(Str $var) {
    state %reseverdWords =
      %(
        "int"    => 0,
        "if"     => 1,
        "else"   => 2,
        "while"  => 3,
        "return" => 4,
      );
    die qq:to/END/ if defined %reseverdWords{$var};
      Cannot defined identifier $var!
        Conflict with reseverd word $var.
      END
      ;
  }

  method !checkDefined($var, %info) {
    return unless defined @!scopes[*-1]{$var};
    return self!dieDefinedVariable($var, %info) unless %info<type> eq 'Function';
    return self!checkDefinedFunction($var, %info);
  }

  method !dieDefinedVariable($var, %info) {
    die qq:to/END/;
      Cannot defined variable $var!
        $var has already been defined in this scope.
      END
      ;
  }

  method !checkDefinedFunction($var, %info) {
    die qq:to/END/ if @!scopes[*-1]{$var}<isDefine>;
      Cannot defined function $var!
        $var has already been defined in this scope.
      END
      ;
    checkFunctionTypeList(%info<typeList>, @!scopes[*-1]{$var}<typeList>)
  }

  method _getScope() {
    return @!scopes[*-1];
  }

  method _getScopes() {
    return @!scopes;
  }

}

# ====================
# Utilty Tools
# ====================

sub checkType(Str $checked, *@checker) {
  die qq:to/END/ unless $checked (elem) @checker
    Type check fails!
      Get $checked,
      expecting @checker[].
    END
    ;
}

sub checkFunctionTypeList(@checked, @checker) {
  die qq:to/END/ unless @checked.elems == @checker.elems;
    Parameters unfit!
      Call with { @checked.elems } parameters,
      expecting { @checker.elems } parameters.
    END
    ;

  for ^@checked.elems -> $i {
    if @checker[$i] eq 'Array' { next if @checked[$i] eq @checker[$i] }
    elsif @checker[$i] eq 'Scalar' { next if @checked[$i] (elem) [@checker[$i], 'Number'] }
    die qq:to/END/;
      Parameters unfit!
        Parameter $i has type @checked[$i],
        expecting @checker[$i].
      END
      ;
  }
  return True;
}

# ====================
# Tokenizer and Parser
# ====================

grammar MiniC {

  # ====================
  # MiniC Syntax
  # ====================

  token TOP { # translateUnit
    :my $*ST = SymbolTable.new;
    <externalDeclaration>+
  }

  token externalDeclaration {
    | <functionDeclaration>
    | <functionDefinition>
    | <variableDefinition> {
      my %info = $<variableDefinition>.made.Hash;
      %info<resolvedId> = $counter.yieldGlobal;
      $*ST.declare(
        $<variableDefinition>.made<id>,
        %info,
      );
      given %info<type> {
        when 'Scalar' { say "var {%info<resolvedId>}" }
        when 'Array'  { say "var {%info<size> * 4} {%info<resolvedId>}" }
      }
    }
  }

  token functionDeclaration {
    | <INT> <IDENTIFIER> <LPAREN> [<variableDeclaration>+ % <COMMA>]? <RPAREN> <SEMI>
      :my %info; {
        %info<id> = $<IDENTIFIER>.made;
        %info<resolvedId> = "f_{%info<id>}";
        %info<isDefine> = False;
        %info<type> = 'Function';
        %info<typeList> = $<variableDeclaration>.Array.map(*.made.<type>);
        $*ST.declare(%info<id>, %info);
      }
  }

  token functionDefinition {
    | <INT> <IDENTIFIER> <LPAREN> [<variableDeclaration>+ % <COMMA>]? <RPAREN>
      :my %info; {
        %info<id> = $<IDENTIFIER>.made;
        %info<resolvedId> = "f_{%info<id>}";
        %info<isDefine> = True;
        %info<type> = 'Function';
        %info<typeList> = $<variableDeclaration>.Array.map(*.made.<type>);
        $*ST.declare(%info<id>, %info);

        say "{%info<resolvedId>} [{%info<typeList>.elems}]";

        $*ST.enterScope;
        for $<variableDeclaration>.Array Z (0...*) {
          my %parameterInfo = .[0].made;
          %parameterInfo<resolvedId> = "p{.[1]}";
          $*ST.declare(%parameterInfo<id>, %parameterInfo);
        }
      } <block> {
        $*ST.leaveScope;
        say "end {%info<resolvedId>}";
      }
  }

  token variableDefinition {
    | <variableDeclaration> <SEMI> {
      make $<variableDeclaration>.made;
    }
  }

  token variableDeclaration {
    | <INT> <IDENTIFIER> <LBRACK> <INTEGER> <RBRACK> {
      make %(
        id => $<IDENTIFIER>.made,
        size => $<INTEGER>.made,
        type => 'Array',
      );
    }
    | <INT> <IDENTIFIER> {
      make %(
        id => $<IDENTIFIER>.made,
        type => 'Scalar',
      );
    }
  }

  token block {
    | <LBRACE> { $*ST.enterScope; } <statement>* { $*ST.leaveScope; } <RBRACE>
  }

  token statement {
    | <block>
    | <ifStatement>
    | <whileStatement>
    | <returnStatement>
    | <variableDefinition> {
      my %info = $<variableDefinition>.made.Hash;
      %info<resolvedId> = $counter.yieldLocal;
      $*ST.declare(
        $<variableDefinition>.made<id>,
        %info,
      );
      given %info<type> {
        when 'Scalar' { say "var {%info<resolvedId>}" }
        when 'Array'  { say "var {%info<size> * 4} {%info<resolvedId>}" }
      }
    }
    | <expression> <SEMI>
    | <SEMI>
  }

  token ifStatement {
    | <IF> <LPAREN> <expression> <RPAREN>
      :my $endLabel = $counter.yieldLabel; {
        say "if {$<expression>.made<id>} == 0 goto $endLabel";
      } <statement> [<ELSE> {
        my $resolvedEndLabel = $counter.yieldLabel;
        say "goto $resolvedEndLabel";
        say "$endLabel:";
        $endLabel = $resolvedEndLabel;
      } <statement>]? {
        say "$endLabel:"
      }
  }

  token whileStatement {
    | <WHILE>
      :my $testLabel = $counter.yieldLabel; {
        say "$testLabel:";
      } <LPAREN> <expression>
      :my $endLabel = $counter.yieldLabel; {
        say "if {$<expression>.made<id>} == 0 goto $endLabel";
      } <RPAREN> <statement> {
        say "goto $testLabel";
        say "$endLabel:";
      }
  }

  token returnStatement {
    | <RETURN> <expression> <SEMI> {
      say "return {$<expression>.made<id>}";
    }
  }

  token expression {
    | <assignmentExpression> {
      make $<assignmentExpression>.made;
    }
  }

  token assignmentExpression {
    | <IDENTIFIER> <LBRACK> <expression> <RBRACK> <ASSIGN> <assignmentExpression> {
      my %info = $*ST.getInfo($<IDENTIFIER>.made);
      checkType(%info<type>, 'Array');
      my $expression = $<expression>.made;
      checkType($expression<type>, 'Scalar', 'Number');
      my $assignmentExpression = $<assignmentExpression>.made;
      checkType($assignmentExpression<type>, 'Scalar', 'Number');

      my $offset;
      given $expression<type> {
          when 'Number' { $offset = $expression<id> * 4 }
          when 'Scalar' {
            my $temp = $counter.yieldLocal;
            say "var $temp";
            say "$temp = {$expression<id>} * 4";
            $offset = $temp;
          }
      }
      say "{%info<resolvedId>} [$offset] = {$assignmentExpression<id>}";
      make $assignmentExpression;
    }
    | <IDENTIFIER> <ASSIGN> <assignmentExpression> {
      my %info = $*ST.getInfo($<IDENTIFIER>.made);
      checkType(%info<type>, 'Scalar');
      my $assignmentExpression = $<assignmentExpression>.made;
      checkType($assignmentExpression<type>, 'Scalar', 'Number');
      say "{%info<resolvedId>} = {$assignmentExpression<id>}";
      make $assignmentExpression;
    }
    | <logicOrExpression> {
      make $<logicOrExpression>.made;
    }
  }

  token logicOrExpression {
    | <logicAndExpression>+ % (<OR>) {
      emitBinOpCode($/, $<logicAndExpression>, $0);
    }
  }

  token logicAndExpression {
    | <equalityExpression>+ % (<AND>) {
      emitBinOpCode($/, $<equalityExpression>, $0);
    }
  }

  token equalityExpression {
    | <relationalExpression>+ % (<EQ>|<NE>) {
      emitBinOpCode($/, $<relationalExpression>, $0);
    }
  }

  token relationalExpression {
    | <additiveExpression>+ % (<LT>|<GT>) {
      emitBinOpCode($/, $<additiveExpression>, $0);
    }
  }

  token additiveExpression {
    | <multiplicativeExpression>+ % (<ADD>|<SUB>) {
      emitBinOpCode($/, $<multiplicativeExpression>, $0);
    }
  }

  token multiplicativeExpression {
    | <unaryExpression>+ % (<MUL>|<DIV>|<MOD>) {
      emitBinOpCode($/, $<unaryExpression>, $0);
    }
  }

  token unaryExpression {
    | (<NEG>|<NOT>) <unaryExpression> {
      my $unaryExpression = $<unaryExpression>.made;
      my $unaryOp = $0.hash.values.[0].made;
      checkType($unaryExpression<type>, 'Scalar', 'Number');

      given $unaryExpression<type> {
        when 'Number' {
          if $unaryOp eq '-' {
            make %(
              id => (-$unaryExpression<id>).Int,
              type => 'Number',
            );
          } else {
            make %(
              id => (!$unaryExpression<id>).Int,
              type => 'Number',
            );
          }
        }
        when 'Scalar' {
          my $temp = $counter.yieldLocal;
          say "var $temp";
          say "$temp = $unaryOp {$unaryExpression<id>}";
          make %(
            id => $temp,
            type => 'Scalar',
          );
        }
      }
    }
    | <postfixExpression> {
      make $<postfixExpression>.made;
    }
  }

  token postfixExpression {
    | <IDENTIFIER> <LBRACK> <expression> <RBRACK> {
      my %info = $*ST.getInfo($<IDENTIFIER>.made);
      checkType(%info<type>, 'Array');
      my $expression = $<expression>[0].made;
      checkType($expression<type>, 'Scalar', 'Number');

      my $offset;
      given $expression<type> {
          when 'Number' { $offset = $expression<id> * 4 }
          when 'Scalar' {
            my $temp = $counter.yieldLocal;
            say "var $temp";
            say "$temp = {$expression<id>} * 4";
            $offset = $temp;
          }
      }

      my $temp = $counter.yieldLocal;
      say "var $temp";
      say "$temp = {%info<resolvedId>} [$offset]";
      make %(
        id => $temp,
        type => 'Scalar',
      );
    }
    | <IDENTIFIER> <LPAREN> [<expression>+ % <COMMA>]? <RPAREN> {
      my %info = $*ST.getInfo($<IDENTIFIER>.made);
      checkType(%info<type>, 'Function');

      my @typeList = [];
      for $<expression>.Array {
        my $expression = .made;
        @typeList.push($expression<type>);
        say "param {$expression<id>}";
      }
      checkFunctionTypeList(@typeList, %info<typeList>);

      my $temp = $counter.yieldLocal;
      say "var $temp";
      say "$temp = call {%info<resolvedId>}";
      make %(
        id => $temp,
        type => 'Scalar',
      );
    }
    | <primaryExpression> {
      make $<primaryExpression>.made;
    }
  }

  token primaryExpression {
    | <LPAREN> <expression> <RPAREN> {
      make $<expression>.made;
    }
    | <IDENTIFIER> {
      my %info = $*ST.getInfo($<IDENTIFIER>.made);
      make %(
        id => %info<resolvedId>,
        type => %info<type>,
      );
    }
    | <INTEGER> {
      make %(
        id => $<INTEGER>.made,
        type => 'Number',
      );
    }
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

die "Syntax error" unless MiniC.parse($TOKENS);
# dd MiniC.new._RESERVED_WORD;
# say 'int$'.match(/<MiniC::_RESERVED_WORD>/)

# ====================
# Utilty Tools
# ====================

sub emitBinOpCode($/, $operands, $operator) {
  my @operands = $operands.Array.map(*.made);
  my @operators = $operator.Array.map(*.hash.values.[0].made);
  if @operands.elems == 1 {
    make @operands[0];
    return;
  }

  checkType(@operands[0]<type>, 'Scalar', 'Number');
  checkType(@operands[1]<type>, 'Scalar', 'Number');
  my $temp = $counter.yieldLocal;
  say "var $temp";
  say "$temp = {@operands[0]<id>} {@operators[0]} {@operands[1]<id>}";
  for 2..^@operands.elems -> $id {
    checkType(@operands[$id]<type>, 'Scalar', 'Number');
    say "$temp = $temp {@operators[$id - 1]} {@operands[$id]<id>}";
  }
  make %(
    id => $temp,
    type => 'Scalar',
  );
}
