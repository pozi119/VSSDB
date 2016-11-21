//
//  VSSDB.m
//  VSSDB
//
//  Created by Valo on 16/7/12.
//  Copyright © 2016年 valo. All rights reserved.
//

#import "VSSDB.h"
#import "ttl.h"

@implementation VSDOptions
@end

@implementation VSDKeyValItem
@end

@implementation VSDHashmapItem
@end

@implementation VSDSortedSetItem
@end

@implementation VSDListItem
@end

@interface VSSDB ()
@end

@implementation VSSDB{
    NSString *_dbPath;
    SSDB *_ssdb;
    ExpirationHandler *_exphandler;
}

+ (instancetype)databaseWithName:(NSString *)name{
    VSSDB *vsdb = [[VSSDB alloc] initWithName:name];
    [vsdb open];
    return vsdb;
}

- (instancetype)initWithName:(NSString *)name{
    self = [super init];
    if (self) {
        self.dbPath = name;
    }
    return self;
}

- (BOOL)open{
    return [self openWithOptions:nil];
}

-(BOOL)openWithOptions:(VSDOptions *)options{
    Options opt = [[self class] ssdbOptions:options];
    std::string path(self.dbPath.UTF8String);
    _ssdb = SSDB::open(opt, path);
    _exphandler = new ExpirationHandler(_ssdb);
    return _ssdb != nil;
}

- (void)close{
    delete _ssdb;
}

#pragma mark - private

- (NSString *)dbPath{
    if (_dbPath.length == 0) {
        _dbPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"com.valo.vssdb.temporary"];
    }
    return _dbPath;
}

- (void)setDbPath:(NSString *)dbPath{
    if (dbPath.length == 0) {
        _dbPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"com.valo.vssdb"];
    }
    else{
        NSString *path = @"Documents/com.valo.vssdb";
        NSString *dir = [NSHomeDirectory() stringByAppendingPathComponent:path];
        BOOL isDir = NO;
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDir];
        if (!isDir || !exist ) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _dbPath = [dir stringByAppendingPathComponent:dbPath];
    }
}

+ (Options)ssdbOptions:(VSDOptions *)inOptions{
    Options opt;
    if (inOptions.cache_size > 0) {
        opt.cache_size = inOptions.cache_size;
    }
    if (inOptions.max_open_files > 0) {
        opt.max_open_files = inOptions.max_open_files;
    }
    if (inOptions.write_buffer_size > 0) {
        opt.write_buffer_size = inOptions.write_buffer_size;
    }
    if (inOptions.block_size > 0) {
        opt.block_size = inOptions.block_size;
    }
    if (inOptions.compaction_speed > 0) {
        opt.compaction_speed = inOptions.compaction_speed;
    }
    opt.compression = inOptions.compression.length>0?inOptions.compression.UTF8String:"yes";
    opt.binlog = inOptions.binlog;

    if (inOptions.binlog_capacity > 0) {
        opt.binlog_capacity = inOptions.binlog_capacity;
    }
    
    return opt;
}

@end

#pragma mark Server
@implementation VSSDB (Database)
- (int)flushdb{
    return _ssdb->flushdb();
}

- (uint64_t)size{
    return _ssdb->size();
}

- (void)compact{
    _ssdb->compact();
}
@end

#pragma mark Key-Value
@implementation VSSDB (KeyValue)

- (BOOL)set:(NSString *)key data:(NSData *)data{
    std::string k(key.UTF8String);
    std::string v((const char*)data.bytes, data.length);
    int ret = _ssdb->set(k, v);
    return ret >= 0; // >0表示新增,=0表示修改
}

- (BOOL)setnx:(NSString *)key data:(NSData *)data{
    std::string k(key.UTF8String);
    std::string v((const char*)data.bytes, data.length);
    int ret = _ssdb->setnx(k, v);
    return ret == 0;
}

- (int64_t)incr:(NSString *)key by:(int64_t)by{
    std::string k(key.UTF8String);
    int64_t newval = INT64_MAX;
    _ssdb->incr(k, by, &newval);
    return newval;
}

- (NSData *)get:(NSString *)key{
    std::string k(key.UTF8String);
    std::string v;
    NSData *data = nil;
    int ret = _ssdb->get(k, &v);
    if(ret == 1){
        data = [NSData dataWithBytes:(const void *)v.data() length:(NSUInteger)v.size()];
    }
    return data;
}

- (BOOL)del:(NSString *)key{
    std::string k(key.UTF8String);
    int ret = _ssdb->del(k);
    return ret == 0;
}

- (BOOL)expire:(NSString *)key ttl:(int64_t)ttl{
    std::string k(key.UTF8String);
    int ret = 0;
    if (ttl > 0) {
        ret = _exphandler->set_ttl(k, ttl);
    }
    else{
        ret = _exphandler->del_ttl(k);
    }
    return ret == 0;
}

- (BOOL)set:(NSString *)key data:(NSData *)data ttl:(int64_t)ttl{
    BOOL ret1 = [self set:key data:data];
    BOOL ret2 = [self expire:key ttl:ttl];
    return ret1 && ret2;
}

- (int64_t)ttl:(NSString *)key{
    std::string k(key.UTF8String);
    return _exphandler->get_ttl(k);
}


- (BOOL)multi_set:(NSDictionary *)keyvals{
    std::vector<Bytes> vector;
    NSArray *keys = keyvals.allKeys;
    for (NSInteger i = 0; i< keyvals.count; i++) {
        NSString *key = keys[i];
        id obj = keyvals[key];
        NSData *val = nil;
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *str = obj;
            val = [str dataUsingEncoding:NSUTF8StringEncoding];
        }
        else if([obj isKindOfClass:[NSNumber class]]){
            NSString *str = [obj stringValue];
            val = [str dataUsingEncoding:NSUTF8StringEncoding];
        }
        else if([obj isKindOfClass:[NSData class]]){
            val = obj;
        }
        if (val) {
            std::string &k = *new std::string(key.UTF8String);
            std::string &v = *new std::string((const char*)val.bytes, val.length);
            vector.push_back(k);
            vector.push_back(v);
        }
    }
    int ret = _ssdb->multi_set(vector);
    return ret == 0;
}

- (BOOL)multi_del:(NSArray<NSString *> *)keys{
    std::vector<Bytes> vector;
    for (NSString *key in keys) {
        std::string &k = *new std::string(key.UTF8String);
        vector.push_back(k);
    }
    int ret = _ssdb->multi_del(vector);
    return ret == keys.count;
}

- (BOOL)setbit:(NSString *)key bitOffset:(int)bitOffset on:(int)on{
    std::string k(key.UTF8String);
    int ret = _ssdb->setbit(k, bitOffset, on);
    return ret == 0;
}

- (int)getbit:(NSString *)key bitOffset:(int)bitoffset{
    std::string k(key.UTF8String);
    return _ssdb->getbit(k, bitoffset);
}

- (NSData *)getset:(NSString *)key newData:(NSData *)newData{
    std::string k(key.UTF8String);
    std::string nv((const char*)newData.bytes, newData.length);
    std::string v;
    NSData *olddata = nil;
    int ret = _ssdb->getset(k, &v, nv);
    if(ret == 1){
        olddata = [NSData dataWithBytes:(const void *)v.data() length:(NSUInteger)v.size()];
    }
    return olddata;
}

- (NSArray *)scan:(NSString *)startKey endKey:(NSString *)endKey limit:(int64_t)limit{
    std::string sk(startKey.UTF8String);
    std::string ek(endKey.UTF8String);
    NSMutableArray *array = @[].mutableCopy;
    KIterator *it = _ssdb->scan(sk, ek, limit);
    while (it->next()) {
        std::string k = it->key;
        std::string v = it->val;
        VSDKeyValItem *item = [VSDKeyValItem new];
        item.key = [NSString stringWithUTF8String:k.c_str()];
        item.val = [NSData dataWithBytes:(const void *)v.data() length:(NSUInteger)v.size()];
        [array addObject:item];
    }
    
    return array;
}

- (NSArray *)rscan:(NSString *)startKey endKey:(NSString *)endKey limit:(int64_t)limit{
    std::string sk(startKey.UTF8String);
    std::string ek(endKey.UTF8String);
    NSMutableArray *array = @[].mutableCopy;
    KIterator *it = _ssdb->rscan(sk, ek, limit);
    while (it->next()) {
        std::string k = it->key;
        std::string v = it->val;
        VSDKeyValItem *item = [VSDKeyValItem new];
        item.key = [NSString stringWithUTF8String:k.c_str()];
        item.val =[NSData dataWithBytes:(const void *)v.data() length:(NSUInteger)v.size()];
        [array addObject:item];
    }
    
    return array;
}
@end

#pragma mark Hashmap
@implementation VSSDB (Hashmap)

- (BOOL)hset:(NSString *)name key:(NSString *)key data:(NSData *)data{
    std::string n(name.UTF8String);
    std::string k(key.UTF8String);
    std::string v((const char*)data.bytes, data.length);
    int ret = _ssdb->hset(n, k, v);
    return ret >= 0; // >0表示新增,=0表示修改
}

- (BOOL)hdel:(NSString *)name key:(NSString *)key{
    std::string n(name.UTF8String);
    std::string k(key.UTF8String);
    int ret = _ssdb->hdel(n, k);
    return ret >= 0; // ret表示删除的个数
}

- (int64_t)hincr:(NSString *)name key:(NSString *)key by:(int64_t)by{
    std::string n(name.UTF8String);
    std::string k(key.UTF8String);
    int64_t newval = INT64_MAX;
    _ssdb->hincr(n, k, by, &newval);
    return newval;
}

- (int64_t)hsize:(NSString *)name{
    std::string n(name.UTF8String);
    return _ssdb->hsize(n);
}

- (int64_t)hclear:(NSString *)name{
    std::string n(name.UTF8String);
    return _ssdb->hclear(n); //返回清楚的数据数量
}

- (NSData *)hget:(NSString *)name key:(NSString *)key{
    std::string n(name.UTF8String);
    std::string k(key.UTF8String);
    std::string v;
    NSData *data = nil;
    int ret = _ssdb->hget(n, k, &v);
    if(ret == 1){
        data = [NSData dataWithBytes:(const void *)v.data() length:(NSUInteger)v.size()];
    }
    return data;
}

- (NSArray *)hlist:(NSString *)startName endName:(NSString *)endName limit:(int64_t)limit{
    std::string sn(startName.UTF8String);
    std::string en(endName.UTF8String);
    NSMutableArray *list = @[].mutableCopy;
    std::vector<std::string> vector;
    int ret = _ssdb->hlist(sn, en, limit, &vector);
    if (ret != 0) {
        return nil;
    }
    std::vector<std::string>::const_iterator it;
    it = vector.begin();
    for(; it != vector.end(); it += 1){
        std::string val = *it;
        NSString *str = [NSString stringWithUTF8String:val.c_str()];
        [list addObject:str];
    }
    return list;
}

- (NSArray *)hscan:(NSString *)name startKey:(NSString *)startKey endKey:(NSString *)endKey limit:(int64_t)limit{
    std::string n(name.UTF8String);
    std::string sk(startKey.UTF8String);
    std::string ek(endKey.UTF8String);
    NSMutableArray *array = @[].mutableCopy;
    HIterator *it = _ssdb->hscan(n, sk, ek, limit);
    while (it->next()) {
        std::string n = it->name;
        std::string k = it->key;
        std::string v = it->val;
        VSDHashmapItem *item = [VSDHashmapItem new];
        item.name = [NSString stringWithUTF8String:n.c_str()];
        item.key = [NSString stringWithUTF8String:k.c_str()];
        item.val = [NSData dataWithBytes:(const void *)v.data() length:(NSUInteger)v.size()];
        [array addObject:item];
    }
    return array;
}

- (NSArray *)hrscan:(NSString *)name startKey:(NSString *)startKey endKey:(NSString *)endKey limit:(int64_t)limit{
    std::string n(name.UTF8String);
    std::string sk(startKey.UTF8String);
    std::string ek(endKey.UTF8String);
    NSMutableArray *array = @[].mutableCopy;
    HIterator *it = _ssdb->hrscan(n, sk, ek, limit);
    while (it->next()) {
        std::string n = it->name;
        std::string k = it->key;
        std::string v = it->val;
        VSDHashmapItem *item = [VSDHashmapItem new];
        item.name = [NSString stringWithUTF8String:n.c_str()];
        item.key = [NSString stringWithUTF8String:k.c_str()];
        item.val = [NSData dataWithBytes:(const void *)v.data() length:(NSUInteger)v.size()];
        [array addObject:item];
    }
    
    return array;
}
@end

#pragma mark Sorted-Set
@implementation VSSDB (SortedSet)
- (BOOL)zset:(NSString *)name key:(NSString *)key score:(NSData *)score{
    std::string n(name.UTF8String);
    std::string k(key.UTF8String);
    std::string s((const char*)score.bytes, score.length);
    int ret = _ssdb->zset(n, k, s);
    return ret >= 0;
}

- (BOOL)zdel:(NSString *)name key:(NSString *)key{
    std::string n(name.UTF8String);
    std::string k(key.UTF8String);
    int ret = _ssdb->zdel(n, k);
    return ret >= 0;
}

- (int64_t)zincr:(NSString *)name key:(NSString *)key by:(int64_t)by{
    std::string n(name.UTF8String);
    std::string k(key.UTF8String);
    int64_t newval = INT64_MAX;
    _ssdb->zincr(n, k, by, &newval);
    return newval;
}

- (int64_t)zsize:(NSString *)name{
    std::string n(name.UTF8String);
    return _ssdb->zsize(n);
}

- (NSData *)zget:(NSString *)name key:(NSString *)key{
    std::string n(name.UTF8String);
    std::string k(key.UTF8String);
    std::string v;
    NSData *score = nil;
    int ret = _ssdb->zget(n, k, &v);
    if(ret == 1){
        score = [NSData dataWithBytes:(const void *)v.data() length:(NSUInteger)v.size()];
    }
    return score;
}

- (int64_t)zrank:(NSString *)name key:(NSString *)key{
    std::string n(name.UTF8String);
    std::string k(key.UTF8String);
    return _ssdb->zrank(n, k);
}

- (int64_t)zrrank:(NSString *)name key:(NSString *)key{
    std::string n(name.UTF8String);
    std::string k(key.UTF8String);
    return _ssdb->zrrank(n, k);
}

- (NSArray *)zrange:(NSString *)name offset:(int64_t)offset limit:(int64_t)limit{
    std::string n(name.UTF8String);
    NSMutableArray *array = @[].mutableCopy;
    ZIterator *it = _ssdb->zrange(n, offset, limit);
    while (it->next()) {
        std::string n = it->name;
        std::string k = it->key;
        std::string v = it->score;
        VSDSortedSetItem *item = [VSDSortedSetItem new];
        item.name = [NSString stringWithUTF8String:n.c_str()];
        item.key = [NSString stringWithUTF8String:k.c_str()];
        item.score = [NSData dataWithBytes:(const void *)v.data() length:(NSUInteger)v.size()];
        [array addObject:item];
    }
    return array;
}

- (NSArray *)zrrange:(NSString *)name offset:(int64_t)offset limit:(int64_t)limit{
    std::string n(name.UTF8String);
    NSMutableArray *array = @[].mutableCopy;
    ZIterator *it = _ssdb->zrrange(n, offset, limit);
    while (it->next()) {
        std::string n = it->name;
        std::string k = it->key;
        std::string v = it->score;
        VSDSortedSetItem *item = [VSDSortedSetItem new];
        item.name = [NSString stringWithUTF8String:n.c_str()];
        item.key = [NSString stringWithUTF8String:k.c_str()];
        item.score = [NSData dataWithBytes:(const void *)v.data() length:(NSUInteger)v.size()];
        [array addObject:item];
    }
    return array;
}

- (NSArray *)zscan:(NSString *)name key:(NSString *)key startScore:(NSString *)startScore endScore:(NSString *)endScore limit:(int64_t)limit{
    std::string n(name.UTF8String);
    std::string k(key.UTF8String);
    std::string ss(startScore.UTF8String);
    std::string es(endScore.UTF8String);
    NSMutableArray *array = @[].mutableCopy;
    ZIterator *it = _ssdb->zscan(n, k, ss, es, limit);
    while (it->next()) {
        std::string n = it->name;
        std::string k = it->key;
        std::string v = it->score;
        VSDSortedSetItem *item = [VSDSortedSetItem new];
        item.name = [NSString stringWithUTF8String:n.c_str()];
        item.key = [NSString stringWithUTF8String:k.c_str()];
        item.score = [NSData dataWithBytes:(const void *)v.data() length:(NSUInteger)v.size()];
        [array addObject:item];
    }
    return array;
}

- (NSArray *)zrscan:(NSString *)name key:(NSString *)key startScore:(NSString *)startScore endScore:(NSString *)endScore limit:(int64_t)limit{
    std::string n(name.UTF8String);
    std::string k(key.UTF8String);
    std::string ss(startScore.UTF8String);
    std::string es(endScore.UTF8String);
    NSMutableArray *array = @[].mutableCopy;
    ZIterator *it = _ssdb->zrscan(n, k, ss, es, limit);
    while (it->next()) {
        std::string n = it->name;
        std::string k = it->key;
        std::string v = it->score;
        VSDSortedSetItem *item = [VSDSortedSetItem new];
        item.name = [NSString stringWithUTF8String:n.c_str()];
        item.key = [NSString stringWithUTF8String:k.c_str()];
        item.score = [NSData dataWithBytes:(const void *)v.data() length:(NSUInteger)v.size()];
        [array addObject:item];
    }
    return array;
}

- (NSArray *)zlist:(NSString *)startName endName:(NSString *)endName limit:(int64_t)limit{
    std::string sn(startName.UTF8String);
    std::string en(endName.UTF8String);
    NSMutableArray *list = @[].mutableCopy;
    std::vector<std::string> vector;
    int ret = _ssdb->zlist(sn, en, limit, &vector);
    if (ret != 0) {
        return nil;
    }
    std::vector<std::string>::const_iterator it;
    it = vector.begin();
    for(; it != vector.end(); it += 1){
        std::string val = *it;
        NSString *str = [NSString stringWithUTF8String:val.c_str()];
        [list addObject:str];
    }
    return list;
}

- (NSArray *)zrlist:(NSString *)startName endName:(NSString *)endName limit:(int64_t)limit{
    std::string sn(startName.UTF8String);
    std::string en(endName.UTF8String);
    NSMutableArray *list = @[].mutableCopy;
    std::vector<std::string> vector;
    int ret = _ssdb->zrlist(sn, en, limit, &vector);
    if (ret != 0) {
        return nil;
    }
    std::vector<std::string>::const_iterator it;
    it = vector.begin();
    for(; it != vector.end(); it += 1){
        std::string val = *it;
        NSString *str = [NSString stringWithUTF8String:val.c_str()];
        [list addObject:str];
    }
    return list;
}

- (int64_t)zfix:(NSString *)name{
    std::string n(name.UTF8String);
    return _ssdb->zfix(n);
}

@end

#pragma mark List
@implementation VSSDB (List)
- (int64_t)qsize:(NSString *)name{
    std::string n(name.UTF8String);
    return _ssdb->qsize(n);
}

- (NSData *)qfront:(NSString *)name{
    std::string n(name.UTF8String);
    std::string i;
    NSData *item = nil;
    int ret = _ssdb->qfront(n, &i);
    if(ret == 1){
        item = [NSData dataWithBytes:(const void *)i.data() length:(NSUInteger)i.size()];
    }
    return item;
}

- (NSData *)qback:(NSString *)name{
    std::string n(name.UTF8String);
    std::string i;
    NSData *item = nil;
    int ret = _ssdb->qback(n, &i);
    if(ret == 1){
        item = [NSData dataWithBytes:(const void *)i.data() length:(NSUInteger)i.size()];
    }
    return item;
}

- (int64_t)qpush_front:(NSString *)name data:(NSData *)data{
    std::string n(name.UTF8String);
    std::string v((const char*)data.bytes, data.length);
    return _ssdb->qpush_front(n, v);
}

- (int64_t)qpush_back:(NSString *)name data:(NSData *)data{
    std::string n(name.UTF8String);
    std::string v((const char*)data.bytes, data.length);
    return _ssdb->qpush_back(n, v);
}

- (NSData *)qpop_front:(NSString *)name{
    std::string n(name.UTF8String);
    std::string v;
    NSData *data = nil;
    int ret = _ssdb->qpop_front(n, &v);
    if(ret == 1){
        data = [NSData dataWithBytes:(const void *)v.data() length:(NSUInteger)v.size()];
    }
    return data;
}

- (NSData *)qpop_back:(NSString *)name{
    std::string n(name.UTF8String);
    std::string v;
    NSData *data = nil;
    int ret = _ssdb->qpop_back(n, &v);
    if(ret == 1){
        data = [NSData dataWithBytes:(const void *)v.data() length:(NSUInteger)v.size()];
    }
    return data;
}

- (int64_t)qfix:(NSString *)name{
    std::string n(name.UTF8String);
    return _ssdb->qfix(n);
}

- (NSArray *)qlist:(NSString *)startName endName:(NSString *)endName limit:(int64_t)limit{
    std::string sn(startName.UTF8String);
    std::string en(endName.UTF8String);
    NSMutableArray *list = @[].mutableCopy;
    std::vector<std::string> vector;
    int ret = _ssdb->qlist(sn, en, limit, &vector);
    if (ret < 0) {
        return nil;
    }
    std::vector<std::string>::const_iterator it;
    it = vector.begin();
    for(; it != vector.end(); it += 1){
        std::string val = *it;
        NSString *str = [NSString stringWithUTF8String:val.c_str()];
        [list addObject:str];
    }
    return list;
}

- (NSArray *)qrlist:(NSString *)startName endName:(NSString *)endName limit:(int64_t)limit{
    std::string sn(startName.UTF8String);
    std::string en(endName.UTF8String);
    NSMutableArray *list = @[].mutableCopy;
    std::vector<std::string> vector;
    int ret = _ssdb->qrlist(sn, en, limit, &vector);
    if (ret < 0) {
        return nil;
    }
    std::vector<std::string>::const_iterator it;
    it = vector.begin();
    for(; it != vector.end(); it += 1){
        std::string val = *it;
        NSString *str = [NSString stringWithUTF8String:val.c_str()];
        [list addObject:str];
    }
    return list;
}

- (NSArray *)qslice:(NSString *)name offset:(int64_t)offset limit:(int64_t)limit{
    std::string n(name.UTF8String);
    NSMutableArray *list = @[].mutableCopy;
    std::vector<std::string> vector;
    int ret = _ssdb->qslice(n, offset, limit, &vector);
    if (ret < 0) {
        return nil;
    }
    std::vector<std::string>::const_iterator it;
    it = vector.begin();
    for(; it != vector.end(); it += 1){
        std::string val = *it;
        NSString *str = [NSString stringWithUTF8String:val.c_str()];
        [list addObject:str];
    }
    return list;
}

- (NSData *)qget:(NSString *)name index:(int64_t)index{
    std::string n(name.UTF8String);
    std::string v;
    NSData *data = nil;
    int ret = _ssdb->qget(n, index, &v);
    if(ret == 1){
        data = [NSData dataWithBytes:(const void *)v.data() length:(NSUInteger)v.size()];
    }
    return data;
}

- (BOOL)qset:(NSString *)name index:(int64_t)index data:(NSData *)data{
    std::string n(name.UTF8String);
    std::string v((const char*)data.bytes, data.length);
    int ret = _ssdb->qset(n, index, v);
    if(ret == 1){
        return YES;
    }
    return NO;
}

- (BOOL)qset_by_seq:(NSString *)name seq:(int64_t)seq data:(NSData *)data{
    std::string n(name.UTF8String);
    std::string v((const char*)data.bytes, data.length);
    int ret = _ssdb->qset_by_seq(n, seq, v);
    if(ret == 0){
        return YES;
    }
    return NO;
}

@end
