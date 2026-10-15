import XCTest
import UIKit
import SwiftUI
@testable import AirCard_iOS

@MainActor
final class CardPhotoCropTests: XCTestCase {
    func testEditorPortraitAndLandscapeAttachments() async throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let originalKeyWindow = scene.windows.first(where: \.isKeyWindow)
        let controller = UIHostingController(rootView: CardPhotoCropView(image: fixture(), onUse: { _ in }))
        let window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: 0, y: 0, width: 393, height: 852)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        defer {
            window.isHidden = true
            originalKeyWindow?.makeKey()
        }
        for (name, size) in [("Portrait", CGSize(width: 393, height: 852)),
                             ("Landscape", CGSize(width: 852, height: 393))] {
            window.frame.size = size
            controller.view.frame = window.bounds
            window.setNeedsLayout()
            window.layoutIfNeeded()
            try await Task.sleep(nanoseconds: 300_000_000)
            controller.view.layoutIfNeeded()
            XCTAssertEqual(controller.view.bounds.size, size, "The snapshot must use the requested layout size")
            let crop = try XCTUnwrap(findCropCanvas(in: controller.view), "The photo editor must be mounted")
            XCTAssertGreaterThan(crop.bounds.width, 0)
            XCTAssertGreaterThan(crop.bounds.height, 0)
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            var drewHierarchy = false
            let image = UIGraphicsImageRenderer(size: controller.view.bounds.size, format: format).image { _ in
                drewHierarchy = controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
            }
            XCTAssertTrue(drewHierarchy, "The editor screenshot must render successfully")
            // Validate actual photo pixels, so an empty/black snapshot cannot pass.
            let expected: [Pixel] = [.red, .green, .blue, .yellow]
            for (index, point) in [(0.15, 0.15), (0.85, 0.15), (0.15, 0.85), (0.85, 0.85)].enumerated() {
                let location = crop.convert(CGPoint(x: crop.bounds.width * point.0,
                                                     y: crop.bounds.height * point.1), to: controller.view)
                assertPixel(sample(image, x: location.x / controller.view.bounds.width,
                                   y: location.y / controller.view.bounds.height), expected[index])
            }
            let attachment = XCTAttachment(image: image)
            attachment.name = "Photo crop editor - \(name)"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
    }

    private func findCropCanvas(in view: UIView) -> CardPhotoCropScrollView? {
        if let crop = view as? CardPhotoCropScrollView { return crop }
        return view.subviews.lazy.compactMap { self.findCropCanvas(in: $0) }.first
    }

    func testCenterFillRemovesTopAndBottomAndExportsExactCardSize() throws {
        let view = canvas(image: fixture(withEdgeBands: true))
        let output = try XCTUnwrap(view.croppedImage())
        XCTAssertEqual(output.cgImage?.width, 1536)
        XCTAssertEqual(output.cgImage?.height, 969)
        XCTAssertEqual(output.imageOrientation, .up)
        assertQuadrants(output, [.red, .green, .blue, .yellow])
        assertPixel(sample(output, x: 0.15, y: 0.005), .red)
        assertPixel(sample(output, x: 0.85, y: 0.995), .yellow)
        try assertMatchesViewport(view)
    }

    func testZoomAndPanClampAtBothEdgesWithoutBlankPixelsAndResetRestoresCrop() throws {
        let view = canvas(image: fixture())
        view.setRelativeZoom(3)
        view.pan(x: 100, y: 100)
        assertQuadrants(try XCTUnwrap(view.croppedImage()), Array(repeating: .yellow, count: 4))
        try assertMatchesViewport(view)

        view.pan(x: -100, y: -100)
        assertQuadrants(try XCTUnwrap(view.croppedImage()), Array(repeating: .red, count: 4))
        try assertMatchesViewport(view)

        view.resetCrop()
        assertQuadrants(try XCTUnwrap(view.croppedImage()), [.red, .green, .blue, .yellow])
        try assertMatchesViewport(view)
    }

    func testResizingPreservesAnOffCenterZoomedSelection() throws {
        let view = canvas(image: fixture())
        view.setRelativeZoom(2)
        view.pan(x: 0.13, y: 0.19)
        let before = try XCTUnwrap(view.croppedImage())
        view.frame.size = CGSize(width: 480, height: 480 * 969 / 1536)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        let after = try XCTUnwrap(view.croppedImage())
        assertSamplesEqual(before, after)
        try assertMatchesViewport(view)
    }

    func testRotatedAndMirroredImageExportMatchesDisplayedOrientation() throws {
        let source = try XCTUnwrap(fixture().cgImage)
        let cases: [(UIImage.Orientation, [Pixel])] = [
            (.right, [.blue, .red, .yellow, .green]),
            (.upMirrored, [.green, .red, .yellow, .blue])
        ]
        for (orientation, expected) in cases {
            let view = canvas(image: UIImage(cgImage: source, scale: 1, orientation: orientation))
            assertQuadrants(try XCTUnwrap(view.croppedImage()), expected)
            try assertMatchesViewport(view)
        }
    }

    private func canvas(image: UIImage) -> CardPhotoCropScrollView {
        let state = CardPhotoCropState()
        let view = CardPhotoCropScrollView(image: image, editor: state)
        view.frame = CGRect(x: 0, y: 0, width: 384, height: 969 / 4)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        return view
    }

    private func fixture(withEdgeBands: Bool = false) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: 800, height: 800), format: format).image { context in
            for (index, color) in [UIColor.red, .green, .blue, .yellow].enumerated() {
                color.setFill()
                context.fill(CGRect(x: (index % 2) * 400, y: (index / 2) * 400, width: 400, height: 400))
            }
            if withEdgeBands {
                UIColor.black.setFill()
                context.fill(CGRect(x: 0, y: 0, width: 800, height: 80))
                context.fill(CGRect(x: 0, y: 720, width: 800, height: 80))
            }
        }
    }

    private func assertMatchesViewport(_ view: CardPhotoCropScrollView,
                                       file: StaticString = #filePath, line: UInt = #line) throws {
        view.layoutIfNeeded()
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1536 / view.bounds.width
        let preview = UIGraphicsImageRenderer(size: view.bounds.size, format: format).image { context in
            view.layer.render(in: context.cgContext)
        }
        assertSamplesEqual(try XCTUnwrap(view.croppedImage()), preview, file: file, line: line)
    }

    private func assertQuadrants(_ image: UIImage, _ expected: [Pixel],
                                 file: StaticString = #filePath, line: UInt = #line) {
        for (index, point) in [(0.15, 0.15), (0.85, 0.15), (0.15, 0.85), (0.85, 0.85)].enumerated() {
            assertPixel(sample(image, x: point.0, y: point.1), expected[index], file: file, line: line)
        }
    }

    private func assertSamplesEqual(_ first: UIImage, _ second: UIImage,
                                    file: StaticString = #filePath, line: UInt = #line) {
        // The off-center fixture splits at x=0.37 and y=0.31. Compare both
        // sides of those edges, avoiding renderer-specific interpolation at
        // the discontinuity itself (CALayer and UIImage use different filters).
        for x in [0.005, 0.15, 0.365, 0.375, 0.65, 0.85, 0.995] {
            for y in [0.005, 0.15, 0.305, 0.315, 0.65, 0.85, 0.995] {
                assertPixel(sample(first, x: x, y: y), sample(second, x: x, y: y), file: file, line: line)
            }
        }
    }

    private struct Pixel {
        let rgba: [UInt8]
        static let red = Pixel(rgba: [255, 0, 0, 255])
        static let green = Pixel(rgba: [0, 255, 0, 255])
        static let blue = Pixel(rgba: [0, 0, 255, 255])
        static let yellow = Pixel(rgba: [255, 255, 0, 255])
    }

    private func sample(_ image: UIImage, x: Double, y: Double) -> Pixel {
        guard let source = image.cgImage,
              let pixel = source.cropping(to: CGRect(x: Int(Double(source.width - 1) * x),
                                                     y: Int(Double(source.height - 1) * y),
                                                     width: 1, height: 1)) else {
            XCTFail("Could not read a rendered pixel")
            return Pixel(rgba: [0, 0, 0, 0])
        }
        var bytes = [UInt8](repeating: 0, count: 4)
        bytes.withUnsafeMutableBytes { buffer in
            let context = CGContext(data: buffer.baseAddress, width: 1, height: 1,
                                    bitsPerComponent: 8, bytesPerRow: 4,
                                    space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            context.draw(pixel, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        return Pixel(rgba: bytes)
    }

    private func assertPixel(_ actual: Pixel, _ expected: Pixel,
                             file: StaticString = #filePath, line: UInt = #line) {
        for (actualComponent, expectedComponent) in zip(actual.rgba, expected.rgba) {
            XCTAssertEqual(Double(actualComponent), Double(expectedComponent), accuracy: 3,
                           "Rendered pixel differs: \(actual.rgba) vs \(expected.rgba)", file: file, line: line)
        }
    }
}


// Regression: legacy TelephonyUI-8 archives with deflated PNG entries and spaced filenames.
// Uses generated coloured squares, not user-provided artwork.
@MainActor
final class PasscodeThemeImportTests: XCTestCase {
    private func fixtureURL() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".passthm")
        let data = try XCTUnwrap(Data(base64Encoded: "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"))
        try data.write(to: url)
        return url
    }

    func testLegacyDeflatedArchiveDecodesAllTenDigits() throws {
        let url = try fixtureURL()
        defer { try? FileManager.default.removeItem(at: url) }
        let result = try XCTUnwrap(PasscodeThemeReader.inspect(url: url))
        XCTAssertEqual(Set(result.keys.keys), Set((0...9).map(String.init)))
        XCTAssertEqual(result.rawData.count, 10)
        XCTAssertEqual(result.fileCount, 10)
    }

    func testImportKeepsStableCopyAndPublishesLoadedTheme() async throws {
        let source = try fixtureURL()
        defer { try? FileManager.default.removeItem(at: source) }
        let vm = AppViewModel()
        vm.importPasscodeSelection([source])
        let deadline = Date().addingTimeInterval(20)
        while vm.isImportingTheme && Date() < deadline {
            try await Task.sleep(nanoseconds: 50_000_000)
        }
        XCTAssertFalse(vm.isImportingTheme, "Import stalled: " + vm.themeImportStatus)
        XCTAssertNil(vm.themeImportError)
        let theme = try XCTUnwrap(vm.loadedTheme, vm.themeImportError ?? vm.themeImportStatus)
        XCTAssertEqual(theme.keysPreview.count, 10)
        XCTAssertNotEqual(theme.filePath, source.path)
        try FileManager.default.removeItem(at: source)
        XCTAssertTrue(FileManager.default.fileExists(atPath: theme.filePath))
        XCTAssertEqual(vm.passcodeMode, .applyTheme)
        vm.clearLoadedTheme()
        XCTAssertFalse(FileManager.default.fileExists(atPath: theme.filePath))
    }

    func testEmptyOrMultipleSelectionsGiveVisibleErrors() {
        let vm = AppViewModel()
        vm.importPasscodeSelection([])
        XCTAssertNotNil(vm.themeImportError)
        let url = URL(fileURLWithPath: "/tmp/test.passthm")
        vm.importPasscodeSelection([url, url])
        XCTAssertNotNil(vm.themeImportError)
        XCTAssertFalse(vm.isImportingTheme)
    }

    func testDamagedArchiveReportsFailure() async throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".passthm")
        try Data("not a zip".utf8).write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        let vm = AppViewModel()
        vm.loadPassthm(url: url)
        let deadline = Date().addingTimeInterval(20)
        while vm.isImportingTheme && Date() < deadline {
            try await Task.sleep(nanoseconds: 50_000_000)
        }
        XCTAssertFalse(vm.isImportingTheme)
        XCTAssertNotNil(vm.themeImportError)
        XCTAssertNil(vm.loadedTheme)
    }
}

// Real SwiftUI screens mounted in a simulator window, never a web mock-up.
// Synthetic images only; no pairing records, artwork or device secrets.
@MainActor
final class FrameKitDesignSnapshotTests: XCTestCase {
    func testSingleHomeRoutesAndCreatorAtPhoneSize() async throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previous = scene.windows.first(where: \.isKeyWindow)
        let model = AppViewModel()
        let window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: 0, y: 0, width: 393, height: 852)
        window.overrideUserInterfaceStyle = .dark
        defer { window.isHidden = true; previous?.makeKey() }

        let routes: [(String, FrameKitDestination?)] = [
            ("Home", nil), ("Connection", .connection), ("Themes", .themes),
            ("Wallpapers", .wallpapers), ("Wallet", .wallet)
        ]
        for (name, route) in routes {
            let host = mount(route, model: model, window: window)
            try await capture(name, host: host, window: window)
            XCTAssertTrue(descendants(of: UITabBar.self, in: host.view).isEmpty,
                          "The home and work screens must not contain a duplicated tab bar")
            let bars = descendants(of: UINavigationBar.self, in: host.view)
            XCTAssertEqual(bars.count, 1, "Each route must share one navigation stack")
            if route != nil {
                XCTAssertNotNil(bars.first?.backItem, "A work screen must provide native back navigation")
            }
        }

        model.passcodeMode = .themeCreator
        var host = mount(.themes, model: model, window: window)
        try await capture("Theme creator", host: host, window: window)

        let keys = Dictionary(uniqueKeysWithValues: (0...9).map { digit in
            (String(digit), UIGraphicsImageRenderer(size: CGSize(width: 120, height: 120)).image { context in
                UIColor.systemBlue.setFill()
                context.fill(CGRect(x: 0, y: 0, width: 120, height: 120))
                (String(digit) as NSString).draw(at: CGPoint(x: 45, y: 38), withAttributes: [
                    .font: UIFont.systemFont(ofSize: 36, weight: .semibold), .foregroundColor: UIColor.white
                ])
            })
        })
        model.passcodeMode = .applyTheme
        model.loadedTheme = PasscodeThemeInfo(name: "Preview theme", filePath: "", fileCount: 10, keysPreview: keys)
        host = mount(.themes, model: model, window: window)
        try await capture("Imported theme", host: host, window: window)
    }

    private func mount(_ route: FrameKitDestination?, model: AppViewModel, window: UIWindow) -> UIViewController {
        let path: [FrameKitDestination] = route.map { [$0] } ?? []
        let host = UIHostingController(rootView: ContentView(initialPath: path).environmentObject(model))
        window.rootViewController = host
        window.makeKeyAndVisible()
        return host
    }

    private func descendants<T: UIView>(of type: T.Type, in view: UIView) -> [T] {
        var result: [T] = []
        if let match = view as? T { result.append(match) }
        for child in view.subviews { result.append(contentsOf: descendants(of: type, in: child)) }
        return result
    }

    private func capture(_ name: String, host: UIViewController, window: UIWindow) async throws {
        window.setNeedsLayout()
        window.layoutIfNeeded()
        try await Task.sleep(nanoseconds: 900_000_000)
        host.view.layoutIfNeeded()
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        var rendered = false
        let image = UIGraphicsImageRenderer(size: window.bounds.size, format: format).image { _ in
            rendered = window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        XCTAssertTrue(rendered)
        let attachment = XCTAttachment(image: image)
        attachment.name = "FrameKit UI - \(name)"
        attachment.lifetime = .keepAlways
        add(attachment)

        if let scroll = verticalScroll(in: host.view) {
            let originalOffset = scroll.contentOffset
            // Forms lazily estimate offscreen rows; repeat after layout to reach
            // the real bottom, including the final action/diagnostic sections.
            for _ in 0..<4 {
                scroll.layoutIfNeeded()
                let bottom = max(-scroll.adjustedContentInset.top,
                                 scroll.contentSize.height - scroll.bounds.height + scroll.adjustedContentInset.bottom)
                scroll.setContentOffset(CGPoint(x: 0, y: bottom), animated: false)
                try await Task.sleep(nanoseconds: 250_000_000)
            }
            let lower = UIGraphicsImageRenderer(size: window.bounds.size, format: format).image { _ in
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            }
            let lowerAttachment = XCTAttachment(image: lower)
            lowerAttachment.name = "FrameKit UI - \(name) - bottom"
            lowerAttachment.lifetime = .keepAlways
            add(lowerAttachment)
            scroll.setContentOffset(originalOffset, animated: false)
            try await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    private func verticalScroll(in view: UIView) -> UIScrollView? {
        guard !view.isHidden, view.alpha > 0.01 else { return nil }
        if let scroll = view as? UIScrollView,
           scroll.bounds.height > 150,
           scroll.contentSize.height + scroll.adjustedContentInset.top + scroll.adjustedContentInset.bottom > scroll.bounds.height + 8 { return scroll }
        return view.subviews.lazy.compactMap { self.verticalScroll(in: $0) }.first
    }
}
