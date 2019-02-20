#import <Cocoa/Cocoa.h>
#import <MetalKit/MetalKit.h>
#import "PIDefines.h"
#import "PIFilter.h"

#include "Logger.h"

#import <dlfcn.h>

#define USE_PLUGIN

#import "FX.h"

int16 StartProc(FilterRecord *filterRecord) {
    
    int16 width  = filterRecord->filterRect.right -filterRecord->filterRect.left;
    int16 height = filterRecord->filterRect.bottom-filterRecord->filterRect.top;
    int16 planes = filterRecord->planes;
    
    filterRecord->inLoPlane = 0;
    filterRecord->inHiPlane = planes - 1;
    filterRecord->outLoPlane = 0;
    filterRecord->outHiPlane = planes - 1;
    filterRecord->outRect = filterRecord->filterRect;
    filterRecord->inRect  = filterRecord->filterRect;
    
    int16 res = filterRecord->advanceState();
    if(res!=noErr) return res;
    
    unsigned char *data = new unsigned char[width*height*4];
    for(int i=0; i<height; i++) {
        uint8 *src = (uint8 *)filterRecord->inData+(i*filterRecord->inRowBytes);
        for(int j=0; j<width; j++) {
            for(int ch=0; ch<planes; ch++) {
                switch(ch) {
                    case 0:
                    case 1:
                    case 2:
                        data[(i*width+j)*4+ch] = src[ch];
                        break;
                }
            }
            src+=planes;
        }
    }
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"org.mizt.CPU"];
    NSString *path = [[bundle URLForResource:@"CPU" withExtension:@"dylib"] path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]) {
        void *dylib = dylib = dlopen([path UTF8String],RTLD_LAZY);
        if(dylib) {
            FX *fx = (FX *)((newPlugin *)dlsym(dylib,"newPlugin"))();
            fx->calc((unsigned int *)data,width,height);
            ((deleteFX *)dlsym(dylib,"deleteFX"))((void *)fx);
            dlclose(dylib);
        }
    }
    
    for(int i=0; i<height; i++) {
        uint8 *dst = (uint8 *)filterRecord->outData+(i*filterRecord->outRowBytes);
        for(int j=0; j<width; j++) {
            for(int ch=0; ch<planes; ch++) {
                switch(ch) {
                    case 0:
                    case 1:
                    case 2:
                        dst[ch] = data[(i*width+j)*4+ch];
                        break;
                }
            }
            dst+=planes;
        }
    }
    
    memset(&(filterRecord->outRect),0,sizeof(Rect));
    memset(&(filterRecord->inRect),0,sizeof(Rect));
    
    delete[] data;
    
    return noErr;
}

DLLExport MACPASCAL void PluginMain(const int16 selector,FilterRecord *filterRecord,int32 *data,int16 *result) {
    switch (selector) {
        case filterSelectorStart:
            *result = StartProc(filterRecord);
            break;
    }
}
