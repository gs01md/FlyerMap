//
//  UIBezierPath+Points.m
//  OHFMap
//
//  Created by 大新 on 2017/4/25.
//  Copyright © 2017年 ColorfulWood. All rights reserved.
//

#import "UIBezierPath+Points.h"

#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]

@implementation UIBezierPath (Points)
void getPointsFromBezier(void *info,const CGPathElement *element){
    
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    
    if (type != kCGPathElementCloseSubpath) {
        [bezierPoints addObject:VALUE(0)];
        if ((type != kCGPathElementAddLineToPoint) && (type != kCGPathElementMoveToPoint)) {
            [bezierPoints addObject:VALUE(1)];
        }
    }
    
    if (type == kCGPathElementAddCurveToPoint) {
        [bezierPoints addObject:VALUE(2)];
    }
    
}

void pathFunction(void *info, const CGPathElement *element)
{
    if (element->type == kCGPathElementAddQuadCurveToPoint)
    {
        CGPoint p;
        p = element->points[0]; // control point
        NSLog(@"%lg %lg", p.x, p.y);
        
        p = element->points[1]; // end point
        NSLog(@"%lg %lg", p.x, p.y);
    }
    // check other cases as well!
}

- (NSArray *)points{
    
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(self.CGPath, (__bridge void *)points, getPointsFromBezier);
    return points;
    
}
@end
