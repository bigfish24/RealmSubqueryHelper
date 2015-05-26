# RealmSubqueryHelper
#####Adds support for SUBQUERY in Realm queries.

Need to query a `RLMObject` against a to-many relationship using multiple properties? This category brings the hidden gem in `NSPredicate`, `SUBQUERY`, to Realm. For example, given this Realm setup:

```Objective-C
Person : RLMObject
@property NSString *Id;
@property RLMArray<Dog> *dogs;

Dog : RLMObject
@property BOOL hasFleas;
@property NSString *color;
```

it is now possible to write a query for all the Person(s) that have at least one Dog with fleas and is colored brown. This makes use of `SUBQUERY` in the resulting Realm query:

```Objective-C
RLMResults *ownersOfBrownDogsWithFleas = [Person objectsWithSubqueryPredicate:@"SUBQUERY(dogs, $dog, $dog.hasFleas = YES AND $dog.color == 'brown').@count > 0"];
```
####Format
The format is similar to the standard NSPredicate `SUBQUERY` expression:
```Objective-C
SUBQUERY(RLMArray keypath, variable, predicate)
```
####Limitations
1. The base object must have a primary key (above, `Person` has primary key `Id`).
2. Only the `@count` collection operator is supported.
3. Compound predicates with `SUBQUERY` are supported, but nested `SUBQUERY` is not.






