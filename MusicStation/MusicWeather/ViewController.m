//
//  ViewController.m
//  MusicWeather
//
//  Created by JianRongCao on 16/2/22.
//  Copyright © 2016年 Suning. All rights reserved.
//

#import "ViewController.h"
#import "LrcParser.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UIImage+WaterMash.h"

@interface ViewController ()<AVAudioPlayerDelegate>

@property (strong, nonatomic) UITableView *lrcTable;

@property (strong, nonatomic) LrcParser* lrcContent;

@property (assign) NSInteger currentRow;

@property (strong, nonatomic) UIImage *albumPoster;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.lrcTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height - 20) style:UITableViewStylePlain];
    [self.lrcTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.lrcTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.lrcTable.showsVerticalScrollIndicator = NO;
    self.lrcTable.delegate = self;
    self.lrcTable.dataSource = self;
    self.lrcTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.lrcTable];
    
    self.lrcContent = [[LrcParser alloc] init];
//    [self.lrcContent parseLrc:@"冰雨"];
    [self.lrcContent parseLrc:@"董小姐"];
    
    self.albumPoster = [[UIImage imageNamed:@"wall.jpg"] generatingAlbumImage];
    
    [self.lrcTable reloadData];
    
    [self initPlayer];
    
    UIImage *img = [UIImage imageNamed:@"wall.jpg"];
    UIImageView *bgView = [[UIImageView alloc] initWithImage:img];
    bgView.alpha = 0.7;
    bgView.frame = self.view.bounds;
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectview.alpha = 0.9;
    effectview.frame = bgView.frame;
    [bgView addSubview:effectview];
    
    [self.view addSubview:bgView];
    bgView.alpha = 1.0;
    [self.view bringSubviewToFront:self.lrcTable];
    [bgView setImage:[self getBlurredImage:img]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lrcContent.wordArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.lrcTable dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.lrcContent.wordArray[indexPath.row];
    cell.textLabel.textColor = (indexPath.row==_currentRow) ? [UIColor redColor] : [UIColor whiteColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)setPlayerUrl:(NSURL *)url
{
    //[self.player ini
    
}

- (void)initPlayer
{
//    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"冰雨"
//                                                                                       withExtension:@"mp3"]
//                                                         error:nil];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"董小姐"
                                                                                       withExtension:@"mp3"]
                                                         error:nil];
    self.player.numberOfLoops = MAXFLOAT;
    self.player.currentTime = 0;
    self.player.volume = 1.0;
    [self.player prepareToPlay];
    [self.player play];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
}

- (void)updateTime
{
    CGFloat currentTime = self.player.currentTime;
//    NSLog(@"%d:%d",(int)currentTime / 60, (int)currentTime % 60);
    for (int index = 0; index < self.lrcContent.timerArray.count; index++) {
        NSArray *timeArray = [self.lrcContent.timerArray[index] componentsSeparatedByString:@":"];
        float lrcTime = [timeArray[0] intValue] * 60 + [timeArray[1] floatValue];
        if (currentTime > lrcTime) {
            _currentRow = index;
        } else {
            break;
        }
    }
    
    [self.lrcTable reloadData];
    [self.lrcTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_currentRow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
//    [info setObject:@"冰雨" forKey:MPMediaItemPropertyTitle];
//    [info setObject:@"刘德华" forKey:MPMediaItemPropertyArtist];
    [info setObject:@"董小姐" forKey:MPMediaItemPropertyTitle];
    [info setObject:@"宋冬野" forKey:MPMediaItemPropertyArtist];
    [info setObject:[self getCurrentArtwork] forKey:MPMediaItemPropertyArtwork];
    //音乐剩余时长
    [info setObject:[NSNumber numberWithDouble:self.player.duration] forKey:MPMediaItemPropertyPlaybackDuration];
    //音乐当前播放时间 在计时器中修改
    [info setObject:[NSNumber numberWithDouble:self.player.currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    //进度光标的速度 （这个随 自己的播放速率调整，我默认是原速播放）
    [info setObject:[NSNumber numberWithFloat:1.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:info];
}

- (MPMediaItemArtwork *)getCurrentArtwork
{
    UIImage *cover = self.albumPoster;
    NSString *lrc = [self.lrcContent.wordArray objectAtIndex:_currentRow];
    NSString *lrcTime = [self.lrcContent.timerArray objectAtIndex:_currentRow];
    NSLog(@"current lrc : (%@)%@", lrcTime,lrc);
//    cover = [cover addWaterMashWithText:lrc];
    cover = [cover addWaterMaskWithText:lrc];
    
    // update cover view
//    coverView.image = cover;
//    [coverView.layer needsDisplay];
    
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:cover];
    return artwork;
}

//实现高斯模糊
- (UIImage *)getBlurredImage:(UIImage *)image
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:ciImage forKey:kCIInputImageKey];
    [filter setValue:@0.1f forKey:@"inputRadius"];
    
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef ref = [context createCGImage:result fromRect:[result extent]];
    return [UIImage imageWithCGImage:ref];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
