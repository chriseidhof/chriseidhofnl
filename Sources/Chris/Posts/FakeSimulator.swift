//
//  ContentView.swift
//  FakeSimulator
//
//  Created by Chris Eidhof on 05.10.22.
//

import SwiftUI

struct Device {
    var size: CGSize
    var bezelWidth: CGFloat = 20
    var topSafeAreaHeight: CGFloat = 47
    var bottomSafeAreaHeight: CGFloat = 34

    var safeAreaSize: CGSize {
        .init(width: size.width, height: size.height-topSafeAreaHeight-bottomSafeAreaHeight)
    }

    static let iPhone13 = Device(size: .init(width: 390, height: 844))
}

struct PhoneModifier: ViewModifier {
    @Environment(\.colorScheme) var parentColorScheme
    var device: Device
    var colorScheme: ColorScheme = .light
    var bluePrint: Bool = false
    var date: Date?

    var deviceShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 40, style: .continuous)
    }

    var bezelColor: Color {
        parentColorScheme == .light ? Color(white: 0.6) : Color(white: 0.3)
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
            Notch()
                .frame(maxHeight: .infinity, alignment: .top)
                .foregroundColor(bezelColor)
            HStack {
                Image(systemName: "wifi")
                Image(systemName: "battery.100")
            }
            .padding(.trailing, 24)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.system(size: 14))
    }

    var homeIndicator: some View {
        Capsule(style: .continuous)
            .frame(width: 160, height: 5)
            .frame(height: 13, alignment: .top)
    }

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .top, spacing: 0) {
                topBar
                    .frame(height: device.topSafeAreaHeight)
                    .opacity(bluePrint ? 0 : 1)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                homeIndicator
                    .frame(height: device.bottomSafeAreaHeight, alignment: .bottom)
            }
            .frame(width: device.size.width, height: device.size.height)
            .background {
                if bluePrint {
                    deviceShape
                        .fill(Color.blue.opacity(0.2))
                } else {
                    deviceShape
                        .fill(.background)
                }
            }
            .clipShape(
                deviceShape.inset(by: bluePrint ? -100 : 0)
            )
            .overlay {
                if bluePrint {
                    deviceShape
                        .stroke(Color.white, style: .init(lineWidth: 2, dash: [10]))
                } else {
                    deviceShape
                        .inset(by: -device.bezelWidth/2)
                        .stroke(bezelColor, lineWidth: device.bezelWidth)
                }
            }
            .padding(device.bezelWidth)
            .colorScheme(colorScheme)
    }
}

extension View {
    func phone(device: Device = .iPhone13, date: Date? = nil) -> some View {
        buttonStyle(.link)
            .modifier(PhoneModifier(device: device, date: date))
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

//
//struct ContentView: View {
//    var body: some View {
//        Color.yellow
//            .edgesIgnoringSafeArea(.all)
//        .modifier(PhoneModifier(device: .iPhone13))
//        .padding()
//        .background(.blue)
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
