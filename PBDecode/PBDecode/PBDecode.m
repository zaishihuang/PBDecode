//
//  PBDecode.m
//  PBDecode
//
//  Created by clovelu on 26/04/2018.
//

#import "PBDecode.h"
#import <ProtocolBuffers/Bootstrap.h>

@implementation PBDecode
+ (NSDictionary *)parseFromHexString:(NSString *)hexString {
    NSData *data = [[self class] dataForHexString:hexString];
    return [self parseFromData:data];
}

+ (NSDictionary *)parseFromData:(NSData *)data {
    if (!data.length) return nil;
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    PBCodedInputStream *input = [PBCodedInputStream streamWithData:data];
    while (YES) {
        SInt32 tag = [input readTag];
        if (tag == 0) {
            break;
        }
        
        SInt32 fileNum = PBWireFormatGetTagFieldNumber(tag);
        SInt32 fileType = PBWireFormatGetTagWireType(tag);
        NSString *key = [NSString stringWithFormat:@"%@-%@-%@", @(fileNum), @(fileType), @(tag)];
        id tvalue = nil;
        switch (fileType) {
            case 0: { //varint
                SInt64 value = [input readRawVarint64];
                tvalue = @(value);
                break;
            }
            case 1: { // fixed64
                SInt64 value = [input readFixed64];
                tvalue = @(value);
                break;
            }
            case 5: { // fixed32
                SInt32 value = [input readFixed32];
                tvalue = @(value);
                break;
            }
            case 2: { // LengthDelimited
                SInt32 len = [input readInt32];
                if (len > 0) {
                    NSData *value = [input readRawData:len];
                    UInt8 buffer;
                    [value getBytes:&buffer range:NSMakeRange(0, 1)];
                    
                    // 特殊逻辑
                    SInt32 tmpfileNum = PBWireFormatGetTagFieldNumber(buffer);
                    SInt32 tmpfileType = PBWireFormatGetTagWireType(buffer);
                    if (tmpfileNum > 1 || tmpfileType >= PBWireFormatFixed32) {
                        info[key] = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
                    } else {
                        NSDictionary *tmpInfo = nil;
                        @try {
                           tmpInfo = [self parseFromData:value];
                        } @catch (NSException *exception) {
                            tmpInfo = nil;
                        }
                        
                        if (tmpInfo) {
                            tvalue = tmpInfo;
                        } else {
                            tvalue =  [value description];
                        }
                    }
                }
                break;
            }
            case 3: { // StartGroup
                SInt32 len = [input readInt32];
                NSData *value = [input readRawData:len];
                tvalue = value.description;
                break;
            }
            case 4: { // endGroup
                break;
            }
            default:
                break;
        }
        
        if (tvalue) {
            id o_value = info[key];
            if (!o_value) {
                info[key] = tvalue;
            } else {
                // repeat 数组
                id o_value = info[key];
                NSMutableArray *list = nil;
                if ([o_value isKindOfClass:[NSMutableArray class]]) {
                    list = (NSMutableArray *)o_value;
                } else {
                    list = [NSMutableArray array];
                    [list addObject:o_value];
                    info[key] = list;
                }
                
                [list addObject:tvalue];
            }
            
        }
        
    }
    
    return info;
}

+ (NSData *)dataForHexString:(NSString *)hexStr {
    hexStr = [hexStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hexStr = [hexStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    hexStr = [hexStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    hexStr = [hexStr lowercaseString];
    
    NSUInteger len = hexStr.length;
    if (!len) return nil;
    unichar *buf = malloc(sizeof(unichar) * len);
    if (!buf) return nil;
    [hexStr getCharacters:buf range:NSMakeRange(0, len)];
    
    NSMutableData *result = [NSMutableData data];
    unsigned char bytes;
    char str[3] = { '\0', '\0', '\0' };
    int i;
    for (i = 0; i < len / 2; i++) {
        str[0] = buf[i * 2];
        str[1] = buf[i * 2 + 1];
        bytes = strtol(str, NULL, 16);
        [result appendBytes:&bytes length:1];
    }
    free(buf);
    return result;
    
}

@end
