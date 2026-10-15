import SwiftUI
import UIKit
import CryptoKit
import AVKit

struct SavedTheme: Codable, Identifiable, Sendable {
    var id: UUID
    var name: String
    var favorite: Bool
    var date: Date
    var keyCount: Int
    var digest: String
}

/// Archives and thumbnails live independently of the temporary import cache.
actor ThemeLibraryStorage {
    nonisolated let directory: URL
    init(directory: URL? = nil) {
        self.directory = directory ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("FrameKit/Themes", isDirectory: true)
    }
    nonisolated func archive(_ id: UUID) -> URL { directory.appendingPathComponent(id.uuidString).appendingPathComponent("theme.passthm") }
    nonisolated func thumbnail(_ id: UUID) -> URL { directory.appendingPathComponent(id.uuidString).appendingPathComponent("preview.png") }
    private var manifest: URL { directory.appendingPathComponent("library.json") }
    func list() throws -> [SavedTheme] {
        guard FileManager.default.fileExists(atPath: manifest.path) else { return [] }
        return try JSONDecoder().decode([SavedTheme].self, from: Data(contentsOf: manifest))
    }
    private func write(_ rows: [SavedTheme]) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try JSONEncoder().encode(rows).write(to: manifest, options: .atomic)
    }
    func save(data: Data, name: String, keyCount: Int, thumbnail: Data?) throws -> [SavedTheme] {
        var rows = try list()
        let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        if rows.contains(where: { $0.digest == digest }) { return rows }
        let row = SavedTheme(id: UUID(), name: Self.cleanName(name), favorite: false, date: Date(), keyCount: keyCount, digest: digest)
        let folder = directory.appendingPathComponent(row.id.uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        do {
            try data.write(to: archive(row.id), options: .atomic)
            if let thumbnail { try thumbnail.write(to: self.thumbnail(row.id), options: .atomic) }
            rows.insert(row, at: 0)
            try write(rows)
            return rows
        } catch { try? FileManager.default.removeItem(at: folder); throw error }
    }
    func rename(_ id: UUID, name: String) throws -> [SavedTheme] {
        var rows = try list()
        if let i = rows.firstIndex(where: { $0.id == id }) { rows[i].name = Self.cleanName(name) }
        try write(rows); return rows
    }
    func favorite(_ id: UUID) throws -> [SavedTheme] {
        var rows = try list()
        if let i = rows.firstIndex(where: { $0.id == id }) { rows[i].favorite.toggle() }
        try write(rows); return rows
    }
    func delete(_ id: UUID) throws -> [SavedTheme] {
        let rows = try list().filter { $0.id != id }
        try write(rows)
        try? FileManager.default.removeItem(at: directory.appendingPathComponent(id.uuidString))
        return rows
    }
    nonisolated static func cleanName(_ name: String) -> String {
        let value = String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(80))
        return value.isEmpty ? "Моя тема" : value
    }
}

enum EditorBackground: String, CaseIterable, Identifiable {
    case original = "Исходный", black = "Чёрный", white = "Белый", blue = "Синий", purple = "Фиолетовый"
    var id: String { rawValue }
    var color: UIColor {
        switch self {
        case .original: return .clear
        case .black: return .black
        case .white: return .white
        case .blue: return UIColor(red: 0.02, green: 0.35, blue: 0.65, alpha: 1)
        case .purple: return UIColor(red: 0.38, green: 0.10, blue: 0.48, alpha: 1)
        }
    }
}

enum ThemeArtwork {
    static func decorate(_ image: UIImage, background: EditorBackground, radius: Double) -> UIImage {
        guard background != .original || radius > 0 else { return image }
        let size = CGSize(width: image.size.width * image.scale, height: image.size.height * image.scale)
        let format = UIGraphicsImageRendererFormat(); format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            let rect = CGRect(origin: .zero, size: size)
            UIBezierPath(roundedRect: rect, cornerRadius: min(size.width, size.height) * CGFloat(radius)).addClip()
            background.color.setFill(); UIRectFill(rect)
            image.draw(in: rect)
        }
    }
    static func thumbnail(_ keys: [String: UIImage]) -> Data? {
        let format = UIGraphicsImageRendererFormat(); format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: 240, height: 300), format: format).image { _ in
            UIColor(white: 0.08, alpha: 1).setFill(); UIRectFill(CGRect(x: 0, y: 0, width: 240, height: 300))
            for digit in 0...9 {
                guard let image = keys[String(digit)] else { continue }
                let index = digit == 0 ? 10 : digit - 1
                image.draw(in: CGRect(x: 25 + (index % 3) * 68, y: 20 + (index / 3) * 68, width: 54, height: 54))
            }
        }.pngData()
    }
}

@MainActor enum FrameKitFeedback {
    static var enabled: Bool { UserDefaults.standard.object(forKey: "framekit.haptics") == nil || UserDefaults.standard.bool(forKey: "framekit.haptics") }
    static func selection() { if enabled { UISelectionFeedbackGenerator().selectionChanged() } }
    static func result(_ success: Bool) { if enabled { UINotificationFeedbackGenerator().notificationOccurred(success ? .success : .error) } }
}

struct FrameKitPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

enum FrameKitApplyTarget: String, Identifiable { case themes, wallpapers, wallet; var id: String { rawValue } }
struct ApplyCheck: Identifiable {
    let title: String
    let detail: String
    let passed: Bool
    var warning: Bool = false
    var id: String { title }
}
struct PreflightSnapshot {
    var wifi: Bool
    var vpn: Bool
    var pairing: Bool
    var content: Bool
    var files: Bool
    var partial: Bool = false
    var unsafe: Bool = false
    var checks: [ApplyCheck] {
        var rows = [
            ApplyCheck(title: "Wi-Fi", detail: wifi ? "Интерфейс доступен" : "Подключись к Wi-Fi", passed: wifi),
            ApplyCheck(title: "VPN-туннель", detail: vpn ? "Интерфейс обнаружен; доступность устройства проверится при записи" : "Включи LocalDevVPN и вернись сюда", passed: vpn),
            ApplyCheck(title: "Файл сопряжения", detail: pairing ? "Локальный файл доступен" : "Главная → Подключение → импорт файла", passed: pairing),
            ApplyCheck(title: "Выбранное оформление", detail: content ? "Данные готовы" : "Сначала импортируй тему, выбери обои или изображение карты", passed: content),
            ApplyCheck(title: "Локальные файлы", detail: files ? "Исходные файлы доступны" : "Файл удалён: импортируй его заново", passed: files)
        ]
        if partial { rows.append(ApplyCheck(title: "Неполная тема", detail: "Не все 10 кнопок найдены. Изменятся только доступные кнопки.", passed: false, warning: true)) }
        if unsafe { rows.append(ApplyCheck(title: "Архив с базой данных", detail: "Содержит SQLite. Применяй только архив из доверенного источника.", passed: false, warning: true)) }
        return rows
    }
    var canApply: Bool { checks.allSatisfy { $0.passed || $0.warning } }
}

extension AppViewModel {
    func reloadLibrary() async {
        do { themeLibrary = try await themeLibraryStorage.list(); libraryError = nil }
        catch { libraryError = "Библиотека не прочитана. Существующие файлы не изменены. \(error.localizedDescription)" }
    }
    func rememberTheme(url: URL, name: String, keys: [String: UIImage]) {
        let preview = ThemeArtwork.thumbnail(keys)
        Task {
            do {
                let data = try Data(contentsOf: url)
                themeLibrary = try await themeLibraryStorage.save(data: data, name: name, keyCount: keys.count, thumbnail: preview)
                libraryError = nil
            } catch { libraryError = "Тема открыта, но не сохранена в библиотеку: \(error.localizedDescription)" }
        }
    }
    func openSavedTheme(_ entry: SavedTheme) {
        loadPassthm(url: themeLibraryStorage.archive(entry.id), displayName: entry.name)
    }
    func renameSavedTheme(_ entry: SavedTheme, name: String) async {
        do { themeLibrary = try await themeLibraryStorage.rename(entry.id, name: name) }
        catch { libraryError = error.localizedDescription }
    }
    func favoriteSavedTheme(_ entry: SavedTheme) async {
        do { themeLibrary = try await themeLibraryStorage.favorite(entry.id); FrameKitFeedback.selection() }
        catch { libraryError = error.localizedDescription }
    }
    func deleteSavedTheme(_ entry: SavedTheme) async {
        do { themeLibrary = try await themeLibraryStorage.delete(entry.id) }
        catch { libraryError = error.localizedDescription }
    }
    func saveCreatorToLibrary(name: String) {
        guard !effectiveKeys.isEmpty, !isSavingTheme else { return }
        let keys = effectiveKeys
        let version = targetTelephonyVersion, language = passcodeLanguageTarget, bold = passcodeBoldTarget
        let preview = ThemeArtwork.thumbnail(keys)
        isSavingTheme = true; libraryError = nil
        Task {
            defer { isSavingTheme = false }
            do {
                let data = try await Task.detached(priority: .userInitiated) {
                    try PasscodeThemePackager.buildPassthm(keys: keys, telephonyVersion: version, language: language, bold: bold)
                }.value
                themeLibrary = try await themeLibraryStorage.save(data: data, name: name, keyCount: keys.count, thumbnail: preview)
                FrameKitFeedback.result(true)
                successAlertMessage = "Тема сохранена в «Мои темы»."; showSuccessAlert = true
            } catch { libraryError = error.localizedDescription; FrameKitFeedback.result(false) }
        }
    }
    func preflight(_ target: FrameKitApplyTarget) -> PreflightSnapshot {
        var content = false, files = true, partial = false, unsafe = false
        switch target {
        case .themes:
            let keys = passcodeMode == .themeCreator ? effectiveKeys : (loadedTheme?.keysPreview ?? [:])
            content = !keys.isEmpty; partial = content && keys.count < 10
            if passcodeMode == .applyTheme, let theme = loadedTheme { files = FileManager.default.fileExists(atPath: theme.filePath) }
        case .wallpapers:
            let items = tendieItems.filter { $0.isSelected }
            content = !items.isEmpty; files = items.allSatisfy { FileManager.default.fileExists(atPath: $0.fileURL.path) }
            unsafe = items.contains { $0.unsafeContainer }
        case .wallet:
            content = cards.contains { $0.isSelected && ($0.customImage != nil || $0.customImageData != nil) }
        }
        return PreflightSnapshot(wifi: wifiUp, vpn: vpnUp, pairing: hasPairingFile && FileManager.default.fileExists(atPath: PairingController.pairingFilePath()), content: content, files: files, partial: partial, unsafe: unsafe)
    }
    func requestApply(_ target: FrameKitApplyTarget) {
        refreshNetworkStatus(); refreshPairingFile(); requestedApply = target; FrameKitFeedback.selection()
    }
    func confirmApply(_ target: FrameKitApplyTarget) {
        refreshNetworkStatus(); refreshPairingFile()
        guard preflight(target).canApply else { return }
        requestedApply = nil
        switch target {
        case .themes: flashPassthm()
        case .wallet: flashCards()
        case .wallpapers: Task { await flashSelectedTendies() }
        }
    }
}

struct ThemeLibraryView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""
    @State private var favoritesOnly = false
    @State private var rename: SavedTheme?
    @State private var name = ""
    @State private var deleting: SavedTheme?
    private var entries: [SavedTheme] {
        vm.themeLibrary.filter { (!favoritesOnly || $0.favorite) && (search.isEmpty || $0.name.localizedCaseInsensitiveContains(search)) }
    }
    var body: some View {
        List {
            Section {
                Toggle("Только избранное", isOn: $favoritesOnly)
            }
            if let error = vm.libraryError { Section { Text(error).foregroundStyle(.orange).textSelection(.enabled) } }
            if entries.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "square.stack").font(.largeTitle).foregroundStyle(FrameKitStyle.blue)
                        Text(vm.themeLibrary.isEmpty ? "Твои темы — в одном месте" : "Ничего не найдено").font(.headline)
                        Text("Импортированные .passthm сохраняются автоматически. Свои темы можно сохранить из редактора.")
                            .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    }.frame(maxWidth: .infinity).padding(.vertical, 24)
                }
            }
            ForEach(entries) { entry in
                HStack(spacing: 14) {
                    Button {
                        vm.openSavedTheme(entry); dismiss()
                    } label: {
                        HStack(spacing: 14) {
                            if let image = UIImage(contentsOfFile: vm.themeLibraryStorage.thumbnail(entry.id).path) {
                                Image(uiImage: image).resizable().scaledToFit().frame(width: 56, height: 70).clipShape(RoundedRectangle(cornerRadius: 8))
                            } else { Image(systemName: "circle.grid.3x3.fill").frame(width: 56, height: 70) }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.name).font(.headline).foregroundStyle(.primary).lineLimit(2)
                                Text("Кнопок: \(entry.keyCount)").font(.subheadline).foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 0)
                        }.contentShape(Rectangle())
                    }.buttonStyle(.plain).disabled(vm.isImportingTheme)
                    Menu {
                        Button(entry.favorite ? "Убрать из избранного" : "В избранное", systemImage: entry.favorite ? "star.slash" : "star") { Task { await vm.favoriteSavedTheme(entry) } }
                        Button("Переименовать", systemImage: "pencil") { name = entry.name; rename = entry }
                        Button("Удалить из библиотеки", systemImage: "trash", role: .destructive) { deleting = entry }
                    } label: { Image(systemName: entry.favorite ? "star.fill" : "ellipsis.circle").frame(width: 44, height: 44).accessibilityLabel("Действия с темой \(entry.name)") }
                }.padding(.vertical, 4)
            }
        }
        .modifier(FrameKitFormStyle()).navigationTitle("Мои темы")
        .searchable(text: $search, prompt: "Название темы")
        .task { await vm.reloadLibrary() }
        .alert("Название темы", isPresented: Binding(get: { rename != nil }, set: { if !$0 { rename = nil } })) {
            TextField("Название", text: $name)
            Button("Сохранить") { if let entry = rename { Task { await vm.renameSavedTheme(entry, name: name) } }; rename = nil }
            Button("Отмена", role: .cancel) { rename = nil }
        }
        .confirmationDialog("Удалить сохранённую тему?", isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }), titleVisibility: .visible) {
            Button("Удалить", role: .destructive) { if let entry = deleting { Task { await vm.deleteSavedTheme(entry) } }; deleting = nil }
        } message: { Text("Это удалит только копию из библиотеки, не оформление iPhone.") }
    }
}

struct ApplyPreflightSheet: View {
    @EnvironmentObject var vm: AppViewModel
    let target: FrameKitApplyTarget
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(vm.preflight(target).checks) { check in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: check.passed ? "checkmark.circle.fill" : (check.warning ? "exclamationmark.triangle.fill" : "xmark.circle.fill"))
                                .foregroundStyle(check.passed ? Color.green : Color.orange).frame(width: 24)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(check.title).font(.headline)
                                Text(check.detail).font(.subheadline).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                            }
                        }.padding(.vertical, 5)
                    }
                } footer: { Text("Это локальная проверка, не гарантия совместимости iOS. Системная запись может завершиться ошибкой; резервное восстановление не реализовано.") }
                Section {
                    Button("Проверить ещё раз", systemImage: "arrow.clockwise") { vm.refreshNetworkStatus(); vm.refreshPairingFile() }
                    Button("Применить оформление", systemImage: "bolt.fill") { vm.confirmApply(target) }
                        .disabled(!vm.preflight(target).canApply)
                }
            }.modifier(FrameKitFormStyle()).navigationTitle("Перед применением")
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Закрыть") { dismiss() } } }
        }.preferredColorScheme(.dark).tint(FrameKitStyle.blue)
    }
}

struct CreatorAppearanceSection: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var savePrompt = false
    @State private var name = "Моя тема"
    var body: some View {
        Section("Фон и форма кнопок") {
            Picker("Фон", selection: $vm.editorBackground) { ForEach(EditorBackground.allCases) { Text($0.rawValue).tag($0) } }
            VStack(alignment: .leading, spacing: 10) {
                Text("Скругление: \(Int(vm.editorCornerRadius * 200))%").font(.subheadline)
                Slider(value: $vm.editorCornerRadius, in: 0...0.5, step: 0.05).accessibilityLabel("Скругление кнопок")
            }.padding(.vertical, 4)
            Text("Фон виден в прозрачных областях. Скругление обрезает края; исходное изображение не меняется.").font(.footnote).foregroundStyle(.secondary)
            Button("Сбросить оформление") { vm.editorBackground = .original; vm.editorCornerRadius = 0 }
        }
        Section {
            Button { savePrompt = true } label: { Label(vm.isSavingTheme ? "Сохранение…" : "Сохранить в «Мои темы»", systemImage: "square.stack.badge.plus") }
                .disabled(vm.effectiveKeys.isEmpty || vm.isSavingTheme)
            if let error = vm.libraryError { Text(error).font(.footnote).foregroundStyle(.orange) }
        }
        .alert("Сохранить тему", isPresented: $savePrompt) {
            TextField("Название", text: $name)
            Button("Сохранить") { vm.saveCreatorToLibrary(name: name) }
            Button("Отмена", role: .cancel) {}
        }
    }
}

struct OperationStatusView: View {
    let stage: String
    let busy: Bool
    let error: String?
    @State private var copied = false
    var body: some View {
        if !stage.isEmpty || error != nil {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    if busy { ProgressView() }
                    else { Image(systemName: error == nil ? "checkmark.circle" : "exclamationmark.triangle").foregroundStyle(error == nil ? Color.green : Color.orange) }
                    Text(stage).font(.subheadline.weight(.semibold))
                }
                if let error {
                    Text(error).font(.footnote).textSelection(.enabled)
                    Button(copied ? "Скопировано" : "Скопировать ошибку", systemImage: "doc.on.doc") {
                        // Deliberately exclude pairing contents, device identifiers and backend logs.
                        UIPasteboard.general.string = "FrameKit \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "")\niOS \(UIDevice.current.systemVersion)\n\(stage)\n\(error)"
                        copied = true
                    }.font(.subheadline)
                }
            }.padding(.vertical, 6)
        }
    }
}

extension TendieItem {
    var fileSizeLabel: String {
        guard let n = (try? FileManager.default.attributesOfItem(atPath: fileURL.path)[.size]) as? NSNumber else { return "Файл недоступен" }
        return ByteCountFormatter.string(fromByteCount: n.int64Value, countStyle: .file)
    }
    var previewVideoURL: URL? {
        guard let name = previewVideoFileName, name == (name as NSString).lastPathComponent else { return nil }
        let url = WallpaperMoviePreview.directory.appendingPathComponent(name)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }
}

enum WallpaperMoviePreview {
    static var directory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("FrameKit/WallpaperPreviews", isDirectory: true)
    }
    static func extract(from folder: URL) async -> (String?, Data?) {
        let fm = FileManager.default
        let enumerator = fm.enumerator(at: folder, includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey], options: [.skipsHiddenFiles])
        var candidates: [URL] = []
        while let url = enumerator?.nextObject() as? URL {
            if ["mov", "mp4", "m4v"].contains(url.pathExtension.lowercased()) { candidates.append(url) }
        }
        for url in candidates.sorted(by: { $0.path < $1.path }).prefix(8) {
            guard let values = try? url.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey]), values.isRegularFile == true, (values.fileSize ?? 0) <= 200_000_000 else { continue }
            let asset = AVURLAsset(url: url)
            guard (try? await asset.load(.isPlayable)) == true,
                  let tracks = try? await asset.loadTracks(withMediaType: .video), !tracks.isEmpty else { continue }
            do {
                try fm.createDirectory(at: directory, withIntermediateDirectories: true)
                let name = UUID().uuidString + "." + url.pathExtension.lowercased()
                try fm.copyItem(at: url, to: directory.appendingPathComponent(name))
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                generator.maximumSize = CGSize(width: 600, height: 600)
                let cg = try? generator.copyCGImage(at: .zero, actualTime: nil)
                return (name, cg.flatMap { UIImage(cgImage: $0).jpegData(compressionQuality: 0.85) })
            } catch { continue }
        }
        return (nil, nil)
    }
}

struct WallpaperPreviewView: View {
    let item: TendieItem
    @State private var player: AVPlayer?
    var body: some View {
        VStack(spacing: 16) {
            if let player {
                VideoPlayer(player: player).frame(height: 300).clipShape(RoundedRectangle(cornerRadius: 16))
                Button("Закрыть видео", systemImage: "stop.circle") { player.pause(); self.player = nil }
            } else if let image = item.uiPreview {
                Image(uiImage: image).resizable().scaledToFit().frame(maxHeight: 300).clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                Image(systemName: "photo.stack").font(.system(size: 44)).foregroundStyle(.secondary).frame(height: 120)
                Text("Изображение для превью не найдено").font(.subheadline).foregroundStyle(.secondary)
            }
            if let url = item.previewVideoURL, player == nil {
                Button("Посмотреть анимацию", systemImage: "play.circle.fill") {
                    let movie = AVPlayer(url: url); movie.isMuted = true; player = movie; movie.play()
                }
            }
            Text(item.previewVideoURL == nil ? "Статичное превью. В архиве нет поддерживаемого видео для просмотра; системные эффекты здесь не воспроизводятся." : "Видео из архива, без звука. Вид на экране блокировки может отличаться.")
                .font(.footnote).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity).padding(.vertical, 12)
        .onDisappear { player?.pause(); player = nil }
    }
}
