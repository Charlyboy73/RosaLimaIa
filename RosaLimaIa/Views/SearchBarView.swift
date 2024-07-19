import SwiftUI

struct SearchBarView: View {
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
                ZStack(alignment: .trailing) {
                    TextEditor(text: $text)
                        .font(.system(size: 14)) // Ajusta el tamaño de la fuente
                        .frame(height: min(textHeight, lineHeight * CGFloat(maxLines))) // Limita la altura a 5 líneas
                        .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 40)) // Ajusta el padding con espacio para el micrófono
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.gray, lineWidth: 3) // Contorno más ancho
                        )
                        .onChange(of: text) { _, _ in

                            recalculateHeight()
                        }

                    if text.isEmpty {
                        Image(systemName: "mic.fill")
                            .padding(.trailing, 16) // Ajusta el padding derecho para el icono
                            .foregroundColor(.gray)
                            .onTapGesture {
                                // Acción al tocar el micrófono
                            }
                    }
                }
                .padding(.leading, 16) // Ajusta el padding horizontal del ZStack
                .padding(.vertical, 2) // Ajusta el padding vertical del ZStack
                // Imagen de la flecha o los audífonos
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
        }
        .padding()
    }

    private func recalculateHeight() {
        let maxSize = CGSize(width: UIScreen.main.bounds.width - 64, height: CGFloat.infinity) // Ajusta el ancho máximo
        let textView = UITextView()
        textView.text = text
        textView.font = font // Ajusta el tamaño de la fuente
        let size = textView.sizeThatFits(maxSize)
        textHeight = size.height
    }
}

#Preview {
    SearchBarView()
}
