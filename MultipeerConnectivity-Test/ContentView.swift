import SwiftUI

struct ContentView: View {
    @EnvironmentObject var multipeerManager: MultipeerManager

     var body: some View {
         VStack {
             if multipeerManager.connected {
                 Text("Connected with \(multipeerManager.connectedWith?.displayName ?? "Unknown")")
                 Button("Start Streaming Mouse Position") {
                     startStreamingMouse()
                 }
             } else {
                 Text("Not connected")
             }
         }
         .padding()
     }

     func startStreamingMouse() {
         NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { event in
             multipeerManager.sendEvent(event: event)
         }
     }
}

#Preview {
    ContentView()
}
