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
  %SYMBOLS{$function}<usedCallee> = Hash.new;
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
        %SYMBOLS{$function}<usedCallee>{$register} = True;
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
  # note %SYMBOLS{$function}<usedCallee>;
  # note "";
  # exit;
}

# ====================
# Code Generate
# ====================

for %SYMBOLS.kv -> $id, %info {
  next unless isGlobal($id);
  say "\t.comm\t$id,{%info<size>},4";
}

for %LINEAR.kv -> $function, %instruction {
  my @instruction = %instruction.values.sort(*.<id>);

  # note qq:to/END/;
  #   # =================
  #   # Function $function
  #   # =================
  #   END
  # .note for @instruction;
  # note "";

  my @callerSave = [
    "s0", "s1", "s2", "s3", "s4", "s5",
    "s6", "s7", "s8", "s9", "s10", "s11",
  ];
  my @calleeSave = [
    "t0", "t1", "t2", "t3", "t4", "t5", "t6",
  ];

  my @riscvCode;
  my $stackSize = 0;
  my $currentParameterId = 0;
  my %registers;
  my %variables;

  # ====================
  # Generate Function Head
  # ====================

  @riscvCode.push("\t.text");
  @riscvCode.push("\t.align\t2");
  @riscvCode.push("\t.global\t{$function.substr(2)}");
  @riscvCode.push("\t.type\t{$function.substr(2)}, \@function");
  @riscvCode.push("{$function.substr(2)}:");
  @riscvCode.push("\tadd\tsp,sp,-STK");
  @riscvCode.push("\tsw\tra,STK-4(sp)");

  # ====================
  # Store Used Callee
  # ====================
  my @usedCallee = %SYMBOLS{$function}<usedCallee>.keys;
  for @usedCallee Z (1..*) -> ($register, $location) {
    @riscvCode.push("\tsw\t$register,{$location*4}(sp)");
    $stackSize += 1;
  }

  # ====================
  # Handle Parameters
  # ====================
  for ^%SYMBOLS{$function}<nParam> -> $i {
    registVariable("p$i");
    my $reg = getRegister("p$i", "a0");
    @riscvCode.push("\tmv\t$reg,a$i");
    storeIfSpilled("p$i", $reg);
  }


  # ====================
  # Main Code Generate
  # ====================
  for @instruction -> $instruction {

    # =================
    # Expire Register
    # =================
    my @saveBackGlobal;
    for %registers.kv -> $register, $holdVariable {
      if %livenessAnalyse{$function}{$holdVariable}<end> < $instruction<id> {
        @saveBackGlobal.push(($register, $holdVariable)) if isGlobal($holdVariable);
        %registers{$register} :delete;
      }
    }

    if $instruction<type> ne 'label' {
      for @saveBackGlobal -> ($register, $holdVariable) {
        next if isArray($holdVariable);
        @riscvCode.push("\tlui\ta5,\%hi($holdVariable)");
        @riscvCode.push("\tsw\t$register,\%lo($holdVariable)(a5)");
      }
    }

    given $instruction<type> {
      when 'param' {
        if $currentParameterId eq 0 {
          for %registers.kv -> $register, $variable {
            storeCaller($register, $variable);
          }
        }
        registVariable($instruction<use>.Array[0]);
        loadParameter($currentParameterId, $instruction<use>.Array[0]);
        $currentParameterId += 1;
      }
      when 'call' {
        $currentParameterId = 0;
        @riscvCode.push("\tcall\t{$instruction<function>.substr(2)}");
        for %registers.kv -> $register, $variable {
          loadCaller($register, $variable);
        }
        if isDefineValid($instruction<def>, $instruction) {
          registVariable($instruction<def>);
          my $register = getRegister($instruction<def>, "a2");
          @riscvCode.push("\tmv\t$register,a0");
          storeIfSpilled($instruction<def>, $register);
        }
      }
      when 'return' {
        registVariable($instruction<use>.Array[0]);
        my $register = getRegister($instruction<use>.Array[0], "a0");
        @riscvCode.push("\tmv\ta0,$register");
        @riscvCode.push("\tlw\tra,STK-4(sp)");
        @riscvCode.push("\tadd\tsp,sp,STK");
        @riscvCode.push("\tjr\tra");
      }
      when 'scalarRval' {
        if isDefineValid($instruction<def>, $instruction) {
          registVariable($instruction<def>);
          registVariable($instruction<use>.Array[0]);
          my $reg2 = getRegister($instruction<def>, "a2");
          my $reg0 = getRegister($instruction<use>.Array[0], "a0");
          @riscvCode.push("\tmv\t$reg2,$reg0");
          storeIfSpilled($instruction<def>, $reg2);
        }
      }
      when 'binary' {
        if isDefineValid($instruction<def>, $instruction) {
          registVariable($instruction<def>);
          registVariable($instruction<use>.Array[0]);
          registVariable($instruction<use>.Array[1]);
          my $reg2 = getRegister($instruction<def>, "a2");
          my $reg0 = getRegister($instruction<use>.Array[0], "a0");
          my $reg1 = getRegister($instruction<use>.Array[1], "a1");
          given $instruction<op> {
            when '||' {
              @riscvCode.push("\tor\t$reg2,$reg0,$reg1");
              @riscvCode.push("\tsnez\t$reg2,$reg2");
            }
            when '&&' {
              @riscvCode.push("\tand\t$reg2,$reg0,$reg1");
              @riscvCode.push("\tsnez\t$reg2,$reg2");
            }
            when '==' {
              @riscvCode.push("\txor\t$reg2,$reg0,$reg1");
              @riscvCode.push("\tseqz\t$reg2,$reg2");
            }
            when '!=' {
              @riscvCode.push("\txor\t$reg2,$reg0,$reg1");
              @riscvCode.push("\tsnez\t$reg2,$reg2");
            }
            when '<' {
              @riscvCode.push("\tslt\t$reg2,$reg0,$reg1");
            }
            when '>' {
              @riscvCode.push("\tsgt\t$reg2,$reg0,$reg1");
            }
            when '+' {
              @riscvCode.push("\tadd\t$reg2,$reg0,$reg1");
            }
            when '-' {
              @riscvCode.push("\tsub\t$reg2,$reg0,$reg1");
            }
            when '*' {
              @riscvCode.push("\tmul\t$reg2,$reg0,$reg1");
            }
            when '/' {
              @riscvCode.push("\tdiv\t$reg2,$reg0,$reg1");
            }
            when '%' {
              @riscvCode.push("\trem\t$reg2,$reg0,$reg1");
            }
          }
          storeIfSpilled($instruction<def>, $reg2);
        }
      }
      default {
        die "NYI {$instruction<type>}";
      }
    }

    if $instruction<type> eq 'label' {
      for @saveBackGlobal -> ($register, $holdVariable) {
        next if isArray($holdVariable);
        @riscvCode.push("\tlui\ta5,\%hi($holdVariable)");
        @riscvCode.push("\tsw\t$register,\%lo($holdVariable)(a5)");
      }
    }

  }

  # ====================
  # Recover Used Callee
  # ====================

  for @usedCallee Z (1..*) -> ($register, $location) {
    @riscvCode.push("\tlw\t$register,{$location*4}(sp)");
  }

  @riscvCode.push("\t.size\t{$function.substr(2)}, .-{$function.substr(2)}");

  my $riscvCode = @riscvCode.join("\n");
  my $STK = (($stackSize div 4) + 1) * 16;
  say $riscvCode.subst(/STK\-4/, $STK - 4, :g)
                .subst(/STK/, $STK, :g);


  # ====================
  # Utility Function
  # ====================

  sub loadParameter($currentParameterId, $rightValue) {
    my $register = "a$currentParameterId";
    if isInteger($rightValue) {
      @riscvCode.push("\tli\t$register,$rightValue");
    } elsif %variables{$rightValue}<reg> {
      @riscvCode.push("\tmv\t$register,{%variables{$rightValue}<reg>}");
    } else {
      if isGlobal($rightValue) {
        @riscvCode.push("\tlui\t$register,\%hi($rightValue)");
        @riscvCode.push("\tlw\t$register,\%lo($rightValue)($register)");
      } else {
        @riscvCode.push("\tlw\t$register,{%variables{$rightValue}<location>*4}(sp)");
      }
    }
  }

  sub registVariable($variable) {
    return if isInteger($variable);
    return if defined %variables{$variable};
    %variables{$variable} = Hash.new;
    if %livenessAnalyse{$function}{$variable}<reg> {
      my $register = %livenessAnalyse{$function}{$variable}<reg>;
      %variables{$variable}<reg> = $register;
      %registers{$register} = $variable;
    }
    return if isGlobal($variable);
    %variables{$variable}<location> = $stackSize;
    $stackSize += %SYMBOLS{$variable}<size> div 4;
  }

  sub getRegister($variable, $spilled) {
    if isInteger($variable) {
      @riscvCode.push("\tli\ta0,$variable");
      return "a0";
    }
    if %variables{$variable}<reg> {
      return %variables{$variable}<reg>;
    }
    loadSpilled($variable, $spilled);
    return "a$spilled";
  }

  sub loadSpilled($variable, $spilled) {
    if isGlobal($variable) {
      @riscvCode.push("\tlui\ta5,\%hi($variable)");
      @riscvCode.push("\tlw\t$spilled,\%lo($variable)(a5)");
    } else {
      @riscvCode.push("\tlw\t$spilled,{%variables{$variable}<location>*4}(sp)");
    }
  }

  sub storeIfSpilled($variable, $spilled) {
    return if isInteger($variable);
    return if isArray($variable);
    return if %variables{$variable}<reg>;
    if isGlobal($variable) {
      @riscvCode.push("\tlui\ta5,\%hi($variable)");
      @riscvCode.push("\tsw\t$spilled,\%lo($variable)(a5)");
    } else {
      @riscvCode.push("\tsw\t$spilled,{%variables{$variable}<location>*4}(sp)");
    }
  }

  sub loadCaller($register, $variable) {
    return unless $register (elem) @callerSave;
    if isGlobal($variable) {
      @riscvCode.push("\tlui\ta5,\%hi($variable)");
      @riscvCode.push("\tlw\t$register,\%lo($variable)(a5)");
    } else {
      @riscvCode.push("\tlw\t$register,{%variables{$variable}<location>*4}(sp)");
    }
  }

  sub storeCaller($register, $variable) {
    return unless $register (elem) @callerSave;
    if isGlobal($variable) {
      @riscvCode.push("\tlui\ta5,\%hi($variable)");
      @riscvCode.push("\tsw\t$register,\%lo($variable)(a5)");
    } else {
      @riscvCode.push("\tsw\t$register,{%variables{$variable}<location>*4}(sp)");
    }
  }

  sub isDefineValid($variable, $instruction) {
    return False if isInteger($variable);
    return False unless defined %livenessAnalyse{$function}{$variable};
    return %livenessAnalyse{$function}{$variable}<start> <= $instruction<id>;
  }

}


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

sub isGlobal($id) {
  return False unless defined %SYMBOLS{$id};
  return $id.starts-with("g");
}

sub isArray($id) {
  return False unless defined %SYMBOLS{$id};
  return %SYMBOLS{$id}<type> eq 'Array';
}
