//
//  F@H_auth.h
//  FeelAtHome
//
//  Created by Michael BARBARIN on 03/02/15.
//  Copyright (c) 2015 Michael BARBARIN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface MyfoxAuth : NSObject
{
    NSString *UserName;
    NSString *PsswdName;
}

- (id) init:(NSString*) username withPassword: (NSString*)password;

- (void) init_autorize:(NSString*) username withPassword: (NSString*)password;
- (void) logout;

- (void) get_request_site: (void(^)(int, NSError*))cb;
- (void) get_request: (NSString*)type withItemName:(NSString*)item_name withBlock: (void(^)(int, int, NSError*))cb;
- (void) get_request_spec: (NSString*)type withItemName:(NSString*)item_name withElem1:(NSString*)elem_name1 withElem2:(NSString*)elem_name2 withBlock: (void(^)(int, int, NSError*))cb;
- (void) set_request_specific_element:(NSString*) typeDevice withNameDevice: (NSString*)nameDevice withState: (bool) state withErrorHandler: (void(^)(NSError*))cb;
- (void) set_request_heater_new_state:(NSString*) nameHeater withState: (bool) state withErrorHandler: (void(^)(NSError*))cb;
- (void) set_request_shutter_new_state:(NSString*) nameShutter withState: (bool) state withErrorHandler: (void(^)(NSError*))cb;
- (void) set_request_electric_group_new_state:(NSString*) nameG_Elec withState: (bool) state withErrorHandler: (void(^)(NSError*))cb;




@end
