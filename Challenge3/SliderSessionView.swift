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
                            .foregroundStyle(.darkPurple)
                            .opacity(timerIsActive ? 0.7 : 0.05)
                            .onReceive(timer) { time in
                                guard timerIsActive else { return }
                                if timerValue > .zero {
                                    timerValue -= .seconds(1)
                                } else {
                                    sessionComplete = true
                                }
                            }
                            .accessibilityLabel("2 minute timer")
                        
                        
                        Spacer()
                        
                        // Image with dynamic size
                        if imageIsActive || UIAccessibility.isVoiceOverRunning {
                            Image("rabbit")
                                .resizable()
                                .scaledToFit()
                                .clipShape(
                                    RoundedRectangle(cornerRadius: imageSize * 0.10)
                                )
                                .frame(width: imageSize, height: imageSize)
                                .accessibilityHidden(true)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("Hold the button for 3 seconds to start the session. Then drag to make the image bigger")
                                .multilineTextAlignment(.center)
                            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
                                // Invisible track
                                Capsule()
//                                    .fill(Color.black.opacity(0.9))
                                    .fill(Material.ultraThin)
//                                    .background(.ultraThinMaterial, in: Capsule())
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
                                .sensoryFeedback(.success, trigger: imageIsActive)
                            }
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                            
                            Text("Release at any time to hide the image")
                                .font(.footnote)
                                .padding(.top, 10)

                        }
                        .padding()
                        .accessibilityRepresentation {
                            Slider(value: $imageSize, in: 1...500, step: 50)
                                .accessibilityLabel("Change image size")
                                .accessibilityHint("Use the slider to increase the size of the image.")
                                .padding(40)
                        }
                        .accessibilitySortPriority(10)
                    }
                }
                .onAppear {
                    bgMusic.playPauseAudio()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Image(bgMusic.isPlaying ? "custom.music.quarternote.3" : "custom.music.quarternote.3.slash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                            .foregroundStyle(.darkPurple).opacity(0.5)
                            .padding(.trailing, 20)
                            .onTapGesture {
                                bgMusic.playPauseAudio()
                            }
                            .onLongPressGesture(minimumDuration: 1.5) {
                                audioSelectionShowing = true
                            }
                            .accessibilityLabel("Play or pause background music")
                            .accessibilityHint("Long press to change the song that is playing")
                            .accessibilityAddTraits(.isButton)
                    }
                }
                .confirmationDialog("Select background music", isPresented: $audioSelectionShowing, titleVisibility: .visible) {
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            UIAccessibility.post(
                                notification: .screenChanged,
                                argument: "Well done! You successfully completed an exposure session. Please rate your Subjective Units of Distress."
                            )
                        }
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
        Circle()
            .fill(dragState.isActive ? Color.darkGreen.mix(with: .black, by: 0.1) : Color.accentColor)
            .overlay(
                Circle()
                    .trim(from: 0, to: dragState.isActive ? 1 : 0)
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .foregroundStyle(.extraDarkGreen.mix(with: .black, by: 0.1))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeIn, value: dragState.isActive)
            )
            .frame(width: 120, height: 120)
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
                            withAnimation {
                                state = .dragging(translation: drag?.translation ?? .zero)
                            }
                            guard let drag = drag else { return }
                            let dragWidth = totalWidth * 0.65

                            // Accumulate offset to smooth out the drag
                            accumulatedOffset += drag.translation.width
                            
                            // Constrain horizontal movement
                            dragOffset = min(max(0, accumulatedOffset), dragWidth)
                            
                            // Map drag offset to image size
                            withAnimation {
                                imageSize = minSize + (dragOffset / dragWidth * sizeRange)
                                imageIsActive = true
                            }
                        default:
                            state = .inactive
                        }
                    }
                    .onEnded { _ in
                        //                         isActive = false
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
