//
//  JetVersion.h
//  Jet
//
//  Created by 洪波 on 2019/1/22.
//  Copyright © 2019 洪波. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JetResource.h"

@interface JetVersion : NSObject

@property (nonatomic,strong) JetResource *jetResource;

+ (instancetype)instance;
- (void)syncVersion;

@end
