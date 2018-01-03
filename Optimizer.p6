#!/usr/bin/env perl6

# use MONKEY-SEE-NO-EVAL;

use lib '.';
use Eeyore;

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

# ====================
# Fix LABEL
# ====================

for %FUNCTIONS.kv -> $function, @instruction {
  for ^@instruction.elems -> $id {
    if @instruction[$id]<type> eq 'label' {
      next unless $id + 1 < @instruction.elems;
      if @instruction[$id + 1]<type> eq any('label', 'goto') {
        %SYMBOLS{@instruction[$id]<label>}<location> = @instruction[$id + 1]<label>;
      }
    }
  }
}

# note qq:to/END/;
#   # ====================
#   # SYMBOL TABLE
#   # ====================
#   END
# .note for %SYMBOLS;

# ====================
# Build Reachable BLOCKS
# ====================

my %BLOCKS;
for %FUNCTIONS.kv -> $function, @instruction {
  %BLOCKS{$function} = Hash.new;

  my $instructionId = 0;
  my %reachedInstruction = %(0 => True);
  my $blockId = 0;
  %BLOCKS{$function}{$blockId} = [@instruction[$instructionId]];

  while $instructionId < @instruction.elems {
    given @instruction[$instructionId]<type> {
      when 'call' {
        $blockId += 1;
        %BLOCKS{$function}{$blockId} = [];
        %reachedInstruction{$instructionId + 1} = True;
      }
      when 'return' {
        $blockId += 1;
        %BLOCKS{$function}{$blockId} = [];
      }
      when 'ifFalse' {
        $blockId += 1;
        %BLOCKS{$function}{$blockId} = [];
        %reachedInstruction{$instructionId + 1} = True;
        %reachedInstruction{resolveLabel(@instruction[$instructionId]<label>)} = True;
      }
      when 'goto' {
        $blockId += 1;
        %BLOCKS{$function}{$blockId} = [];
        %reachedInstruction{resolveLabel(@instruction[$instructionId]<label>)} = True;
      }
      default {
        %reachedInstruction{$instructionId + 1} = True;
      }
    }

    repeat { $instructionId += 1 } until %reachedInstruction{$instructionId} or $instructionId >= @instruction.elems;
    last if $instructionId >= @instruction.elems;

    if @instruction[$instructionId]<type> eq 'label' {
      if %BLOCKS{$function}{$blockId}.elems > 0 {
        $blockId += 1;
        %BLOCKS{$function}{$blockId} = [];
      }
    }

    %BLOCKS{$function}{$blockId}.push(@instruction[$instructionId]);
  }

  # note qq:to/END/;
  #   # ====================
  #   # FUNCTION $function
  #   # ====================
  #   END
  #
  # for ^%BLOCKS{$function}.elems -> $blockId {
  #   note qq:to/END/;
  #     # ====================
  #     # BLOCKS $blockId
  #     # ====================
  #     END
  #   .note for %BLOCKS{$function}{$blockId}.Array;
  #   note "";
  # }
}

# ====================
# Utility Function
# ====================
sub resolveLabel(Str $label is copy) {
  until %SYMBOLS{$label}<location>.match(/^\d+$/) {
    $label = %SYMBOLS{$label}<location>;
  }
  return %SYMBOLS{$label}<location>;
}
