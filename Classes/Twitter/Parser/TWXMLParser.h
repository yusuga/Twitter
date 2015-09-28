//
//  TWXMLParser.h
//  Develop
//
//  Created by Yu Sugawara on 9/28/15.
//  Copyright © 2015 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWXMLParser : NSObject

+ (void)parseErrorXML:(NSString *)xml
                 code:(NSNumber **)codePtr
              message:(NSString **)messagePtr;

@end
