import SwiftUI

struct AppIcon: View {
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let scale = size / 100 // 使用100作为基准尺寸
            
            ZStack {
                // 背景渐变
                LinearGradient(
                    colors: [
                        Color(red: 0.4, green: 0.6, blue: 1.0),
                        Color(red: 0.2, green: 0.4, blue: 0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 记事本效果
                VStack(spacing: -4 * scale) {
                    // 顶部装订圈
                    HStack(spacing: 6 * scale) {
                        ForEach(0..<5) { _ in
                            Circle()
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 10 * scale, height: 10 * scale)
                                .shadow(color: .black.opacity(0.1), radius: 1 * scale)
                        }
                    }
                    .offset(y: 5 * scale)
                    
                    // 记事本主体
                    RoundedRectangle(cornerRadius: 12 * scale)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 4 * scale, x: 0, y: 2 * scale)
                        .overlay(
                            VStack(alignment: .leading, spacing: 8 * scale) {
                                // 标题行
                                RoundedRectangle(cornerRadius: 2 * scale)
                                    .fill(Color(red: 0.4, green: 0.6, blue: 1.0))
                                    .frame(width: 60 * scale, height: 4 * scale)
                                
                                // 内容行
                                ForEach(0..<3) { i in
                                    RoundedRectangle(cornerRadius: 2 * scale)
                                        .fill(Color(red: 0.9, green: 0.9, blue: 0.95))
                                        .frame(width: [80.0, 65.0, 70.0][i] * scale, height: 4 * scale)
                                }
                            }
                            .padding(16 * scale)
                        )
                        .padding(12 * scale)
                }
                .shadow(color: .black.opacity(0.1), radius: 8 * scale)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct IconPreview: View {
    let sizes: [(String, CGFloat)] = [
        ("40x40", 40),
        ("60x60", 60),
        ("58x58", 58),
        ("87x87", 87),
        ("80x80", 80),
        ("120x120", 120),
        ("180x180", 180),
        ("1024x1024", 1024)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 150))
            ], spacing: 20) {
                ForEach(sizes, id: \.0) { name, size in
                    VStack {
                        AppIcon()
                            .frame(width: min(size, 150), height: min(size, 150))
                            .clipShape(RoundedRectangle(cornerRadius: size * 0.225))
                            .shadow(color: .black.opacity(0.1), radius: 2)
                        Text("\(name)")
                            .font(.caption)
                    }
                }
            }
            .padding()
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    IconPreview()
} 