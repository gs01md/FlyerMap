//
//  OHFMKPolylineRenderer.m
//  OHFMap
//
//  Created by 大新 on 2017/4/24.
//  Copyright © 2017年 ColorfulWood. All rights reserved.
//

#import "OHFMKPolylineRenderer.h"

#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]

#define degreesToRadian(x) (M_PI * (x) / 180)
#define BallLineStartDegrees 30.
#define BallLineEndDegrees 50.
#define ShadowLineStartDegrees 20.
#define ShadowLineEndDegrees  40.


#define ContestHall_BallLineStartDegrees 30.
#define ContestHall_BallLineEndDegrees 50.
#define ContestHall_ShadowLineStartDegrees 1.
#define ContestHall_ShadowLineEndDegrees  3.


#define DisLineStartDegrees 10.
#define DisLineEndDegrees 20.

#define TerminalLineWidthHalfTrack  1.
#define TerminalLineWidthHalfContestHall  0.5
#define TerminalLineWidthHalfGpsControl   3.
#define TerminalLineWidthHalfGreenControl   2.
#define TerminalLineWidthHalf ((_layerStyle==VGDrawLineLayerStyleTrack)?TerminalLineWidthHalfTrack:((_layerStyle==VGDrawLineLayerStyleContestHall)?TerminalLineWidthHalfContestHall:(isBetweenGpsControlPoint?TerminalLineWidthHalfGpsControl:TerminalLineWidthHalfGreenControl)))

#define CONTROL_POINT_SCALE 0.26

@implementation PointModel

@end

@interface OHFMKPolylineRenderer()
{
    VGDrawLineLayerStyle _layerStyle;
}
@end

@implementation OHFMKPolylineRenderer

- (void)strokePath:(CGPathRef)path inContext:(CGContextRef)context{
    
    //[super strokePath:path inContext:context];
    CGContextSaveGState(context);
    _layerStyle = VGDrawLineLayerStyleTrack;
    
    [self.m_points removeAllObjects];
    
    CGPathApply(path, (__bridge void *)self.m_points, getPointsFromBezier);
    CGPoint  pointStart , pointEnd;
    
    if (self.m_points.count>0 && [self.m_points[0] isKindOfClass:[PointModel class]]) {
        
        
        PointModel * model = self.m_points[0];
        pointStart.x = [model.m_pointX doubleValue];
        pointStart.y = [model.m_pointY doubleValue];
        
        
        if (self.m_points.count>1 && [self.m_points[1] isKindOfClass:[PointModel class]]) {
            
            PointModel * model = self.m_points[1];
            pointEnd.x = [model.m_pointX doubleValue];
            pointEnd.y = [model.m_pointY doubleValue];
            
        }
    }
    
    //CGContextClip(context);
    CGFloat locs[3] = { 0.0, 0.5, 1.0 };
    CGFloat colors[12];
    if((_layerStyle == VGDrawLineLayerStyleTrack)||(_layerStyle == VGDrawLineLayerStyleContestHall)||(_layerStyle == VGDrawLineLayerStyleDisNew))
    {
        colors[0] = 0.;
        colors[1] = 0.;
        colors[2] = 0.;
        colors[3] = 0.4; // 开始颜色，透明灰
        colors[4] = 0.;
        colors[5] = 0.;
        colors[6] = 0.;
        colors[7] = 0.4;  // 中间颜色，黑色
        colors[8] = 0.;
        colors[9] = 0.;
        colors[10] = 0.;
        colors[11] = 0.4; // 末尾颜色，透明灰
    }
    
    CGFloat colors1[] =
    {
        204.0 / 255.0, 224.0 / 255.0, 244.0 / 255.0, 1.00,
        29.0 / 255.0, 156.0 / 255.0, 215.0 / 255.0, 1.00,
        0.0 / 255.0,  50.0 / 255.0, 126.0 / 255.0, 1.00,
    };
    
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();

    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors1, NULL, sizeof(colors)/(sizeof(colors[0])*4));
    //CGColorSpaceRelease(rgb);
    
    CGContextMoveToPoint(context, pointStart.x, pointStart.y);//设置Path的起点
    //CGContextAddQuadCurveToPoint(context,pointEnd.x/2., pointEnd.y/2. + 500000, pointEnd.x, pointEnd.y);
    CGContextDrawLinearGradient(context, gradient,pointStart ,pointEnd,kCGGradientDrawsAfterEndLocation);
    CGContextStrokePath(context);
    
    //CGContextRestoreGState(context);
    
    NSLog(@"22222");
    //CGContextFillPath(context);
    
//    CGColorSpaceRef sp = CGColorSpaceCreateDeviceRGB();
//    CGGradientRef grad = CGGradientCreateWithColorComponents(sp, colors, locs, 3);
//    CGContextDrawLinearGradient(context, grad, pointStart, pointEnd, 0);
    //CGColorSpaceRelease(sp);
    //CGGradientRelease(grad);
    //CGContextRestoreGState(context);
    
    return;
    
//    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
//    
//    CGContextMoveToPoint(context, pointStart.x, pointStart.y);//设置Path的起点
//    
//    NSLog(@"%f,%f",pointStart.x, pointStart.y);
//    
//    CGPoint  p1 = CGPathGetCurrentPoint(path);
//    
//    CGContextAddQuadCurveToPoint(context,p1.x/2., p1.y/2. + 500000, p1.x, p1.y);
//    
//    CGContextStrokePath(context);
    
    [self drawBezierPathWithBeginPoint:pointStart endPoint:pointEnd context:context isBetweenGpsControlPoint:NO isDiced:YES];
    
    
    
}


-(void)drawBezierPathWithBeginPoint:(CGPoint)beginPoint endPoint:(CGPoint)endPoint context:(CGContextRef)ctx isBetweenGpsControlPoint:(BOOL)isBetweenGpsControlPoint isDiced:(BOOL)isDiced
{
    //fabs获得浮点型的绝对值，整数用abs
    if (fabs((beginPoint.x - endPoint.x)*(beginPoint.x - endPoint.x) + (beginPoint.y - endPoint.y)*(beginPoint.y - endPoint.y)) < 2)
    {
        return;
    }
    
    CGFloat xGap = 0.0;
    CGFloat yGap = 0.0;
    
    // ------------------draw shadow line--------------------
    if ((_layerStyle == VGDrawLineLayerStyleTrack)||(_layerStyle == VGDrawLineLayerStyleContestHall)||(_layerStyle == VGDrawLineLayerStyleDisNew))
    {
        NSMutableArray * lineTwo = [NSMutableArray array];
        if ((_layerStyle == VGDrawLineLayerStyleTrack)||(_layerStyle == VGDrawLineLayerStyleDisNew))
        {
            [lineTwo addObject:[NSValue valueWithCGPoint:endPoint]];
            [lineTwo addObject:[NSValue valueWithCGPoint:[self getControlPointWithBeginPoint:beginPoint endPoint:endPoint isMainLine:NO isTopLine:YES xGap:&xGap yGap:&yGap isBetweenGpsControlPoint:isBetweenGpsControlPoint]]];
            [lineTwo addObject:[NSValue valueWithCGPoint:CGPointMake(beginPoint.x+xGap, beginPoint.y+yGap)]];
            [lineTwo addObject:[NSValue valueWithCGPoint:CGPointMake(beginPoint.x-xGap, beginPoint.y-yGap)]];
            [lineTwo addObject:[NSValue valueWithCGPoint:[self getControlPointWithBeginPoint:beginPoint endPoint:endPoint isMainLine:NO isTopLine:NO xGap:&xGap yGap:&yGap isBetweenGpsControlPoint:isBetweenGpsControlPoint]]];
            [lineTwo addObject:[NSValue valueWithCGPoint:endPoint]];
        }
        else
        {
            [lineTwo addObject:[NSValue valueWithCGPoint:beginPoint]];
            [lineTwo addObject:[NSValue valueWithCGPoint:[self getControlPointWithBeginPoint:endPoint endPoint:beginPoint isMainLine:NO isTopLine:YES xGap:&xGap yGap:&yGap isBetweenGpsControlPoint:isBetweenGpsControlPoint]]];
            [lineTwo addObject:[NSValue valueWithCGPoint:CGPointMake(endPoint.x+xGap, endPoint.y+yGap)]];
            [lineTwo addObject:[NSValue valueWithCGPoint:CGPointMake(endPoint.x-xGap, endPoint.y-yGap)]];
            [lineTwo addObject:[NSValue valueWithCGPoint:[self getControlPointWithBeginPoint:endPoint endPoint:beginPoint isMainLine:NO isTopLine:NO xGap:&xGap yGap:&yGap isBetweenGpsControlPoint:isBetweenGpsControlPoint]]];
            [lineTwo addObject:[NSValue valueWithCGPoint:beginPoint]];
        }
        
        //    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor);
        CGContextSaveGState(ctx);
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, [[lineTwo objectAtIndex:0] CGPointValue].x, [[lineTwo objectAtIndex:0] CGPointValue].y);  //起点坐标
        CGContextAddQuadCurveToPoint(ctx, [[lineTwo objectAtIndex:1] CGPointValue].x, [[lineTwo objectAtIndex:1] CGPointValue].y, [[lineTwo objectAtIndex:2] CGPointValue].x, [[lineTwo objectAtIndex:2] CGPointValue].y);
        CGContextAddLineToPoint(ctx, [[lineTwo objectAtIndex:3] CGPointValue].x, [[lineTwo objectAtIndex:3] CGPointValue].y);
        CGContextAddQuadCurveToPoint(ctx, [[lineTwo objectAtIndex:4] CGPointValue].x, [[lineTwo objectAtIndex:4] CGPointValue].y, [[lineTwo objectAtIndex:5] CGPointValue].x, [[lineTwo objectAtIndex:5] CGPointValue].y);
        //    CGContextEOFillPath(ctx);
        CGContextClip(ctx);
        CGFloat locs[3] = { 0.0, 0.5, 1.0 };
        CGFloat colors[12];
        if((_layerStyle == VGDrawLineLayerStyleTrack)||(_layerStyle == VGDrawLineLayerStyleContestHall)||(_layerStyle == VGDrawLineLayerStyleDisNew))
        {
            colors[0] = 0.;
            colors[1] = 0.;
            colors[2] = 0.;
            colors[3] = 0.4; // 开始颜色，透明灰
            colors[4] = 0.;
            colors[5] = 0.;
            colors[6] = 0.;
            colors[7] = 0.4;  // 中间颜色，黑色
            colors[8] = 0.;
            colors[9] = 0.;
            colors[10] = 0.;
            colors[11] = 0.4; // 末尾颜色，透明灰
        }
        
        CGColorSpaceRef sp = CGColorSpaceCreateDeviceRGB();
        CGGradientRef grad = CGGradientCreateWithColorComponents(sp, colors, locs, 3);
        CGContextDrawLinearGradient(ctx, grad, beginPoint, endPoint, 0);
        CGColorSpaceRelease(sp);
        CGGradientRelease(grad);
        CGContextRestoreGState(ctx);
    }
    
    return;
    
    // --------------------draw ball Line--------------------
    NSMutableArray * lineOne = [NSMutableArray array];
    [lineOne addObject:[NSValue valueWithCGPoint:endPoint]];
    [lineOne addObject:[NSValue valueWithCGPoint:[self getControlPointWithBeginPoint:beginPoint endPoint:endPoint isMainLine:YES isTopLine:YES xGap:&xGap yGap:&yGap isBetweenGpsControlPoint:isBetweenGpsControlPoint]]];
    [lineOne addObject:[NSValue valueWithCGPoint:CGPointMake(beginPoint.x+xGap, beginPoint.y+yGap)]];
    [lineOne addObject:[NSValue valueWithCGPoint:CGPointMake(beginPoint.x-xGap, beginPoint.y-yGap)]];
    [lineOne addObject:[NSValue valueWithCGPoint:[self getControlPointWithBeginPoint:beginPoint endPoint:endPoint isMainLine:YES isTopLine:NO xGap:&xGap yGap:&yGap isBetweenGpsControlPoint:isBetweenGpsControlPoint]]];
    [lineOne addObject:[NSValue valueWithCGPoint:endPoint]];
    
    CGContextSaveGState(ctx);
    //    CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, [[lineOne objectAtIndex:0] CGPointValue].x, [[lineOne objectAtIndex:0] CGPointValue].y);  //起点坐标
    CGContextAddQuadCurveToPoint(ctx, [[lineOne objectAtIndex:1] CGPointValue].x, [[lineOne objectAtIndex:1] CGPointValue].y, [[lineOne objectAtIndex:2] CGPointValue].x, [[lineOne objectAtIndex:2] CGPointValue].y);
    CGContextAddLineToPoint(ctx, [[lineOne objectAtIndex:3] CGPointValue].x, [[lineOne objectAtIndex:3] CGPointValue].y);
    CGContextAddQuadCurveToPoint(ctx, [[lineOne objectAtIndex:4] CGPointValue].x, [[lineOne objectAtIndex:4] CGPointValue].y, [[lineOne objectAtIndex:5] CGPointValue].x, [[lineOne objectAtIndex:5] CGPointValue].y);
    //    CGContextEOFillPath(ctx);
    CGContextClip(ctx);
    CGFloat locs1[3] = { 0.0, 0.5, 1.0 };
    CGFloat colors1[12];
    if(_layerStyle == VGDrawLineLayerStyleTrack)
    {
        colors1[0] = 1.0;
        colors1[1] = 36./255.;
        colors1[2] = 0.;
        colors1[3] = 1.0; // 开始颜色，透明灰
        colors1[4] = 1.0;
        colors1[5] = 78./255.;
        colors1[6] = 0.;
        colors1[7] = 1.0;  // 中间颜色，黑色
        colors1[8] = 1.0;
        colors1[9] = 120./255.;
        colors1[10] = 0.;
        colors1[11] = 1.0; // 末尾颜色，透明灰
    }
    else if (_layerStyle == VGDrawLineLayerStyleDisNew)
    {
        if (isDiced)
        {
            colors1[0] = 1.0;
            colors1[1] = 36./255.;
            colors1[2] = 0.;
            colors1[3] = 0.5; // 开始颜色，透明灰
            colors1[4] = 1.0;
            colors1[5] = 78./255.;
            colors1[6] = 0.;
            colors1[7] = 0.5;  // 中间颜色，黑色
            colors1[8] = 1.0;
            colors1[9] = 120./255.;
            colors1[10] = 0.;
            colors1[11] = 0.5; // 末尾颜色，透明灰
        }
        else
        {
            colors1[0] = 1.0;
            colors1[1] = 36./255.;
            colors1[2] = 0.;
            colors1[3] = 1.0; // 开始颜色，透明灰
            colors1[4] = 1.0;
            colors1[5] = 78./255.;
            colors1[6] = 0.;
            colors1[7] = 1.0;  // 中间颜色，黑色
            colors1[8] = 1.0;
            colors1[9] = 120./255.;
            colors1[10] = 0.;
            colors1[11] = 1.0; // 末尾颜色，透明灰
        }
    }
    else if(_layerStyle == VGDrawLineLayerStyleContestHall)
    {
        colors1[0] = 0xF6/255.;
        colors1[1] = 0xF7/255.;
        colors1[2] = 0x46/255.;
        colors1[3] = 1.0; // 开始颜色
        colors1[4] = 250.0/255.;
        colors1[5] = 78./255.;
        colors1[6] = 35./255.;
        colors1[7] = 1.0;  // 中间颜色
        colors1[8] = 1.0;
        colors1[9] = 0.;
        colors1[10] = 0.;
        colors1[11] = 1.0; // 末尾颜色
    }
    else
    {
        if (isBetweenGpsControlPoint)
        {
            colors1[0] = 1.;
            colors1[1] = 1.;
            colors1[2] = 1.;
            colors1[3] = 1.; // 开始颜色
            colors1[4] = 1.;
            colors1[5] = 1.;
            colors1[6] = 1.;
            colors1[7] = 1.;  // 中间颜色
            colors1[8] = 1.;
            colors1[9] = 1.;
            colors1[10] = 1.;
            colors1[11] = 1.; // 末尾颜色
        }
        else
        {
            colors1[0] = 1.;
            colors1[1] = 1.;
            colors1[2] = 1.;
            colors1[3] = 0.6; // 开始颜色
            colors1[4] = 1.;
            colors1[5] = 1.;
            colors1[6] = 1.;
            colors1[7] = 0.6;  // 中间颜色
            colors1[8] = 1.;
            colors1[9] = 1.;
            colors1[10] = 1.;
            colors1[11] = 0.6; // 末尾颜色
        }
    }
    CGColorSpaceRef sp1 = CGColorSpaceCreateDeviceRGB();
    CGGradientRef grad1 = CGGradientCreateWithColorComponents (sp1, colors1, locs1, 3);
    CGContextDrawLinearGradient(ctx, grad1, beginPoint, endPoint, 0);
    CGColorSpaceRelease(sp1);
    CGGradientRelease(grad1);
    CGContextRestoreGState(ctx);
}


-(CGPoint)getControlPointWithBeginPoint:(CGPoint)beginPoint endPoint:(CGPoint)endPoint isMainLine:(BOOL)isMainLine isTopLine:(BOOL)isTopLine xGap:(CGFloat *)xGap  yGap:(CGFloat *)yGap isBetweenGpsControlPoint:(BOOL)isBetweenGpsControlPoint
{
    CGPoint controlPoint = CGPointMake(0, 0);
    if (fabs((beginPoint.x - endPoint.x)*(beginPoint.x - endPoint.x) + (beginPoint.y - endPoint.y)*(beginPoint.y - endPoint.y)) < 2)
    {
        return CGPointMake((beginPoint.x+endPoint.x)/2., (beginPoint.y+endPoint.y)/2.);
    }
    CGFloat alpha = .0;
    CGFloat beta = .0;
    if ((_layerStyle == VGDrawLineLayerStyleTrack)||(_layerStyle == VGDrawLineLayerStyleDisNew))
    {
        if (isMainLine)
        {
            alpha = degreesToRadian(BallLineStartDegrees);
            beta = degreesToRadian(BallLineEndDegrees);
        }
        else
        {
            alpha = degreesToRadian(ShadowLineStartDegrees);
            beta = degreesToRadian(ShadowLineEndDegrees);
        }
    }
    else if (_layerStyle == VGDrawLineLayerStyleContestHall)
    {
        if (isMainLine)
        {
            alpha = degreesToRadian(ContestHall_BallLineStartDegrees);
            beta = degreesToRadian(ContestHall_BallLineEndDegrees);
        }
        else
        {
            alpha = degreesToRadian(ContestHall_ShadowLineStartDegrees);
            beta = degreesToRadian(ContestHall_ShadowLineEndDegrees);
        }
    }
    else
    {
        alpha = degreesToRadian(DisLineStartDegrees);
        beta = degreesToRadian(DisLineEndDegrees);
    }
    
    CGFloat tgAlpha = tanf(alpha);
    CGFloat tgBeta = tanf(beta);
    
    CGFloat xe2 = (beginPoint.x-endPoint.x)*(beginPoint.x-endPoint.x);
    CGFloat ye2 = (beginPoint.y-endPoint.y)*(beginPoint.y-endPoint.y);
    CGFloat xye2 = sqrtf(xe2+ye2);
    CGFloat A = xye2/(1+tgAlpha/tgBeta);
    CGFloat B = xye2/(1+tgBeta/tgAlpha);
    CGFloat C;
    if (isTopLine)
    {
        C = B * tgBeta + 5;
    }
    else
    {
        C = B * tgBeta;
    }
    CGFloat sita = atanf(fabs(beginPoint.y-endPoint.y)/fabs(beginPoint.x-endPoint.x));
    if ((endPoint.x >= beginPoint.x)&&(endPoint.y <= beginPoint.y))// 1
    {
        CGFloat x0 = endPoint.x - B * cosf(sita);
        CGFloat y0 = endPoint.y + B * sinf(sita);
        CGFloat gama = M_PI_2 - sita;
        controlPoint = CGPointMake(x0-C*cosf(gama), y0-C*sinf(gama));
        if (sita+alpha>M_PI/2)
        {
            CGFloat delta = alpha+sita-M_PI_2;
            *xGap = -TerminalLineWidthHalf * cosf(delta);
            *yGap = TerminalLineWidthHalf * sinf(delta);
        }
        else
        {
            CGFloat delta = M_PI_2-alpha-sita;
            *xGap = -TerminalLineWidthHalf * cosf(delta);
            *yGap = -TerminalLineWidthHalf * sinf(delta);
        }
    }
    else if ((endPoint.x < beginPoint.x)&&(endPoint.y <= beginPoint.y)) //2
    {
        CGFloat x0 = endPoint.x + B * cosf(sita);
        CGFloat y0 = endPoint.y + B * sinf(sita);
        CGFloat gama = M_PI_2 - sita;
        controlPoint = CGPointMake(x0+C*cosf(gama), y0-C*sinf(gama));
        if (sita+alpha>M_PI/2)
        {
            CGFloat delta = alpha+sita-M_PI_2;
            *xGap = TerminalLineWidthHalf * cosf(delta);
            *yGap = TerminalLineWidthHalf * sinf(delta);
        }
        else
        {
            CGFloat delta = M_PI_2-alpha-sita;
            *xGap = TerminalLineWidthHalf * cosf(delta);
            *yGap = -TerminalLineWidthHalf * sinf(delta);
        }
    }
    else if ((endPoint.x < beginPoint.x)&&(endPoint.y > beginPoint.y)) //3
    {
        CGFloat x0 = beginPoint.x - A * cosf(sita);
        CGFloat y0 = beginPoint.y + A * sinf(sita);
        CGFloat gama = M_PI_2 - sita;
        controlPoint = CGPointMake(x0-C*cosf(gama), y0-C*sinf(gama));
        if (sita>alpha)
        {
            CGFloat delta = sita-alpha;
            *xGap = -TerminalLineWidthHalf * sinf(delta);
            *yGap = -TerminalLineWidthHalf * cosf(delta);
        }
        else
        {
            CGFloat delta = alpha-sita;
            *xGap = TerminalLineWidthHalf * sinf(delta);
            *yGap = -TerminalLineWidthHalf * cosf(delta);
        }
    }
    else
    {
        CGFloat x0 = beginPoint.x + A * cosf(sita);
        CGFloat y0 = beginPoint.y + A * sinf(sita);
        CGFloat gama = M_PI_2 - sita;
        controlPoint = CGPointMake(x0+C*cosf(gama), y0-C*sinf(gama));
        if (sita>alpha)
        {
            CGFloat delta = sita-alpha;
            *xGap = TerminalLineWidthHalf * sinf(delta);
            *yGap = -TerminalLineWidthHalf * cosf(delta);
        }
        else
        {
            CGFloat delta = alpha-sita;
            *xGap = -TerminalLineWidthHalf * sinf(delta);
            *yGap = -TerminalLineWidthHalf * cosf(delta);
        }
    }
    
    return controlPoint;
}



- (void)strokePathOld:(CGPathRef)path inContext:(CGContextRef)context{
    
    [super strokePath:path inContext:context];
    
    CGRect rect1 = CGPathGetBoundingBox(path);
    NSLog(@"%@",rect1);
//    CLLocationCoordinate2D coordinateStart = CLLocationCoordinate2DMake(39.55, 116.23);
//    CLLocationCoordinate2D coordinateEnd = CLLocationCoordinate2DMake(31.2, 121.4);
//    
//    MKMapPoint pointStart = MKMapPointForCoordinate(coordinateStart);
//    MKMapPoint pointEnd = MKMapPointForCoordinate(coordinateEnd);
    
    //CGContextAddPath(context, path) ;
    
    //UIBezierPath * bezierPath = [UIBezierPath bezierPathWithCGPath:path];
//    [bezierPath addClip];
//    bezierPath.lineCapStyle = kCGLineCapRound; //线条拐角
//    bezierPath.lineJoinStyle = kCGLineCapRound; //终点处理
    //CGContextAddPath(context, bezierPath.CGPath);
    //
    
    
    //NSArray* array = [self points:bezierPath];
    
    //[self.m_points removeAllObjects];
    
    NSMutableArray * array = [NSMutableArray new];
    
    //CGPathApply(path, (__bridge void * _Nullable)(self), pathFunc);
    CGPathApply(path, (__bridge void *)array, getPointsFromBezier);
    CGPoint  pointStart , pointEnd;
    
    if (array.count>0 && [array[0] isKindOfClass:[PointModel class]]) {
        
        
        PointModel * model = array[0];
        pointStart.x = [model.m_pointX doubleValue];
        pointStart.y = [model.m_pointY doubleValue];
        
        
        if (self.m_points.count>1 && [array[1] isKindOfClass:[PointModel class]]) {
            PointModel * model = array[1];
            pointEnd.x = [model.m_pointX doubleValue];
            pointEnd.y = [model.m_pointY doubleValue];
            
            
            
            
        }
    }
    

    
//    double startX = pointStart.x;
//    double startY = pointStart.y;
//    double endX = pointEnd.x;
//    double endY = pointEnd.y;
    
    
//    for (int i=0; i<array.count; i++) {
//        
//        //if (i==1) {
//            
//            CGPoint * point = (__bridge CGPoint *)(array[i]);
//        
//        NSLog(@"%@",point);
//            //[bezierPath addQuadCurveToPoint:*point controlPoint:CGPointMake(0, 30000)];
//        //}
//    }
    //CGContextAddPath(context, bezierPath.CGPath);
    
//    CGContextBeginPath(context);
//    CGContextMoveToPoint(context, 0, 0);//设置Path的起点
//    CGContextAddQuadCurveToPoint(context,10, 10, point->x*100, point->y*100);//设置贝塞尔曲线的控制点坐标和终点坐标
//    
//    MKMapPoint * points1 = self.polyline.points;
//    CGContextAddLineToPoint(context, points1->x*10000, points1->y*10000);
    
    //CGContextAddPath(context, bezierPath.CGPath);

    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    CGContextMoveToPoint(context, pointStart.x, pointStart.y);//设置Path的起点

    NSLog(@"%f,%f",pointStart.x, pointStart.y);
    
    CGPoint  p1 = CGPathGetCurrentPoint(path);

    //NSLog(@"移动到点：{%f,%f}",p1.x , p1.y);
    //CGContextAddLineToPoint(context, p1.x , p1.y);
    
    double distance = sqrt(pow((pointStart.x - pointEnd.x), 2) + pow((pointStart.y - pointEnd.y), 2));
    
    CGContextAddQuadCurveToPoint(context,p1.x/2., p1.y/2. + 500000, p1.x, p1.y);
    

    //CGContextMoveToPoint(context, pointEnd->x, pointEnd->y);//设置Path的起点
    //CGContextMoveToPoint(context, pointEnd->x, pointEnd->y);//设置Path的起点
    
    CGGradientRef gradientRef = [self jianbianse];
    
    //CGContextDrawLinearGradient(context,gradientRef, CGPointMake(0.0f, 0.0f), CGPointMake(p1.x, p1.y), 0);
    
    
    CGContextStrokePath(context);
    return;
    
    
    
    //CGPathApply(path, nil, func);
    
    MKMapPoint * points = self.polyline.points;
    MKMapRect rect = self.polyline.boundingMapRect;
    
    
    CGContextBeginPath(context);
    /*画贝塞尔曲线*/
    //二次曲线
    CGContextMoveToPoint(context, 0, 0);//设置Path的起点
    //CGContextAddQuadCurveToPoint(context,points->x, points->y, points->x, points->y);//设置贝塞尔曲线的控制点坐标和终点坐标
    
//    //三次曲线函数
//    CGContextMoveToPoint(context, 200, 300);//设置Path的起点
//    CGContextAddCurveToPoint(context,250, 280, 250, 400, 280, 300);//设置贝塞尔曲线的控制点坐标和控制点坐标终点坐标
//    CGContextStrokePath(context);
    
    
    //CGContextAddQuadCurveToPoint(context, points->x/2., 0, points->y, points->x);
    
    //CLLocationCoordinate2D coordinate2 = CLLocationCoordinate2DMake(31.2, 121.4);
    
    //MKMapPoint point2 = MKMapPointForCoordinate(coordinate2);
    CGContextAddLineToPoint(context, points->y,points->x);
    
//    [[UIColor yellowColor]setFill];
//    [[UIColor redColor]setStroke];
    
    CGContextStrokePath(context);
    
    //绘制路径
    //CGContextDrawPath(context, kCGPathFillStroke);
    
}

-(CGGradientRef)jianbianse {
    
    
    //创建色彩空间对象
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    //创建起点颜色
    CGColorRef beginColor = CGColorCreate(colorSpaceRef, (CGFloat[]){0.01f, 0.99f, 0.01f, 1.0f});
    
    //创建终点颜色
    CGColorRef endColor = CGColorCreate(colorSpaceRef, (CGFloat[]){0.99f, 0.99f, 0.01f, 1.0f});
    
    //创建颜色数组
    CFArrayRef
    colorArray = CFArrayCreate(kCFAllocatorDefault, (const void*[]){beginColor,
        endColor}, 2, nil);
    
    //创建渐变对象
    CGGradientRef gradientRef = CGGradientCreateWithColors(colorSpaceRef, colorArray, (CGFloat[]){
        0.0f,      
        //对应起点颜色位置
        1.0f       
        //对应终点颜色位置
    });
    
    return gradientRef;
}

void pathFunc(void * __nullable info,
          const CGPathElement *  element){

    OHFMKPolylineRenderer *this = (__bridge OHFMKPolylineRenderer *)info;
    
    CGPoint point = *(*element).points;
    CGPoint po = CGPointMake(point.x, point.y);

    switch ((*element).type) {
        case kCGPathElementMoveToPoint:
            NSLog(@"移动到点：{%f,%f}",point.x , point.y);
            break;
        case kCGPathElementAddLineToPoint:
            NSLog(@"添加线到点：{%f,%f}",point.x , point.y);
            break;
        case kCGPathElementAddQuadCurveToPoint:
            //NSLog(@"移动到点：%@",(*element).points);
            break;
        case kCGPathElementAddCurveToPoint:
            //NSLog(@"移动到点：%@",(*element).points);
            break;
        case kCGPathElementCloseSubpath:
            //NSLog(@"移动到点：%@",(*element).points);
            break;
        default:
            break;
    }
    
}

-(void)ddd{
    
    // 北京的位置
    CLLocation *location = [[CLLocation alloc] initWithLatitude:39.55 longitude:116.23];
    // 上海的位置
    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:31.2 longitude:121.4];
    
    CLLocationCoordinate2D coordinate1 = CLLocationCoordinate2DMake(39.55, 116.23);
    CLLocationCoordinate2D coordinate2 = CLLocationCoordinate2DMake(31.2, 121.4);
    
    MKMapPoint point1 = MKMapPointForCoordinate(coordinate1);
    MKMapPoint point2 = MKMapPointForCoordinate(coordinate2);
//    CGContextMoveToPoint(context, point1.x, point1.y);//设置Path的起点
//    CGContextAddLineToPoint(context, point2.x,point2.y);
//    CGContextStrokePath(context);
}

void getPointsFromBezier(void *info,const CGPathElement *element){
    
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    
    
    if (type != kCGPathElementCloseSubpath) {
        //[bezierPoints addObject:VALUE(0)];
        
        CGPoint p = points[0];
        PointModel * model = [PointModel new];
        model.m_pointX = [NSString stringWithFormat:@"%f",p.x];
        model.m_pointY = [NSString stringWithFormat:@"%f",p.y];
        [bezierPoints addObject:model];
        
        if ((type != kCGPathElementAddLineToPoint) && (type != kCGPathElementMoveToPoint)) {
            //[bezierPoints addObject:VALUE(1)];
            
            CGPoint p = points[1];
            PointModel * model = [PointModel new];
            model.m_pointX = [NSString stringWithFormat:@"%f",p.x];
            model.m_pointY = [NSString stringWithFormat:@"%f",p.y];
            [bezierPoints addObject:model];
        }
    }
    
    if (type == kCGPathElementAddCurveToPoint) {
        //[bezierPoints addObject:VALUE(2)];
        
        CGPoint p = points[2];
        PointModel * model = [PointModel new];
        model.m_pointX = [NSString stringWithFormat:@"%f",p.x];
        model.m_pointY = [NSString stringWithFormat:@"%f",p.y];
        [bezierPoints addObject:model];
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
    

}


- (NSArray *)points:(UIBezierPath*)bezier{
    
    
    [self.m_points removeAllObjects];
    
    CGPathApply(bezier.CGPath, (__bridge void *)self.m_points, getPointsFromBezier);
    return self.m_points;
    
}

-(NSMutableArray*)m_points{
    
    if (!_m_points) {
        _m_points = [NSMutableArray array];
    }
    
    return _m_points;
}



@end
