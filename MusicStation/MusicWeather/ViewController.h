//
//  ViewController.h
//  MusicWeather
//
//  Created by JianRongCao on 16/2/22.
//  Copyright © 2016年 Suning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) AVAudioPlayer *player;

@end

