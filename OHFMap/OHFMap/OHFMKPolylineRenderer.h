//
//  OHFMKPolylineRenderer.h
//  OHFMap
//
//  Created by 大新 on 2017/4/24.
//  Copyright © 2017年 ColorfulWood. All rights reserved.
//

#import <MapKit/MapKit.h>

typedef enum
{
    VGDrawLineLayerStyleTrack, //生涯记分的布局样式
    VGDrawLineLayerStyleDis, //测距的布局样式
    VGDrawLineLayerStyleDisNew, //新的测距的布局样式
    VGDrawLineLayerStyleContestHall, //赛事直播的样式
}VGDrawLineLayerStyle;

@interface PointModel : NSObject

@property(nonatomic, strong) NSString* m_pointX;
@property(nonatomic, strong) NSString* m_pointY;

@end

@interface OHFMKPolylineRenderer : MKPolylineRenderer
@property(nonatomic,strong)NSMutableArray * m_points;
@end
