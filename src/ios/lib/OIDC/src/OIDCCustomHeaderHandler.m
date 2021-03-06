// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "OIDCCustomHeaderHandler.h"

@implementation OIDCCustomHeaderHandler

static NSMutableDictionary* s_customHeaders = nil;
static NSMutableDictionary* s_customHeadersForSingleUse = nil;

+ (void)initialize
{
    if (self == [OIDCCustomHeaderHandler class])
    {
    // MacOS does not use PKeyAuth.
#if TARGET_OS_IPHONE
        s_customHeaders = [NSMutableDictionary dictionaryWithDictionary: @{@"x-ms-PkeyAuth":@"1.0"}];
#else
        s_customHeaders = [NSMutableDictionary dictionary];
#endif
        
        s_customHeadersForSingleUse = [NSMutableDictionary new];
    }
}

+ (void)addCustomHeaderValue:(NSString*)value
                forHeaderKey:(NSString*)key
                forSingleUse:(BOOL)singleUse
{
    if(singleUse)
    {
        [s_customHeadersForSingleUse setObject:value forKey:key];
    }
    else
    {
        [s_customHeaders setObject:value forKey:key];
    }
}

+ (void)applyCustomHeadersTo:(NSMutableURLRequest*) request
{
    for(NSString* key in s_customHeaders)
    {
        id value = [s_customHeaders objectForKey:key];
        [request setValue:value forHTTPHeaderField:key];
    }
    
    for(NSString* key in s_customHeadersForSingleUse)
    {
        id value = [s_customHeadersForSingleUse objectForKey:key];
        [request setValue:value forHTTPHeaderField:key];
        [s_customHeadersForSingleUse removeObjectForKey:key];
    }
}

@end
