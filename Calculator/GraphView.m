//
//  GraphView.m
//
//  Created by Linge Dai on 9/16/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@implementation GraphView

@synthesize scale = _scale;
@synthesize dataSource = _dataSource;
@synthesize offset = _offset;
#define DEFAULT_SCALE 12.5

- (CGFloat)scale
{
    if (!_scale) {
        return DEFAULT_SCALE;
    } else {
        return _scale;
    }
}

- (void)setScale:(CGFloat)scale
{
    if (scale != _scale) {
        _scale = scale;
        [self setNeedsDisplay];
    }
}

/* Method that saves the values of scale and offset to NSUserDefaults */
- (void)saveDefaults
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    [currentDefaults setFloat:self.scale
                       forKey:@"default_scale"];
    [currentDefaults setFloat:self.offset.x 
                       forKey:@"offset_x"];
    [currentDefaults setFloat:self.offset.y 
                       forKey:@"offset_y"];
   
}

/* Method that loads the values of scale and offset to NSUserDefaults */
- (void)loadDefaults
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    
    if (currentDefaults) {
        [self setScale:[currentDefaults floatForKey:@"default_scale"]];
        self.offset = CGPointMake([currentDefaults floatForKey:@"offset_x"], [currentDefaults floatForKey:@"offset_y"]);
    }
    
    
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale;
        gesture.scale = 1;
        [self setNeedsDisplay];
        [self saveDefaults];
    }
    
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [gesture translationInView:self];
        self.offset = CGPointMake(self.offset.x + translation.x, self.offset.y + translation.y);
        
        [gesture setTranslation:CGPointZero
                     inView:self];
        [self setNeedsDisplay];
        [self saveDefaults];
    }
}

- (void)tripleTap:(UITapGestureRecognizer *)gesture
{
    self.scale = DEFAULT_SCALE;
    self.offset = CGPointZero;
    
    [self setNeedsDisplay];
    [self saveDefaults];
    
}

- (void)setup
{
    self.contentMode = UIViewContentModeRedraw;
}

/* In both awakeFromNib and initWithFrame, the same set of initializations needs to be done */
- (void)awakeFromNib
{
    [self setup];
    [self loadDefaults];
    [self.dataSource updateDescription];
}

/* It is not called for a UIView coming out of a storyboard */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
        [self loadDefaults];
        [self.dataSource updateDescription];
    }
    
    return self;
}

/* Method that plots the program on the graph */
/* It iterates the x values on the display and calculates the y value according to the program */
- (void)drawCurve:(CGContextRef)context
{
    CGFloat leftx = (-self.offset.x - self.bounds.size.width/2)/self.scale;
    
    CGFloat lefty = [self.dataSource xForYValue:leftx];
    
    CGFloat dispx = self.offset.x+leftx * self.scale + self.bounds.size.width/2;
    CGFloat dispy = self.offset.y - lefty * self.scale + self.bounds.size.height/2;
    
    UIGraphicsPushContext(context);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, dispx, dispy);
    
    for (int i = 1; i < 101; i++) {
        leftx = (self.bounds.size.width/100)/self.scale + leftx;
        lefty = [self.dataSource xForYValue:leftx];
        dispx = leftx * self.scale + self.bounds.size.width/2+self.offset.x;
        dispy = self.offset.y-lefty * self.scale + self.bounds.size.height/2;
        
        CGContextAddLineToPoint(context, dispx, dispy);
    }
    
    CGContextStrokePath(context);
    UIGraphicsPopContext();
    [self setNeedsDisplay];
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGPoint midPoint;
    midPoint.x = self.bounds.size.width/2 + self.offset.x;
    midPoint.y = self.offset.y + self.bounds.size.height/2;

    CGFloat size = self.bounds.size.width/2;
    if (self.bounds.size.height < self.bounds.size.width) 
        size = self.bounds.size.height/2;
    
    [AxesDrawer drawAxesInRect:rect
                 originAtPoint:midPoint
                         scale:self.scale];
    [self drawCurve:UIGraphicsGetCurrentContext()];
    
    [self.dataSource updateDescription];

    
}


@end
