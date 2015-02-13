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

+ (void)initialize;
- (id) init:(NSString*) username withPassword: (NSString*)password;
- (void) init_autorize:(NSString*) username withPassword: (NSString*)password;
- (void) logout;
- (void) get_request_site: (void(^)(int, NSError*))cb;
- (void) list_devices: (NSString*)type withBlock: (void(^)(NSArray*, NSError*))cb;
- (void) set_request_specific_element:(NSString*) typeDevice withIdDevice: (NSInteger)deviceId withState: (bool) state withErrorHandler: (void(^)(NSError*))cb;
- (void) set_request_heater_new_state:(NSInteger) heaterId withState: (bool) state withErrorHandler: (void(^)(NSError*))cb;
- (void) set_request_shutter_new_state:(NSInteger)shutterId withState: (bool) state  withErrorHandler: (void(^)(NSError*))cb;
- (void) set_request_electric_group_new_state:(NSInteger)G_ElecId withState: (bool) state withErrorHandler: (void(^)(NSError*))cb;

@end
