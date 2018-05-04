//
//  PBDecode.h
//  PBDecode
//
//  Created by clovelu on 26/04/2018.
//

#import <Foundation/Foundation.h>

@interface PBDecode : NSObject
+ (NSDictionary *)parseFromData:(NSData *)data;
+ (NSDictionary *)parseFromHexString:(NSData *)hexString;

+ (NSData *)dataForHexString:(NSString *)hexStr;
@end
