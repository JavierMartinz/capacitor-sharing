import Foundation
import Capacitor

@objc(SharingPlugin)
public class SharingPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "SharingPlugin"
    public let jsName = "Sharing"
    
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "share", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "shareTo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "canShareTo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "shareToInstagramStories", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "canShareToInstagramStories", returnType: CAPPluginReturnPromise)
    ]
    
    private let implementation = Sharing()
    
    @objc func share(_ call: CAPPluginCall) {
        implementation.share(call, plugin: self)
    }
    
    @objc func shareTo(_ call: CAPPluginCall) {
        implementation.shareTo(call, plugin: self)
    }
    
    @objc func canShareTo(_ call: CAPPluginCall) {
        implementation.canShareTo(call, plugin: self)
    }
    
    @objc func shareToInstagramStories(_ call: CAPPluginCall) {
        implementation.shareToInstagramStories(call, plugin: self)
    }
    
    @objc func canShareToInstagramStories(_ call: CAPPluginCall) {
        implementation.canShareToInstagramStories(call, plugin: self)
    }
}
