import SwiftUI
import AVFoundation

struct SliderSessionView: View {
    @Environment(\.scenePhase) var scenePhase
    @State private var path = NavigationPath()
    @StateObject var bgMusic = AudioPlayer()

    @State private var audioSelectionShowing: Bool = false
    
    @State private var imageSize: CGFloat = 1 // Initial size
    @State private var dragOffset: CGFloat = 0 // Tracks button position
    
    @State var imageIsActive: Bool = false
    @State var imageIsBig: Bool = false
    
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var timerValue: Duration = .seconds(10)
    var timerIsActive: Bool {
        if imageSize > 150  {
            return true
        } else {
            return false
        }
    }
    
    @State private var sessionComplete: Bool = false
    
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack(path: $path) {
                ZStack {
                    
                    AnimatedMeshView()
                        .accessibilityHidden(true)
                    
                    VStack {
                        
                        Text("\(timerValue.formatted(.time(pattern: .minuteSecond(padMinuteToLength: 1))))")
                            .font(.largeTitle).bold()
                            .foregroundStyle(.accent)
                            .opacity(timerIsActive ? 0.8 : 0.05)
                            .onReceive(timer) { time in
                                guard timerIsActive else { return }
                                if timerValue > .zero {
                                    timerValue -= .seconds(1)
                                } else {
                                    sessionComplete = true
                                }
                            }

                        
                        Spacer()
                        
                        // Image with dynamic size
                        if imageIsActive {
                            Image("rabbit")
                                .resizable()
                                .scaledToFit()
                                .clipShape(
                                    RoundedRectangle(cornerRadius: imageSize * 0.10)
                                )
                                .frame(width: imageSize, height: imageSize)
                        }
                        
                        Spacer()
                        
                        // Constrained draggable area
                        VStack {
                            Text("Hold the button for 3 seconds to start the session")
                                .multilineTextAlignment(.center)
                            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
                                // Invisible track
                                Capsule()
//                                    .fill(Color.gray.opacity(0.2))
                                    .fill(Material.ultraThin.opacity(0.8))
                                    .frame(height: 50)
                                Text("Full size")
                                    .opacity(imageIsActive ? 0.4 : 0)
                                    .padding()
                                
                                // Draggable button
                                HStack {
                                    DraggableSizeControl(
                                        imageIsActive: $imageIsActive,
                                        imageIsBig: $imageIsBig,
                                        dragOffset: $dragOffset,
                                        imageSize: $imageSize,
                                        totalWidth: geometry.size.width,
                                        minSize: 10,
                                        maxSize: geometry.size.width * 0.9
                                    )
                                    Spacer()
                                }
                            }
                            Text("Release the button at any time to hide the image")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(.top, 10)
                        }
                        .padding()
                    }
                }
                .onAppear {
//                    bgMusic.playPauseAudio()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Image(bgMusic.isPlaying ? "custom.music.quarternote.3" : "custom.music.quarternote.3.slash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                            .foregroundStyle(.accent).opacity(0.8)
                            .padding(.trailing, 20)
                            .onTapGesture {
                                bgMusic.playPauseAudio()
                            }
                            .onLongPressGesture(minimumDuration: 1.5) {
                                audioSelectionShowing = true
                            }
                    }
                }
                .confirmationDialog("Select background music", isPresented: $audioSelectionShowing) {
                    Button("Hymn") {
                        bgMusic.setMusic("hymn")
                    }
                    Button("Petrichor") {
                        bgMusic.setMusic("petrichor")
                    }
                    Button("Restoration") {
                        bgMusic.setMusic("restoration")
                    }
                    Button("Sky") {
                        bgMusic.setMusic("sky")
                    }
                }
                .onChange(of: sessionComplete) { _, _ in
                    if sessionComplete {
                        path.append("completedSession")
                    }
                }
                .navigationDestination(for: String.self) { value in
                    if value == "completedSession" {
                        SessionSuccessView()
                    }
                }
            }
        }
    }
}

struct DraggableSizeControl: View {
    @Binding var imageIsActive: Bool
    @Binding var imageIsBig: Bool
    @Binding var dragOffset: CGFloat
    @Binding var imageSize: CGFloat
    let totalWidth: CGFloat
    let minSize: CGFloat
    let maxSize: CGFloat
    var sizeRange: CGFloat {
        maxSize - minSize
    }
    
    enum DragState {
        case inactive
        case pressing
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
        
        var isPressing: Bool {
            switch self {
            case .inactive:
                return false
            case .pressing:
                return true
            case .dragging:
                return false
            }
        }
        
        var isActive: Bool {
            switch self {
            case .inactive, .pressing:
                return false
            case .dragging:
                return true
            }
        }
        
        
        var isDragging: Bool {
            switch self {
            case .inactive, .pressing:
                return false
            case .dragging:
                return true
            }
        }
    }
    
    @GestureState var dragState = DragState.inactive
//    @State private var isActive = false
    @State private var accumulatedOffset: CGFloat = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 30)
            .fill(dragState.isActive ? Color.darkGreen : Color.extraDarkGreen.mix(with: .black, by: 0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .trim(from: 0, to: dragState.isActive ? 1 : 0)
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .foregroundStyle(.extraDarkGreen.mix(with: .black, by: 0.1))
                    .rotationEffect(.degrees(-90))
                    .animation(.default, value: dragState.isActive)
            )
            .frame(width: 110, height: 110)
            .gesture(
                // Combine long press with drag
                LongPressGesture(minimumDuration: 0.5)
                    .sequenced(before: DragGesture())
                    .updating($dragState) { value, state, transaction in
                        switch value {
                        case .first(true):
                            transaction.animation = Animation.bouncy()
                            state = .pressing
                            accumulatedOffset = 0
                            
                        case .second(true, let drag):
//                            print(state)
                            state = .dragging(translation: drag?.translation ?? .zero)
                            guard let drag = drag else { return }
                            let dragWidth = totalWidth * 0.65
                            withAnimation {
                                imageIsActive = true
                            }
                             // Accumulate offset to smooth out the drag
                             accumulatedOffset += drag.translation.width

                             // Constrain horizontal movement
                             dragOffset = min(max(0, accumulatedOffset), dragWidth)

                             // Map drag offset to image size
                            withAnimation {
                                imageSize = minSize + (dragOffset / dragWidth * sizeRange)
                            }
                        default:
                            state = .inactive
                        }
                    }
                     .onEnded { _ in
                         withAnimation {
                             dragOffset = 0
                             imageSize = minSize
                             accumulatedOffset = 0
                             imageIsActive = false
                             imageIsBig = false
                         }
                     }
            )
            .offset(x: dragOffset)
    }

}

#Preview {
    SliderSessionView()
}
