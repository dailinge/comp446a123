//
//  GraphView.h
//
//  Created by Linge Dai on 9/16/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphViewDataSource
- (CGFloat)xForYValue:(CGFloat)x;
- (void)updateDescription;
@end

@interface GraphView : UIView

/* scale of the display */
@property (nonatomic) CGFloat scale;

/* offset of the display */
@property (nonatomic) CGPoint offset;

/* gesture recognizers */
- (void)pinch:(UIPinchGestureRecognizer *)gesture;
- (void)pan:(UIPinchGestureRecognizer *)gesture;
- (void)tripleTap:(UITapGestureRecognizer *)gesture;

@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;

@end
