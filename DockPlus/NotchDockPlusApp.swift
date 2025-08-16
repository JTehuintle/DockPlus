//
//  NotchDockPlusApp.swift
//  DockPlus
//
//  Created by Juan Tehuintle Temor on 8/15/25.
//

import SwiftUI
import AppKit

@main
struct NotchDockPlusApp: App {
    @StateObject private var dockController = DockWindowController()
    @StateObject private var hotKeys = HotKeyManager.shared
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    
    var body: some Scene {
        Settings{
            SettingsView(launchAtLogin : $launchAtLogin)
                .freame(width: 380)
                .onChanged(of: launchAtLogin){
                    new in LoginItemManager.setEnabled(new)
                }
        }
        .commands{
            CommandGroup(replacing: .appSettings){}
        }
        .onAppear{
            dockController.startMouseTracking()
            hotKeys.registerDefaults()
        }
    }
}
