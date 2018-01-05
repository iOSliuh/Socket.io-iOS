//
//  ViewController.m
//  TestSocket.IO.Swift
//
//  Created by liuh on 2018/1/4.
//  Copyright © 2018年 liuh. All rights reserved.
//

#import "ViewController.h"
@import SocketIO;
@interface ViewController (){
    
    NSMutableArray *cookieArray;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    cookieArray = [[NSMutableArray alloc] init];
    [self socketIOTest];
}

-(void)socketIOTest{
    
    NSURL* url = [[NSURL alloc] initWithString:@"http://*******"];// 服务器域名

    // cookie
    NSDictionary *cookieValuesAndNamesArr = [NSDictionary dictionaryWithObjectsAndKeys:@"0055",@"mid_0055",@"c0055_000001",@"uid_0055",@"9735fdee-ae27-42ef-9854-18c3ff67d79d",@"skey_0055",@"4",@"client_type",@"1",@"user_type", nil];
    
    NSArray *keysArr = [cookieValuesAndNamesArr allKeys];
    for (int i=0; i<keysArr.count; i++) {
        NSString *key = keysArr[i];
        NSString *value = cookieValuesAndNamesArr[key];
        
        [self createCookieWithValue:value andName:key];
    }
    
    SocketManager *manager = [[SocketManager alloc] initWithSocketURL:url config:@{@"log": @YES, @"compress": @YES,@"forceNew":@YES,@"path":@"/push",@"connectParams": @{@"mid": @"0055",@"user_type":@1},@"cookies":cookieArray}];
    SocketIOClient *socket = manager.defaultSocket;
    
    [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        
        NSLog(@"socket connected");
        NSLog(@"ack--------%@",ack);
    }];
    
    [socket on:@"currentAmount" callback:^(NSArray* data, SocketAckEmitter* ack) {
        double cur = [[data objectAtIndex:0] floatValue];
        
        [[socket emitWithAck:@"canUpdate" with:@[@(cur)]] timingOutAfter:0 callback:^(NSArray* data) {
            [socket emit:@"update" with:@[@{@"amount": @(cur + 2.50)}]];
        }];
        
        [ack with:@[@"Got your currentAmount, ", @"dude"]];
    }];
    
    [socket connect];
}

-(void)createCookieWithValue:(NSString *)value andName:(NSString *)name{
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"dev-kh.inquiry.local" forKey:NSHTTPCookieDomain];
    
    [cookieProperties setObject:name forKey:NSHTTPCookieName];
    [cookieProperties setObject:value forKey:NSHTTPCookieValue];
    
    NSHTTPCookie *dealedCookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:dealedCookie];

    [cookieArray addObject:dealedCookie];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
