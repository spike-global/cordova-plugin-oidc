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

#import "OIDCWebAuthRequest.h"
#import "OIDCWebAuthResponse.h"
#import "OIDCWorkPlaceJoinConstants.h"
#import "OIDCClientMetrics.h"
#import "NSDictionary+OIDCExtensions.h"
#import "OIDCOAuth2Constants.h"
#import "OIDCWebResponse.h"
#import "OIDCPkeyAuthHelper.h"

@implementation OIDCWebAuthRequest

@synthesize returnRawResponse = _returnRawResponse;
@synthesize retryIfServerError = _retryIfServerError;
@synthesize startTime = _startTime;
@synthesize acceptOnlyOKResponse = _acceptOnlyOKResponse;

- (id)initWithURL:(NSURL *)url
          context:(id<OIDCRequestContext>)context
{
    self = [super initWithURL:url context:context];
    if (!self)
    {
        return nil;
    }
    
    [_requestHeaders setObject:@"application/json" forKey:@"Accept"];
    [_requestHeaders setObject:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
    
    // Mac OS does not use PKeyAuth.
#if TARGET_OS_IPHONE
    [_requestHeaders setObject:kOIDCPKeyAuthHeaderVersion forKey:kOIDCPKeyAuthHeader];
#endif
    
    _retryIfServerError = YES;
    
    return self;
}

- (void)sendRequest:(OIDCWebResponseCallback)completionBlock
{
    if ([self isGetRequest] && [_requestDictionary allKeys].count > 0)
    {
        NSString* newURL = [NSString stringWithFormat:@"%@?%@", [_requestURL absoluteString], [_requestDictionary adURLFormEncode]];
        _requestURL = [NSURL URLWithString:newURL];
    }
    else
    {
        [self setBody:[[_requestDictionary adURLFormEncode] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    _startTime = [NSDate new];
    [[OIDCClientMetrics getInstance] addClientMetrics:_requestHeaders endpoint:[_requestURL absoluteString]];
    
    [self send:^( NSError *error, OIDCWebResponse *webResponse )
    {
        if (error)
        {
            [OIDCWebAuthResponse processError:error request:self completion:completionBlock];
        }
        else
        {
            [OIDCWebAuthResponse processResponse:webResponse request:self completion:completionBlock];
        }
    }];
}


@end
