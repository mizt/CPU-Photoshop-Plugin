#import <Cocoa/Cocoa.h> 
#import "FX.h" 
namespace CPU {
    class Object {
        public:
            Object() {} 
            ~Object() {}

            void calc(unsigned int *buffer,int w,int h) { 
                for(int k=0; k<h*w; k++) { 
                    buffer[k] = 0xFF000000|~buffer[k]; 
                } 
            } 
    }; 
} 

FX::FX() { 
    this->instance = (void *)(new CPU::Object()); 
}

FX::~FX() {
    delete (CPU::Object *)this->instance; 
}
 
const char *FX::uid() { return "CPU"; } 

void FX::calc(unsigned int *buffer,int w,int h) { 
    ((CPU::Object *)this->instance)->calc(buffer,w,h); 
}
