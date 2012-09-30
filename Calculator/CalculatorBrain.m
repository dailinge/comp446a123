//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Linge Dai on 8/28/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import "CalculatorBrain.h"
#import "math.h"

@interface CalculatorBrain()
/* Array to store the operands */
@property (nonatomic, strong) NSMutableArray *programStack;
@end
@implementation CalculatorBrain

/* The stack to store the operands and operations */
@synthesize programStack = _programStack;

/* The dictionary to store the values of the variables */
@synthesize variables = _variables;

/* Setter of the operandStack. It uses lazy instantiation */
- (NSMutableArray *)programStack
{
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

/* Push operand or operation to the program stack */
- (void)pushOperand:(id)operandObject
{
    [self.programStack addObject:operandObject];
    
}

/* Remove the last operand from the program stack */
- (void)removeLastOperand {
    if ([self.programStack lastObject] != nil) {
        [self.programStack removeLastObject];
    }
}

/* The getter for the program */
- (id)program
{
    // self.programStack is an internal state
    
    // return an immutable array
    return [self.programStack copy];
}


/* The method to evaluate the program description */
+ (NSString *)descriptionOfProgram:(id)program
{
    // introspection
    NSMutableArray *stack = [program mutableCopy];
    NSString *result = [NSMutableString stringWithFormat: @""];
    
    while ([stack lastObject] != nil) {
        result = [NSString stringWithFormat:@"%@%@%@", [CalculatorBrain descriptionOfProgramHelp:stack addParentheses:NO], @",", result];
        
    }
    
    if (![result isEqualToString:@""])
        result = [result substringToIndex:[result length]-1];
    
    return result;
}

+ (NSString *)descriptionOfFirstProgram:(id)program
{
    NSMutableArray *stack = [program mutableCopy];
    NSString *result = [CalculatorBrain descriptionOfProgramHelp:stack addParentheses:NO];
    
    return result;
}

/* The help function of descriptionOfProgram */
+ (NSString *)descriptionOfProgramHelp:(NSMutableArray *)stack
                    addParentheses:(BOOL)need 
{
    NSString *op1;
    NSString *op2;
    NSString *result = @"";
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [NSString stringWithFormat:@"%g", [topOfStack doubleValue]];
    }
    else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            op2 = [CalculatorBrain descriptionOfProgramHelp:stack addParentheses:NO]; 
            op1 = [CalculatorBrain descriptionOfProgramHelp:stack addParentheses:NO];
            if (need == YES) {
                result = [NSString stringWithFormat:@"%@%@%@%@%@", @"(", op1, @"+", op2, @")"];
            } else {
                result = [NSString stringWithFormat:@"%@%@%@", op1, @"+", op2];
            }
            
        } else if ([@"*" isEqualToString:operation]) {
            op2 = [CalculatorBrain descriptionOfProgramHelp:stack addParentheses:YES]; 
            op1 = [CalculatorBrain descriptionOfProgramHelp:stack addParentheses:YES];
            
            result = [NSString stringWithFormat:@"%@%@%@", op1, @"*", op2];
            
            
            
        } else if ([operation isEqualToString:@"-"]) {
            op2 = [CalculatorBrain descriptionOfProgramHelp:stack addParentheses:NO]; 
            op1 = [CalculatorBrain descriptionOfProgramHelp:stack addParentheses:NO];
            if (need == YES) {
                result = [NSString stringWithFormat:@"%@%@%@%@%@", @"(", op1, @"-", op2, @")"];
            } else {
                result = [NSString stringWithFormat:@"%@%@%@", op1, @"-", op2];
            }
            
        } else if ([operation isEqualToString:@"/"]) {
            op2 = [CalculatorBrain descriptionOfProgramHelp:stack addParentheses:YES]; 
            op1 = [CalculatorBrain descriptionOfProgramHelp:stack addParentheses:YES];
            
            result = [NSString stringWithFormat:@"%@%@%@", op1, @"/", op2];
            
        } else if ([operation isEqualToString:@"sin"]) {
            op1 = [CalculatorBrain descriptionOfProgramHelp:stack addParentheses:NO];
            
            result = [NSString stringWithFormat:@"%@%@%@%@", @"sin", @"(",op1,@")"];
            
        } else if ([operation isEqualToString:@"cos"]) {
            op1 = [CalculatorBrain descriptionOfProgramHelp:stack addParentheses:NO];
            
            result = [NSString stringWithFormat:@"%@%@%@%@", @"cos", @"(",op1,@")"];
            
        } else if ([operation isEqualToString:@"sqrt"]) {
            op1 = [CalculatorBrain descriptionOfProgramHelp:stack addParentheses:NO];
            
            result = [NSString stringWithFormat:@"%@%@%@%@", @"sqrt", @"(",op1,@")"];
            
        } else if ([operation isEqualToString:@"π"]) {
            result = operation;
        } else if ([operation isEqualToString:@"E"]) {
            NSMutableArray *nextStack = [stack mutableCopy];
            result = [CalculatorBrain descriptionOfProgramHelp:nextStack addParentheses:NO];
            
        } else {
            return operation;
                    
        }
    }
    
    return result;
}

/* The method to return a collection of the variables used in the input program */
+ (NSSet *)variableUsedInProgram:(id)program
{
    NSMutableSet *variableSet = [[NSMutableSet alloc] init];
    for (id operation in (NSMutableArray *)program) {
        if ([operation isKindOfClass:[NSString class]] && [CalculatorBrain isVariable:operation] ) {
            [variableSet addObject:operation];
        }
    }
    return [variableSet copy];
}

+ (BOOL)isOperation:(NSString *)operation
{
    NSSet *operations = [NSSet setWithObjects:@"+", @"-", @"*", @"/", @"sin", @"cos", @"sqrt", @"π", nil];
    
    return [operations containsObject:operation];
}

+ (BOOL)isVariable:(NSString *)operation
{
    NSSet *variables = [NSSet setWithObjects:@"x", @"a", @"b", nil];
    return [variables containsObject:operation];
}


+ (id)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues;
{
    NSMutableArray *stack;
    id result;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    // popOperandOffStack handles nil
    result = [self popOperandOffStack:stack
         usingVariableValues:variableValues];
    
    return result;
}

/* The method to pop operand off the stack */
/* If there is an error occurring during the process, the method will return the error message string */
+ (id)popOperandOffStack:(NSMutableArray *)stack
     usingVariableValues:(NSDictionary *)variableValues;
{
    id op1;
    id op2;
    
    
    id topOfStack = [stack lastObject];
    if (topOfStack) 
    {
        [stack removeLastObject];
        
        if ([topOfStack isKindOfClass:[NSNumber class]]) {
            return topOfStack;
        }
        
        else if ([topOfStack isKindOfClass:[NSString class]]) {
            NSString *operation = topOfStack;
            if ([operation isEqualToString:@"+"]) {
                op2 = [self popOperandOffStack:stack usingVariableValues:variableValues];
                if ([op2 isKindOfClass:[NSString class]]) {
                    return op2;
                }
                op1 = [self popOperandOffStack:stack usingVariableValues:variableValues];
                if ([op1 isKindOfClass:[NSString class]]) {
                    return op1;
                }
            
                return [NSNumber numberWithDouble:[(NSNumber *)op1 doubleValue]+[(NSNumber *)op2 doubleValue]];
            } else if ([@"*" isEqualToString:operation]) {
                op2 = [self popOperandOffStack:stack usingVariableValues:variableValues];
                if ([op2 isKindOfClass:[NSString class]]) {
                    return op2;
                }
                op1 = [self popOperandOffStack:stack usingVariableValues:variableValues];
                if ([op1 isKindOfClass:[NSString class]]) {
                    return op1;
                }
                return [NSNumber numberWithDouble:[(NSNumber *)op1 doubleValue]*[(NSNumber *)op2 doubleValue]];
            } else if ([operation isEqualToString:@"-"]) {
                op2 = [self popOperandOffStack:stack usingVariableValues:variableValues];
                if ([op2 isKindOfClass:[NSString class]]) {
                    return op2;
                }
                op1 = [self popOperandOffStack:stack usingVariableValues:variableValues];
                if ([op1 isKindOfClass:[NSString class]]) {
                    return op1;
                }
                return [NSNumber numberWithDouble:[(NSNumber *)op1 doubleValue]-[(NSNumber *)op2 doubleValue]];
            } else if ([operation isEqualToString:@"/"]) {
                op2 = [self popOperandOffStack:stack usingVariableValues:variableValues];
                if ([op2 isKindOfClass:[NSString class]]) {
                    return op2;
                }
                op1 = [self popOperandOffStack:stack usingVariableValues:variableValues];
                if ([op1 isKindOfClass:[NSString class]]) {
                    return op1;
                }
                if ([(NSNumber *)op2 doubleValue] == 0) {
                    return @"divide by zero!";
                }
                return [NSNumber numberWithDouble:[(NSNumber *)op1 doubleValue]/[(NSNumber *)op2 doubleValue]];
            } else if ([operation isEqualToString:@"sin"]) {
                op1 = [self popOperandOffStack:stack usingVariableValues:variableValues];
                if ([op1 isKindOfClass:[NSString class]]) {
                    return op1;
                }
                return [NSNumber numberWithDouble:sin([op1 doubleValue])];
            }  else if ([operation isEqualToString:@"cos"]) {
                op1 = [self popOperandOffStack:stack usingVariableValues:variableValues];
                if ([op1 isKindOfClass:[NSString class]]) {
                    return op1;
                }
                return [NSNumber numberWithDouble:cos([(NSNumber *)op1 doubleValue])];
            } else if ([operation isEqualToString:@"sqrt"]) {
                op1 = [self popOperandOffStack:stack usingVariableValues:variableValues];
                if ([op1 isKindOfClass:[NSString class]]) {
                    return op1;
                }
                if ([(NSNumber *)op1 doubleValue] < 0) {
                    return @"square root of a negative number!";
                }
                return [NSNumber numberWithDouble:sqrt([(NSNumber *)op1 doubleValue])];
            } else if ([operation isEqualToString:@"π"]) {
                return [NSNumber numberWithDouble:M_PI];
            } else if ([operation isEqualToString:@"E"]) {
                return [CalculatorBrain runProgram:stack usingVariableValues:variableValues];
                
            } else {
                NSNumber *variableValue = (NSNumber *)[variableValues objectForKey:operation]; 
                if (variableValue) {
                    return variableValue;            
                }
                else {
                    return [NSNumber numberWithDouble:0];
                }
            }
            
        }
    }
    
    return @"not enough operands!";
}

/* The method to clear all the operands from the program stack */
- (void)clearOperand
{
    [self.programStack removeAllObjects];
}


@end
