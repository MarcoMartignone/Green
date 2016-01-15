import UIKit
import GPUImage
import AssetsLibrary

class ViewController: UIViewController {
    var videoCamera:GPUImageVideoCamera?
    var filter:GPUImageChromaKeyBlendFilter?
    var pathToMovie: String!
    var effectSlider: float_t!
    
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
        
        if let resourceUrl = NSBundle.mainBundle().URLForResource("small", withExtension: "mp4") {
            print(resourceUrl)
            if NSFileManager.defaultManager().fileExistsAtPath(resourceUrl.path!) {
                backgroundMovie = GPUImageMovie.init(URL: resourceUrl)
                backgroundMovie.shouldRepeat = true
            }
        }
        
        // Setup camera processing
        setupCamera()
    }
    
    //Resume Processing
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
        
        videoCamera!.outputImageOrientation = .LandscapeRight;
        
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}