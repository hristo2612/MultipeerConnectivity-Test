import Foundation
import MultipeerConnectivity

class MultipeerManager: NSObject, ObservableObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    static let shared = MultipeerManager()
    @Published var connected = false
    @Published var connectedWith: MCPeerID?
    @Published var connecting = false
    var peerId: MCPeerID!
    var foundPeerId: MCPeerID? // The Peer ID of the other Mac
    var mcSession: MCSession?
    var mcAdvertiser: MCNearbyServiceAdvertiser?
    var mcBrowser: MCNearbyServiceBrowser?

    override init() {
        super.init()
        self.initSession()
        // By default each app becomes an advertiser.
        self.initAdvertiser()
    }

    func initSession() {
        peerId = MCPeerID(displayName: getHostName())
        mcSession = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
    }

    func initAdvertiser(serviceType: String = "mpc-service") {
        mcAdvertiser = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: serviceType)
        mcAdvertiser?.delegate = self
        mcAdvertiser?.startAdvertisingPeer()
    }

    func initBrowser(serviceType: String = "mpc-service") {
        mcBrowser = MCNearbyServiceBrowser(peer: peerId, serviceType: serviceType)
        mcBrowser?.delegate = self
        mcBrowser?.startBrowsingForPeers()
    }

    func deinitAdvertiser() {
        mcAdvertiser?.stopAdvertisingPeer()
        mcAdvertiser?.delegate = nil
        mcAdvertiser = nil
    }

    func deinitBrowser() {
        mcBrowser?.stopBrowsingForPeers()
        mcBrowser?.delegate = nil
        mcBrowser = nil
    }

    func deinitSession() {
        mcSession?.disconnect()
        mcSession = nil
    }

    // Advertiser
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("INVITATION TO JOIN SESSION FROM: \(peerID.displayName)")
        foundPeerId = peerID
        invitationHandler(true, mcSession)
    }

    // Browser
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("FOUND PEER \(peerID.displayName)")
        guard let mcSession = mcSession else { return }
        if peerID.displayName != peerId.displayName {
            foundPeerId = peerID
            mcBrowser?.invitePeer(peerID, to: mcSession, withContext: nil, timeout: TimeInterval(10.0))
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("LOST PEER \(peerID.displayName)")
        DispatchQueue.main.async { [weak self] in
            self?.foundPeerId = nil
            self?.connected = false
        }
    }

    // Session

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("DID CHANGE FOR: \(peerID.displayName)")
        if state == .connected {
            print("DID CHANGE: CONNECTED")
            DispatchQueue.main.async { [weak self] in
                self?.connected = true
                self?.connectedWith = self?.foundPeerId
            }
        } else if state == .notConnected {
            print("DID CHANGE: NOT CONNECTED")
            DispatchQueue.main.async { [weak self] in
                self?.connected = false
                self?.connectedWith = nil
            }
        } else if state == .connecting {
            print("DID CHANGE: CONNECTING....")
            DispatchQueue.main.async { [weak self] in
                self?.connected = false
                self?.connectedWith = nil
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("DID RECEIVE DATA")
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("DID RECEIVE STREAM")
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("DID START RECEIVING")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("DID FINISH RECEIVING")
    }
}
