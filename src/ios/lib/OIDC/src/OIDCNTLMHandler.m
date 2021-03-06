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

#import "OIDCNTLMHandler.h"
#import "OIDCAuthenticationSettings.h"
#import "NSString+OIDCHelperMethods.h"
#import "OIDCErrorCodes.h"
#import "OIDC_Internal.h"
#import "OIDCURLProtocol.h"
#import "OIDCNTLMUIPrompt.h"

@implementation OIDCNTLMHandler

static NSString *_cancellationUrl = nil;
static BOOL _challengeCancelled = NO;
static NSMutableURLRequest *_challengeUrl = nil;
static NSURLSession *_session = nil;

+ (void)load
{
    [OIDCURLProtocol registerHandler:self
                        authMethod:NSURLAuthenticationMethodNTLM];
}

+ (void)setCancellationUrl:(NSString*) url
{
    if (_cancellationUrl == url)
    {
        return;
    }
    _cancellationUrl = [url copy];
}

+ (BOOL)isChallengeCancelled
{
    return _challengeCancelled;
}

/* Stops the HTTPS interception. */
+ (void)resetHandler
{
    @synchronized(self)//Protect the sOIDC_Identity_Ref from being cleared while used.
    {
        [OIDCNTLMUIPrompt dismissPrompt];
        
        _challengeUrl = nil;
        _cancellationUrl = nil;
        _session = nil;
        _challengeCancelled = NO;
    }
}


+ (BOOL)handleChallenge:(NSURLAuthenticationChallenge *)challenge
                session:(NSURLSession *)session
                   task:(NSURLSessionTask *)task
               protocol:(OIDCURLProtocol *)protocol
      completionHandler:(ChallengeCompletionHandler)completionHandler
{
    @synchronized(self)
    {
        if (_session)
        {
            _session = nil;
        }
        
        // This is the NTLM challenge: use the identity to authenticate:
        OIDC_LOG_INFO_F(@"Attempting to handle NTLM challenge", nil,  @"host: %@", challenge.protectionSpace.host);
        
        [OIDCNTLMUIPrompt presentPrompt:^(NSString *username, NSString *password)
         {
             if (username)
             {
                 NSURLCredential *credential;
                 credential = [NSURLCredential
                               credentialWithUser:username
                               password:password
                               persistence:NSURLCredentialPersistenceForSession];
                 
                 completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
                 
                 OIDC_LOG_INFO_F(@"NTLM credentials added", nil, @"host: %@", challenge.protectionSpace.host);
             }
             else
             {
                 _challengeCancelled = YES;
                 OIDC_LOG_INFO_F(@"NTLM challenge cancelled", nil, @"host: %@", challenge.protectionSpace.host);
                 
                 completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);

                 NSError *error = [NSError errorWithDomain:OIDCAuthenticationErrorDomain code:OIDC_ERROR_UI_USER_CANCEL userInfo:nil];
                 [protocol URLSession:session task:task didCompleteWithError:error];
             }
         }];
    }//@synchronized
    
    return YES;
}




@end
