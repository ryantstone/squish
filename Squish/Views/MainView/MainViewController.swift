import Cocoa

class MainViewController: NSViewController {
    lazy var importerViewController = ImporterViewController.init(nibName: "ImporterViewController", bundle: nil)
    lazy var metadataViewController = MetadataView.init(nibName: "MetadataView", bundle: nil)
    var files = [URL]()
    var fileData: FileData!
    var mp3Joiner: MP3Joiner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadView(importerViewController)
        importerViewController.delegate = self
        metadataViewController.delegate = self
    }
    
    func loadView(_ viewController: NSViewController) {
//        if let window = view.window where window.styleMask.rawValue & NSFullScreenWindowMask.rawValue > 0 {
//        viewController.view.frame = CGRect(x: view.window?.frame.origin.x ?? 0, y: view.window?.frame.origin.y ?? 0, width: view.window?.frame.width ?? 0, height: view.window?.frame.height ?? 0)
//        }
        present(viewController, animator: MyTransitionAnimator())
//                view.window?.contentViewController = viewController
        //        addChild(viewController)
        //        view = viewController.view
    }
}

extension MainViewController: ImporterViewControllerDelegate {
    func didReceiveFiles(_ files: [URL]) {
        self.files = files
        loadView(metadataViewController)
    }
}

extension MainViewController: MetadataViewDelegate {
    func didTapExport(metadata: MetadataViewModel) {
        fileData            = FileData(files: files, metaData: metadata)
        mp3Joiner           = MP3Joiner(fileData)
        mp3Joiner.delegate  = self
        mp3Joiner.perform()
    }
}

extension MainViewController: Mp3JoinerDelegate {
    func didProgress(_ progress: Int) {
        print("Progress: \(progress)%")
    }
    
    func didFinish(joinedFileURL: URL) {
        print(joinedFileURL)
    }
}


class MyTransitionAnimator: NSObject, NSViewControllerPresentationAnimator {
    func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
        let bottomVC = fromViewController
        let topVC = viewController
        
        // make sure the view has a CA layer for smooth animation
        topVC.view.wantsLayer = true
        
        // set redraw policy
        topVC.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        
        // start out invisible
        topVC.view.alphaValue = 0
        
        // add view of presented viewcontroller
        bottomVC.view.addSubview(topVC.view)
        
        // adjust size
        topVC.view.frame = bottomVC.view.frame
        
        // Do some CoreAnimation stuff to present view
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            
            // fade duration
            context.duration = 2
            // animate to alpha 1
            topVC.view.animator().alphaValue = 1
           
//            bottomVC.view.animator().alphaValue = 0
        }, completionHandler: nil)
        
    }
    

    func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
        let bottomVC = fromViewController
        let topVC = viewController
        
        // make sure the view has a CA layer for smooth animation
        topVC.view.wantsLayer = true
        
        // set redraw policy
        topVC.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
        
        // Do some CoreAnimation stuff to present view
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            
            // fade duration
            context.duration = 2
            // animate view to alpha 0
            topVC.view.animator().alphaValue = 0
            
        }, completionHandler: {
            
            // remove view
            topVC.view.removeFromSuperview()
        })
        
    }
}
