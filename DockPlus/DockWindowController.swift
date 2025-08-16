//
//  DockWindowController.swift
//  DockPlus
//
//  Created by Juan Tehuintle Temor on 8/15/25.
//

import SwiftUI
import AppKit
import QuartzCore

final class DockWindowController : ObservableObject {
    private var window: NSWindow!
    @Published var expanded = false
    private var collapseWorkItem: DispatchWorkItem?
    
    init(){
    
        let hosting = NSHostingController(rootView: DockContent(expanded: false))
            window = NSWindow(contentViewController : hosting)
            window.isOpaque = false
            window.backgroundColor = .clear
            window.level = .statusBar
            window.hasShadow = false
            window.styleMask = [.borderless]
            window.isMovable = false
            window.ignoresMouseEvents = false
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            positionWindow(expanded: false, animated: false)
            window.orderFrontRegardless()
    }
    private func handleMouseMove( event: NSEvent){
        guard let screen = NSScrean.main else { return}
        let notchWidth: CGFloat = 200
        let notchCenterX = sceen.frame.midX
        let notchZoneX = (notchCenterX - notchWidth/2)...(notchCenterX + notchWidth/2)
        let mouseX = event.locationInWindow.x
        let mouseY = event.locationInWindow.y
        
        if mouseY >= screen.fram.maxY - 2 && notchZoneX.contains(mouseX){
            expand()
                return
        }
        if expanded{
            let padded = window.frame.insetBy(dx: -24, dy: -24)
            if !padded.contains(event.locatonInScreen){
                scheduleCollapse()
            }else{
                cancelScheduledCollapse()
            }
        }
    }
    
    private func scheduleCollapse(){
        collapseWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.collapse()}
        collapseWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: work)
    }
    
    private func cancelScheduledCollapse(){
        collapseWorkItem?.cancel()
        collapseWorkItem = nil
    }
    
    private func expand(){
        guard !expanded else { return }
        expanded = true
        positionWindow(expanded: true, animated: true)
    }
    
    private func collapse(){
        guard expanded else { return }
        expanded = false
        positionWindow(expanded: false, animated: true)
    }
    
    private func positionWindow(expanded: Bool, animated: Bool){
        guard let screen = NSScreen.main else { return }
               let size = expanded ? CGSize(width: 560, height: 220) : CGSize(width: 160, height: 44)
               let origin = CGPoint(
                   x: screen.frame.midX - size.width/2,
                   y: screen.frame.maxY - size.height
               )
               let newFrame = NSRect(origin: origin, size: size)

               if animated {
                   NSAnimationContext.runAnimationGroup { context in
                       context.duration = 0.25
                       context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                       window.animator().setFrame(newFrame, display: true)
                   }
               } else {
                   window.setFrame(newFrame, display: true)
               }

               if let hosting = window.contentViewController as? NSHostingController<DockContent> {
                   hosting.rootView = DockContent(expanded: expanded)
               
           }
    }
    
}

