//
//  ViewController.swift
//  CoreMLVisionApp
//
//  Created by Steve Kerney on 8/7/17.
//  Copyright © 2017 d4rkz3r0. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController
{
    //MARK: IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageResultTextLabel: UILabel!
    

    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        imageView.image = #imageLiteral(resourceName: "fatCat");
        guard let vImage = imageView.image else { print("UIImageView has no image set."); return; }
        guard let ciImage = CIImage(image: vImage) else { fatalError("UIImage from CIImage conversion failed."); }
        detectObject(image: ciImage);
    }
    
    //MARK: IBActions
    @IBAction func useCameraButtonPressed(_ sender: Any)
    {
        let pickerController = UIImagePickerController();
        pickerController.delegate = self;
        pickerController.sourceType = .camera;
        present(pickerController, animated: true);
    }
    
    
    @IBAction func usePhotoLibraryButtonPressed(_ sender: Any)
    {
        let pickerController = UIImagePickerController();
        pickerController.delegate = self;
        pickerController.sourceType = .savedPhotosAlbum;
        present(pickerController, animated: true);
    }
    
    //MARK: Helper Methods
    private func detectObject(image: CIImage)
    {
        imageResultTextLabel.text = "Detecting Object...";
        
        //Load Model
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else { fatalError("Unable to load Inceptionv3 Model."); }
        
        let vowels: [Character] = ["a", "e", "i", "o", "u"]
        
        //Create Vision Request
        let visionRequest = VNCoreMLRequest(model: model) { [weak self] (request, error) in
            
            //Parse Results
            guard let results = request.results as? [VNClassificationObservation], let bestResult = results.first else { fatalError("Unexpected result type."); }

            let nextBestResult = results[1];

            DispatchQueue.main.async { [weak self] in
                
                //1st Result
                //Object Name & Accuracy
                let bestIdentifier = bestResult.identifier;
                let bestConfidence = Int(bestResult.confidence * 100);
                let bestObjectArticle = (vowels.contains(bestResult.identifier.first!)) ? "an" : "a";
                self?.imageResultTextLabel.text = "It's \(bestObjectArticle) \(bestIdentifier) with \(bestConfidence)% confidence.";
                
                //2nd Result
                let nextBestIdentifier = nextBestResult.identifier;
                let nextBestConfidence = Int(nextBestResult.confidence * 100);
                let nextBestObjectArticle = (vowels.contains(nextBestResult.identifier.first!)) ? "an" : "a";
                self?.imageResultTextLabel.text?.append("\nOR\nIt's \(nextBestObjectArticle) \(nextBestIdentifier) with \(nextBestConfidence)% confidence.");
            }
        }
        
        let imageRequestHandler = VNImageRequestHandler(ciImage: image)
        
        //Fire off the request.
        DispatchQueue.global(qos: .userInteractive).async
            {
                    do
                    {
                        try imageRequestHandler.perform([visionRequest]);
                    } catch { print(error.localizedDescription); }
            }
    }
}

//MARK: Protocol Conformance
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        dismiss(animated: true, completion: nil);
        
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { fatalError("Unable to load selected image."); }
        
        imageView.image = selectedImage;
        
        guard let ciImage = CIImage(image: selectedImage) else { fatalError("UIImage from CIImage failed."); }
        detectObject(image: ciImage);
    }
}
