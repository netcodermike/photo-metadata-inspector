import AppKit
import ImageIO
import UniformTypeIdentifiers

func flatten(_ value: Any, prefix: String = "") -> [String] {
    if let dict = value as? [String: Any] { return dict.keys.sorted().flatMap { key in flatten(dict[key]!, prefix: prefix.isEmpty ? key : prefix + "." + key) } }
    if let array = value as? [Any] { return array.enumerated().flatMap { flatten($0.element, prefix: prefix + "[\($0.offset)]") } }
    return [prefix + ": " + String(describing: value)]
}
func inspect(_ url: URL) throws -> String {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil), let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else { throw NSError(domain: "Unreadable image or metadata", code: 1) }
    return "File: \(url.lastPathComponent)\nImages in container: \(CGImageSourceGetCount(source))\n\n" + flatten(properties).joined(separator: "\n")
}
@MainActor final class Delegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    let files = NSPopUpButton()
    let text = NSTextView()
    let filter = NSSearchField()
    var reports: [(URL, String)] = []
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        let main = NSMenu(); let appItem = NSMenuItem(); main.addItem(appItem); let appMenu = NSMenu(); appMenu.addItem(withTitle: "Quit Photo Metadata", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"); appItem.submenu = appMenu; NSApp.mainMenu = main
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1000, height: 720), styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false); window.title = "Photo Metadata Inspector"; window.isReleasedWhenClosed = false
        let root = NSView(); window.contentView = root
        let open = NSButton(title: "Open images…", target: self, action: #selector(pick)); let export = NSButton(title: "Export full report…", target: self, action: #selector(save))
        let help = NSTextField(labelWithString: "Metadata may include GPS coordinates and identifying details. Export only what you intend to share.")
        let row = NSStackView(views: [open, files, filter, export]); row.orientation = .horizontal; row.spacing = 10
        files.target = self; files.action = #selector(draw); files.widthAnchor.constraint(equalToConstant: 240).isActive = true
        filter.placeholderString = "Filter metadata"; filter.target = self; filter.action = #selector(draw)
        text.isEditable = false; text.isSelectable = true; text.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        let scroll = NSScrollView(); scroll.documentView = text; scroll.hasVerticalScroller = true; text.isVerticallyResizable = true; text.autoresizingMask = [.width]; text.textContainer?.widthTracksTextView = true
        for view in [row, help, scroll] as [NSView] { view.translatesAutoresizingMaskIntoConstraints = false; root.addSubview(view) }
        NSLayoutConstraint.activate([row.topAnchor.constraint(equalTo: root.topAnchor, constant: 20), row.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 20), row.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -20), help.topAnchor.constraint(equalTo: row.bottomAnchor, constant: 14), help.leadingAnchor.constraint(equalTo: row.leadingAnchor), scroll.topAnchor.constraint(equalTo: help.bottomAnchor, constant: 14), scroll.leadingAnchor.constraint(equalTo: row.leadingAnchor), scroll.trailingAnchor.constraint(equalTo: row.trailingAnchor), scroll.bottomAnchor.constraint(equalTo: root.bottomAnchor, constant: -20)])
        text.string = "Choose one or more image files. Inspection is read-only and local."; window.center(); window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true)
    }
    @objc func pick() {
        let panel = NSOpenPanel(); panel.allowedContentTypes = [.image]; panel.allowsMultipleSelection = true; panel.canChooseDirectories = false
        guard panel.runModal() == .OK else { return }
        var next: [(URL, String)] = []
        for url in panel.urls.prefix(100) { do { next.append((url, try inspect(url))) } catch { next.append((url, "Read failed: \(error.localizedDescription)")) } }
        reports = next; files.removeAllItems(); files.addItems(withTitles: reports.map { $0.0.lastPathComponent }); draw()
    }
    @objc func draw() {
        guard reports.indices.contains(files.indexOfSelectedItem) else { return }
        let report = reports[files.indexOfSelectedItem].1
        text.string = filter.stringValue.isEmpty ? report : report.components(separatedBy: "\n").filter { $0.localizedCaseInsensitiveContains(filter.stringValue) }.joined(separator: "\n")
    }
    @objc func save() {
        guard reports.indices.contains(files.indexOfSelectedItem) else { return }
        let panel = NSSavePanel(); panel.nameFieldStringValue = "metadata.txt"; panel.allowedContentTypes = [.plainText]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do { try reports[files.indexOfSelectedItem].1.write(to: url, atomically: true, encoding: .utf8) } catch { let alert = NSAlert(error: error); alert.runModal() }
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}
@main struct PhotoMetadata {
    @MainActor static func main() throws {
        if CommandLine.arguments.contains("--self-test") {
            let rows = flatten(["Exif": ["ISO": 200], "Size": [10, 20]] as [String: Any]); precondition(rows.contains("Exif.ISO: 200") && rows.contains("Size[1]: 20"))
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".png"); defer { try? FileManager.default.removeItem(at: url) }
            let context = CGContext(data: nil, width: 3, height: 2, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            context.setFillColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1)); context.fill(CGRect(x: 0, y: 0, width: 3, height: 2))
            let image = context.makeImage()!; let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
            CGImageDestinationAddImage(destination, image, nil); precondition(CGImageDestinationFinalize(destination))
            let report = try inspect(url); precondition(report.contains("PixelWidth:") && report.contains("PixelHeight:")); print("Metadata flattening and real PNG inspection passed"); return
        }
        let app = NSApplication.shared; let delegate = Delegate(); app.delegate = delegate; app.run()
    }
}
