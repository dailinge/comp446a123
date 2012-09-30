//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Linge Dai on 8/28/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject
/* Method to push the oeprand to the operandStack */
- (void)pushOperand:(id)operandObject;


- (void)removeLastOperand;

@property (readonly) id program;
@property (readwrite, nonatomic, strong) NSMutableDictionary *variables;

/* Pop the operand from the stack */
+ (id)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues;
+ (NSString *)descriptionOfProgram:(id)program;

+ (NSString *)descriptionOfFirstProgram:(id)program;
+ (NSSet *)variableUsedInProgram:(id)program;


/* Method to clear the all the operands from the operandStack */
- (void)clearOperand;

@end
