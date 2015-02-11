//
//  MyfoxShutterAction.m
//  FeelAtHome
//
//  Created by Michael BARBARIN on 11/02/15.
//  Copyright (c) 2015 Michael BARBARIN. All rights reserved.
//

#import "MyfoxShutterAction.h"
#import "MyfoxAuth.h"

@implementation MyfoxShutterAction
{
    MyfoxAuth *auth;
    NSString *shutter;
    NSString *username;
    NSString *password;
}

#pragma mark - NSCoding

- (id) initWithCoder: (NSCoder*)decoder
{
    username = [decoder decodeObjectForKey:@"username"];
    password = [decoder decodeObjectForKey:@"password"];
    auth = [[MyfoxAuth alloc] init:username withPassword:password];
    shutter = [decoder decodeObjectForKey:@"shutter"];
    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:username forKey:@"username"];
    [encoder encodeObject:password forKey:@"password"];
    [encoder encodeObject:shutter forKey:@"shutter"];
}

#pragma mark - end NSCoding

- (void) run {
    [auth set_request_shutter_new_state:shutter withState:TRUE withErrorHandler:nil];
}

@end