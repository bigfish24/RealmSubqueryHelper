//
//  RLMObject+Subquery.h
//  RBQFetchedResultsControllerExample
//
//  Created by Adam Fish on 5/22/15.
//  Copyright (c) 2015 Roobiq. All rights reserved.
//

#import <Realm/RLMObject.h>

@interface RLMObject (Subquery)

/**
 *  Perform a query on a RLMObject subclass that utilizes a subquery within the predicate.
 *
 *  Current supported SUBQUERY form is:
 *  SUBQUERY(toManyProperty, $x, predicate string using $x).@count > 0
 *
 *  @param predicate NSPredicate containing one or more SUBQUERY
 *
 *  @return RLMResults representing the objects that match the predicate
 */
+ (RLMResults *)objectsWithSubqueryPredicate:(NSPredicate *)predicate;

/**
 *  Perform a query on a RLMObject subclass that utilizes a subquery within the predicate string
 *
 *  Current supported SUBQUERY form is:
 *  SUBQUERY(toManyProperty, $x, predicate string using $x).@count > 0
 *
 *  @param predicateFormat NSString representing the predicate string that contains one or more SUBQUERY
 *
 *  @return RLMResults representing the objects that match the predicate string
 */
+ (RLMResults *)objectsWhereWithSubquery:(NSString *)predicateFormat, ...;

/**
 *  Perform a query on a RLMObject subclass that utilizes a subquery within the predicate.
 *
 *  Current supported SUBQUERY form is:
 *  SUBQUERY(toManyProperty, $x, predicate string using $x).@count > 0
 *
 *  @param realm     RLMRealm instance that contains RLMObject subclass
 *  @param predicate predicate NSPredicate containing one or more SUBQUERY
 *
 *  @return RLMResults representing the objects that match the predicate
 */
+ (RLMResults *)objectsInRealm:(RLMRealm *)realm withSubqueryPredicate:(NSPredicate *)predicate;

/**
 *  Perform a query on a RLMObject subclass that utilizes a subquery within the predicate string
 *
 *  Current supported SUBQUERY form is:
 *  SUBQUERY(toManyProperty, $x, predicate string using $x).@count > 0
 *
 *  @param realm     RLMRealm instance that contains RLMObject subclass
 *  @param predicateFormat NSString representing the predicate string that contains one or more SUBQUERY
 *
 *  @return RLMResults representing the objects that match the predicate string
 */
+ (RLMResults *)objectsInRealm:(RLMRealm *)realm whereWithSubQuery:(NSString *)predicateFormat, ...;

@end
