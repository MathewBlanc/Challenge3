import SwiftUI

struct ContentView: View {
    @State private var imageSize: CGFloat = 1 // Initial size
    @State private var dragOffset: CGFloat = 0 // Tracks button position
    
    @State var imageIsActive: Bool = false
    @State var imageIsBig: Bool = false
    @State private var timerStartDate: Date? = nil
    
    var imageSizeTracker: Bool {
        if imageSize > 100 {
            return true
        } else {
            return false
        }
    }
    
    var timerInterval: ClosedRange<Date> {
            let now = Date()
            let endDate = timerStartDate.map { $0.addingTimeInterval(2 * 60) } ?? now
            return now...endDate
        }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                AnimatedMeshView()
                    .accessibilityHidden(true)
                
                VStack {
                    if timerStartDate != nil {
                        Text(timerInterval: timerInterval)
                            .font(.largeTitle).bold()
                            .opacity(0.5)
                        
                    } else {
                        Text("2:00")
                            .font(.largeTitle).bold()
                            .opacity(0.05)
                    }
                    
                    Spacer()
                    
                    // Image with dynamic size
                    Image("rabbit")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize, height: imageSize)
                    
                    Spacer()
                    
                    // Constrained draggable area
                    VStack {
                        Text("Hold the button for 3 seconds to start the session")
                            .multilineTextAlignment(.center)
                        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
                            // Invisible track
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 50)
                            Text("Full size")
                                .opacity(imageIsActive ? 0.5 : 0)
                                .padding()
                            
                            // Draggable button
                            HStack {
                                DraggableSizeControl(
                                    imageIsActive: $imageIsActive,
                                    imageIsBig: $imageIsBig,
                                    timerStartDate: $timerStartDate,
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
        }
    }
}

struct DraggableSizeControl: View {
    @Binding var imageIsActive: Bool
    @Binding var imageIsBig: Bool
    @Binding var timerStartDate: Date?
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
        
        var isActive: Bool {
            switch self {
            case .inactive:
                return false
            case .pressing, .dragging:
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
            .fill(dragState.isActive ? Color.teal : Color.gray)
            .overlay(
                Circle()
                    .trim(from: 0, to: dragState.isActive ? 1 : 0)
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .foregroundStyle(.teal.mix(with: .black, by: 0.1))
                    .rotationEffect(.degrees(-90))
                    .animation(.default, value: dragState.isActive)
            )
            .frame(width: 120, height: 120)
            .gesture(
                // Combine long press with drag
                LongPressGesture(minimumDuration: 0.5)
                    .sequenced(before: DragGesture())
                    .updating($dragState) { value, state, transaction in
                        switch value {
                        case .first(true):
                            state = .pressing
                            accumulatedOffset = 0
                            withAnimation {
                                imageIsActive = true
                            }
                        case .second(true, let drag):
                            state = .dragging(translation: drag?.translation ?? .zero)
                            guard let drag = drag else { return }
                            let dragWidth = totalWidth * 0.65

                             // Accumulate offset to smooth out the drag
                             accumulatedOffset += drag.translation.width

                             // Constrain horizontal movement
                             dragOffset = min(max(0, accumulatedOffset), dragWidth)

                             // Map drag offset to image size
                            withAnimation {
                                imageSize = minSize + (dragOffset / dragWidth * sizeRange)
                                if imageSize > 100 && timerStartDate == nil {
                                    timerStartDate = Date()
                                }
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
    ContentView()
}
