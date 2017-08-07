//
//  ViewController.swift
//  CoreMLVisionApp
//
//  Created by Steve Kerney on 8/7/17.
//  Copyright © 2017 d4rkz3r0. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    //MARK: IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageResultTextLabel: UILabel!
    

    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        imageView.image = #imageLiteral(resourceName: "fatCat");
        
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
}

//MARK: Protocol Conformance
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        dismiss(animated: true, completion: nil);
        
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { fatalError("Unable to load selected image."); }
        
        imageView.image = selectedImage;
    }
}
