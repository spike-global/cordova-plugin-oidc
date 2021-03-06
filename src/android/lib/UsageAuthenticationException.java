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

package com.cordova.plugin.oidc;

/**
 * usage authentication error.
 */
public class UsageAuthenticationException extends AuthenticationException {
    static final long serialVersionUID = 1;

    /**
     * Constructs a new UsageAuthenticationException with message.
     * @param code The error code for {@link UsageAuthenticationException}.
     * @param msg Detailed message for the reason causing the exception.
     */
    public UsageAuthenticationException(OIDCError code, String msg) {
        super(code, msg);
    }
    
    /**
     * Constructs a new UsageAuthenticationException with message and the cause exception.
     * 
     * @param code Resource file related error code. Message will be derived
     *            from resource with using app context.
     * @param msg Detailed message for the reason causing the exception.
     * @param throwable {@link Throwable}
     */
    public UsageAuthenticationException(OIDCError code, String msg, Throwable throwable) {
        super(code, msg, throwable);
    }
}
