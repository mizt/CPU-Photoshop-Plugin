#import "Plugin.h"

class FX : public Plugin {
    
    public:
        
        FX();
        ~FX();
    
        int type() { return (int)(2); }
        virtual const char* uid();
        
        virtual void calc(unsigned int *buffer,int w, int h);
        
};

#ifdef USE_PLUGIN

    typedef void *newPlugin();
    typedef void deleteFX(void *);
    

#else
 
    extern "C" void *newPlugin() { 
        return (void *)new FX(); 
    }
    
    extern "C" void deleteFX(void *instance) { 
        delete (FX *)instance; 
    }

#endif
