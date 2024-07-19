import SwiftUI
import Speech

private extension SearchBarView {
    func toggleSpeechRecognition() {
        if speechAnalyzer.isProcessing {
            speechAnalyzer.stop()
        } else {
            speechAnalyzer.start()
        }
    }
    
    func ejecutaCodigo() {
        text = speechAnalyzer.recognizedText ?? ""
        print("El reconocimiento de voz se ha detenido debido a inactividad. Texto reconocido: \(recognizedText)")
        recognizedText = ""
    }
}

struct SearchBarView: View {
    @State private var recording = 0.0
    
    private enum Constants {
        static let recognizeButtonSide: CGFloat = 100
        static let animationDuration: Double = 0.8
        static let maxScale: CGFloat = 3.3
    }
    
    @ObservedObject private var speechAnalyzer = SpeaktoText()
    @State private var isAnimating: Bool = false
    @State private var recognizedText: String = ""
    
    @State private var text: String = ""
    @State private var textHeight: CGFloat
    private let maxLines: Int = 5
    private let font: UIFont = UIFont.systemFont(ofSize: 14)
    
    private var lineHeight: CGFloat {
        font.lineHeight
    }
    
    init() {
        _textHeight = State(initialValue: UIFont.systemFont(ofSize: 14).lineHeight)
    }
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 3)
                        .fill(Color(.purple).gradient)
                        .frame(width: 44, height: 44)
                        .scaleEffect(recording)
                        .animation(.easeOut(duration: 0.5).delay(0.3).repeatForever(autoreverses: true), value: recording)
                    Circle()
                        .stroke(lineWidth: 1)
                        .fill(Color(.cyan).gradient)
                        .frame(width: 44, height: 44)
                        .scaleEffect(recording)
                        .animation(.easeOut(duration: 0.5).delay(1).repeatForever(autoreverses: false), value: recording)
                    Circle()
                        .fill(Color(.black).gradient)
                        .frame(width: 38, height: 38)
                        .scaleEffect(recording)
                        .animation(.easeInOut(duration: 0.5).delay(0.5).repeatForever(autoreverses: false), value: recording)
                    Circle()
                        .fill(.white.gradient)
                        .frame(width: 30, height: 30)
                    Image(systemName: "mic.fill")
                        .foregroundColor(.gray)
                        .font(.title2)
                        .onTapGesture {
                            recording = .random(in: 1..<1.2)
                            //toggleSpeechRecognition()
                        }
                } //del ZStack
                //.padding(.leading, 1)
                
                //ZStack(alignment: .trailing) {
                    TextEditor(text: $text)
                        .font(.system(size: 14)) // Ajusta el tamaño de la fuente
                        .frame(height: min(textHeight, lineHeight * CGFloat(maxLines))) // Limita la altura a 5 líneas
                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 40)) // Ajusta el padding con espacio para el micrófono
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.gray, lineWidth: 1) // Contorno más ancho
                        )
                        .onChange(of: text) { _, _ in
                            recalculateHeight()
                        }
                    
                    if text.isEmpty {
                        EmptyView()
                    }
                //}//del ZStack TextEditor
                //.padding(.vertical, 2) // Ajusta el padding vertical del ZStack
                
                if text.isEmpty {
                    Image(systemName: "headphones")
                        .resizable()
                        .frame(width: 24, height: 24) // Ajusta el tamaño de la imagen
                        .foregroundColor(.gray)
                        .padding(.trailing, 8) // Ajusta el padding derecho
                } else {
                    Image(systemName: "arrow.up.circle")
                        .resizable()
                        .frame(width: 24, height: 24) // Ajusta el tamaño de la imagen
                        .foregroundColor(.gray)
                        .padding(.trailing, 8) // Ajusta el padding derecho
                }
            }
            Spacer()
        } //VStack principal
        .onReceive(speechAnalyzer.$recognizedText) { texto in
            self.text = texto ?? ""
        }
        .onAppear {
            recording = .random(in: 1..<1.2)
            speechAnalyzer.onRecognitionStop = {
                self.ejecutaCodigo()
            }
        }
        .padding()
    }// del body
    
    private func recalculateHeight() {
        let maxSize = CGSize(width: UIScreen.main.bounds.width - 64, height: CGFloat.infinity) // Ajusta el ancho máximo
        let textView = UITextView()
        textView.text = text
        textView.font = font // Ajusta el tamaño de la fuente
        let size = textView.sizeThatFits(maxSize)
        textHeight = size.height
    }
}//del struct

#Preview {
    SearchBarView()
}
