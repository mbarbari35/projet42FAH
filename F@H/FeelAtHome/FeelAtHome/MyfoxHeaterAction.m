//
//  MyfoxHeaterAction.m
//  FeelAtHome
//
//  Created by Michael BARBARIN on 11/02/15.
//  Copyright (c) 2015 Michael BARBARIN. All rights reserved.
//

#import "MyfoxHeaterAction.h"
#import "MyfoxAuth.h"

@implementation MyfoxHeaterAction
{
    MyfoxAuth *auth;
    NSString *heater;
    NSString *username;
    NSString *password;
}

#pragma mark - NSCoding

- (id) initWithCoder: (NSCoder*)decoder
{
    username = [decoder decodeObjectForKey:@"username"];
    password = [decoder decodeObjectForKey:@"password"];
    auth = [[MyfoxAuth alloc] init:username withPassword:password];
    heater = [decoder decodeObjectForKey:@"Heater"];
    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:username forKey:@"username"];
    [encoder encodeObject:password forKey:@"password"];
    [encoder encodeObject:heater forKey:@"Heater"];
}

#pragma mark - end NSCoding

- (void) run {
    [auth set_request_shutter_new_state:heater withState:TRUE withErrorHandler:nil];
}

@end
