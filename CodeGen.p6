#!/usr/bin/env perl6

# use MONKEY-SEE-NO-EVAL;

use lib '.';
use Eeyore;



# ====================
# Fix LABEL Location
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

}

# ====================
# Constant Folder
# ====================

for %BLOCKS.kv -> $function, %blocks {
  for ^%blocks.elems -> $blockId {
    for ^%blocks{$blockId}.Array.elems -> $instructionId {
      my $instruction := %blocks{$blockId}[$instructionId];
      given $instruction<type> {
        when 'unary' {
          if $instruction<use>[0].match(/^\d+$/) {
            my %instruction;
            %instruction<id> = $instruction<id>;
            %instruction<type> = 'scalarRval';
            %instruction<def> = $instruction<def>;
            %instruction<use> = [resolveUnary($instruction<op>, $instruction<use>[0].Int)];
            $instruction = %instruction;
          }
        }
        when 'binary' {
          if $instruction<use>[0].match(/^\d+$/) and $instruction<use>[1].match(/^\d+$/) {
            my %instruction;
            %instruction<id> = $instruction<id>;
            %instruction<type> = 'scalarRval';
            %instruction<def> = $instruction<def>;
            %instruction<use> = [resolveBinary($instruction<op>, $instruction<use>[0].Int, $instruction<use>[1].Int)];
            $instruction = %instruction;
          }
        }
      }
    }
  }
}

# ====================
# Convert BLOCKS to LINEAR
# ====================

my %LINEAR;
for %BLOCKS.kv -> $function, %blocks {
  %LINEAR{$function} = [];
  for ^%blocks.elems -> $blockId {
    %LINEAR{$function}.append(%blocks{$blockId}.Array);
  }
}



# ====================
# Analyse and Allocation
# ====================
my %livenessAnalyse;
for %LINEAR.kv -> $function, @instruction {
  .<prev> = [] for @instruction;
  .<succ> = [] for @instruction;
  .<live> = [] for @instruction;
  @instruction[0]<prev>.push("-1");

  for ^@instruction.elems -> $id {
    my $instruction := @instruction[$id];
    given $instruction<type> {
      when 'return' {
        ;
      }
      when 'ifFalse' {
        $instruction<succ>.push(resolveLabel($instruction<label>));
        next unless $id + 1 < @instruction.elems;
        $instruction<succ>.push($id + 1);
        $instruction<succ>.unique;
      }
      when 'goto' {
        $instruction<succ>.push(resolveLabel($instruction<label>));
      }
      default {
        next unless $id + 1 < @instruction.elems;
        $instruction<succ>.push($id + 1);
      }
    }
    for $instruction<succ>.Array {
      @instruction[$_]<prev>.push($instruction<id>);
    }
  }


  # =================
  # Generate Live Range
  # =================
  for @instruction -> $instruction {
    next unless defined $instruction<use>;
    for $instruction<use>.Array -> $usedRval {
      next if $usedRval.match(/^\d+$/);

      my @notifyLiveQueue = [];
      unless $usedRval (elem) $instruction<live> {
        $instruction<live>.push($usedRval);
      } # Do not forget defined and used in the same instruction

      @notifyLiveQueue.append($instruction<prev>.Array);
      while @notifyLiveQueue.elems > 0 {
        my $notifiedId = @notifyLiveQueue.shift;
        next if $notifiedId < 0;
        next if $usedRval (elem) @instruction[$notifiedId]<live>;
        next if $usedRval (elem) @instruction[$notifiedId]<def>;
        @instruction[$notifiedId]<live>.push($usedRval);
        @notifyLiveQueue.append(@instruction[$notifiedId]<prev>.Array);
      }
    }
  }



  # =================
  # Generate Live Interval
  # =================
  %livenessAnalyse{$function} = Hash.new;
  for @instruction -> $instruction {
    for $instruction<live>.Array -> $variable {
      unless defined %livenessAnalyse{$function}{$variable} {
        %livenessAnalyse{$function}{$variable} = { };
        %livenessAnalyse{$function}{$variable}<start> = Inf;
        %livenessAnalyse{$function}{$variable}<end> = -Inf;
        %livenessAnalyse{$function}{$variable}<reg> = "";
      }
      %livenessAnalyse{$function}{$variable}<start> min= $instruction<id>-1;
      %livenessAnalyse{$function}{$variable}<start> max= 0;
      %livenessAnalyse{$function}{$variable}<end> max= $instruction<id>;
    }
  }

  note qq:to/END/;
    # ====================
    # FUNCTION $function
    # ====================
    END
  .note for %livenessAnalyse{$function}.Hash;
  note "";
}


# for %LINEAR.kv -> $function, @instruction {
#   note qq:to/END/;
#     # ====================
#     # FUNCTION $function
#     # ====================
#     END
#   .note for @instruction;
#   note "";
# }

# ====================
# Utility Function
# ====================
sub resolveLabel(Str $label is copy) is export {
  until %SYMBOLS{$label}<location>.match(/^\d+$/) {
    $label = %SYMBOLS{$label}<location>;
  }
  return %SYMBOLS{$label}<location>;
}

sub resolveUnary(Str $op, Int $x) {
  given $op {
    when '-' { return -$x }
    when '!' { return !$x }
    default { die 'Malformed Unary' }
  }
}

sub resolveBinary(Str $op, Int $lhs, Int $rhs) {
  given $op {
    when '||' { return ($lhs || $rhs) ?? 1 !! 0 }
    when '&&' { return ($lhs && $rhs) ?? 1 !! 0 }
    when '==' { return ($lhs == $rhs) ?? 1 !! 0 }
    when '!=' { return ($lhs != $rhs) ?? 1 !! 0 }
    when '>' { return ($lhs > $rhs) ?? 1 !! 0 }
    when '<' { return ($lhs < $rhs) ?? 1 !! 0 }
    when '+' { return $lhs + $rhs }
    when '-' { return $lhs - $rhs }
    when '*' { return $lhs * $rhs }
    when '/' { return $lhs div $rhs }
    when '%' { return $lhs % $rhs }
    default { die 'Malformed Binary' }
  }
}
