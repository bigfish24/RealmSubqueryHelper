//
//  ViewController.m
//  RealmSubqueryHelperExample
//
//  Created by Adam Fish on 5/26/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import "ViewController.h"
#import "LinkedObject.h"
#import "TestObject.h"

#import "RLMObject+Subquery.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create LinkedObjects and link them to TestObjects
    // Will be 45 LinkedObjects and 9 TestObjects, each containing 5 LinkedObjects
    // LinkedObjects all have unique dates and alternating isOn values
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    NSInteger chunkTest = -1;
    
    [realm beginWriteTransaction];
    
    for (NSUInteger i = 0; i < 45; i++) {
        NSTimeInterval year = 60 * 60 * 24 * 365; // ignoring leap years...
        
        NSTimeInterval years = year * i;
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:years];
        
        NSString *linkedObjectKey = [NSString stringWithFormat:@"linkedObject-%lu",(unsigned long)i];
        
        LinkedObject *linkedObject = [LinkedObject objectForPrimaryKey:linkedObjectKey];
        
        if (!linkedObject) {
            LinkedObject *linkedObject = [[LinkedObject alloc] init];
            
            linkedObject.date = date;
            
            linkedObject.Id = linkedObjectKey;
            
            [realm addOrUpdateObject:linkedObject];
        }
        
        if (i % 2 == 0) {
            linkedObject.isOn = YES;
        }
        
        float chunk = (float)i / 5;
        float roundedChunk = floorf(chunk);
        
        // Add 5 LinkedObjects to ever TestObject
        if (roundedChunk != chunkTest) {
            chunkTest = roundedChunk;
        }
        
        NSString *testObjectKey = [NSString stringWithFormat:@"testObject-%lu",(unsigned long)chunkTest];
        
        TestObject *testObject = [TestObject objectForPrimaryKey:testObjectKey];
        
        if (!testObject) {
            
            testObject = [[TestObject alloc] init];
            
            testObject.Id = testObjectKey;
            
            [realm addOrUpdateObject:testObject];
        }
        
        if ([testObject.linkedObjects indexOfObject:linkedObject] == NSNotFound) {
            [testObject.linkedObjects addObject:linkedObject];
        }
    }
    
    [realm commitWriteTransaction];
    
    NSInteger fiveYearIntervals = 3;
    
    NSTimeInterval timeInterval = 60 * 60 * 24 * 365 * 5 * fiveYearIntervals;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(linkedObjects, $x, $x.isOn == YES && $x.date > %@).@count > 0",[NSDate dateWithTimeIntervalSince1970:timeInterval]];
    
    RLMResults *results = [TestObject objectsWithSubqueryPredicate:predicate];
    
    NSAssert(9 - results.count == fiveYearIntervals, @"Subquery predicate did not evaluate correctly!");
    
    NSLog(@"\n\nThe example project uses a model in which 9 TestObjects are created that each hold 5 LinkedObjects. Each LinkedObject has a date starting with 1970 and continuing to 2015. In addition the LinkedObjects alternate their BOOL property isON.\n\nThis sets up a SUBQUERY that asks for all the TestObjects that link to LinkedObjects where isOn == YES and date is greater than a specified date.\n\nAdjust the fiveyearIntervals variable to play around with the SUBQUERY.\n\n");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
