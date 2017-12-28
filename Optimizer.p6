#!/usr/bin/env perl6

# use MONKEY-SEE-NO-EVAL;

use lib '.';
use Eeyore;

# my @data = $*IN.slurp.lines;
# my %SYMBOLS = EVAL(@data[0]);
# my %FUNCTIONS = EVAL(@data[1]);

note qq:to/END/;
  # ====================
  # SYMBOL TABLE
  # ====================
  END
.note for %SYMBOLS;
note "";
for %FUNCTIONS.kv -> $function, @instruction {
  note qq:to/END/;
    # ====================
    # FUNCTION $function
    # ====================
    END
  .note for @instruction;
  note "";
}

# for %FUNCTIONS.kv -> $function, @instruction {
#
# }
