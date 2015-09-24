# Twitter for Objective-C# Twitter for Objective-C

## ATS

|domain|Key|Signature algorithm|
|:---:|:---:|:---:|
|api.twitter.com|EC 256 bits|SHA256withRSA|
|userstream.twitter.com|RSA 2048 bits (e 65537)|SHA256withRSA|
|sitestream.twitter.com|RSA 2048 bits (e 65537)|SHA256withRSA|
|upload.twitter.com|RSA 2048 bits (e 65537)|**SHA1withRSA**|
|stream.twitter.com|RSA 2048 bits (e 65537)|**SHA1withRSA**|
*https://globalsign.ssllabs.com/index.html*

### info.plist
```
- NSAppTransportSecurity (Dictionary)
	- NSExceptionDomains (Dictionary)
		- upload.twitter.com (Dictionary)
			- NSExceptionRequiresForwardSecrecy : NO
		- stream.twitter.com (Dictionary)
			- NSExceptionRequiresForwardSecrecy : NO
```
or NSIncludesSubdomains : YES
