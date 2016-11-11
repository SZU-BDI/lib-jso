//https://github.com/SZU-BDI/lib-ios-jso/blob/master/JSO.m
//Author: 双虎, Wanjo Chan

#import "JSO.h"

@implementation JSO

+ (id)s2id:(NSString *)s
{
    NSData *data = [s dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    
    //[PHP]$idid = NSJSONSerialization::JSONObjectWithData($data, $optinos=NSJSONReadingAllowFragments, &$error);
    //    id idid = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    id idid = [NSJSONSerialization
               JSONObjectWithData:data
               options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
               error:&error];
    
    if (error.description) {
        NSLog(@"s2id() err=>%@", error.description);
        idid=s;
    }
    
    return idid;
}

+ (NSString *)id2s:(id)idid flagThrowEx:(BOOL)flagThrowEx
{
    //[PHP]if($idid==null) return "null";
    if (idid==nil) return @"null";
    
    //[PHP]if (is_string($idid)) return $idid;
    if ([idid isKindOfClass:[NSString class]]){
        return (NSString *)idid;
    }
    
    //[PHP]if(is_boolean($idid)) return idid?"true":"false";
    if([idid isKindOfClass:[NSNumber class]]){
        if (strcmp([idid objCType], [@(NO) objCType]) == 0){
            return [idid boolValue] ? @"true" : @"false";
        }
        //TODO improve later float/double/int ...?
        return [idid stringValue];
    }
    
    NSError *error;
    NSData *result =nil;
    if (flagThrowEx) {
        result = [NSJSONSerialization dataWithJSONObject:idid options:0 error:&error];
    }else{
        @try
        {
            result = [NSJSONSerialization dataWithJSONObject:idid options:0 error:&error];
        }
        @catch (NSException *theException)
        {
            NSLog(@"id2s() Exception: %@", theException);
            NSLog(@"id2s() %@", idid);
        }
    }
    if(error.description!=nil){
        NSLog(@"id2s() err=> %@", error.description);
    }
    
    // encode to string
    //[PHP] $rt= (new String())->initWithData($result, NSUTF8StringEncoding);
    NSString *rt = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    return rt;
    
}
+ (NSString *)id2s:(id)idid
{
    return [self id2s:idid flagThrowEx:NO];
}

+ (JSO *)s2o:(NSString *)s
{
    //[PHP] $idid=$this->s2id($s);
    id idid = [self s2id:s];
    
    //[PHP] $o=new JSO;
    JSO *o = [[JSO alloc] init];
    
    //$o->setValue("_innerid",$idid);
    [o setValue:idid forKey:@"_innerid"];
    
    return o;
}

+ (NSString *)o2s:(JSO *)o
{
    id idid = [o valueForKey:@"_innerid"];
    
    //[PHP] $s=$this->id2s($idid);
    NSString *s = [self id2s:idid];
    
    return s;
}

- (NSString *)toString
{
    //[PHP] return JSO::o2s($this);
    return [JSO o2s:self];
}

- (void)fromString:(NSString *)s
{
    //[PHP] $idid=JSO::s2id($s);
    id idid = [JSO s2id:s];
    
    //[PHP] $this->setValue("_innerid", $idid);
    [self setValue:idid forKey:@"_innerid"];
}

- (JSO *)getChild:(NSString *)key
{
    if(true)
        return [self getChildByPath:key];
    
    if (key == nil) return nil;
    
    if (_innerid==nil) return nil;
    
    //if ($this->innerid){ }
    //if ([_innerid isKindOfClass:[NSDictionary class]]) {
    
    id subid = [_innerid valueForKey:key];
    
    if(subid != nil){
        //$o=new JSO;
        JSO *o =[[JSO alloc] init];
        
        //$o->setValue("_innerid",$idid);
        [o setValue:subid forKey:@"_innerid"];
        
        return o;
    }
    //}
    return nil;
}

- (void)setChild:(NSString *)k JSO:(JSO *)o{
    
    if (_innerid==nil) return;
    id childid=[o valueForKey:@"_innerid"];
    if(nil==childid)return;
    @try{
        NSMutableDictionary *ddd=(NSMutableDictionary *)_innerid;
        [ddd setObject:childid forKey:k];
    }
    @catch (NSException *theException)
    {
        NSLog(@"setChild() Exception: %@", theException);
        //NSLog(@"setChild() %@", childid);
    }
}

-(JSO *)getChildByPath:(NSString *)path{
    if (_innerid==nil) return nil;
    id subid;
    @try{
        subid=[_innerid valueForKeyPath:path];
    }
    @catch (NSException *theException)
    {
        NSLog(@"getChildByPath() Exception: %@", theException);
        NSLog(@"getChildByPath() %@", subid);
    }
    if(subid!=nil){
        //$o=new JSO;
        JSO *o=[[JSO alloc] init];
        
        //$o->setValue("_innerid",$idid);
        [o setValue:subid forKey:@"_innerid"];
        return o;
    }else{
        return nil;
    }
}

- (void)removeChild:(NSString *)k{
    if (_innerid==nil) return;
    @try{
        NSMutableDictionary *ddd=(NSMutableDictionary *)_innerid;
        [ddd removeObjectForKey:k];
    }
    @catch (NSException *theException)
    {
        NSLog(@"setChild() Exception: %@", theException);
    }
}

- (NSArray *)getChildKeys
{
    if (_innerid!=nil) {
        NSArray *keys=[_innerid allKeys];
        return keys;
    }else{
        return [[NSMutableArray alloc] copy];
    }
}


@end
