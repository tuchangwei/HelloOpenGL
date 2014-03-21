//
//  OpenGLView.m
//  HelloOpenGL
//
//  Created by Leelen-mac1 on 14-3-21.
//  Copyright (c) 2014年 Leelen. All rights reserved.
//

#import "OpenGLView.h"

@implementation OpenGLView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self render];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer *)self.layer;
    //提高性能
    _eaglLayer.opaque = YES;
}

- (void)setupContext
{
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context)
    {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    if (![EAGLContext setCurrentContext:_context])
    {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

//创建渲染缓冲区
- (void)setupRenderBuffer
{
    //  调用glGenRenderbuffers来创建一个新的render buffer object。这里返回一个唯一的integer来标记render buffer（这里把这个唯一值赋值到_colorRenderBuffer）。有时候你会发现这个唯一值被用来作为程序内的一个OpenGL 的名称。（反正它唯一嘛）
    glGenRenderbuffers(1, &_colorRenderBuffer);
    
    //调用glBindRenderbuffer ，告诉这个OpenGL：我在后面引用GL_RENDERBUFFER的地方，其实是想用_colorRenderBuffer。其实就是告诉OpenGL，我们定义的buffer对象是属于哪一种OpenGL对象
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    //最后，为render buffer分配空间。renderbufferStorage
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

//创建帧缓冲区
- (void)setupFrameBuffer
{
    //Frame buffer也是OpenGL的对象，它包含了前面提到的render buffer，以及其它后面会讲到的诸如：depth buffer、stencil buffer 和 accumulation buffer。
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    //让你把前面创建的buffer render依附在frame buffer的GL_COLOR_ATTACHMENT0位置上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    
}

- (void)render
{
    //调用glClearColor ，设置一个RGB颜色和透明度，接下来会用这个颜色涂满全屏。
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    //调用glClear来进行这个“填色”的动作（大概就是photoshop那个油桶嘛）。还记得前面说过有很多buffer的话，这里我们要用到GL_COLOR_BUFFER_BIT来声明要清理哪一个缓冲区。
    glClear(GL_COLOR_BUFFER_BIT);
    //调用OpenGL context的presentRenderbuffer方法，把缓冲区（render buffer和color buffer）的颜色呈现到UIView上
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}
@end
