import SwiftUI
import UIKit
import PhotosUI
import UniformTypeIdentifiers

// MARK: - Shared helpers

func logLineColor(_ line: String) -> Color {
    if line.contains("✅") || line.contains("🎉") { return .green }
    if line.contains("❌") { return .red }
    if line.contains("⚠️") { return .orange }
    return .secondary
}

// MARK: - Share Sheet for Exporting .passthm

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - About FrameKit

struct CreditsSheet: View {
    @Environment(\.dismiss) private var dismiss

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.4.1"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(spacing: 12) {
                        Image(uiImage: UIImage(named: "AppIcon") ?? UIImage(systemName: "viewfinder")!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .foregroundStyle(.blue)
                        Text("FrameKit")
                            .font(.largeTitle.bold())
                        Text("Версия \(version)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Темы, обои и оформление твоего iPhone.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Открытый исходный код")
                            .font(.headline)
                        Text("FrameKit is a fork of AirCard-iOS. This build adds independent branding and removes donation prompts; the underlying system logic is retained from the original project.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Link("Исходный код FrameKit", destination: URL(string: "https://github.com/brdish1488/FrameKit")!)
                        Link("Original project: AirCard-iOS", destination: URL(string: "https://github.com/Mak5er/AirCard-iOS")!)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Благодарности")
                            .font(.headline)
                        Text("AirCard-iOS: @mak5er, @merybist and upstream contributors. AirLift: @0xjohnnydev. NeoSpring / PosterBoard: @rooootdev, @skadz108 and @neonmodder123.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    DisclosureGroup("MIT license") {
                        Text("MIT License\n\nCopyright (c) 2026 Johnny Franks\n\nPermission is hereby granted, free of charge, to any person obtaining a copy\nof this software and associated documentation files (the \"Software\"), to deal\nin the Software without restriction, including without limitation the rights\nto use, copy, modify, merge, publish, distribute, sublicense, and/or sell\ncopies of the Software, and to permit persons to whom the Software is\nfurnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all\ncopies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\nIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\nFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\nAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\nLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\nOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\nSOFTWARE.\n")
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                            .padding(.top, 12)
                    }
                }
                .padding(24)
            }
            .navigationTitle("О FrameKit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Pairing File Guide Sheet

struct PairingGuideSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onImportTapped: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Where to find your pairing file")
                            .font(.title2.bold())
                        Text("FrameKit can import pairing files exported by SideStore, LiveContainer, iLoader, or your computer.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // SideStore Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "app.badge.checkmark.fill")
                                .font(.title3)
                                .foregroundStyle(.blue)
                            Text("SideStore")
                                .font(.headline.bold())
                            Spacer()
                            Text("Recommended")
                                .font(.caption2.bold())
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Color.blue.opacity(0.12))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }

                        Text("SideStore automatically creates a pairing file during setup. You can pick it directly in the Files app:")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Path in Files app:")
                                .font(.caption2.bold())
                                .foregroundStyle(.secondary)
                            Text("On My iPhone › SideStore › ALTPairingFile.mobiledevicepairing")
                                .font(.caption.monospaced())
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(uiColor: .systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(14)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // LiveContainer Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "shippingbox.fill")
                                .font(.title3)
                                .foregroundStyle(.purple)
                            Text("LiveContainer (SideStore inside)")
                                .font(.headline.bold())
                        }

                        Text("If you run SideStore inside LiveContainer, the pairing file is stored inside LiveContainer's app storage:")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Path in Files app:")
                                .font(.caption2.bold())
                                .foregroundStyle(.secondary)
                            Text("On My iPhone › LiveContainer › SideStore › Documents › ALTPairingFile.mobiledevicepairing")
                                .font(.caption.monospaced())
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(uiColor: .systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(14)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // iLoader / Jitterbug / AltStore Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.down.doc.fill")
                                .font(.title3)
                                .foregroundStyle(.orange)
                            Text("iLoader / Jitterbug / AltStore")
                                .font(.headline.bold())
                        }

                        Text("• In iLoader: Settings › Export Pairing File › save to Files.\n• In Jitterbug: Export your <UDID>.mobiledevicepairing.\n• On PC/Mac: Run jitterbugpair or export from SideServer / AltServer, then AirDrop to your iPhone.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Direct Placement Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "folder.fill")
                                .font(.title3)
                                .foregroundStyle(.green)
                            Text("Manual Drop in Files App")
                                .font(.headline.bold())
                        }

                        Text("You can also copy any .mobiledevicepairing or .plist file directly into:")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Text("Files app › On My iPhone › FrameKit")
                            .font(.caption.monospaced())
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(uiColor: .systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Text("It will immediately appear under 'Discovered in Documents' in FrameKit.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Action Button
                    Button {
                        dismiss()
                        onImportTapped()
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "square.and.arrow.down.fill")
                            Text("Import Pairing File Now")
                            Spacer()
                        }
                        .font(.headline)
                        .frame(height: 48)
                    }
                    .buttonStyle(.borderedProminent)
            .tint(FrameKitStyle.blueFill)
                    .padding(.top, 4)
                }
                .padding()
            }
            .navigationTitle("Pairing Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") { dismiss() }.bold()
                }
            }
        }
    }
}

// MARK: - Compact Scrollable Log View with 1-Click Copy

struct CompactLogView: View {
    let title: String
    let lines: [String]
    var onClear: (() -> Void)? = nil
    @State private var copied: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                if let onClear = onClear, !lines.isEmpty {
                    Button(action: onClear) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.borderless)
                    .padding(.trailing, 6)
                }
                Button {
                    UIPasteboard.general.string = lines.joined(separator: "\n")
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    var t = Transaction()
                    t.disablesAnimations = true
                    withTransaction(t) {
                        copied = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        var t2 = Transaction()
                        t2.disablesAnimations = true
                        withTransaction(t2) {
                            copied = false
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 11, weight: .bold))
                        Text(copied ? "Copied" : "Copy")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundStyle(copied ? .green : .blue)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color(uiColor: .tertiarySystemFill))
                    .clipShape(Capsule())
                }
                .buttonStyle(.borderless)
                .transaction { $0.animation = nil }
            }

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(lines.enumerated()), id: \.offset) { idx, line in
                            Text(line)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(logLineColor(line))
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id(idx)
                        }
                    }
                    .padding(8)
                }
                .frame(maxHeight: 180)
                .background(Color(uiColor: .tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.secondary.opacity(0.18), lineWidth: 0.5)
                )
                .onChange(of: lines.count) { _, _ in
                    if !lines.isEmpty {
                        proxy.scrollTo(lines.count - 1, anchor: .bottom)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Native Document Picker

struct DocumentPickerView: UIViewControllerRepresentable {
    let allowedContentTypes: [UTType]
    let onPick: (URL) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedContentTypes, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerView

        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            let shouldStop = url.startAccessingSecurityScopedResource()
            defer {
                if shouldStop { url.stopAccessingSecurityScopedResource() }
            }
            parent.onPick(url)
            parent.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.dismiss()
        }
    }
}

// MARK: - FrameKit visual language

// Shared native styling only. Import, pairing and apply engines stay unchanged.
enum FrameKitStyle {
    static let blue = Color(red: 0.23, green: 0.69, blue: 1.0)
    static let purple = Color(red: 0.82, green: 0.32, blue: 0.98)
    // Filled actions use darker shades so white labels retain AA contrast.
    static let blueFill = Color(red: 0.0, green: 0.40, blue: 0.73)
    static let purpleFill = Color(red: 0.61, green: 0.12, blue: 0.73)
    static let redFill = Color(red: 0.72, green: 0.13, blue: 0.13)
    static let orangeFill = Color(red: 0.62, green: 0.30, blue: 0.02)
    static let surface = Color(red: 0.11, green: 0.11, blue: 0.12)
}

struct FrameKitFormStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .listSectionSpacing(24)
            .environment(\.defaultMinListRowHeight, 54)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
    }
}

struct FrameKitHero: View {
    let title: String
    let subtitle: String
    let symbol: String
    var accent: Color = FrameKitStyle.blue

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 25, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: 56, height: 56)
                .background(accent.opacity(0.13), in: RoundedRectangle(cornerRadius: 17))
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.headline).foregroundStyle(.white)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
    }
}

struct FrameKitStatusRow: View {
    let title: String
    let subtitle: String
    let symbol: String
    let active: Bool

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: symbol)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(active ? Color.green : Color.orange)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.body.weight(.semibold)).foregroundStyle(.white)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
                    .lineLimit(2).truncationMode(.middle)
            }
            Spacer(minLength: 4)
            Image(systemName: active ? "checkmark.circle.fill" : "exclamationmark.circle")
                .foregroundStyle(active ? Color.green : Color.orange)
                .accessibilityLabel(active ? "Готово" : "Требует внимания")
        }
        .padding(.vertical, 10)
    }
}

struct FrameKitRouteRow: View {
    let title: String
    let subtitle: String
    let symbol: String
    var accent: Color = FrameKitStyle.blue

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: symbol).font(.system(size: 25)).foregroundStyle(accent)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.body.weight(.semibold)).foregroundStyle(.white)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 4)
            Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.secondary)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

// MARK: - Single home navigation

enum FrameKitDestination: Hashable {
    case connection, themes, wallpapers, wallet
}

struct FrameKitFeatureCard: View {
    let title: String
    let subtitle: String
    let format: String
    let symbol: String
    let accent: Color

    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text(format).font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(accent)
                VStack(alignment: .leading, spacing: 6) {
                    Text(title).font(.system(size: 24, weight: .bold)).foregroundStyle(.white)
                    Text(subtitle).font(.subheadline).foregroundStyle(.white.opacity(0.65))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
            Image(systemName: symbol)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(accent)
                .frame(width: 64, height: 72)
                .accessibilityHidden(true)
        }
        .padding(22)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(LinearGradient(colors: [accent.opacity(0.16), FrameKitStyle.surface], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(accent.opacity(0.16), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 26))
    }
}

struct FrameKitHomeView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showCredits = false

    private var connectionReady: Bool { vm.wifiUp && vm.vpnUp && vm.hasPairingFile }
    private var connectionDetail: String {
        if !vm.hasPairingFile { return "Добавь файл сопряжения" }
        if !vm.wifiUp { return "Подключи Wi-Fi" }
        if !vm.vpnUp { return "Включи LocalDevVPN" }
        return "Можно применять оформление"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                NavigationLink(value: FrameKitDestination.connection) {
                    HStack(spacing: 14) {
                        Image(systemName: connectionReady ? "checkmark.circle.fill" : "link")
                            .font(.system(size: 23, weight: .medium))
                            .foregroundStyle(connectionReady ? Color.green : FrameKitStyle.blue)
                            .frame(width: 30)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Подключение").font(.body.weight(.semibold)).foregroundStyle(.white)
                            Text(connectionDetail).font(.subheadline)
                                .foregroundStyle(connectionReady ? Color.green : Color.white.opacity(0.65))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.white.opacity(0.55))
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, minHeight: 82, alignment: .leading)
                    .background(FrameKitStyle.surface, in: RoundedRectangle(cornerRadius: 22))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("home.connection")

                VStack(spacing: 16) {
                    NavigationLink(value: FrameKitDestination.themes) {
                        FrameKitFeatureCard(title: "Темы пароля", subtitle: "Свой стиль кнопок
экрана блокировки", format: ".passthm", symbol: "circle.grid.3x3.fill", accent: FrameKitStyle.blue)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("home.themes")

                    NavigationLink(value: FrameKitDestination.wallpapers) {
                        FrameKitFeatureCard(title: "Обои", subtitle: "Добавь движение
экрану блокировки", format: ".tendies", symbol: "photo.stack", accent: FrameKitStyle.purple)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("home.wallpapers")

                    NavigationLink(value: FrameKitDestination.wallet) {
                        FrameKitRouteRow(title: "Карты Wallet", subtitle: "Твои изображения на картах", symbol: "creditcard.fill")
                            .padding(.horizontal, 20).padding(.vertical, 8)
                            .background(FrameKitStyle.surface, in: RoundedRectangle(cornerRadius: 22))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("home.wallet")
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
        .background(Color.black)
        .navigationTitle("FrameKit")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showCredits = true } label: {
                    Image(systemName: "info.circle").frame(width: 44, height: 44)
                }.accessibilityLabel("О FrameKit")
            }
        }
        .sheet(isPresented: $showCredits) { CreditsSheet() }
        .onAppear { vm.refreshNetworkStatus(); vm.refreshPairingFile() }
        .refreshable { vm.refreshNetworkStatus(); vm.refreshPairingFile() }
    }
}

struct ContentView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var path: [FrameKitDestination]

    // Initial routes make the actual navigation hierarchy testable without a
    // second navigation stack or preview-only screen implementation.
    init(initialPath: [FrameKitDestination] = []) {
        _path = State(initialValue: initialPath)
    }

    var body: some View {
        NavigationStack(path: $path) {
            FrameKitHomeView()
                .navigationDestination(for: FrameKitDestination.self) { destination in
                    switch destination {
                    case .connection: PairingTab()
                    case .themes: PasscodeThemeTab()
                    case .wallpapers: TendiesView()
                    case .wallet: WalletCardsTab()
                    }
                }
        }
        .preferredColorScheme(.dark)
        .tint(FrameKitStyle.blue)
        .alert("Внимание", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .alert("Готово", isPresented: $vm.showSuccessAlert) {
            Button("OK") {}
        } message: {
            Text(vm.successAlertMessage)
        }
        .sheet(isPresented: $vm.showShareSheet) {
            if let url = vm.exportedThemeURL {
                ShareSheet(items: [url])
            }
        }
        .onAppear {
            vm.showSuccessAlert = false
            vm.successAlertMessage = ""
        }
    }
}

// MARK: - Pairing Tab

struct PairingTab: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showDeleteConfirm = false
    @State private var showFilePicker = false
    @State private var showPairingGuide = false
    @State private var showRespringConfirm = false

    private var isIOS27OrNewer: Bool {
        ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 27
    }

    var body: some View {
            Form {
                Section("Подключение и сопряжение") {
                    FrameKitStatusRow(title: vm.wifiUp ? "Wi-Fi подключён" : "Wi-Fi недоступен",
                                      subtitle: "Беспроводной интерфейс", symbol: "wifi", active: vm.wifiUp)
                    FrameKitStatusRow(title: vm.vpnUp ? "VPN-туннель активен" : "Нужен VPN-туннель",
                                      subtitle: "Для работы нужен LocalDevVPN", symbol: "shield.lefthalf.filled", active: vm.vpnUp)
                    FrameKitStatusRow(title: vm.hasPairingFile ? "Файл сопряжения готов" : "Сопряжение не настроено",
                                      subtitle: vm.hasPairingFile ? "\(vm.pairingFileName) · \(vm.pairingFileSizeString)" : "Импортируй файл или создай его ниже",
                                      symbol: "checkmark.seal", active: vm.hasPairingFile)

                    Button { showFilePicker = true } label: {
                        Label(vm.hasPairingFile ? "Заменить файл сопряжения" : "Импортировать файл сопряжения", systemImage: "square.and.arrow.down")
                            .font(.body.weight(.semibold)).frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.borderedProminent).tint(FrameKitStyle.purpleFill)
                    .padding(.vertical, 4)

                    Button { showPairingGuide = true } label: {
                        Label("Где взять файл?", systemImage: "questionmark.circle")
                            .frame(minHeight: 44)
                    }

                    DisclosureGroup("Настройки туннеля") {
                        VPNStatusRow(vm: vm).padding(.vertical, 8)
                    }
                    if vm.hasPairingFile {
                        Button("Удалить активное сопряжение", role: .destructive) { showDeleteConfirm = true }
                            .frame(minHeight: 44)
                    }
                }

                if isIOS27OrNewer {
                    Section("Сопряжение на iPhone") {
                        if vm.pairingPhase == .pairing {
                            HStack(spacing: 12) {
                                ProgressView()
                                Text(vm.pairingStatus.isEmpty ? "Запуск сопряжения…" : vm.pairingStatus)
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                            if let pin = vm.pairingPIN {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("PIN для сопряжения").font(.subheadline).foregroundStyle(.secondary)
                                    HStack {
                                        Text(pin).font(.system(size: 36, weight: .bold, design: .monospaced))
                                            .foregroundStyle(FrameKitStyle.blue)
                                        Spacer()
                                        Button { UIPasteboard.general.string = pin } label: {
                                            Image(systemName: "doc.on.doc").frame(width: 44, height: 44)
                                        }.accessibilityLabel("Скопировать PIN")
                                    }
                                    Text("Настройки → Конфиденциальность и безопасность → Режим разработчика → Сопряжение с FrameKit")
                                        .font(.subheadline).foregroundStyle(.secondary)
                                    Button("Открыть настройки приложения") {
                                        if let url = URL(string: UIApplication.openSettingsURLString) {
                                            UIApplication.shared.open(url)
                                        }
                                    }.frame(minHeight: 44)
                                }.padding(.vertical, 8)
                            }
                            Button("Отменить сопряжение", role: .cancel) { vm.cancelPairing() }
                                .frame(minHeight: 44)
                        } else {
                            Button { vm.startPairing() } label: {
                                Label(vm.hasPairingFile ? "Создать сопряжение заново" : "Создать сопряжение", systemImage: "antenna.radiowaves.left.and.right")
                                    .font(.body.weight(.semibold)).frame(maxWidth: .infinity, minHeight: 48)
                            }.buttonStyle(.borderedProminent)
            .tint(FrameKitStyle.blueFill).padding(.vertical, 4)
                            if !vm.pairingStatus.isEmpty && vm.pairingStatus != "idle" {
                                Text(vm.pairingStatus).font(.subheadline).foregroundStyle(.secondary)
                                    .textSelection(.enabled)
                            }
                        }
                    }
                }

                if !vm.documentsPlistFiles.isEmpty {
                    Section("Файлы в папке приложения") {
                        ForEach(vm.documentsPlistFiles, id: \.self) { filename in
                            Button { vm.selectPairingFile(filename: filename) } label: {
                                Label(filename, systemImage: "doc.text").lineLimit(2)
                            }.frame(minHeight: 44)
                        }
                    }
                }

                Section("Действия") {
                    Button { showRespringConfirm = true } label: {
                        Label("Перезапустить интерфейс", systemImage: "arrow.clockwise.circle.fill")
                            .font(.body.weight(.semibold)).frame(minHeight: 48)
                    }
                    Button { vm.refreshNetworkStatus(); vm.refreshPairingFile() } label: {
                        Label("Обновить состояние", systemImage: "arrow.triangle.2.circlepath")
                            .frame(minHeight: 44)
                    }
                }
                Section("Движок") {
                    HStack(spacing: 14) {
                        Image(systemName: "cpu").font(.title2).foregroundStyle(FrameKitStyle.blue)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Airlift").font(.headline)
                            Text("На устройстве").font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("ON DEVICE").font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(FrameKitStyle.blue)
                    }
                    .padding(.vertical, 8)
                    Text("Совместимость зависит от версии iOS. В исходном проекте заявлено: iOS 18 — 27.2 beta 2; с 27.2 beta 3 уязвимость исправлена.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }

                if !vm.log.isEmpty {
                    Section("Диагностика") {
                        CompactLogView(title: "Журнал подключения", lines: vm.log, onClear: { vm.log.removeAll() })
                    }
                }
            }
            .modifier(FrameKitFormStyle())
            .navigationTitle("Подключение")
            .confirmationDialog("Удалить сопряжение?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Удалить", role: .destructive) { vm.deletePairingFile() }
                Button("Отмена", role: .cancel) {}
            } message: { Text("Для работы потребуется создать или импортировать другой файл сопряжения.") }
            .confirmationDialog("Перезапустить интерфейс iPhone?", isPresented: $showRespringConfirm, titleVisibility: .visible) {
                Button("Перезапустить", role: .destructive) { vm.respringDevice() }
                Button("Отмена", role: .cancel) {}
            } message: { Text("NeoSpring временно прервёт работу интерфейса. Сохрани открытые данные.") }
            .sheet(isPresented: $showFilePicker) {
                DocumentPickerView(allowedContentTypes: [
                    UTType(filenameExtension: "mobiledevicepairing") ?? .data,
                    UTType(filenameExtension: "plist") ?? .propertyList,
                    UTType(filenameExtension: "mobilepair") ?? .data,
                    .propertyList, .data, .item
                ]) { url in
                    _ = vm.importPairingFile(from: url, originalName: url.lastPathComponent)
                }
            }
            .sheet(isPresented: $showPairingGuide) {
                PairingGuideSheet {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { showFilePicker = true }
                }
            }
            .onAppear { vm.refreshNetworkStatus(); vm.refreshPairingFile() }
            .refreshable { vm.refreshNetworkStatus(); vm.refreshPairingFile() }
            .overlay {
                if vm.isNeoSpringing {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        NeoSpringView().brightness(-1.0).ignoresSafeArea()
                    }
                }
            }
        
    }
}

// MARK: - VPN Status Row

struct VPNStatusRow: View {
    @ObservedObject var vm: AppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: vm.vpnUp
                      ? "checkmark.shield.fill"
                      : "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundStyle(vm.vpnUp ? .green : .orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text(vm.vpnUp ? "Loopback VPN Active" : "Loopback VPN Not Detected")
                        .font(.subheadline.bold())
                    Text(vm.vpnUp
                         ? "RSD tunnel ready — exploit will connect."
                         : "Connect LocalDevVPN before running flashes.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !vm.vpnUp {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Setup LocalDevVPN:")
                        .font(.caption.bold())
                    ForEach([
                        "1. Open LocalDevVPN app and tap Connect.",
                        "2. Return to FrameKit — status indicator turns green."
                    ], id: \.self) { step in
                        Text(step)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Link("Launch LocalDevVPN",
                         destination: URL(string: "localdevvpn://")!)
                        .font(.caption.bold())
                }
                .padding(10)
                .background(Color.orange.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            HStack(spacing: 8) {
                Text("Device IP:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("10.7.0.1", text: $vm.deviceIP)
                    .font(.caption.monospaced())
                    .keyboardType(.decimalPad)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(uiColor: .tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .frame(width: 120)
                Spacer()
                Button {
                    vm.refreshNetworkStatus()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption.bold())
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
            }

            if !vm.networkDetail.isEmpty {
                Text(vm.networkDetail)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Apple Wallet Card View Component (Authentic AirCard Style)

struct WalletCardView: View {
    let card: CardItem
    let cardIndex: Int
    let onToggleSelected: (Bool) -> Void
    let onPickImage: () -> Void
    let onClearImage: () -> Void
    let onDelete: () -> Void
    var onRename: ((String) -> Void)? = nil

    @State private var copied = false
    @State private var isRenaming = false
    @State private var renameText = ""

    var body: some View {
        VStack(spacing: 12) {
            // Realistic Apple Wallet Card Mockup (1.586 : 1 aspect ratio)
            GeometryReader { geo in
                let width = geo.size.width
                let height = width / 1.586

                ZStack {
                    if let img = card.uiImage {
                        // Custom skin applied
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: width, height: height)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                            // Subtle Apple Wallet Card Gloss Overlay
                            LinearGradient(
                                colors: [.white.opacity(0.18), .clear, .black.opacity(0.12)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                            // Top Right Remove Button
                            Button(action: onClearImage) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.white.opacity(0.95))
                                    .background(Circle().fill(Color.black.opacity(0.55)))
                            }
                            .buttonStyle(.plain)
                            .padding(10)
                        }
                    } else {
                        // Empty / Placeholder Card Mockup
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(uiColor: .secondarySystemBackground),
                                            Color(uiColor: .tertiarySystemBackground)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )

                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    Color.secondary.opacity(0.25),
                                    style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                                )

                            // Contactless & Chip icons
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "wave.3.right")
                                        .font(.system(size: 15))
                                        .foregroundStyle(.secondary.opacity(0.6))
                                    Spacer()
                                    Image(systemName: "creditcard")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.secondary.opacity(0.5))
                                }
                                .padding(14)
                                Spacer()
                            }

                            // Center Action Callout
                            VStack(spacing: 8) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 32))
                                    .foregroundStyle(.blue)

                                Text("Assign Card Skin")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.primary)

                                Text("Tap to choose photo")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .frame(width: width, height: height)
                .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
                .contentShape(Rectangle())
                .onTapGesture { onPickImage() }
            }
            .aspectRatio(1.586, contentMode: .fit)

            // Card Controls & Meta Bar
            HStack(spacing: 8) {
                Toggle("", isOn: Binding(
                    get: { card.isSelected },
                    set: { onToggleSelected($0) }
                ))
                .labelsHidden()

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(card.title)
                            .font(.system(size: 13, weight: .bold))
                            .lineLimit(1)

                        if let network = card.paymentNetwork {
                            Text(network)
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.12))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    }

                    // Monospace Hash Pill with Copy Button
                    HStack(spacing: 4) {
                        Text(card.id.prefix(8) + "…" + card.id.suffix(6))
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)

                        Button {
                            UIPasteboard.general.string = card.id
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            copied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = false }
                        } label: {
                            Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc")
                                .font(.system(size: 10))
                                .foregroundStyle(copied ? .green : .secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()

                Button {
                    renameText = card.displayName ?? ""
                    isRenaming = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if card.uiImage != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.system(size: 14))
                }

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(card.isSelected ? Color.blue.opacity(0.35) : Color.clear, lineWidth: 1.5)
        )
        .alert("Rename Card", isPresented: $isRenaming) {
            TextField("Card Name (e.g. Monobank)", text: $renameText)
            Button("Save") {
                onRename?(renameText)
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Enter a custom display name or bank name for this card.")
        }
    }
}

// MARK: - Wallet Cards Tab

struct WalletCardsTab: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var newHashText = ""
    @State private var showAddSheet = false
    enum ActiveCardPicker: Identifiable {
        case singleCard(String)
        case bulkAll
        var id: String {
            switch self {
            case .singleCard(let id): return id
            case .bulkAll: return "bulk_all"
            }
        }
    }
    @State private var activePicker: ActiveCardPicker? = nil
    @State private var showSourceDialog: Bool = false
    @State private var isPhotosPickerPresented: Bool = false
    @State private var isDocumentPickerPresented: Bool = false
    private struct CropRequest: Identifiable {
        let id = UUID()
        let image: UIImage
        let target: ActiveCardPicker
    }
    @State private var pendingCrop: CropRequest?
    @State private var cropRequest: CropRequest?
    @State private var photoLoadFailed = false
    @State private var pendingLoadError = false
    @State private var cropAccepted = false

    var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    scannerBanner

                    if vm.cards.isEmpty {
                        walletEmptyState
                            .padding(.top, 40)
                    } else {
                        cardsList
                    }
                }
                .padding(.vertical)
                .transaction { $0.animation = nil }
            }
            .transaction { $0.animation = nil }
            .modifier(FrameKitFormStyle())
            .background(Color.black)
            .navigationTitle("Карты Wallet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button { vm.toggleCardScanning() } label: {
                            Label(vm.isScanningCards ? "Остановить поиск" : "Сканировать карты", systemImage: vm.isScanningCards ? "stop.circle" : "wave.3.left.circle")
                        }
                        Button {
                            showAddSheet = true
                        } label: {
                            Label("Добавить карту вручную", systemImage: "plus")
                        }
                        if !vm.cards.isEmpty {
                            Button {
                                activePicker = .bulkAll
                                showSourceDialog = true
                            } label: {
                                Label("Оформить все карты", systemImage: "photo.on.rectangle.angled")
                            }

                            Divider()

                            Button {
                                vm.selectAllCards(true)
                            } label: {
                                Label("Выбрать все", systemImage: "checkmark.circle")
                            }

                            Button {
                                vm.selectAllCards(false)
                            } label: {
                                Label("Снять выбор", systemImage: "circle")
                            }

                            Divider()

                            Button(role: .destructive) {
                                withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                                    vm.clearAllCards()
                                }
                            } label: {
                                Label("Удалить все карты", systemImage: "trash")
                            }

                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                    }
                }

            }
            .safeAreaInset(edge: .bottom) {
                if !vm.cards.isEmpty {
                    flashButton.padding(.horizontal, 20).padding(.vertical, 12)
                        .background(Color.black)
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddCardSheet(hashText: $newHashText) {
                    vm.addCardHash(newHashText)
                    newHashText = ""
                    showAddSheet = false
                }
            }
            .confirmationDialog("Источник изображения", isPresented: $showSourceDialog, titleVisibility: .visible) {
                Button {
                    isPhotosPickerPresented = true
                } label: {
                    Label("Медиатека", systemImage: "photo.on.rectangle")
                }
                Button {
                    isDocumentPickerPresented = true
                } label: {
                    Label("Выбрать из файлов…", systemImage: "folder")
                }
                Button("Отмена", role: .cancel) {
                    activePicker = nil
                }
            }
            .sheet(isPresented: $isPhotosPickerPresented, onDismiss: { activePicker = nil }) {
                if let target = activePicker {
                    CardPhotoPicker { image in
                        assignImage(image, to: target)
                    }
                }
            }
            .sheet(isPresented: $isDocumentPickerPresented, onDismiss: presentPendingCrop) {
                DocumentPickerView(allowedContentTypes: [
                    .image, .png, .jpeg, .heic,
                    UTType(filenameExtension: "webp") ?? .image,
                    UTType(filenameExtension: "tiff") ?? .image
                ]) { url in
                    guard let picker = activePicker else { return }
                    if let data = try? Data(contentsOf: url),
                       let image = ImageEngine.safeImageFromData(data, maxDimension: 2560) {
                        pendingCrop = CropRequest(image: image, target: picker)
                    } else {
                        pendingLoadError = true
                    }
                    activePicker = nil
                }
            }
            .sheet(item: $cropRequest, onDismiss: {
                if !cropAccepted { isDocumentPickerPresented = true }
            }) { request in
                CardPhotoCropView(image: request.image) { croppedImage in
                    cropAccepted = true
                    assignImage(croppedImage, to: request.target)
                    activePicker = nil
                }
            }
            .alert("Couldn't Load Photo", isPresented: $photoLoadFailed) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Choose another image or try downloading the photo to your iPhone first.")
            }
        
    }

    private func assignImage(_ image: UIImage, to target: ActiveCardPicker) {
        switch target {
        case .singleCard(let cardId):
            vm.setCardImage(for: cardId, image: image)
        case .bulkAll:
            vm.setSkinForAllCards(image: image)
        }
    }

    private func presentPendingCrop() {
        guard !isPhotosPickerPresented, !isDocumentPickerPresented else { return }
        if let request = pendingCrop {
            pendingCrop = nil
            cropAccepted = false
            activePicker = request.target
            cropRequest = request
        } else if pendingLoadError {
            pendingLoadError = false
            photoLoadFailed = true
        }
    }

    @ViewBuilder
    private var scannerBanner: some View {
        if vm.isScanningCards || !vm.scanStatusText.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    if vm.isScanningCards {
                        ProgressView().scaleEffect(0.85)
                        Text("Live Scanner Active")
                            .font(.subheadline.bold())
                            .foregroundStyle(.blue)
                    } else {
                        Image(systemName: "wave.3.left.circle")
                            .foregroundStyle(.secondary)
                        Text("Scanner Status")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if vm.isScanningCards {
                        Button("Stop") {
                            vm.stopCardScanning()
                        }
                        .font(.caption.bold())
                        .buttonStyle(.borderedProminent)
                        .tint(FrameKitStyle.redFill)
                        .controlSize(.small)
                    }
                }
                Text(vm.scanStatusText)
                    .font(.caption)
                    .foregroundStyle(vm.scanStatusText.contains("stopped") || vm.scanStatusText.contains("error") ? .orange : .secondary)
            }
            .padding(14)
            .background(vm.isScanningCards ? Color.blue.opacity(0.12) : Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal)
            .transaction { $0.animation = nil }
        }
    }

    @ViewBuilder
    private var cardsList: some View {
        VStack(spacing: 16) {
            ForEach(vm.cards, id: \.id) { card in
                let cardIndex = vm.cards.firstIndex(where: { $0.id == card.id }) ?? 0
                WalletCardView(
                    card: card,
                    cardIndex: cardIndex,
                    onToggleSelected: { isSelected in
                        vm.setCardSelected(id: card.id, selected: isSelected)
                    },
                    onPickImage: {
                        activePicker = .singleCard(card.id)
                        showSourceDialog = true
                    },
                    onClearImage: { vm.clearCardImage(for: card.id) },
                    onDelete: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        vm.deleteCard(id: card.id)
                    },
                    onRename: { newName in
                        vm.updateCardName(id: card.id, newName: newName)
                    }
                )
                .id(card.id)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 0.85).combined(with: .opacity)
                ))
            }

            if !vm.cardFlashLog.isEmpty {
                CompactLogView(
                    title: "Flash Log (\(vm.cardFlashLog.count) lines)",
                    lines: vm.cardFlashLog,
                    onClear: { vm.cardFlashLog.removeAll() }
                )
                .padding(.top, 8)
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var flashButton: some View {
        Button {
            vm.flashCards()
        } label: {
            HStack(spacing: 6) {
                if case .running = vm.cardFlashPhase {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.75)
                    Text("Применение…")
                        .font(.headline)
                } else if case .done(let ok) = vm.cardFlashPhase, !ok {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Повторить")
                        .font(.headline)
                } else {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Применить")
                        .font(.headline)
                }
            }
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, minHeight: 48)
        }
        .buttonStyle(.borderedProminent)
        .tint({
            if case .done(let ok) = vm.cardFlashPhase, !ok {
                return FrameKitStyle.orangeFill
            }
            return FrameKitStyle.blueFill
        }())
        .disabled(!vm.canFlashCards || vm.cardFlashPhase == .running)
        .animation(.easeInOut(duration: 0.2), value: vm.cardFlashPhase)
    }

    private var walletEmptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "creditcard.viewfinder")
                .font(.system(size: 56))
                .foregroundStyle(.blue.opacity(0.8))

            Text("Пока нет карт")
                .font(.title3.bold())

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Text("1.")
                        .bold()
                        .foregroundStyle(.blue)
                    Text("Нажми **Поиск**, чтобы найти карты Wallet.")
                }
                HStack(alignment: .top, spacing: 10) {
                    Text("2.")
                        .bold()
                        .foregroundStyle(.blue)
                    Text("Открой Wallet **двойным нажатием боковой кнопки**, подтверди Face ID и выбери карту.")
                }
                HStack(alignment: .top, spacing: 10) {
                    Text("3.")
                        .bold()
                        .foregroundStyle(.blue)
                    Text("Карта появится здесь автоматически.")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(16)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 24)

            HStack(spacing: 12) {
                Button {
                    vm.toggleCardScanning()
                } label: {
                    HStack(spacing: 6) {
                        Spacer()
                        Image(systemName: vm.isScanningCards ? "stop.circle.fill" : "wave.3.left.circle")
                        Text(vm.isScanningCards ? "Стоп" : "Поиск")
                            .lineLimit(1).minimumScaleFactor(0.9)
                        Spacer()
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                }
                .buttonStyle(.borderedProminent)
                .tint(vm.isScanningCards ? FrameKitStyle.redFill : FrameKitStyle.blueFill)
                .transaction { $0.animation = nil }

                Button {
                    showAddSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Spacer()
                        Image(systemName: "plus")
                        Text("Вручную")
                        Spacer()
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                }
                .buttonStyle(.bordered)
                .transaction { $0.animation = nil }
            }
            .padding(.horizontal, 24)
            .transaction { $0.animation = nil }
        }
        .frame(maxWidth: .infinity)
        .transaction { $0.animation = nil }
    }
}

// MARK: - Add Card Sheet

struct AddCardSheet: View {
    @Binding var hashText: String
    let onAdd: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Card Hash") {
                    TextField("Paste card hash (e.g. M6nDwZrkYbFl…)", text: $hashText, axis: .vertical)
                        .font(.system(.body, design: .monospaced))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .lineLimit(4...8)
                }
                Section {
                    Text("You can add multiple hashes at once — separate them with spaces, commas, or newlines.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Add Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") { onAdd() }
                        .disabled(hashText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .bold()
                }
            }
        }
    }
}

// MARK: - Passcode Theme Tab

struct PasscodeThemeTab: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showThemeFileImporter = false

    var body: some View {
            Form {
                // Mode picker
                Section {
                    Picker("Режим", selection: $vm.passcodeMode) {
                        ForEach(CreatorMode.allCases) { mode in
                            Text(mode == .applyTheme ? "Готовая тема" : "Создать свою").tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if vm.passcodeMode == .applyTheme {
                    ApplyThemeSection(onImport: {
                        vm.themeImportError = nil
                        vm.themeImportStatus = "Выбери один файл .passthm и нажми «Открыть»."
                        showThemeFileImporter = true
                    })
                } else {
                    ThemeCreatorSection()
                }

                if vm.isImportingTheme || !vm.themeImportStatus.isEmpty || vm.themeImportError != nil || vm.loadedTheme != nil {
                Section("Состояние импорта") {
                    if vm.isImportingTheme {
                        ProgressView("Чтение темы…")
                    }
                    if !vm.themeImportStatus.isEmpty {
                        Text(vm.themeImportStatus)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                    if let message = vm.themeImportError {
                        Label(message, systemImage: "exclamationmark.triangle")
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .textSelection(.enabled)
                    }
                    if let theme = vm.loadedTheme {
                        Text("Загружено: \(theme.name) · кнопок: \(theme.keysPreview.count)")
                            .font(.footnote.bold())
                            .foregroundStyle(.green)
                    }
                }
                }

                // Flash log
                if !vm.passthmFlashLog.isEmpty {
                    Section {
                        CompactLogView(
                            title: "Flash Log (\(vm.passthmFlashLog.count) lines)",
                            lines: vm.passthmFlashLog,
                            onClear: { vm.passthmFlashLog.removeAll() }
                        )
                    }
                }
            }
            .modifier(FrameKitFormStyle())
            .navigationTitle("Темы пароля")
            .sheet(isPresented: $showThemeFileImporter) {
                // Exactly the working wallpaper picker: same UIKit controller,
                // asCopy setting, selection mode, content types and delegate.
                TendiesDocumentPickerView { urls in
                    vm.importPasscodeSelection(urls)
                }
            }
            .onAppear { vm.scanDocumentsDirectory() }
        
    }
}

// MARK: Apply Theme section

struct ApplyThemeSection: View {
    @EnvironmentObject var vm: AppViewModel
    let onImport: () -> Void

    var body: some View {
        // Themes dropped directly into Documents folder
        if !vm.documentsThemes.isEmpty {
            Section("Темы в папке FrameKit") {
                ForEach(vm.documentsThemes, id: \.self) { file in
                    HStack {
                        Image(systemName: "paintpalette.fill")
                            .foregroundStyle(.blue)
                        Text(file)
                            .font(.system(size: 13, design: .monospaced))
                        Spacer()
                        Button("Загрузить") {
                            vm.loadPassthmFromDocuments(filename: file)
                        }
                        .font(.caption.bold())
                        .buttonStyle(.borderedProminent)
            .tint(FrameKitStyle.blueFill)
                        .controlSize(.small)
                    }
                }
            }
        }

        Section("Импорт темы") {
            HStack {
                Button {
                    onImport()
                } label: {
                    Label(vm.loadedTheme == nil ? "Импорт .passthm" : "Заменить .passthm",
                          systemImage: "doc.badge.plus")
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                if vm.loadedTheme != nil {
                    Button {
                        vm.clearLoadedTheme()
                    } label: {
                        Text("Очистить")
                            .font(.caption.bold())
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .disabled(vm.isImportingTheme)


            Text("Выбери один .passthm и нажми «Открыть». Для просмотра темы сопряжение не требуется.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

        }

        if vm.loadedTheme == nil {
            Section("Интерактивное превью") {
                VStack(spacing: 16) {
                    Image(systemName: "circle.grid.3x3.fill")
                        .font(.system(size: 48, weight: .light)).foregroundStyle(FrameKitStyle.blue.opacity(0.7))
                    Text("Твоя тема появится здесь").font(.headline)
                    Text("Импортируй .passthm или открой «Создать свою», чтобы добавить изображение.")
                        .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }.frame(maxWidth: .infinity).padding(.vertical, 28)
            }
        }

        if let theme = vm.loadedTheme {
            Section("Интерактивное превью") {
                KeypadPreviewView(keys: theme.keysPreview)
                    .listRowInsets(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6))
                    .listRowBackground(Color.clear)
            }

            Section("О теме") {
                LabeledContent("Файлов в теме", value: "\(theme.fileCount)")
                LabeledContent("Кнопок", value: "\(theme.keysPreview.count)")

                Button {
                    vm.adoptThemeIntoCreator()
                } label: {
                    Label("Редактировать тему", systemImage: "pencil")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.bordered)
            }

            PasscodeTargetSection()

            Section {
                VStack(spacing: 12) {
                    flashButton

                    Button(role: .destructive) {
                        vm.clearLoadedTheme()
                    } label: {
                        HStack(spacing: 8) {
                            Spacer()
                            Image(systemName: "trash")
                            Text("Выгрузить тему")
                            Spacer()
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14))
            }
        }
    }

    @ViewBuilder
    private var flashButton: some View {
        if case .running = vm.passthmFlashPhase {
            HStack(spacing: 10) {
                ProgressView()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Применение темы…").font(.subheadline.bold())
                    ProgressView(value: vm.passthmFlashProgress)
                }
            }
            .padding(.vertical, 4)
        } else if case .done(let ok) = vm.passthmFlashPhase, !ok {
            Button {
                vm.flashPassthm()
            } label: {
                HStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "arrow.clockwise")
                    Text("Повторить применение")
                    Spacer()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            }
            .buttonStyle(.borderedProminent)
            .tint(FrameKitStyle.orangeFill)
            .disabled(!vm.canFlashPassthm)
        } else {
            Button {
                vm.flashPassthm()
            } label: {
                HStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "bolt.fill")
                    Text("Применить тему")
                    Spacer()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            }
            .buttonStyle(.borderedProminent)
            .tint(FrameKitStyle.blueFill)
            .disabled(!vm.canFlashPassthm)
        }
    }
}

// MARK: - Passcode Target Section (matching AirCard macOS)

struct PasscodeTargetSection: View {
    @EnvironmentObject var vm: AppViewModel

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.badge.clock")
                        .foregroundColor(.blue)
                        .font(.headline)
                    Text("Параметры применения")
                        .font(.headline)
                }

                // 1. Target System
                VStack(alignment: .leading, spacing: 4) {
                    Text("Системный кэш")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    Picker("Системный кэш", selection: $vm.targetTelephonyVersion) {
                        Text("TelephonyUI-10 (iOS 18+)").tag("TelephonyUI-10")
                        Text("TelephonyUI-9 (iOS 16–17)").tag("TelephonyUI-9")
                        Text("TelephonyUI-8 (iOS 14–15)").tag("TelephonyUI-8")
                        Text("Universal (All)").tag("all")
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }

                Divider()

                // 2. System Language
                VStack(alignment: .leading, spacing: 4) {
                    Text("Язык код-пароля")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    Picker("Язык код-пароля", selection: $vm.passcodeLanguageTarget) {
                        ForEach(PasscodeLanguageTarget.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }

                Divider()

                // 3. Font Weight / Style
                VStack(alignment: .leading, spacing: 4) {
                    Text("Стиль шрифта")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    Picker("Стиль шрифта", selection: $vm.passcodeBoldTarget) {
                        ForEach(PasscodeBoldTarget.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }

                // Dynamic hint
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: vm.passcodeLanguageTarget == .all && vm.passcodeBoldTarget == .both ? "globe" : "bolt.fill")
                        .font(.caption)
                        .foregroundColor(vm.passcodeLanguageTarget == .all && vm.passcodeBoldTarget == .both ? .secondary : .orange)
                        .padding(.top, 1)

                    if vm.passcodeLanguageTarget == .all && vm.passcodeBoldTarget == .both {
                        Text("Universal mode flashes ~600 files for all languages & Bold text. Selecting a specific language (e.g. Ukrainian) speeds up flashing dramatically.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Text("Fast mode selected: only targets \(vm.passcodeLanguageTarget.rawValue) with \(vm.passcodeBoldTarget.rawValue).")
                            .font(.caption2)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: Theme Creator section

struct ThemeCreatorSection: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var selectedDigitForPicker: String? = nil
    @State private var showKeySourceDialog: Bool = false
    @State private var isKeyPhotosPickerPresented: Bool = false
    @State private var isKeyDocumentPickerPresented: Bool = false
    @State private var selectedKey: [PhotosPickerItem] = []

    @State private var showPosterSourceDialog: Bool = false
    @State private var isPosterPhotosPickerPresented: Bool = false
    @State private var isPosterDocumentPickerPresented: Bool = false
    @State private var selectedPoster: [PhotosPickerItem] = []

    var body: some View {
        Section("Источник оформления") {
            Picker("", selection: $vm.sliceMode) {
                ForEach(SliceMode.allCases) { m in
                    Text(m == .posterSlice ? "Изображение" : "Отдельные кнопки").tag(m)
                }
            }
            .pickerStyle(.segmented)
        }

        if vm.sliceMode == .posterSlice {
            posterSliceSection
        } else {
            individualKeysSection
        }

        // Preview
        Section("Интерактивное превью") {
            KeypadPreviewView(keys: vm.effectiveKeys)
                .listRowInsets(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6))
                .listRowBackground(Color.clear)
        }

        PasscodeTargetSection()

        // Action Section
        Section {
            VStack(spacing: 12) {
                flashButton

                if !vm.effectiveKeys.isEmpty {
                    Button {
                        _ = vm.exportPassthm()
                    } label: {
                        HStack(spacing: 8) {
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                            Text("Экспорт .passthm")
                            Spacer()
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                    }
                    .buttonStyle(.bordered)

                    Button(role: .destructive) {
                        vm.clearAllCreator()
                    } label: {
                        HStack(spacing: 8) {
                            Spacer()
                            Image(systemName: "trash")
                            Text("Очистить всё")
                            Spacer()
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
            .listRowInsets(EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14))
        }
    }

    private var posterSliceSection: some View {
        Group {
            Section("Изображение для клавиатуры") {
                Button {
                    showPosterSourceDialog = true
                } label: {
                    Label(vm.posterImage == nil ? "Добавить изображение" : "Заменить изображение",
                          systemImage: "photo")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .confirmationDialog("Источник изображения", isPresented: $showPosterSourceDialog, titleVisibility: .visible) {
                Button {
                    isPosterPhotosPickerPresented = true
                } label: {
                    Label("Медиатека", systemImage: "photo.on.rectangle")
                }
                Button {
                    isPosterDocumentPickerPresented = true
                } label: {
                    Label("Выбрать из файлов…", systemImage: "folder")
                }
                Button("Отмена", role: .cancel) {}
            }
            .photosPicker(
                isPresented: $isPosterPhotosPickerPresented,
                selection: $selectedPoster,
                maxSelectionCount: 1,
                matching: .images
            )
            .onChange(of: selectedPoster) { _, items in
                guard let item = items.first else { return }
                Task {
                    if let image = await item.loadUIImage(maxDimension: 2560) {
                        await MainActor.run { vm.setPosterImage(image) }
                    }
                    await MainActor.run { selectedPoster = [] }
                }
            }
            .sheet(isPresented: $isPosterDocumentPickerPresented) {
                DocumentPickerView(allowedContentTypes: [
                    .image, .png, .jpeg, .heic,
                    UTType(filenameExtension: "webp") ?? .image,
                    UTType(filenameExtension: "tiff") ?? .image
                ]) { url in
                    if let data = try? Data(contentsOf: url),
                       let image = ImageEngine.safeImageFromData(data, maxDimension: 2560) {
                        vm.setPosterImage(image)
                    }
                }
            }

            if vm.posterImage != nil {
                Section("Форма кнопок") {
                    VStack(alignment: .leading, spacing: 6) {
                        Picker("", selection: $vm.maskToCircles) {
                            Text("Цельное изображение").tag(false)
                            Text("Кружки").tag(true)
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: vm.maskToCircles) { _, _ in
                            vm.updatePosterSlicing()
                        }

                        Text(vm.maskToCircles ? "Изображение обрезается по форме круглых кнопок." : "Цельное изображение без круглой обрезки, распределённое по клавишам.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 2)
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Масштаб и положение")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("Сбросить положение") {
                                withAnimation(.spring()) {
                                    vm.resetPosterPosition()
                                }
                            }
                            .font(.caption2)
                            .buttonStyle(.borderless)
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "minus.magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.caption)

                            Slider(value: $vm.posterZoom, in: 0.5...3.0, step: 0.05)
                                .onChange(of: vm.posterZoom) { _, _ in
                                    vm.updatePosterSlicing()
                                }

                            Image(systemName: "plus.magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.caption)

                            Text(String(format: "%.1fx", vm.posterZoom))
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .frame(width: 38, alignment: .trailing)
                        }

                        HStack(spacing: 6) {
                            Image(systemName: "hand.draw")
                                .foregroundColor(.secondary)
                                .font(.caption2)
                            Text("Drag anywhere on the dialer preview to reposition")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private var individualKeysSection: some View {
        Section("Individual Keys") {
            Text("Tap a button row to assign a custom image.")
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(KeypadLayout.allButtons) { btn in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(uiColor: .secondarySystemBackground))
                            .frame(width: 44, height: 44)
                        if let img = vm.customKeys[btn.digit] {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                        } else {
                            Text(btn.digit)
                                .font(.title3.bold())
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Key \(btn.digit)")
                            .font(.subheadline.weight(.medium))
                        if !btn.letters.isEmpty {
                            Text(btn.letters)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    if vm.customKeys[btn.digit] != nil {
                        Button(role: .destructive) {
                            vm.clearIndividualKey(digit: btn.digit)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                                .font(.title3)
                        }
                        .buttonStyle(.borderless)
                    } else {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.title3)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedDigitForPicker = btn.digit
                    showKeySourceDialog = true
                }
            }
        }
        .confirmationDialog("Choose Key \(selectedDigitForPicker ?? "") Image Source", isPresented: $showKeySourceDialog, titleVisibility: .visible) {
            Button {
                isKeyPhotosPickerPresented = true
            } label: {
                Label("Медиатека", systemImage: "photo.on.rectangle")
            }
            Button {
                isKeyDocumentPickerPresented = true
            } label: {
                Label("Выбрать из файлов…", systemImage: "folder")
            }
            Button("Отмена", role: .cancel) {
                selectedDigitForPicker = nil
            }
        }
        .photosPicker(
            isPresented: $isKeyPhotosPickerPresented,
            selection: $selectedKey,
            maxSelectionCount: 1,
            matching: .images
        )
        .onChange(of: selectedKey) { _, items in
            guard let item = items.first,
                  let digit = selectedDigitForPicker else {
                if items.isEmpty { selectedDigitForPicker = nil }
                return
            }
            let currentDigit = digit
            Task {
                if let image = await item.loadUIImage(maxDimension: 1024) {
                    await MainActor.run { vm.setIndividualKey(digit: currentDigit, image: image) }
                }
                await MainActor.run {
                    selectedKey = []
                    selectedDigitForPicker = nil
                }
            }
        }
        .sheet(isPresented: $isKeyDocumentPickerPresented) {
            DocumentPickerView(allowedContentTypes: [
                .image, .png, .jpeg, .heic,
                UTType(filenameExtension: "webp") ?? .image,
                UTType(filenameExtension: "tiff") ?? .image
            ]) { url in
                guard let digit = selectedDigitForPicker else { return }
                if let data = try? Data(contentsOf: url),
                   let image = ImageEngine.safeImageFromData(data, maxDimension: 1024) {
                    vm.setIndividualKey(digit: digit, image: image)
                }
                selectedDigitForPicker = nil
            }
        }
    }

    @ViewBuilder
    private var flashButton: some View {
        if case .running = vm.passthmFlashPhase {
            HStack(spacing: 10) {
                ProgressView()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Применение темы…").font(.subheadline.bold())
                    ProgressView(value: vm.passthmFlashProgress)
                }
            }
            .padding(.vertical, 4)
        } else if case .done(let ok) = vm.passthmFlashPhase, !ok {
            Button {
                vm.flashPassthm()
            } label: {
                HStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "arrow.clockwise")
                    Text("Повторить применение")
                    Spacer()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            }
            .buttonStyle(.borderedProminent)
            .tint(FrameKitStyle.orangeFill)
            .disabled(!vm.canFlashPassthm)
        } else {
            Button {
                vm.flashPassthm()
            } label: {
                HStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "bolt.fill")
                    Text("Применить тему")
                    Spacer()
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            }
            .buttonStyle(.borderedProminent)
            .tint(FrameKitStyle.blueFill)
            .disabled(!vm.canFlashPassthm)
        }
    }
}

// MARK: - Keypad Preview (clean modern lock screen dialer preview)

struct KeypadPreviewView: View {
    @EnvironmentObject var vm: AppViewModel
    let keys: [String: UIImage]

    @State private var dragOffsetStart: CGPoint = .zero
    @State private var isDragging: Bool = false

    private func scaledPosterDimensions(for poster: UIImage, gridW: CGFloat, gridH: CGFloat) -> (width: CGFloat, height: CGFloat) {
        let imgW = poster.size.width
        let imgH = poster.size.height
        guard imgW > 0, imgH > 0 else { return (gridW, gridH) }

        let imgAspect = imgW / imgH
        let gridAspect = gridW / gridH

        if imgAspect > gridAspect {
            let h = gridH * vm.posterZoom
            return (width: h * imgAspect, height: h)
        } else {
            let w = gridW * vm.posterZoom
            return (width: w, height: w / imgAspect)
        }
    }

    var body: some View {
        let scale: CGFloat = 0.68
        let btnD: CGFloat = KeypadLayout.buttonDiameter * scale
        let colW: CGFloat = KeypadLayout.colWidth * scale
        let rowH: CGFloat = KeypadLayout.rowHeight * scale
        let gridW: CGFloat = KeypadLayout.gridWidth * scale
        let gridH: CGFloat = KeypadLayout.gridHeight * scale

        let isSeamlessPoster = (vm.passcodeMode == .themeCreator && vm.sliceMode == .posterSlice && !vm.maskToCircles && vm.posterImage != nil)

        ZStack {
            // Dark luxury frosted card backdrop
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(red: 0.07, green: 0.07, blue: 0.09))

            LinearGradient(
                colors: [Color.white.opacity(0.06), Color.clear, Color.black.opacity(0.35)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(spacing: 12) {
                // Keypad grid
                ZStack {
                    // Layer 1: Background wallpaper in Seamless Poster mode
                    if isSeamlessPoster, let poster = vm.posterImage {
                        let dims = scaledPosterDimensions(for: poster, gridW: gridW, gridH: gridH)
                        Image(uiImage: poster)
                            .resizable()
                            .frame(width: dims.width, height: dims.height)
                            .position(
                                x: gridW / 2.0 + (vm.posterOffset.x * scale),
                                y: gridH / 2.0 + (vm.posterOffset.y * scale)
                            )
                    }

                    // Layer 2: 10 Keypad buttons
                    ForEach(KeypadLayout.allButtons) { btn in
                        let cx = CGFloat(btn.col) * colW + colW / 2
                        let cy = CGFloat(btn.row) * rowH + rowH / 2

                        keypadButton(btn: btn, btnD: btnD, scale: scale, isSeamlessPoster: isSeamlessPoster)
                            .position(x: cx, y: cy)
                    }
                }
                .frame(width: gridW, height: gridH)
                .clipped()
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 1)
                        .onChanged { value in
                            if vm.passcodeMode == .themeCreator && vm.sliceMode == .posterSlice && vm.posterImage != nil {
                                if !isDragging {
                                    isDragging = true
                                    dragOffsetStart = vm.posterOffset
                                }
                                vm.posterOffset = CGPoint(
                                    x: dragOffsetStart.x + value.translation.width / scale,
                                    y: dragOffsetStart.y + value.translation.height / scale
                                )
                                vm.updatePosterSlicing()
                            }
                        }
                        .onEnded { _ in
                            isDragging = false
                            dragOffsetStart = vm.posterOffset
                        }
                )

                // Drag hint pill (only shown when dragging poster is possible)
                if vm.passcodeMode == .themeCreator && vm.sliceMode == .posterSlice && vm.posterImage != nil {
                    HStack(spacing: 5) {
                        Image(systemName: "hand.draw.fill")
                            .font(.system(size: 10))
                        Text("Drag preview to reposition")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(.white.opacity(0.65))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.white.opacity(0.08)))
                }
            }
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: (vm.passcodeMode == .themeCreator && vm.sliceMode == .posterSlice && vm.posterImage != nil) ? 320 : 295)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func keypadButton(btn: KeypadButtonGeometry, btnD: CGFloat, scale: CGFloat, isSeamlessPoster: Bool) -> some View {
        ZStack {
            if isSeamlessPoster {
                // Seamless mode: Frosted glass touch target ring
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: btnD, height: btnD)

                Circle()
                    .stroke(Color.white.opacity(0.35), lineWidth: 1.0)
                    .frame(width: btnD, height: btnD)

                VStack(spacing: 0) {
                    Text(btn.digit)
                        .font(.system(size: 26 * scale, weight: .light))
                        .foregroundStyle(.white.opacity(0.95))
                    if !btn.letters.isEmpty {
                        Text(btn.letters)
                            .font(.system(size: 8.5 * scale, weight: .semibold))
                            .tracking(0.8 * scale)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
            } else if let img = keys[btn.digit] {
                // Custom theme button: Pure artwork without clashing superimposed text!
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: btnD, height: btnD)

                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: btnD, height: btnD)
                    .clipShape(Circle())

                Circle()
                    .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
                    .frame(width: btnD, height: btnD)
            } else {
                // Default iOS dialer style for unstyled buttons
                Circle()
                    .fill(Color.white.opacity(0.14))
                    .frame(width: btnD, height: btnD)

                Circle()
                    .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
                    .frame(width: btnD, height: btnD)

                VStack(spacing: 0) {
                    Text(btn.digit)
                        .font(.system(size: 26 * scale, weight: .light))
                        .foregroundStyle(.white)
                    if !btn.letters.isEmpty {
                        Text(btn.letters)
                            .font(.system(size: 8.5 * scale, weight: .semibold))
                            .tracking(0.8 * scale)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
            }
        }
        .frame(width: btnD, height: btnD)
    }
}
