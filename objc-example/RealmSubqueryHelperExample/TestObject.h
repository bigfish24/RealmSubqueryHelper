//
//  TestObject.h
//  RealmSubqueryHelperExample
//
//  Created by Adam Fish on 5/26/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import <Realm/Realm.h>

#import "LinkedObject.h"

@interface TestObject : RLMObject

@property NSString *Id;

@property RLMArray<LinkedObject> *linkedObjects;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<TestObject>
RLM_ARRAY_TYPE(TestObject)
