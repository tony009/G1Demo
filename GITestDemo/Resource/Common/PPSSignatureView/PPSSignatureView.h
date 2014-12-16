#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES1/glext.h>

@interface PPSSignatureView : GLKView

@property (assign, nonatomic) BOOL hasSignature;
@property (strong, nonatomic) UIImage *signatureImage;

- (void)erase;

@end
