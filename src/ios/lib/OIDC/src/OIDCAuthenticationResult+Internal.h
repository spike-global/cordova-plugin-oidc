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

#import "OIDCAuthenticationResult.h"

@class OIDCTokenCacheItem;

/* Internally accessible methods.*/
@interface OIDCAuthenticationResult (Internal)

/*! Creates a result from a user or request cancellation condition, with/without correlation id. */
+ (OIDCAuthenticationResult*)resultFromCancellation;
+ (OIDCAuthenticationResult*)resultFromCancellation:(NSUUID*)correlationId;

/*! Creates an authentication result from an error condition, with/without correlation id. */
+ (OIDCAuthenticationResult*)resultFromError:(OIDCAuthenticationError*)error;
+ (OIDCAuthenticationResult*)resultFromError:(OIDCAuthenticationError*)error
                             correlationId:(NSUUID*)correlationId;

+ (OIDCAuthenticationResult*)resultFromParameterError:(NSString*)details;
+ (OIDCAuthenticationResult*)resultFromParameterError:(NSString*)details
                                      correlationId:(NSUUID*)correlationId;

/*! Creates an instance of the result from a pre-setup token cache store item */
+ (OIDCAuthenticationResult*)resultFromTokenCacheItem:(OIDCTokenCacheItem*)item
                               multiResourceRefreshToken:(BOOL)multiResourceRefreshToken
                                           correlationId:(NSUUID*)correlationId;

/*! Creates an authentication result from broker response, which can be with/without correlation id. */
+ (OIDCAuthenticationResult*)resultFromBrokerResponse:(NSDictionary*)response;

/*! Internal method to set the extendedLifetimeToken flag. */
- (void)setExtendedLifeTimeToken:(BOOL)extendedLifeTimeToken;

@end