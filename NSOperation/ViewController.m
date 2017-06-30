//
//  ViewController.m
//  NSOperation
//
//  Created by huangjian on 17/6/3.
//  Copyright © 2017年 huangjian. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic,strong)NSOperationQueue *queue;
@property (nonatomic,strong)NSBlockOperation *blockOperation;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self demo6];
}
//NSInvocationOperation 没用NSOperationQueue，再当前线程执行
-(void)demo
{
    NSLog(@"---begin");
    NSInvocationOperation *operation=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(test) object:nil];
    [operation start];
    
    NSLog(@"---end");
}
-(void)test
{
    [NSThread sleepForTimeInterval:2];
    for (int i=0; i<3; i++) {
        NSLog(@"---%d---%@",i,[NSThread currentThread]);
    }
}
//NSBlockOperation 没用NSOperationQueue，再当前线程执行
-(void)demo1
{
    NSLog(@"---begin");
    NSBlockOperation *blockOp=[NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:4];
        for (int i=0; i<3; i++) {
            NSLog(@"---%d---%@",i,[NSThread currentThread]);
        }
    }];
    [blockOp start];
    NSLog(@"---end");
}
//NSBlockOperation  addExecutionBlock方法
-(void)demo2
{
    NSLog(@"---begin");
    //主线程中执行
    NSBlockOperation *blockOp=[NSBlockOperation blockOperationWithBlock:^{
        for (int i=0; i<3; i++) {
            NSLog(@"---%d---%@",i,[NSThread currentThread]);
        }
    }];
    //主线程和其他线程中执行
    [blockOp addExecutionBlock:^{
        [NSThread sleepForTimeInterval:2];
        for (int i=3; i<6; i++) {
            NSLog(@"---%d---%@",i,[NSThread currentThread]);
        }
    }];
    [blockOp addExecutionBlock:^{
        [NSThread sleepForTimeInterval:3];
        for (int i=6; i<9; i++) {
            NSLog(@"---%d---%@",i,[NSThread currentThread]);
        }
    }];
    [blockOp start];
    NSLog(@"---end");
}
//队列
-(void)demo3
{
    NSLog(@"---begin");
    //队列
    NSOperationQueue *queue=[[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount=1;//最大并发数  1即为串行   默认-1并行
    //任务
    NSInvocationOperation *invOp=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(test) object:nil];
    NSBlockOperation *blockOp=[NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:2];
        for (int i=3; i<6; i++) {
            NSLog(@"---%d---%@",i,[NSThread currentThread]);
        }
    }];
    [queue addOperation:invOp];
    [queue addOperation:blockOp];
    NSLog(@"---end");
}

-(void)demo5
{
    NSLog(@"---begin");
    //队列
    NSOperationQueue *queue=[[NSOperationQueue alloc]init];
    //任务
    [queue addOperationWithBlock:^{
        [self test];
    }];
    [queue addOperationWithBlock:^{
        [NSThread sleepForTimeInterval:2];
        for (int i=3; i<6; i++) {
            NSLog(@"---%d---%@",i,[NSThread currentThread]);
        }
    }];
    NSLog(@"---end");
}
//操作依赖
-(void)demo4
{
    NSLog(@"---begin");
    NSOperationQueue *queue=[[NSOperationQueue alloc]init];
    NSBlockOperation *blockOp=[NSBlockOperation blockOperationWithBlock:^{
        
        for (int i=0; i<3; i++) {
            NSLog(@"---%d---%@",i,[NSThread currentThread]);
        }
    }];
    NSBlockOperation *blockOp1=[NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:3];
        for (int i=3; i<6; i++) {
            NSLog(@"---%d---%@",i,[NSThread currentThread]);
        }
    }];
    NSBlockOperation *blockOp2=[NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:2];
        for (int i=6; i<9; i++) {
            NSLog(@"---%d---%@",i,[NSThread currentThread]);
        }
    }];
    //blockOp 依赖于blockOp1，即等blockOp1 执行完再执行 blockOp
    [blockOp addDependency:blockOp1];
    
    [queue addOperation:blockOp];
    [queue addOperation:blockOp1];
    [queue addOperation:blockOp2];
    blockOp.completionBlock=^{
        NSLog(@"---blockOp  over");
    };
    NSLog(@"---end");
}
-(void)demo6
{
    NSLog(@"---h begin");
    NSOperationQueue *queue=[[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount=1;
    NSBlockOperation *blockOp=[NSBlockOperation blockOperationWithBlock:^{
        
        for (int i=0; i<3; i++) {
            NSLog(@"---h %d---%@",i,[NSThread currentThread]);
        }
    }];
    NSBlockOperation *blockOp1=[NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:1];
        for (int i=3; i<6; i++) {
            NSLog(@"---h %d---%@",i,[NSThread currentThread]);
        }
    }];
    NSBlockOperation *blockOp2=[NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:3];
        for (int i=6; i<9; i++) {
            NSLog(@"---h %d---%@",i,[NSThread currentThread]);
        }
    }];
    NSBlockOperation *blockOp3=[NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:4];
        for (int i=9; i<12; i++) {
            NSLog(@"---h %d---%@",i,[NSThread currentThread]);
        }
    }];
    
    [queue addOperation:blockOp];
    [queue addOperation:blockOp1];
    [queue addOperation:blockOp2];
    [queue addOperation:blockOp3];
    self.blockOperation=blockOp3;
    self.queue=queue;
    NSLog(@"---h end");
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.queue.suspended=!self.queue.suspended;
    if (self.queue.suspended) {
        NSLog(@"---h暂停");
    }else
    {
        NSLog(@"---h恢复");
    }
}
@end
