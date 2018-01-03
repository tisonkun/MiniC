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
          if isInteger($instruction<use>[0]) {
            my %instruction;
            %instruction<id> = $instruction<id>;
            %instruction<type> = 'scalarRval';
            %instruction<def> = $instruction<def>;
            %instruction<use> = [resolveUnary($instruction<op>, $instruction<use>[0].Int)];
            $instruction = %instruction;
          }
        }
        when 'binary' {
          if isInteger($instruction<use>[0]) and isInteger($instruction<use>[1]) {
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
  %LINEAR{$function} = Hash.new;
  for ^%blocks.elems -> $blockId {
    for %blocks{$blockId}.Array -> $instruction {
      %LINEAR{$function}{$instruction<id>} = $instruction;
    }
  }
}




# ====================
# Analyse and Allocation
# ====================
my %livenessAnalyse;
for %LINEAR.kv -> $function, %instruction {


  .value.<prev> = [] for %instruction;
  .value.<succ> = [] for %instruction;
  .value.<live> = [] for %instruction;


  %instruction{0}<prev>.push("-1");
  my $maxInstructionId = max(%instruction.keys.map(*.Int));

  for %instruction.kv -> $id, $instruction {
    given $instruction<type> {
      when 'return' {
        ;
      }
      when 'ifFalse' {
        $instruction<succ>.push(resolveLabel($instruction<label>));
        next if $id + 1 > $maxInstructionId;
        $instruction<succ>.push($id + 1);
        $instruction<succ>.unique;
      }
      when 'goto' {
        $instruction<succ>.push(resolveLabel($instruction<label>));
      }
      default {
        next if $id + 1 > $maxInstructionId;
        $instruction<succ>.push($id + 1);
      }
    }
    for $instruction<succ>.Array {
      %instruction{$_}<prev>.push($instruction<id>);
    }
  }

  # note qq:to/END/;
  #   # ====================
  #   # FUNCTION $function
  #   # ====================
  #   END
  #
  # .note for %instruction.Array.sort(*.key.Int);
  # note "";


  # =================
  # Generate Live Range
  # =================
  for %instruction.kv -> $id, $instruction {
    next unless defined $instruction<use>;
    for $instruction<use>.Array -> $usedRval {
      next if isInteger($usedRval);

      my @notifyLiveQueue = [];
      unless $usedRval (elem) $instruction<live> {
        $instruction<live>.push($usedRval);
      } # Do not forget defined and used in the same instruction

      @notifyLiveQueue.append($instruction<prev>.Array);
      while @notifyLiveQueue.elems > 0 {
        my $notifiedId = @notifyLiveQueue.shift;
        next if $notifiedId < 0;
        next if $usedRval (elem) %instruction{$notifiedId}<live>;
        next if $usedRval (elem) %instruction{$notifiedId}<def>;
        %instruction{$notifiedId}<live>.push($usedRval);
        @notifyLiveQueue.append(%instruction{$notifiedId}<prev>.Array);
      }
    }
  }


  my %usedOnCall = Hash.new;
  # =================
  # Generate Live Interval
  # =================
  %livenessAnalyse{$function} = Hash.new;
  for %instruction.kv -> $id, $instruction {
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
      %usedOnCall{$variable} = True if $instruction<type> eq 'call';
    }
  }

  # =================
  # Alloc Register
  # =================
  my @variables = %livenessAnalyse{$function}.Hash;
  @variables.=sort({
    $^a.value<start> != $^b.value<start>
    ?? $^a.value<start> <=> $^b.value<start>
    !! $^b.value<end> <=> $^a.value<end>
  });

  # note qq:to/END/;
  #   # ====================
  #   # FUNCTION $function
  #   # ====================
  #   END
  # .note for @variables;
  # note "";

  my @callerSave = [
    "s0", "s1", "s2", "s3", "s4", "s5",
    "s6", "s7", "s8", "s9", "s10", "s11",
  ];
  my @calleeSave = [
    "t0", "t1", "t2", "t3", "t4", "t5", "t6",
  ];

  my %registers;
  for @variables -> %variableInfo {
    my $variable = %variableInfo.key;

    # =================
    # Expire Variable
    # =================

    for %registers.kv -> $register, $holdVariable {
      if %livenessAnalyse{$function}{$holdVariable}<end> < %livenessAnalyse{$function}{$variable}<start> {
        %registers{$register} :delete;
        @calleeSave.unshift($register) if $register.starts-with("t");
        @callerSave.unshift($register) if $register.starts-with("s");
      }
    }

    # =================
    # Registe Register
    # =================

    if %usedOnCall{$variable} {
      if @calleeSave.elems > 0 {
        my $register = @calleeSave.shift;
        %livenessAnalyse{$function}{$variable}<reg> = $register;
        %registers{$register} = $variable;
        next;
      }
    }

    if @callerSave.elems > 0 {
      my $register = @callerSave.shift;
      %livenessAnalyse{$function}{$variable}<reg> = $register;
      %registers{$register} = $variable;
    }
  }

  # note qq:to/END/;
  #   # ====================
  #   # FUNCTION $function
  #   # ====================
  #   END
  # .note for @variables;
  # note %usedOnCall;
  # note "";
}

# ====================
# Code Generate
# ====================

# ====================
# Utility Function
# ====================
sub resolveLabel(Str $label is copy) is export {
  until isInteger(%SYMBOLS{$label}<location>) {
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

sub isInteger($var) {
  return so $var.match(/^\-?\d+$/);
}
