//
//  TWConstants.m
//
//  Created by Yu Sugawara on 4/10/15.
//  Copyright (c) 2015 Yu Sugawara. All rights reserved.
//

#import "TWConstants.h"

#pragma mark - URL

/**
 Server Key and Certificate #1
 Common names	api.twitter.com
 Alternative names	api.twitter.com
 Prefix handling	Not required for subdomains
 Valid from	Tue, 11 Aug 2015 00:00:00 UTC
 Valid until	Mon, 15 Aug 2016 12:00:00 UTC (expires in 10 months and 22 days)
 Key	EC 256 bits
 Weak key (Debian)	No
 Issuer	DigiCert SHA2 High Assurance Server CA
 Signature algorithm	SHA256withRSA
 Extended Validation	No
 Certificate Transparency	No
 Revocation information	CRL, OCSP
 Revocation status	Good (not revoked)
 Trusted	Yes
 
 https://globalsign.ssllabs.com/analyze.html?d=api.twitter.com
 */
NSString *kTWBaseURLString_API = @"https://api.twitter.com/";
NSString *kTWBaseURLString_API_1_1 = @"https://api.twitter.com/1.1/";

/**
 Server Key and Certificate #1
 Subject	upload.twitter.com
 Fingerprint SHA1: 6bca8263f568d6df2edfe34ecd8e70e43664c361
 Pin SHA256: I0HR2nKbG52OX/ZX+R7eXlZFKMNSJHbROzkHwjUFJps=
 Common names	upload.twitter.com
 Alternative names	upload.twitter.com
 Prefix handling	Not required for subdomains
 Valid from	Fri, 18 Sep 2015 00:00:00 UTC
 Valid until	Sun, 01 Apr 2018 12:00:00 UTC (expires in 2 years and 4 months)
 Key	EC 256 bits
 Weak key (Debian)	No
 Issuer	DigiCert SHA2 High Assurance Server CA
 Signature algorithm	SHA256withRSA
 Extended Validation	No
 Certificate Transparency	Yes (certificate)
 Revocation information	CRL, OCSP
 Revocation status	Good (not revoked)
 Trusted	Yes
 
 https://globalsign.ssllabs.com/analyze.html?d=upload.twitter.com
 */
NSString *kTWBaseURLString_Upload_1_1 = @"https://upload.twitter.com/1.1/";

/**
 Server Key and Certificate #1
 Common names	stream.twitter.com
 Alternative names	stream.twitter.com partnerstream1.twitter.com partnerstream2.twitter.com
 Prefix handling	Not required for subdomains
 Valid from	Wed, 09 Apr 2014 00:00:00 UTC
 Valid until	Fri, 30 Dec 2016 23:59:59 UTC (expires in 1 year and 3 months)
 Key	RSA 2048 bits (e 65537)
 Weak key (Debian)	No
 Issuer	VeriSign Class 3 Secure Server CA - G3
 Signature algorithm	SHA1withRSA   WEAK
 Extended Validation	No
 Certificate Transparency	No
 Revocation information	CRL, OCSP
 Revocation status	Good (not revoked)
 Trusted	Yes
 
 https://globalsign.ssllabs.com/analyze.html?d=stream.twitter.com
 */
NSString *kTWBaseURLString_Stream_1_1 = @"https://stream.twitter.com/1.1/";

/**
 Server Key and Certificate #1
 Common names	userstream.twitter.com
 Alternative names	userstream.twitter.com
 Prefix handling	Not required for subdomains
 Valid from	Wed, 16 Sep 2015 00:00:00 UTC
 Valid until	Sun, 01 Apr 2018 12:00:00 UTC (expires in 2 years and 6 months)
 Key	RSA 2048 bits (e 65537)
 Weak key (Debian)	No
 Issuer	DigiCert SHA2 High Assurance Server CA
 Signature algorithm	SHA256withRSA
 Extended Validation	No
 Revocation information	CRL, OCSP
 Revocation status	Good (not revoked)
 Trusted	Yes
 
 https://globalsign.ssllabs.com/analyze.html?d=userstream.twitter.com
 */
NSString *kTWBaseURLString_UserStream_1_1 = @"https://userstream.twitter.com/1.1/";

/**
 Server Key and Certificate #1
 Common names	sitestream.twitter.com
 Alternative names	sitestream.twitter.com
 Prefix handling	Not required for subdomains
 Valid from	Thu, 17 Sep 2015 00:00:00 UTC
 Valid until	Sun, 01 Apr 2018 12:00:00 UTC (expires in 2 years and 6 months)
 Key	RSA 2048 bits (e 65537)
 Weak key (Debian)	No
 Issuer	DigiCert SHA2 High Assurance Server CA
 Signature algorithm	SHA256withRSA
 Extended Validation	No
 Revocation information	CRL, OCSP
 Revocation status	Good (not revoked)
 Trusted	Yes
 
 https://globalsign.ssllabs.com/analyze.html?d=sitestream.twitter.com
 */
NSString *kTWBaseURLString_SiteStream_1_1 = @"https://sitestream.twitter.com/1.1/";

NSString *kTWHTTPMethodGET = @"GET";
NSString *kTWHTTPMethodPOST = @"POST";
NSString *kTWHTTPMethodDELETE = @"DELETE";
NSString *kTWHTTPMethodPUT = @"PUT";

#pragma mark - Model key

NSString * const kTWPostData = @"kTWPostData";

@implementation TWConstants

@end
