import UIKit

class FotoViewController: UIViewController {
    //MARK: - outlets
    @IBOutlet private weak var collectionView: UICollectionView!
    
    //MARK: - var
    var photoAlbum: [Picture] = []
    var index = 0
    
    //MARK: - life cycle funcs
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            self.loadPhotoAlbum()
        self.collectionView.reloadData()
    }
    
    //MARK: - IBActions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func imagePickerButtonPressed(_ sender: UIButton) {
        self.loadPhotoAlbum()
        self.performImagePicker()
    }
    
    //MARK: - flow funcs
    private func performImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .overFullScreen
//        imagePicker.allowsEditing = true
        
        let alert = UIAlertController(title: nil, message: "Image source", preferredStyle: .actionSheet)
        let cameraActon = UIAlertAction(title: "Camera", style: .default) { UIAlertAction in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: .default) { UIAlertAction in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        let canselAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cameraActon)
        alert.addAction(gallaryAction)
        alert.addAction(canselAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func navigation() {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController else {
            return
        }
        controller.index = self.index
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func loadPhotoAlbum() {
        if let photoAlbum = UserDefaults.standard.value([Picture].self, forKey: "photoAlbum") {
            self.photoAlbum = photoAlbum
        }
    }
}

//MARK: - extension
extension FotoViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var  chosenImage = UIImage()
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            chosenImage = image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            chosenImage = image
        }
        if let name = self.saveImage(image: chosenImage) {
            let picture = Picture(image: name, text: "", heart: true)
            self.photoAlbum.append(picture)
            self.collectionView.reloadData()
            
            UserDefaults.standard.set(encodable: photoAlbum, forKey: "photoAlbum")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension FotoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photoAlbum.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as? CustomCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.config(with: self.loadSave(fileName: self.photoAlbum[indexPath.item].image) ?? UIImage())
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = collectionView.frame.width / 3 - 5
        return CGSize(width: side, height: side)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        self.index = indexPath.item
        self.navigation()
    }
}

