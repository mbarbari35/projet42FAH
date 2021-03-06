//
//  F@H_auth.m
//  FeelAtHome
//
//  Created by Michael BARBARIN on 03/02/15.
//  Copyright (c) 2015 Michael BARBARIN. All rights reserved.
//

#import "MyfoxAuth.h"
#import <NXOAuth2Client.h>
#import <NXOAuth2Client/NXOAuth2AccountStore.h>
#import <NXOAuth2Client/NXOAuth2Request.h>


NSString *errDomain = @"feelathome.myfox";
enum {
    UNKNOWN_TYPE,
    INVALID_DATA,
    KO_CONNECTION
};

@implementation MyfoxAuth

+ (void)initialize
{
    if (self == [MyfoxAuth class])
    {
        [[NXOAuth2AccountStore sharedStore] setClientID:@"fd7528601d0a09a72221de7cfdddeaaa"
                                                 secret:@"nsKGMQpfGT6Hb599XxD4AgyWnErAmR64"
                                       authorizationURL:[NSURL URLWithString: @"https://api.myfox.me/oauth2/authorize"]
                                               tokenURL:[NSURL URLWithString: @"https://api.myfox.me/oauth2/token"]
                                            redirectURL:[NSURL URLWithString: @"https://localhost/"]
                                         forAccountType:@"myfox"];
    }
}

- (id) init:(NSString*) username withPassword: (NSString*)password
{
    UserName = username;
    PsswdName = password;
    return (self);
}

- (void) init_autorize:(NSString*) username withPassword: (NSString*)password
{
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:@"myfox"
                                                              username:username // TODO : Fill username password
                                                              password:password];
}

- (void) logout
{
    [[NXOAuth2AccountStore sharedStore] removeAccount:[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"myfox"][0]];
}

- (void) get_request_site: (void(^)(int, NSError*))cb
{
    [self init_autorize: UserName withPassword: PsswdName];
    
    [NXOAuth2Request performMethod:@"GET"
                        onResource:[NSURL URLWithString:@"https://api.myfox.me/v2/client/site/items"]
                   usingParameters:nil
                       withAccount:[[[NXOAuth2AccountStore sharedStore] accountsWithAccountType: @"myfox"] firstObject]
               sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
                   NSLog(@"bytesSend : %llu pour un total de %llu!", bytesSend, bytesTotal);
               }
                   responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                       if (error)
                       {
                           cb(0, error);
                           return ;
                       }
                       NSError *err2 = nil;
                       id object = [NSJSONSerialization
                                    JSONObjectWithData:responseData
                                    options:0
                                    error:&err2];
                       
                       if(err2)
                       {
                           NSLog(@"Error X100.11: cannot receive a JSON format");
                           cb(0, err2);
                       }
                       else if([object isKindOfClass:[NSDictionary class]])
                       {
                           NSDictionary *results = object;
                           if([results[@"status"] isEqualToString: @"OK"]) {
                               NSLog(@"Error X155.0: %s", "Status communication KO with heater");
                               cb(0, [NSError errorWithDomain:errDomain code:KO_CONNECTION userInfo:nil]);
                               return ;
                           }
                           else
                               cb([results[@"payload"][@"items"][0][@"siteId"] integerValue], nil);
                       }
                       else {
                           NSLog(@"Error X100.21: the data receive not a dictionary data");
                           cb(0, [NSError errorWithDomain:errDomain code:INVALID_DATA userInfo:nil]);
                       }
                   }];
}

- (void) list_devices: (NSString*)type withBlock: (void(^)(NSArray*, NSError*))cb
{
    [self get_request_site: ^(int siteId, NSError* error_site) {
        if (error_site){
            cb(nil, error_site);
            return ;
        }
        NSString *add_request;
        
        add_request = [NSString stringWithFormat:@"%@%d%@%@%@", @"https://api.myfox.me:443/v2/site/" ,siteId, @"/device/data/", type, @"/items"];
        
        if ([type  isEqual: @"light"] || [type  isEqual: @"heater"] || [type  isEqual: @"shutter"] || [type  isEqual: @"electric"])
        {
            NSLog(@"Error X200.12: %@ type does not exist !", type);
            cb(nil, [NSError errorWithDomain:errDomain code:UNKNOWN_TYPE userInfo:@{@"unknownType": type}]);
        }
        
        [NXOAuth2Request performMethod:@"GET"
                            onResource:[NSURL URLWithString:add_request]
                       usingParameters:nil
                           withAccount:[[[NXOAuth2AccountStore sharedStore] accountsWithAccountType: @"myfox"] firstObject]
                   sendProgressHandler:nil
                       responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error)
         {
             if (error) {
                 cb(nil, error);
                 return ;
             }
             NSError *err2 = nil;
             id object = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:0
                          error:&err2];
             if(err2)
             {
                 NSLog(@"Error X100.1: cannot receive a JSON format : %@", response);
                 cb(nil, err2);
             }
             else if([object isKindOfClass:[NSDictionary class]])
             {
                 NSDictionary *results = object;
                 if([results[@"status"] isEqualToString: @"OK"]) {
                     NSLog(@"Error X155.0: %s", "Status communication KO with heater");
                     cb(nil, [NSError errorWithDomain:errDomain code:KO_CONNECTION userInfo:nil]);
                 }
                 else
                     cb(results[@"payload"][@"items"], nil);
             }
             else
             {
                 NSLog(@"Error X100.22: %s", "the data receive not a dictionary data");
                 cb(nil, [NSError errorWithDomain:errDomain code:INVALID_DATA userInfo:nil]);
             }
         }];
        
    }];

}

- (void) set_request_specific_element:(NSString*) typeDevice withIdDevice: (NSInteger)deviceId withState: (bool) state withErrorHandler: (void(^)(NSError*))cb
{
    /*
     if state = 1 : on the heater with nameheater
     else if state = 0, off the heater/
     */
    /*
     ** modeLabel (string) = ['boiler' or 'wired']: The heater heating mode,
     ** stateLabel (string) = ['on' or 'off' or 'eco' or 'frost' or 'boost' or 'away' or 'auto']: The heater state,
     ** lastTemperature (float, null, optional): Last temperature,
     ** deviceId (integer): The device identifier,
     ** label (string): The device label,
     ** modelId (string): The device model identifier,
     ** modelLabel (string): The device model label
     */
    
    [self get_request_site:^(int siteId, NSError *error_site)
     {
         if (error_site) {
             cb(error_site);
             return ;
         }
         NSString *add_request;
         
         if (state == TRUE)
             add_request = [NSString stringWithFormat:@"%@%d%@%d%@%@%@", @"https://api.myfox.me:443/v2/site/" ,siteId, @"device/", deviceId, @"/", typeDevice, @"/on"];
         else
             add_request = [NSString stringWithFormat:@"%@%d%@%d%@%@%@", @"https://api.myfox.me:443/v2/site/" ,siteId, @"device/", deviceId, @"/", typeDevice, @"/off"];
         
         
         [NXOAuth2Request performMethod:@"POST"
                             onResource:[NSURL URLWithString:add_request]
                        usingParameters:nil
                            withAccount:[[[NXOAuth2AccountStore sharedStore] accountsWithAccountType: @"myfox"] firstObject]
                    sendProgressHandler:nil
                        responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                            if (error) {
                                cb(error);
                                return ;
                            }
                            NSError *err2 = nil;
                            id object = [NSJSONSerialization
                                         JSONObjectWithData:responseData
                                         options:0
                                         error:&err2];
                            if(err2)
                            {
                                NSLog(@"Error X100.1: cannot receive a JSON format : %@", response);
                                cb(err2);
                            }
                            else if([object isKindOfClass:[NSDictionary class]])
                            {
                                NSDictionary *results = object;
                                if([results[@"status"] isEqualToString: @"OK"])
                                {
                                    NSLog(@"Error X155.0: %s", "Status communication KO with heater");
                                    cb([NSError errorWithDomain:errDomain code:KO_CONNECTION userInfo:nil]);
                                }
                            }
                            
                            else
                            {
                                NSLog(@"Error X100.22: %s", "the data receive not a dictionary data");
                                cb([NSError errorWithDomain:errDomain code:INVALID_DATA userInfo:nil]);
                            }
                            
                        }];
     }];
}

- (void) set_request_heater_new_state:(NSInteger) heaterId withState: (bool) state withErrorHandler: (void(^)(NSError*))cb
{
    /*
     if state = 1 : on the heater with nameheater
     else if state = 0, off the heater/
     */
    /*
     ** modeLabel (string) = ['boiler' or 'wired']: The heater heating mode,
     ** stateLabel (string) = ['on' or 'off' or 'eco' or 'frost' or 'boost' or 'away' or 'auto']: The heater state,
     ** lastTemperature (float, null, optional): Last temperature,
     ** deviceId (integer): The device identifier,
     ** label (string): The device label,
     ** modelId (string): The device model identifier,
     ** modelLabel (string): The device model label
     */
    
    [self set_request_specific_element:@"heater" withIdDevice:heaterId withState:state withErrorHandler:^(NSError *error) {
        if (error) {
            cb(error);
            return ;
        }
    }];
}


- (void) set_request_shutter_new_state:(NSInteger)shutterId withState: (bool) state  withErrorHandler: (void(^)(NSError*))cb
{
    /*
     if state = 1 : open the shutter with nameshutter
     else if state = 0, close the shutter/
     */
    /*
     deviceId (integer): The device identifier,
     label (string): The device label,
     modelId (string): The device model identifier,
     modelLabel (string): The device model label
     */
    
    [self set_request_specific_element:@"shutter" withIdDevice:shutterId withState:state withErrorHandler:^(NSError *error) {
        if (error) {
            cb(error);
            return ;
        }
    }];
}


- (void) set_request_electric_group_new_state:(NSInteger)G_ElecId withState: (bool) state withErrorHandler: (void(^)(NSError*))cb
{
    /*
     if state = 1 : open the shutter with nameshutter
     else if state = 0, close the shutter/
     */
    /*
     GroupElectric {
        groupId (integer): The group identifier,
        label (string): The group label,
        type (string): The group type,
        devices (array[Device]): The group devices list
     }
     Device {
        deviceId (integer): The device identifier,
        label (string): The device label,
        modelId (string): The device model identifier,
        modelLabel (string): The device model label
     }
     */
    [self get_request_site:^(int siteId, NSError *error_site)
     {
         if (error_site) {
             cb(error_site);
             return ;
         }
         NSString *add_request;
         
         
         if (state == TRUE) //Open the electric group
             add_request = [NSString stringWithFormat:@"%@%d%@%d%@", @"https://api.myfox.me:443/v2/site/" ,siteId, @"group/", G_ElecId, @"/electric/on"];
         else // Close the electric group
             add_request = [NSString stringWithFormat:@"%@%d%@%d%@", @"https://api.myfox.me:443/v2/site/" ,siteId, @"group/", G_ElecId, @"/electric/off"];
         
         
         [NXOAuth2Request performMethod:@"POST"
                             onResource:[NSURL URLWithString:add_request]
                        usingParameters:nil
                            withAccount:[[[NXOAuth2AccountStore sharedStore] accountsWithAccountType: @"myfox"] firstObject]
                    sendProgressHandler:nil
                        responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                            if (error) {
                                cb(error);
                                return ;
                            }
                            NSError *err2 = nil;
                            id object = [NSJSONSerialization
                                         JSONObjectWithData:responseData
                                         options:0
                                         error:&err2];
                            if(err2)
                            {
                                NSLog(@"Error X100.1: cannot receive a JSON format : %@", response);
                                cb(err2);
                            }
                            else if([object isKindOfClass:[NSDictionary class]])
                            {
                                NSDictionary *results = object;
                                if([results[@"status"] isEqualToString: @"OK"])
                                {
                                    NSLog(@"Error X155.0: %s", "Status communication KO with heater");
                                    cb([NSError errorWithDomain:errDomain code:KO_CONNECTION userInfo:nil]);
                                }
                            }
                            
                            else
                            {
                                NSLog(@"Error X100.22: %s", "the data receive not a dictionary data");
                                cb([NSError errorWithDomain:errDomain code:INVALID_DATA userInfo:nil]);
                            }
                            
                        }];
     }];
}
@end
