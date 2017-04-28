//
//  ViewController.m
//  OHFMap
//
//  Created by 大新 on 2017/4/24.
//  Copyright © 2017年 ColorfulWood. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "OHFMKPolylineRenderer.h"

@interface ViewController ()<MKMapViewDelegate>
@property (strong, nonatomic) MKMapView *mapView;

/** 位置管理者 */
@property (nonatomic, strong) CLLocationManager *locationM;

@end

@implementation ViewController

#pragma mark -懒加载
-(CLLocationManager *)locationM
{
    if (!_locationM) {
        _locationM = [[CLLocationManager alloc] init];
        
        // 版本适配
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            [_locationM requestAlwaysAuthorization];
        }
        
    }
    return _locationM;
}

-(MKMapView*)mapView{
    
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        _mapView.delegate = self;
        
        // 北京的位置
        CLLocation *location = [[CLLocation alloc] initWithLatitude:39.55 longitude:116.23];
        // 上海的位置
        CLLocation *location1 = [[CLLocation alloc] initWithLatitude:40. longitude:121.4];
        NSArray *polylint = [[NSArray alloc] initWithObjects:location,location1, nil];
        
        NSInteger pointCount = polylint.count;
        
        CLLocationCoordinate2D *coordinateArray = (CLLocationCoordinate2D *)malloc(pointCount * sizeof(CLLocationCoordinate2D));
        
        for (int i = 0; i < pointCount; i++)
        {
            CLLocation *location = [polylint objectAtIndex:i];
            coordinateArray[i] = [location coordinate];
            NSLog(@"%d",i);
            NSLog(@"%f,%f",location.coordinate.latitude,location.coordinate.longitude);
            
            
            
        }
        
        MKPolyline *lines = [MKPolyline polylineWithCoordinates:coordinateArray count:pointCount];
        [_mapView addOverlay:lines];
        MKCoordinateSpan span ={8,8};
        MKCoordinateRegion regon = MKCoordinateRegionMake(coordinateArray[0], span);
        [_mapView setRegion:regon animated:YES];
        MKMapCamera * camera = [MKMapCamera ];
        [_mapView setCamera:camera];
        
        [self.view addSubview:_mapView];
    }
    return _mapView;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    MKMapTypeStandard = 0, // 标准地图
    //    MKMapTypeSatellite, // 卫星云图
    //    MKMapTypeHybrid, // 混合(在卫星云图上加了标准地图的覆盖层)
    //    MKMapTypeSatelliteFlyover NS_ENUM_AVAILABLE(10_11, 9_0), // 3D立体
    //    MKMapTypeHybridFlyover NS_ENUM_AVAILABLE(10_11, 9_0), // 3D混合
    // 设置地图显示样式(必须注意,设置时 注意对应的版本)
    self.mapView.mapType = MKMapTypeStandard;
    
    
    // 设置地图的控制项
    // 是否可以滚动
    //    self.mapView.scrollEnabled = NO;
    // 缩放
    //    self.mapView.zoomEnabled = NO;
    // 旋转
    //    self.mapView.rotateEnabled = NO;
    
    
    // 设置地图的显示项(注意::版本适配)
    // 显示建筑物
    self.mapView.showsBuildings = YES;
    // 指南针
    self.mapView.showsCompass = YES;
    // 兴趣点
    self.mapView.showsPointsOfInterest = YES;
    // 比例尺
    self.mapView.showsScale = YES;
    // 交通
    self.mapView.showsTraffic = YES;
    
    
    // 显示用户位置
    [self locationM];
    // 显示用户位置, 但是地图并不会自动放大到合适比例
    //   self.mapView.showsUserLocation = YES;
    
    /**
     *  MKUserTrackingModeNone = 0, 不追踪
     MKUserTrackingModeFollow,  追踪
     MKUserTrackingModeFollowWithHeading, 带方向的追踪
     */
    // 不但显示用户位置, 而且还会自动放大地图到合适的比例(也要进行定位授权)
    // 不灵光
    //self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
}


//实现画线的代理方法
//- (MKPolylineRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
//    
//    if ([overlay isKindOfClass:[MKPolyline class]]) {
//        
//        OHFMKPolylineRenderer *line = [[OHFMKPolylineRenderer alloc] initWithOverlay:overlay];
//        line.strokeColor = [UIColor blackColor];
//        line.lineWidth = 3.5f;
//        return line;
//        
//    }else{
//        
//        return nil;
//        
//    }
//    
//    
//}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        
        OHFMKPolylineRenderer *line = [[OHFMKPolylineRenderer alloc] initWithOverlay:overlay];
        line.strokeColor = [UIColor blackColor];
        line.lineWidth = 3.5f;
        return line;
        
    }else{
        
        return nil;
        
    }
}
@end
