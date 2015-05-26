//
//  TestObject.m
//  RealmSubqueryHelperExample
//
//  Created by Adam Fish on 5/26/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import "TestObject.h"

@implementation TestObject

+ (NSString *)primaryKey
{
    return @"Id";
}

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

@end
