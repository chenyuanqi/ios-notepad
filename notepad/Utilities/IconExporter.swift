import SwiftUI

@MainActor
struct IconExporter {
    static func exportIcon() async {
        let sizes: [(String, CGFloat)] = [
            ("icon_40", 40),
            ("icon_60", 60),
            ("icon_58", 58),
            ("icon_87", 87),
            ("icon_80", 80),
            ("icon_120", 120),
            ("icon_180", 180),
            ("icon_1024", 1024)
        ]
        
        let renderer = ImageRenderer(content: AppIcon())
        
        for (name, size) in sizes {
            renderer.proposedSize = .init(width: size, height: size)
            
            if let image = renderer.uiImage {
                if let data = image.pngData() {
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let fileURL = documentsDirectory.appendingPathComponent("\(name).png")
                    try? data.write(to: fileURL)
                    print("Icon saved: \(fileURL.path)")
                }
            }
        }
    }
}

struct IconExporterView: View {
    @State private var isExporting = false
    
    var body: some View {
        Button("导出图标") {
            isExporting = true
            Task {
                await IconExporter.exportIcon()
                isExporting = false
            }
        }
        .padding()
        .disabled(isExporting)
        .overlay {
            if isExporting {
                ProgressView()
                    .padding(.leading, 8)
            }
        }
    }
}

#Preview {
    IconExporterView()
} 