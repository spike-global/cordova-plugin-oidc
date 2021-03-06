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

#import <Foundation/Foundation.h>
#import "OIDCClientMetrics.h"
#import "OIDCHelpers.h"
#import "NSString+OIDCHelperMethods.h"
#import "OIDCLogger.h"
#import "OIDCErrorCodes.h"

@implementation OIDCClientMetrics

//header keys
const NSString* OidcHeaderLastError = @"x-client-last-error";
const NSString* OidcHeaderLastRequest = @"x-client-last-request";
const NSString* OidcHeaderLastResponseTime = @"x-client-last-response-time";
const NSString* OidcHeaderLastEndpoint = @"x-client-last-endpoint";

//values
@synthesize endpoint = _endpoint;
@synthesize responseTime = _responseTime;
@synthesize correlationId = _correlationId;
@synthesize startTime = _startTime;
@synthesize errorToReport = _errorToReport;
@synthesize isPending = _isPending;

+ (OIDCClientMetrics *)getInstance
{
    static OIDCClientMetrics* instance = nil;
    static dispatch_once_t onceToken = 0;
    @synchronized(self)
    {
        dispatch_once(&onceToken, ^{
            instance = [[OIDCClientMetrics alloc] init];
        });
    }
    return instance;
}

- (void)addClientMetrics:(NSMutableDictionary *)requestHeaders
                endpoint:(NSString *)endPoint
{
    if ([OIDCHelpers isOAUTHInstance:endPoint])
    {
        return;
    }
    
    @synchronized(self)
    {
        if (!_isPending)
        {
            return;
        }
        
        if (_errorToReport && _responseTime && _endpoint && _correlationId)
        {
            [requestHeaders setObject:_errorToReport forKey:OidcHeaderLastError];
            [requestHeaders setObject:_responseTime forKey:OidcHeaderLastResponseTime];
            [requestHeaders setObject:[OIDCHelpers getEndpointName:_endpoint] forKey:OidcHeaderLastEndpoint];
            [requestHeaders setObject:_correlationId forKey:OidcHeaderLastRequest];
        }
        else
        {
            //OIDC_LOG_ERROR(@"unable to add client metrics.", OIDC_ERROR_UNEXPECTED, nil, nil);
        }
        
        _errorToReport = nil;
        _endpoint = nil;
        _correlationId = nil;
        _responseTime = nil;
        
        _isPending = NO;
    }
}

- (void)endClientMetricsRecord:(NSString *)endpoint
                     startTime:(NSDate *)startTime
                 correlationId:(NSUUID *)correlationId
                  errorDetails:(NSString *)errorDetails
{
    if ([OIDCHelpers isOAUTHInstance:endpoint])
    {
        return;
    }
    
    @synchronized(self)
    {
        _endpoint = endpoint;
        _errorToReport = [NSString adIsStringNilOrBlank:errorDetails] ? @"" : errorDetails;
        _correlationId = [correlationId UUIDString];
        _responseTime = [NSString stringWithFormat:@"%f", [startTime timeIntervalSinceNow] * -1000.0];
        _isPending = YES;
    }
}

- (void)clearMetrics
{
    @synchronized (self)
    {
        _errorToReport = nil;
        _endpoint = nil;
        _correlationId = nil;
        _responseTime = nil;
        
        _isPending = NO;
    }
}

@end
