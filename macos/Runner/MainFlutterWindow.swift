import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var pasteChannel: FlutterMethodChannel?
  private var keyMonitor: Any?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    pasteChannel = FlutterMethodChannel(
      name: "clyde/macos_paste",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
      guard let self = self else { return event }
      let mods = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
      let isPlainCmdV =
        mods == .command &&
        (event.keyCode == 9 /* kVK_ANSI_V */ ||
         event.charactersIgnoringModifiers?.lowercased() == "v")
      guard isPlainCmdV else { return event }
      guard self.isKeyWindow else { return event }
      self.pasteChannel?.invokeMethod("paste", arguments: nil)
      return nil
    }

    super.awakeFromNib()
  }

  deinit {
    if let monitor = keyMonitor {
      NSEvent.removeMonitor(monitor)
    }
  }
}
