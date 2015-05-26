//
//  LinkedObject.h
//  RealmSubqueryHelperExample
//
//  Created by Adam Fish on 5/26/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import <Realm/Realm.h>

@interface LinkedObject : RLMObject

@property NSString *Id;

@property NSDate *date;

@property BOOL isOn;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<LinkedObject>
RLM_ARRAY_TYPE(LinkedObject)
