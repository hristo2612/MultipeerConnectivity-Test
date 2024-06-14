import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var shouldFreezeMouse = false
    var freezePosition: CGPoint?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            self?.mouseMoved(event: event)
        }
    }
    
    func mouseMoved(event: NSEvent) {
        let screenFrame = NSScreen.main!.frame
        let mouseLocation = NSEvent.mouseLocation
        if mouseLocation.x <= 0 || mouseLocation.y <= 0 || mouseLocation.x >= screenFrame.size.width || mouseLocation.y >= screenFrame.size.height {
            print("Mouse is at the edge of the screen")
            freezePosition = mouseLocation
            shouldFreezeMouse = true
            preventMouseMovement()
        } else if shouldFreezeMouse {
            // If the mouse is not at the edge, stop freezing
            shouldFreezeMouse = false
            freezePosition = nil
        }
    }
    
    func preventMouseMovement() {
        guard let freezePosition = freezePosition else { return }
        
        if shouldFreezeMouse {
            // Reset mouse position to the freeze position
            CGWarpMouseCursorPosition(freezePosition)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                // self.preventMouseMovement()
            }
        }
    }
}

@main
struct MultipeerConnectivity_TestApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var multipeerManager = MultipeerManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(multipeerManager)
                .onAppear {
                    multipeerManager.initBrowser()  // Start browsing for peers
                }
        }
    }
}
