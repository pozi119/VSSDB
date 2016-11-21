//
//  VSSDB.h
//  VSSDB
//
//  Created by Valo on 16/7/12.
//  Copyright © 2016年 valo. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double VSSDBVersionNumber;
FOUNDATION_EXPORT const unsigned char VSSDBVersionString[];

@interface VSDOptions : NSObject
@property (nonatomic, assign) size_t    cache_size;
@property (nonatomic, assign) size_t    max_open_files;
@property (nonatomic, assign) size_t    write_buffer_size;
@property (nonatomic, assign) size_t    block_size;
@property (nonatomic, assign) int       compaction_speed;
@property (nonatomic, copy  , nullable) NSString *compression;
@property (nonatomic, assign) BOOL      binlog;
@property (nonatomic, assign) size_t    binlog_capacity;
@end

@interface VSDKeyValItem : NSObject
@property (nonatomic, copy  , nonnull) NSString *key;
@property (nonatomic, strong, nonnull) NSData   *val;
@end

@interface VSDHashmapItem : NSObject
@property (nonatomic, copy  , nonnull) NSString *name;
@property (nonatomic, copy  , nonnull) NSString *key;
@property (nonatomic, strong, nonnull) NSData   *val;
@end

@interface VSDSortedSetItem : NSObject
@property (nonatomic, copy  , nonnull) NSString *name;
@property (nonatomic, copy  , nonnull) NSString *key;
@property (nonatomic, copy  , nonnull) NSData   *score;
@end

@interface VSDListItem : NSObject
@property (nonatomic, copy  , nonnull) NSString *key;
@property (nonatomic, strong, nonnull) NSData   *val;
@end

@interface VSSDB : NSObject

@property (nonatomic, copy  , nonnull) NSString *dbPath; ///< 数据库路径,

#pragma mark - 基本操作

/**
 *  初始化数据库
 *  @param name 数据库文件路径
 *  @return Objective-C封装后的ssdb数据库
 */
- (nonnull instancetype)initWithName:(nonnull NSString *)name;

/**
 *  打开数据库
 *  @return 数据库是否打开成功
 */
- (BOOL)open;

/**
 *  打开数据库
 *  @param options ssdb数据库参数
 *  @return 数据库是否打开成功
 */
- (BOOL)openWithOptions:(nullable VSDOptions *)options;

/**
 *  关闭数据库
 */
- (void)close;

@end

#pragma mark - 数据库相关操作
@interface VSSDB (Database)
/**
 *  删除 SSDB 数据库的所有数据.
 *  @return 是否删除成功
 */
- (int)flushdb;

/**
 *  返回数据库占用空间的估计值, 以字节为单位. 如果开启数据压缩, 返回的是压缩后的值.
 *  @return 数据库占用空间
 */
- (uint64_t)size;

/**
 *  压缩数据库
 */
- (void)compact;
@end

#pragma mark - Key-Value数据类型的各种操作
@interface VSSDB (KeyValue)
/**
 *  设置指定 key 的值内容.
 *  @param key  指定的key
 *  @param data 要设置的数据
 *  @return 是否设置成功
 */
- (BOOL)set:(nonnull NSString *)key data:(nonnull NSData *)data;

/**
 *  当 key 不存在时, 设置指定 key 的值内容. 如果已存在, 则不设置.
 *  @param key  指定的key
 *  @param data 要设置的数据
 *  @return 是否设置成功
 */
- (BOOL)setnx:(nonnull NSString *)key data:(nonnull NSData *)data;

/**
 *  使 key 对应的值增加 num. 参数 num 可以为负数. 如果原来的值不是整数(字符串形式的整数), 它会被先转换成整数.
 *  @param key    指定的key
 *  @param by     增加的num
 *  @return newval,增加后的值
 */
- (int64_t)incr:(nonnull NSString *)key by:(int64_t)by;

/**
 *  获取指定 key 的值内容.
 *  @param key  指定的key
 *  @return data,获取到的数据,失败则为nil
 */
- (nullable NSData *)get:(nonnull NSString *)key;

/**
 *  删除指定的 key.即使 key 不存在, 也会返回 YES.
 *  @param key 要删除的key
 *  @return 是否删除成功
 */
- (BOOL)del:(nonnull NSString *)key;

/**
 *  设置 key(只针对 KV 类型) 的存活时间.
 *  @param key 指定的key
 *  @param ttl 生存的时长
 *  @return 是否设置成功
 */
- (BOOL)expire:(nonnull NSString *)key ttl:(int64_t)ttl;

/**
 *  设置 key(只针对 KV 类型) 的数据和存活时间.
 *  @param key  指定的key
 *  @param data 要设置的数据
 *  @param ttl  生存的时长
 *  @return 是否设置成功
 */
- (BOOL)set:(nonnull NSString *)key data:(nonnull NSData *)data ttl:(int64_t)ttl;

/**
 *  返回 key(只针对 KV 类型) 的存活时间.
 *  @param key 指定的key
 *  @return 生存时间
 */
- (int64_t)ttl:(nonnull NSString *)key;

/**
 *  批量设置一批 key-value.
 *  @param keyvals keys以及对应的数据
 *  @return 是否设置成功
 */
- (BOOL)multi_set:(nonnull NSDictionary *)keyvals;

/**
 *  批量删除一批 key 和其对应的值内容.
 *  @param keys 要删除的keys
 *  @return 是否删除成功
 */
- (BOOL)multi_del:(nonnull NSArray<NSString *> *)keys;

/**
 *  设置字符串内指定位置的位值(BIT), 字符串的长度会自动扩展.
 *  @param key       指定的key
 *  @param bitOffset 要设置的位
 *  @param on        0或1
 *  @return 是否设置成功
 */
- (BOOL)setbit:(nonnull NSString *)key bitOffset:(int)bitOffset on:(int)on;

/**
 *  获取字符串内指定位置的位值(BIT).
 *  @param key       指定的key
 *  @param bitoffset 要获取的位
 *  @return 0或1
 */
- (int)getbit:(nonnull NSString *)key bitOffset:(int)bitoffset;

/**
 *  更新 key 对应的 value, 并返回更新前的旧的 value. 返回修改前 key 对应的值, 如果 key 不存在, 返回NO. 注意, 即使返回NO, 值也会被新加进去.
 *  @param key     指定key
 *  @param newData 新数据
 *  @return olddata,旧数据
 */
- (nullable NSData *)getset:(nonnull NSString *)key newData:(nonnull NSData *)newData;

/**
 *  顺序列出处于区间 (startKey, endKey] 的 key-value 列表. ("", ""] 表示整个区间. 此方法可实现类似通配符 * 号的查找, 但是, 仅支持前缀查找, 而且, * 必须被省略 - 不要在查询参数里输入 * 号! 注意, scan 并不是前缀搜索, 即使不带有指定参数前缀的 key 也会返回, 因为这是区间搜索!
 *  @param startKey 区间开始
 *  @param endKey   区间结束
 *  @param limit    获取的最大数量
 *  @return 获取到的Key-value对
 */
- (nonnull NSArray *)scan:(nonnull NSString *)startKey endKey:(nonnull NSString *)endKey limit:(int64_t)limit;

/**
 *  类似 scan, 逆序.startKey必须大于endKey,否则区间无效.
 *  @param startKey 区间开始
 *  @param endKey   区间结束
 *  @param limit    获取的最大数量
 *  @return 获取到的Key-value对
 */
- (nonnull NSArray *)rscan:(nonnull NSString *)startKey endKey:(nonnull NSString *)endKey limit:(int64_t)limit;

@end

#pragma mark Hashmap
@interface VSSDB (Hashmap)
/**
 *  设置 hashmap 中指定 key 对应的值内容.
 *  @param name hashmap 的名字
 *  @param key  hashmap 中的 key
 *  @param data key 对应的值内容
 *  @return 是否设置成功
 */
- (BOOL)hset:(nonnull NSString *)name key:(nonnull NSString *)key data:(nonnull NSData *)data;

/**
 *  删除 hashmap 中的指定 key. 如果要删除整个 hashmap, 请使用 hclear.
 *  @param name hashmap 的名字
 *  @param key  hashmap 中的 key
 *  @return 是否删除成功
 */
- (BOOL)hdel:(nonnull NSString *)name key:(nonnull NSString *)key;

/**
 *  使 hashmap 中的 key 对应的值增加 num. 参数 num 可以为负数. 如果原来的值不是整数(字符串形式的整数), 它会被先转换成整数.
 *  @param name   hashmap 的名字
 *  @param key    hashmap 中的 key
 *  @param by     必须是有符号整数
 *  @return 增加后的数据
 */
- (int64_t)hincr:(nonnull NSString *)name key:(nonnull NSString *)key by:(int64_t)by;

/**
 *  返回 hashmap 中的元素个数.
 *  @param name   hashmap 的名字
 *  @return 元素个数
 */
- (int64_t)hsize:(nonnull NSString *)name;

/**
 *  删除 hashmap 中的所有 key.
 *  @param name   hashmap 的名字
 *  @return 删除的个数
 */
- (int64_t)hclear:(nonnull NSString *)name;

/**
 *  获取 hashmap 中指定 key 的值内容.
 *  @param name hashmap 的名字
 *  @param key  hashmap 中的 key
 *  @return key对应的值内容,nil表示失败
 */
- (nullable NSData *)hget:(nonnull NSString *)name key:(nonnull NSString *)key;

/**
 *  顺序列出名字处于区间 (startName, endName] 的 hashmap.
 *  @param startName 区间开始
 *  @param endName   区间结束
 *  @param limit     要获取的 hashmap 个数
 *  @return 获取到的 hashmap
 */
- (nonnull NSArray *)hlist:(nonnull NSString *)startName endName:(nonnull NSString *)endName limit:(int64_t)limit;

/**
 *  顺序列出 hashmap 中处于区间 (startKey, endKey] 的 key-value 列表.
 *  @param name     hashmap 的名字
 *  @param startKey 区间开始
 *  @param endKey   区间结束
 *  @param limit    获取的最大个数
 *  @return 获取到的数据
 */
- (nonnull NSArray *)hscan:(nonnull NSString *)name startKey:(nonnull NSString *)startKey endKey:(nonnull NSString *)endKey limit:(int64_t)limit;

/**
 *  类似hscan, 逆序. starKey必须大于endKey,否则区间无效.
 *  @param name     hashmap 的名字
 *  @param startKey 区间开始
 *  @param endKey   区间结束
 *  @param limit    获取的最大个数
 *  @return 获取到的数据
 */
- (nonnull NSArray *)hrscan:(nonnull NSString *)name startKey:(nonnull NSString *)startKey endKey:(nonnull NSString *)endKey limit:(int64_t)limit;

@end

#pragma mark Sorted-Set
@interface VSSDB (SortedSet)
/**
 *  设置有序集合中指定 key 对应的权重
 *  @param name  有序集合的名字
 *  @param key   指定的key
 *  @param score 权重
 *  @return 是否设置成功
 */
- (BOOL)zset:(nonnull NSString *)name key:(nonnull NSString *)key score:(nonnull NSData *)score;

/**
 *  删除有序集合中指定的 key
 *  @param name 有序集合的名字
 *  @param key  指定的key
 *  @return 是否删除成功
 */
- (BOOL)zdel:(nonnull NSString *)name key:(nonnull NSString *)key;

/**
 *  使有序集合中的 key 对应的值增加 num. 参数 num 可以为负数. 如果原来的值不是整数(字符串形式的整数), 它会被先转换成整数.
 *  @param name   有序集合的名字
 *  @param key    指定的key
 *  @param by     有符号的整数
 *  @return 增加num后的值
 */
- (int64_t)zincr:(nonnull NSString *)name key:(nonnull NSString *)key by:(int64_t)by;

/**
 *  获取有序集合的元素个数
 *  @param name 有序集合的名字
 *  @return 元素个数
 */
- (int64_t)zsize:(nonnull NSString *)name;

/**
 *  获取有序集合中指定 key 的权重
 *  @param name  有序集合的名字
 *  @param key   指定的key
 *  @return score,获取到的权重
 */
- (nullable NSData *)zget:(nonnull NSString *)name key:(nonnull NSString *)key;

/**
 *  顺序获取指定 key 在 有序集合 中的排序位置(排名), 排名从 0 开始
 *  @param name 有序集合的名字
 *  @param key  指定的key
 *  @return 排名
 */
- (int64_t)zrank:(nonnull NSString *)name key:(nonnull NSString *)key;

/**
 *  倒序获取指定 key 在有序集合中的排名
 *  @param name 有序集合的名字
 *  @param key  指定的key
 *  @return 排名
 */
- (int64_t)zrrank:(nonnull NSString *)name key:(nonnull NSString *)key;

/**
 *  根据下标索引区间 [offset, offset + limit) 顺序获取key-score对
 *  @param name   有序集合
 *  @param offset 偏移量
 *  @param limit  获取的最大个数
 *  @return 获取到的数据
 */
- (nonnull NSArray *)zrange:(nonnull NSString *)name offset:(int64_t)offset limit:(int64_t)limit;

/**
 *  类似zrange,逆序.
 *  @param name   有序集合的名字
 *  @param offset 偏移量
 *  @param limit  获取的最大个数
 *  @return 获取到的数据
 */
- (nonnull NSArray *)zrrange:(nonnull NSString *)name offset:(int64_t)offset limit:(int64_t)limit;

/**
 *  顺序列出有序集合中处于区间 (key+startScore, endScore] 的key-score列表
 *  @param name       有序集合的名字
 *  @param key        指定的key
 *  @param startScore 区间开始
 *  @param endScore   区间结束
 *  @param limit      获取的最大个数
 *  @return 获取到的结果
 */
- (nonnull NSArray *)zscan:(nonnull NSString *)name key:(nonnull NSString *)key startScore:(nonnull NSString *)startScore endScore:(nonnull NSString *)endScore limit:(int64_t)limit;

/**
 *  类似zscan, 逆序.
 *  @param name       有序集合的名字
 *  @param key        指定的key
 *  @param startScore 区间开始
 *  @param endScore   区间结束
 *  @param limit      获取的最大个数
 *  @return 获取到的结果
 */
- (nonnull NSArray *)zrscan:(nonnull NSString *)name key:(nonnull NSString *)key startScore:(nonnull NSString *)startScore endScore:(nonnull NSString *)endScore limit:(int64_t)limit;

/**
 *  顺序列出名字处于区间 (name_start, name_end] 的有序集合
 *  @param startName 区间开始
 *  @param endName   区间结束
 *  @param limit     最大个数
 *  @return 获取到的集合
 */
- (nonnull NSArray *)zlist:(nonnull NSString *)startName endName:(nonnull NSString *)endName limit:(int64_t)limit;

/**
 *  类似zlist, 逆序.
 *  @param startName 区间开始
 *  @param endName   区间结束
 *  @param limit     最大个数
 *  @return 获取到的集合
 */
- (nonnull NSArray *)zrlist:(nonnull NSString *)startName endName:(nonnull NSString *)endName limit:(int64_t)limit;

/**
 *  功能未知(测试无任何效果)
 *  @param name 有序集合的名字
 *  @return 是否成功
 */
- (int64_t)zfix:(nonnull NSString *)name;

@end

#pragma mark List
@interface VSSDB (List)
/**
 *  获取队列长度
 *  @param name 队列名
 *  @return 队列长度
 */
- (int64_t)qsize:(nonnull NSString *)name;

/**
 *  从队列首部弹出一个元素.
 *  @param name 队列名
 *  @return 获取到的元素
 */
- (nullable NSData *)qfront:(nonnull NSString *)name;

/**
 *  从队列尾部弹出一个元素.
 *  @param name 队列名
 *  @return 获取到的元素
 */
- (nullable NSData *)qback:(nonnull NSString *)name;

/**
 *  往队列的首部添加一个元素
 *  @param name 队列名
 *  @param data 要添加的元素
 *  @return 添加的个数
 */
- (int64_t)qpush_front:(nonnull NSString *)name data:(nonnull NSData *)data;

/**
 *  往队列的尾部添加一个元素
 *  @param name 队列名
 *  @param data 要添加的元素
 *  @return 添加的个数
 */
- (int64_t)qpush_back:(nonnull NSString *)name data:(nonnull NSData *)data;

/**
 *  从队列首部弹出一个元素
 *  @param name 队列名
 *  @return 弹出的数据
 */
- (nonnull NSData *)qpop_front:(nonnull NSString *)name;

/**
 *  从队列尾部弹出一个或者多个元素
 *  @param name 队列名
 *  @return 弹出的数据
 */
- (nonnull NSData *)qpop_back:(nonnull NSString *)name;

/**
 *  功能未知(测试无任何效果)
 *  @param name 有序集合的名字
 *  @return 是否成功
 */
- (int64_t)qfix:(nonnull NSString *)name;

/**
 *  顺序列出名字处于区间 (startName, endName] 的队列
 *  @param startName 区间开始
 *  @param endName   区间结束
 *  @param limit     获取队列的数量
 *  @return 获取到的队列
 */
- (nonnull NSArray *)qlist:(nonnull NSString *)startName endName:(nonnull NSString *)endName limit:(int64_t)limit;

/**
 *  类似qlist, 逆序
 *  @param startName 开始的队列名
 *  @param endName   结束的队列名
 *  @param limit     获取队列的数量
 *  @return 获取到的队列
 */
- (nonnull NSArray *)qrlist:(nonnull NSString *)startName endName:(nonnull NSString *)endName limit:(int64_t)limit;

/**
 *  返回下标处于区域 [begin, end] 的元素. begin 和 end 可以是负数
 *  @param name   队列名
 *  @param offset 起始下标
 *  @param limit  获取的元素个数
 *  @return 获取到的元素
 */
- (nonnull NSArray *)qslice:(nonnull NSString *)name offset:(int64_t)offset limit:(int64_t)limit;

/**
 *  返回指定位置的元素. 0 表示第一个元素, 1 是第二个 ... -1 是最后一个
 *  @param name  队列名
 *  @param index 索引
 *  @return 获取到的数据
 */
- (nonnull NSString *)qget:(nonnull NSString *)name index:(int64_t)index;

/**
 *  更新位于 index 位置的元素. 如果超过现有的元素范围, 会返回错误
 *  @param name  队列名
 *  @param index 索引
 *  @param data  要设置的数据
 *  @return 是否设置成功
 */
- (BOOL)qset:(nonnull NSString *)name index:(int64_t)index data:(nonnull NSData *)data;

/**
 *  更新多个位置的元素. 如果超过现有的元素范围, 会返回错误
 *  @param name  队列名
 *  @param seq   要设置的数量
 *  @param data  要设置的数据
 *  @return 是否设置成功
 */
- (BOOL)qset_by_seq:(nonnull NSString *)name seq:(int64_t)seq data:(nonnull NSData *)data;

@end
