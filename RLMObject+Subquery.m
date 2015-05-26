//
//  RLMObject+Subquery.m
//  RBQFetchedResultsControllerExample
//
//  Created by Adam Fish on 5/22/15.
//  Copyright (c) 2015 Roobiq. All rights reserved.
//

#import "RLMObject+Subquery.h"

#import <Realm/Realm.h>
#import <Realm/RLMObjectSchema.h>
#import <Realm/RLMProperty.h>
#import <objc/runtime.h>

// This macro validates predicate format with optional arguments
#define RLM_VARARG(PREDICATE_FORMAT, ARGS) \
va_start(ARGS, PREDICATE_FORMAT);          \
va_end(ARGS);                              \
if (PREDICATE_FORMAT && ![PREDICATE_FORMAT isKindOfClass:[NSString class]]) {         \
NSString *reason = @"predicate must be an NSString with optional format va_list"; \
[NSException exceptionWithName:RLMExceptionName reason:reason userInfo:nil];       \
}

@implementation RLMObject (Subquery)

#pragma mark - Public Class

+ (RLMResults *)objectsWithSubqueryPredicate:(NSPredicate *)predicate
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    return [self objectsInRealm:realm withSubqueryPredicate:predicate];
}

+ (RLMResults *)objectsWhereWithSubquery:(NSString *)predicateFormat, ...
{
    va_list args;
    
    RLM_VARARG(predicateFormat, args);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:args];
    
    return [self objectsWithSubqueryPredicate:predicate];
}

+ (RLMResults *)objectsInRealm:(RLMRealm *)realm withSubqueryPredicate:(NSPredicate *)predicate
{
    NSPredicate *cleanedPredicate = [self rebuildPredicate:predicate
                                                usingRealm:realm];
    
    RLMResults *results = [self objectsInRealm:realm
                                 withPredicate:cleanedPredicate];
    
    return results;
}

+ (RLMResults *)objectsInRealm:(RLMRealm *)realm whereWithSubQuery:(NSString *)predicateFormat, ...
{
    va_list args;
    
    RLM_VARARG(predicateFormat, args);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:args];
    
    return [self objectsInRealm:realm withSubqueryPredicate:predicate];
}

#pragma mark - Private Class

+ (NSExpression *)retrieveFunctionExpressionInComparisonPredicate:(NSComparisonPredicate *)comparisonPredicate
{
    if (comparisonPredicate.leftExpression.expressionType == NSFunctionExpressionType) {
        return comparisonPredicate.leftExpression;
    }
    else if (comparisonPredicate.rightExpression.expressionType == NSFunctionExpressionType) {
        return comparisonPredicate.rightExpression;
    }
    
    return nil;
}

+ (NSExpression *)retrieveSubqueryExpressionInFunctionExpression:(NSExpression *)functionExpression
{
    if (functionExpression.expressionType == NSFunctionExpressionType) {
        
        if (functionExpression.operand.expressionType == NSSubqueryExpressionType) {
            
            return functionExpression.operand;
        }
    }
    
    return nil;
}

+ (NSPredicate *)retrievePredicateFromSubqueryExpression:(NSExpression *)subqueryExpression
{
    if (subqueryExpression.expressionType == NSSubqueryExpressionType) {
        
        return subqueryExpression.predicate;
    }
    
    return nil;
}

+ (NSPredicate *)cleanSubqueryPredicate:(NSPredicate *)subqueryPredicate
                          usingVariable:(NSString *)variable
{
    NSString *predicateString = subqueryPredicate.predicateFormat;
    
    NSString *variableSubstitution = [NSString stringWithFormat:@"$%@.",variable];
    
    if ([predicateString containsString:variableSubstitution]) {
        // Remove instances of '$variable.' since we don't need this for subquery
        NSString *cleanedPredicateString = [predicateString stringByReplacingOccurrencesOfString:variableSubstitution withString:@""];
        
        NSPredicate *cleanedPredicate = [NSPredicate predicateWithFormat:cleanedPredicateString];
        
        return cleanedPredicate;
    }
    
    return subqueryPredicate;
}

+ (NSPredicate *)replaceSubqueryPredicateIfAvailable:(NSComparisonPredicate *)predicate
                                          usingRealm:(RLMRealm *)realm
{
    if ([predicate isMemberOfClass:[NSComparisonPredicate class]]) {
        NSComparisonPredicate *comparisonPredicate = (NSComparisonPredicate *)predicate;
        
        NSExpression *functionExpression = [self retrieveFunctionExpressionInComparisonPredicate:comparisonPredicate];
        
        if (functionExpression) {
            NSExpression *subqueryExpression = [self retrieveSubqueryExpressionInFunctionExpression:functionExpression];
            
            if (subqueryExpression) {
                NSPredicate *subqueryPredicate = [self retrievePredicateFromSubqueryExpression:subqueryExpression];
                
                NSString *variable = subqueryExpression.variable;
                
                NSString *subqueryPropertyName = [NSString stringWithFormat:@"%@",subqueryExpression.collection];
                
                NSPredicate *cleanedSubquery = [self cleanSubqueryPredicate:subqueryPredicate
                                                              usingVariable:variable];
                
                Class containerClass = NSClassFromString([self className]);
                
                Class subqueryClass = [self classOfToManyPropertyNamed:subqueryPropertyName
                                                      containedInClass:containerClass];
                
                if (subqueryClass) {
                    RLMResults *subquery = [subqueryClass objectsInRealm:realm
                                                           withPredicate:cleanedSubquery];
                    
                    NSMutableSet *primaryKeys = [NSMutableSet set];
                    
                    NSString *primaryKey = nil;
                    
                    for (RLMObject *subqueryObject in subquery) {
                        
                        NSArray *linkedObjects = [subqueryObject linkingObjectsOfClass:[self className]
                                                                           forProperty:subqueryPropertyName];
                        
                        if (linkedObjects.count > 0) {
                            RLMObject *containerObject = linkedObjects[0];
                            
                            if (containerObject.objectSchema.primaryKeyProperty) {
                                primaryKey = containerObject.objectSchema.primaryKeyProperty.name;
                                
                                id primaryKeyValue = [containerObject valueForKey:primaryKey];
                                
                                [primaryKeys addObject:primaryKeyValue];
                            }
                            else {
                                @throw [NSException exceptionWithName:@"RLMException"
                                                               reason:@"Subquery requires base object to have primary key"
                                                             userInfo:nil];
                            }
                        }
                    }
                    
                    // Create replacement predicate with primary keys
                    NSPredicate *subqueryReplacement = [NSPredicate predicateWithFormat:@"%K IN %@",primaryKey,primaryKeys];
                    
                    return subqueryReplacement;
                }
            }
        }
    }
    
    return predicate;
}

+ (NSPredicate *)rebuildPredicate:(NSPredicate *)predicate
                       usingRealm:(RLMRealm *)realm
{
    if ([predicate isMemberOfClass:[NSComparisonPredicate class]]) {
        NSComparisonPredicate *comparisonPredicate = (NSComparisonPredicate *)predicate;
        
        NSPredicate *predicateFromSubquery = [self replaceSubqueryPredicateIfAvailable:comparisonPredicate
                                                                            usingRealm:realm];
        
        return predicateFromSubquery;
    }
    else if ([predicate isMemberOfClass:[NSCompoundPredicate class]]) {
        NSCompoundPredicate *compoundPredicate = (NSCompoundPredicate *)predicate;
        
        NSMutableArray *replacedSubpredicates = [NSMutableArray arrayWithCapacity:compoundPredicate.subpredicates.count];
        
        for (NSPredicate *subpredicate in compoundPredicate.subpredicates) {
            NSPredicate *cleanedSubpredicate = [self rebuildPredicate:subpredicate
                                                           usingRealm:realm];
            
            [replacedSubpredicates addObject:cleanedSubpredicate];
        }
        
        NSCompoundPredicate *cleanedCompoundPredicate = [[NSCompoundPredicate alloc] initWithType:compoundPredicate.compoundPredicateType subpredicates:replacedSubpredicates];
        
        return cleanedCompoundPredicate;
    }
    
    return predicate;
}

+ (Class)classOfToManyPropertyNamed:(NSString *)propertyName
                   containedInClass:(Class)containerClass
{
    objc_property_t property = class_getProperty(containerClass, [propertyName UTF8String]);
    
    NSString *propertyAttributes = [NSString stringWithCString:property_getAttributes(property)
                                                      encoding:NSUTF8StringEncoding];
    
    NSArray *splitPropertyAttributes = [propertyAttributes componentsSeparatedByString:@","];
    
    if (splitPropertyAttributes.count > 0)
    {
        NSString *encodeType = splitPropertyAttributes[0];
        
        NSArray *splitEncodeType = [encodeType componentsSeparatedByString:@"\""];
        
        NSString *propertyClassName = splitEncodeType[1];
        
        if ([propertyClassName containsString:@"<"] &&
            [propertyClassName containsString:@">"]) {
            
            NSRange beginning = [propertyClassName rangeOfString:@"<"];
            
            NSRange end = [propertyClassName rangeOfString:@">"];
            
            NSString *toManyClassString = [propertyClassName substringWithRange:NSMakeRange(beginning.location + 1, (end.location - beginning.location -1))];
            
            Class toManyClass = NSClassFromString(toManyClassString);
            
            return toManyClass;
        }
    }
    
    return nil;
}

@end
