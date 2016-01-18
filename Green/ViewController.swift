import UIKit
import AudioToolbox
import GPUImage
import AssetsLibrary
import FBSDKMessengerShareKit

class ViewController: UIViewController, UIGestureRecognizerDelegate{
    var videoCamera:GPUImageVideoCamera?
    var filter:GPUImageChromaKeyBlendFilter?
    var pathToMovie: String!
    var effectSlider: float_t!
    var savedImage: UIImage!
    
    @IBOutlet weak var gpuImage: GPUImageView!
    var backgroundMovie: GPUImageMovie!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resumeActivities", name: UIApplicationDidBecomeActiveNotification, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopActivities", name: UIApplicationWillResignActiveNotification, object: nil);
        
        effectSlider = 0.4
        pathToMovie = ""
        
        self.view.backgroundColor = UIColor.whiteColor()
        gpuImage.backgroundColor = UIColor.whiteColor()

        if let resourceUrl = NSBundle.mainBundle().URLForResource("do", withExtension: "mp4") {
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
        
        // Setup camera processing
        setupCamera()
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
    
    // Called on start
    func setupCamera(){
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
        
        savedImage = image
        
        print("PIC TAKEN")
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}