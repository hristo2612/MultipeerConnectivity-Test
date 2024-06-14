import Foundation

func getHostName() -> String {
    return Host.current().localizedName ?? "Mac"
}
