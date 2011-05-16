//
//  main.m
//  KaPow
//
//  Created by Brady Love on 5/15/11.
//  Copyright 2011 None. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <MacRuby/MacRuby.h>

int main(int argc, char *argv[])
{
    return macruby_main("rb_main.rb", argc, argv);
}
