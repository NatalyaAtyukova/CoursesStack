import SwiftUI
import AVKit

struct VideoPlayerView: View {
    var videoURL: URL
    
    var body: some View {
        VideoPlayer(player: AVPlayer(url: videoURL))
            .onDisappear {
                // Остановка видео при выходе из экрана
                AVPlayer(url: videoURL).pause()
            }
            .frame(maxWidth: .infinity, maxHeight: 250)
            .cornerRadius(10)
            .shadow(radius: 5)
    }
}
