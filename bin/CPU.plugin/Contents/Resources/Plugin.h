class Plugin {
    
    protected:
        void *instance = nullptr;
        
        
    public:
        
        Plugin() {}
        ~Plugin() {}
        
        const char* uid() { return "undefined"; }
        virtual int type() = 0; 
        
};

#ifdef USE_PLUGIN

    typedef void *newPlugin();
    
#endif
