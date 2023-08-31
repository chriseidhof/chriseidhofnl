import SwiftUI

struct Device {
    var size: CGSize
    var bezelWidth: CGFloat = 20
    var topSafeAreaHeight: CGFloat = 59
    var bottomSafeAreaHeight: CGFloat = 34
    var dynamicIsland: Bool = false
    var outline: Bool = false
    var redactedTopBar = false

    var safeAreaSize: CGSize {
        .init(width: size.width, height: size.height-topSafeAreaHeight-bottomSafeAreaHeight)
    }

    static let iPhone13 = Device(size: .init(width: 390, height: 844))
    static let iPhone14 = Device(size: .init(width: 393, height: 852), topSafeAreaHeight: 59, bottomSafeAreaHeight: 34, dynamicIsland: true)
}

struct PhoneModifier: ViewModifier {
    @Environment(\.colorScheme) var parentColorScheme
    var device: Device
    var colorScheme: ColorScheme = .light
    var date: Date?
    var accessoryColor: Color  = Color(white: 0.8)

    var deviceShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 40, style: .continuous)
    }

    var bezelColor: Color?
    private var bezelColor_: Color {
        bezelColor ?? (parentColorScheme == .light ? Color(white: 0.6) : Color(white: 0.3))
    }

    var topBar: some View {
        HStack {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                Text(date ?? context.date, format:
                        Date.FormatStyle(date: .none, time: .shortened)
                           .hour(.defaultDigits(amPM: .omitted))
                )
                    .fontWeight(.medium)
                    .padding(.leading, 24)
                    .frame(maxWidth: .infinity)
            }
            if device.dynamicIsland {
                dynamicIsland
            } else {
                Notch()
                    .frame(maxHeight: .infinity, alignment: .top)
                    .foregroundColor(bezelColor_)
            }
            HStack {
                Image(systemName: "wifi")
                Image(systemName: "battery.100")
            }
            .padding(.trailing, 24)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.system(size: 14))
    }

    @ViewBuilder var dynamicIsland: some View {
        let capsule = Capsule(style: .continuous)
        ZStack {
            if device.outline {
                capsule.fill(Material.regular)
            } else {
                capsule .fill(bezelColor_)
            }
        }.frame(width: 125, height: 30)
    }

    @ViewBuilder
    var homeIndicator: some View {
        let capsule = Capsule(style: .continuous)
        ZStack {
            if device.outline {
                capsule
                    .fill(Material.regular)

            } else {
                capsule
            }
        }
        .frame(width: 160, height: 5)
        .frame(height: 13)
    }

    func body(content: Content) -> some View {
        VStack {
            content
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .top, spacing: 0) {
                ZStack {
                    if device.redactedTopBar {
                        topBar.redacted(reason: .placeholder)
                    } else {
                        topBar
                    }
                }
                    .frame(height: device.topSafeAreaHeight)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                homeIndicator
                    .frame(height: device.bottomSafeAreaHeight)
            }
            .frame(width: device.size.width, height: device.size.height)
            .background {
                deviceShape
                    .fill(.background)
            }
            .clipShape(deviceShape)
            .overlay {
                deviceShape
                    .strokeBorder(bezelColor_, lineWidth: device.bezelWidth)
            }
            .padding(device.bezelWidth/2)
            .colorScheme(colorScheme)
    }
}

extension View {
    func phone(device: Device = .iPhone14, date: Date? = nil, bezelColor: Color? = nil) -> some View {
        buttonStyle(.link)
            .modifier(PhoneModifier(device: device, date: date, bezelColor: bezelColor))
            .compositingGroup()
    }
}

struct CornerShape: Shape {
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        Path { p in
            p.addRoundedRect(in: rect, cornerSize: .init(width: cornerRadius, height: cornerRadius), style: .continuous)
            p.addRect(rect)
        }
    }
}

struct Notch: View {
    var height: CGFloat = 34
    var topRadius: CGFloat = 8

    var body: some View {
        let topCorner =  CornerShape(cornerRadius: topRadius)
            .fill(style: .init(eoFill: true))
            .frame(width: topRadius*2, height: topRadius*2)
            .frame(width: topRadius, height: topRadius, alignment: .topTrailing)
            .clipped()

        HStack(alignment: .top, spacing: 0) {
            topCorner
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .frame(height: height*2)
                .frame(width: 162, height: height, alignment: .bottom)
            topCorner
                .scaleEffect(x: -1)
        }
    }
}

extension Device {
    static var myDevice: Device {
        var device = Device.iPhone14
        device.bezelWidth = 1
        device.outline = true
        device.redactedTopBar = true
        return device
    }
}

//#Preview {
//    Text("Hello")
//        .modifier(PhoneModifier(device: .myDevice, accessoryColor: Color(white: 0.9), bezelColor: Color(white: 0.8)))
//        .compositingGroup()
//        .padding()
//}
//
//#Preview {
//    Color.yellow
//        .ignoresSafeArea()
//        .phone(device: .myDevice)
//}
