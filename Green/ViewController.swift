import UIKit
import AudioToolbox
import GPUImage
import AssetsLibrary
import FBSDKMessengerShareKit
import QuartzCore

class ViewController: UIViewController, UIGestureRecognizerDelegate{
    var videoCamera:GPUImageVideoCamera?
    var filter:GPUImageChromaKeyBlendFilter?
    var effectSlider: float_t!
    var savedImage: UIImage!
    var backgroundMovie: GPUImageMovie!
    @IBOutlet weak var gpuImage: GPUImageView!
    @IBOutlet var borderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resumeActivities", name: UIApplicationDidBecomeActiveNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopActivities", name: UIApplicationWillResignActiveNotification, object: nil);
        
        effectSlider = 0.4
        
        self.view.backgroundColor = UIColor.redColor()
        gpuImage.backgroundColor = UIColor.clearColor()

        if let resourceUrl = NSBundle.mainBundle().URLForResource("galaxy", withExtension: "mp4") {
            print(resourceUrl)
            if NSFileManager.defaultManager().fileExistsAtPath(resourceUrl.path!) {
                backgroundMovie = GPUImageMovie.init(URL: resourceUrl)
                backgroundMovie.shouldRepeat = true
            }
        }
        
        // Setup view tappable area
        let tap = UITapGestureRecognizer(target: self, action: "takePhoto")
        tap.numberOfTapsRequired = 1;
        gpuImage.addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: "switchCamera")
        doubleTap.numberOfTapsRequired = 2
        gpuImage.addGestureRecognizer(doubleTap)
        tap.requireGestureRecognizerToFail(doubleTap)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: "sharePhoto")
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        gpuImage.addGestureRecognizer(swipeUp)
        
        // Setup borderView
        borderView.backgroundColor = UIColor.clearColor()
        borderView.layer.borderColor = UIColor.whiteColor().CGColor
        borderView.layer.borderWidth = 8
        borderView.alpha = 0;

        // Setup camera processing
        setupCamera()
    }
        
    // Called on start
    func setupCamera() {
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: .Back)
        
        videoCamera!.outputImageOrientation = .Portrait;
        
        //Create the filter
        filter = GPUImageChromaKeyBlendFilter()
        
        //Set the color and threshold for filter
        filter?.setColorToReplaceRed(0.0, green: 1.0, blue: 0.0)
        filter?.thresholdSensitivity = CGFloat(effectSlider)
        
        //Add the sources to the filter
        videoCamera?.addTarget(filter)
        backgroundMovie.addTarget(filter)
        
        //Start showing filter output on view
        filter?.addTarget(gpuImage)
    }
    
    func captureThis() {
        let image = (filter?.imageFromCurrentFramebuffer())!
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        flashBorderView()
        
        savedImage = image
    }
    
    func takePhoto() {
        filter?.useNextFrameForImageCapture()
        self.captureThis()
    }
    
    func switchCamera() {
        videoCamera!.rotateCamera()
    }
    
    func sharePhoto() {
        if (savedImage != nil) {
            FBSDKMessengerSharer.shareImage(savedImage, withOptions: nil)
        }
    }
    
    // Resume Processing
    func resumeActivities() {
        videoCamera?.startCameraCapture()
        backgroundMovie.startProcessing()
    }
    
    // Suspend processing
    func stopActivities() {
        videoCamera!.stopCameraCapture()
        backgroundMovie.endProcessing()
    }
    
    func flashBorderView() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.borderView.alpha = 1
            }) { (Bool) -> Void in
                self.borderView.alpha = 0;
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}