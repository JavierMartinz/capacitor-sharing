#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(SharingPlugin, "Sharing",
           CAP_PLUGIN_METHOD(shareToFacebookStories, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(shareToInstagramStories, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(share, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(canShareToFacebookStories, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(canShareToInstagramStories, CAPPluginReturnPromise);
)
