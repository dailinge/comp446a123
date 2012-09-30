//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Linge Dai on 8/28/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"

@interface CalculatorViewController ()
/* A boolean value to check whether the user is in the middle of typing a number */
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
/* The model of the calculator */
@property (nonatomic, strong) CalculatorBrain *brain;
@end

@implementation CalculatorViewController
@synthesize display = _display;
@synthesize historyDisplay = _historyDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;

/* Getter of the model class. It does lazy instantiation */
- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];   
    return _brain;
}

- (NSString *)execute 
{
    id result = [CalculatorBrain runProgram:[self.brain program] usingVariableValues:self.brain.variables];
    
    if ([result isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%g", [result doubleValue]];
    } else {
        return result;
    }
}

- (void)updateHistoryDisplay 
{
    self.historyDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

- (void)updateResultDisplay 
{
    self.display.text = [self execute];
}

- (void)clearVariableDictionary 
{
    self.brain.variables = [[NSMutableDictionary alloc] init];
}


/* Event handler for the digit buttons */
- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [sender currentTitle];
    
    // If the user is in the middle of typing a number, append the new digit to the current text. If the number already contains a "." for float number, new "." will not be appended to the string. 
    // When the user starts a new number, if the new digit is ".", a "0" is added to the start of the number. If the new digit is "0", it is not appended to the number and it doesn't count toward a valid input. 
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([digit isEqualToString:@"0"]) {
            if ([self.display.text isEqualToString:@"0"]) {
                return;
            }
        }
        NSRange range = [self.display.text rangeOfString:@"."];
        // handle the case of reentering the dot
        if ((range.location != NSNotFound) && ([digit isEqualToString:@"."])) {
            return;
        }
        
        self.display.text = [self.display.text stringByAppendingString:digit];
        
        
    } else {
        if ([digit isEqualToString:@"."]) {
            self.display.text = @"0";
            self.display.text = [self.display.text stringByAppendingString:digit];
        } else if ([digit isEqualToString:@"0"]){
            self.display.text = @"0";
            self.userIsInTheMiddleOfEnteringANumber = YES;
            return;
            
        } else {
            self.display.text = digit;
        }
        
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

/* Event handler of the variable button */
- (IBAction)variablePressed:(UIButton *)sender {
    
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    NSString *variable = [sender currentTitle];
    [self.brain pushOperand:variable];
    
    
    
    //display the value of the variable in the display
    NSNumber *variableValue = [self.brain.variables objectForKey:variable];
    
    if (variableValue) {
        double variableDoubleValue = [variableValue doubleValue];
        self.display.text = [NSString stringWithFormat:@"%g", variableDoubleValue];
        
    } else {
        self.display.text = [NSString stringWithFormat:@"0"];
    }
    [self updateHistoryDisplay];
    
}

/* Event handler of the enter button */
- (IBAction)enterPressed {
    
    if (self.userIsInTheMiddleOfEnteringANumber) {
        // call the pushOperand method in the model to add the operand 
        [self.brain pushOperand:[NSNumber numberWithDouble:[self.display.text doubleValue]]];
        self.userIsInTheMiddleOfEnteringANumber = NO;
    }
    
    else {
        [self.brain pushOperand:@"E"];
    }
    
    [self updateHistoryDisplay];
  
}

/* Event handler of the operation button */
- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }

    NSString *operation = [sender currentTitle];
    
    if ([operation isEqualToString:@"π"] && (self.userIsInTheMiddleOfEnteringANumber)) {
        [self enterPressed];
    }
    
    [self.brain pushOperand:operation];
    [self updateResultDisplay];
    [self updateHistoryDisplay];
}

/* Event handler of the clear button */
- (IBAction)clearPressed {
    // clear the history display text
    self.historyDisplay.text = @"";
    
    // clear the number display text
    self.display.text = @"0";
    
    // user will start a new number
    self.userIsInTheMiddleOfEnteringANumber = NO;
    
    // call the model to clear the operand stack
    [self.brain clearOperand];
    [self clearVariableDictionary];
    
}

/* Event handler of the undo button */
- (IBAction)undoPressed {
    // undo the last digit that is typed in
    if (!self.userIsInTheMiddleOfEnteringANumber) {
        [self.brain removeLastOperand];
    } 
    else {
        NSString *newDisplay = [self.display.text substringToIndex:[self.display.text length] - 1];
        if (![newDisplay isEqualToString:@""]) {
            self.display.text = newDisplay;
            return;
        } 
    }
    
    [self updateResultDisplay];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self updateHistoryDisplay];
}

- (GraphViewController *)splitViewGraphViewController
{
    id gvc = [self.splitViewController.viewControllers lastObject];
    if (![gvc isKindOfClass:[GraphViewController class]]) {
        gvc = nil;
    }
    return gvc;
}

/* The method to perform segue */
- (void)showGraph
{
    if ([self splitViewGraphViewController]) {
        [[self splitViewGraphViewController] setGraphBrain:self.brain];
    } else {
        [self performSegueWithIdentifier:@"ShowGraph" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowGraph"]) {
        [segue.destinationViewController setGraphBrain: self.brain];
    }
}

/* Event handler of the graph button */
- (IBAction)graphPressed {
    // perform a segue to the graph view
    [self showGraph];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


@end
