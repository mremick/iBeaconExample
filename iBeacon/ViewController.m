//
//  ViewController.m
//  iBeacon
//
//  Created by Matt Remick on 1/22/14.
//  Copyright (c) 2014 Matt Remick. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

#define BEACON_UUID @"A1EC7CD6-BF60-40A4-85F2-F89F61D78588"

@interface ViewController () <CLLocationManagerDelegate>

@property (strong,nonatomic) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"%@",[[NSUUID UUID] UUIDString]);
    
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    //creating the region I'm interested in, the region around an emitter
    //identifier does not need to mathc the emitter, it's only for your own callbacks
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:BEACON_UUID];
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:2 minor:1 identifier:@"com.mremick.ibeacon.region"];
    
    //sends events on entry and exit
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    
    //sends an event if the device or app awakes from sleep in the region
    region.notifyEntryStateOnDisplay = YES;
    
    //start to monitor the region
    [self.locationManager startMonitoringForRegion:region];
    
    //not sure of connectivity
    [self.locationManager requestStateForRegion:region];
    
    NSLog(@"view loaded");
}

#pragma mark - CLLocation Manager delegate

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if (state == CLRegionStateInside) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        [self.locationManager startRangingBeaconsInRegion:beaconRegion];
    }
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        if ([beaconRegion.identifier isEqualToString:@"com.mremick.ibeacon.region"]) {
            
            //start ranging the beacon to see how close it is
            //lots of battery and call back.. so stop whe the region is left
            [self.locationManager startRangingBeaconsInRegion:beaconRegion];
            NSLog(@"DID ENTER REGION");
            
        }
    }
}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        if ([beaconRegion.identifier isEqualToString:@"com.mremick.ibeacon.region"]) {
            
            //start ranging the beacon to see how close it is
            //lots of battery and call back.. so stop whe the region is left
            [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
            
        }
    }
}

- (NSString *)stringForProximity:(CLProximity)proximity {
    switch (proximity) {
        case CLProximityUnknown:    return @"Unknown";
        case CLProximityFar:        return @"Far";
        case CLProximityNear:       return @"Near";
        case CLProximityImmediate:  return @"Immediate";
        default:
            return nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    for (CLBeacon *beacon in beacons) {
        //how close it is
        NSLog(@"Ranging beacon: %@", beacon.proximityUUID);
        //major and minor
        NSLog(@"%@ - %@", beacon.major, beacon.minor);
        //how far away it is (unknown, immeadiate, near,far)
        NSLog(@"Range: %@", [self stringForProximity:beacon.proximity]);
        
        [self setColorForProximity:beacon.proximity];
    }
}

- (void)setColorForProximity:(CLProximity)proximity {
    switch (proximity) {
        case CLProximityUnknown:
            self.view.backgroundColor = [UIColor whiteColor];
            break;
            
        case CLProximityFar:
            self.view.backgroundColor = [UIColor yellowColor];
            break;
            
        case CLProximityNear:
            self.view.backgroundColor = [UIColor orangeColor];
            break;
            
        case CLProximityImmediate:
            self.view.backgroundColor = [UIColor redColor];
            break;
            
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
