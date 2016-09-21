# Twitter for Objective-C

## API

- [Upcoming changes to Tweets](https://dev.twitter.com/overview/api/upcoming-changes-to-tweets)
- [New attachment_url option is now live on the Tweet endpoints](https://twittercommunity.com/t/new-attachment-url-option-is-now-live-on-the-tweet-endpoints/74270)

## ATS

|domain|Key|Signature algorithm|
|:---:|:---:|:---:|
|api.twitter.com|EC 256 bits|SHA256withRSA|
|userstream.twitter.com|RSA 2048 bits (e 65537)|SHA256withRSA|
|sitestream.twitter.com|RSA 2048 bits (e 65537)|SHA256withRSA|
|upload.twitter.com|RSA 2048 bits (e 65537)|SHA256withRSA|
|stream.twitter.com|RSA 2048 bits (e 65537)|**SHA1withRSA**|
|twimg.com| RSA 2048 bits (e 65537)|SHA256withRSA or **SHA1withRSA**|
*https://globalsign.ssllabs.com/index.html*


### info.plist
```
- NSAppTransportSecurity (Dictionary)
	- NSExceptionDomains (Dictionary)
		- stream.twitter.com (Dictionary)
			- NSExceptionRequiresForwardSecrecy : NO
		- twimg.com (Dictionary)
			- NSIncludesSubdomains : YES
			- NSExceptionRequiresForwardSecrecy : NO
```
