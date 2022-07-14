import UIKit

class ViewController: UIViewController {
    
    //MARK: - outlets
    @IBOutlet private weak var fotoImageView: UIImageView!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var heartButton: UIButton!
    @IBOutlet private weak var buttonConstraint: NSLayoutConstraint!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var deleteButtonPressed: UIButton!
    @IBOutlet private weak var imageViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var sendButtonPressed: UIButton!
    
    //MARK: - var
    var photoAlbum: [Picture] = []
    var index = 0
    
    //MARK: - life cycle funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadPhotoAlbum()
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setup()
    }
    
    //MARK: - IBActions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.savePicture()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func leftSwipeDetected (_ sender: UISwipeGestureRecognizer) {
        if self.photoAlbum.count > 1 {
            self.moveImageLeft()
        }
    }
    
    @IBAction func rightSwipeDetected (_ sender: UISwipeGestureRecognizer) {
        if self.photoAlbum.count > 1 {
            self.moveImageRight()
        }
    }
    
    @IBAction func heartButtonPressed(_ sender: UIButton) {
        self.photoAlbum[index].heart = !self.photoAlbum[index].heart
        self.setHeartButton()
    }
    
    @IBAction func commentEditingChanged(_ sender: UITextField) {
        self.photoAlbum[index].text = sender.text ?? ""
    }
    
    @IBAction func tapRecognizer(_ sender: UITapGestureRecognizer) {
        self.zoomImage()
        
    }
    @IBAction func removeZoomImage(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
            sender.view?.frame = self.fotoImageView.frame
        } completion: { (_) in
            sender.view?.removeFromSuperview()
        }
    }
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        self.removeIndexArray()
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        let activityItems = [self.fotoImageView.image]
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        present(activityController, animated: true, completion: nil)
    }
    
    //MARK: - flow funcs
    func loadPhotoAlbum() {
        if let photoAlbum = UserDefaults.standard.value([Picture].self, forKey: "photoAlbum") {
            self.photoAlbum = photoAlbum
        }
    }
    
    func loadImage(_ imageView: UIImageView) {
        if let image = self.loadSave(fileName:self.photoAlbum[index].image) {
            imageView.image = image
        }
    }
    
    func loadImageDel(_ imageView: UIImageView) {
        if let image = self.loadSave(fileName:self.photoAlbum[index + 1].image) {
            imageView.image = image
        }
        
    }
    
    func savePicture() {
        UserDefaults.standard.set(encodable: photoAlbum, forKey: "photoAlbum")
    }
}

//MARK: - extension
private extension ViewController {
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        let userInfo = notification.userInfo!
        let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            self.buttonConstraint.constant = 0
            self.imageViewConstraint.constant = 110
        } else {
            self.buttonConstraint.constant = keyboardScreenEndFrame.height - 80
            self.imageViewConstraint.constant = -keyboardScreenEndFrame.height + 190
        }
        
        view.needsUpdateConstraints()
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func nextIndexPicture() {
        if self.index == self.photoAlbum.count - 1 {
            self.index = 0
        } else {
            self.index += 1
        }
    }
    
    func backIndexPicture() {
        if self.index == 0 {
            self.index = self.photoAlbum.count - 1
        } else {
            self.index -= 1
        }
    }
    
    func removeIndexArray () {
        if self.index == self.photoAlbum.count - 1 && self.photoAlbum.count > 1 {
            self.photoAlbum.remove(at: index)
            self.index = 0
            self.loadComment()
            self.loadImage(self.fotoImageView)
            self.setHeartButton()
        }  else if self.photoAlbum.count == 1 {
            self.photoAlbum.remove(at: index)
            self.setup()
        } else {
            self.loadCommentDel()
            self.loadImageDel(self.fotoImageView)
            self.setHeartButtonDel()
            self.photoAlbum.remove(at: index)
        }
    }
    
    func loadComment() {
        self.textField.text = self.photoAlbum[self.index].text
    }
    
    func loadCommentDel() {
        self.textField.text = self.photoAlbum[self.index + 1].text
    }
    
    func createImageView (x: CGFloat) -> UIImageView {
        let newImageView = UIImageView()
        newImageView.frame = CGRect(x: x,
                                    y: 0,
                                    width: self.fotoImageView.frame.size.width ,
                                    height: self.fotoImageView.frame.size.height)
        newImageView.contentMode = .scaleAspectFill
        newImageView.clipsToBounds = true
        self.loadImage(newImageView)
        self.fotoImageView.addSubview(newImageView)
        return newImageView
    }
    
    func animateImage(_ newImageView: UIImageView, finish: CGFloat) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
            newImageView.frame.origin.x -= finish
        } completion: { (_) in
            self.fotoImageView.image = newImageView.image
            newImageView.removeFromSuperview()
        }
    }
    
    func moveImageRight() {
        self.backIndexPicture()
        self.setHeartButton()
        self.loadComment()
        let newImageView = self.createImageView(x: -self.fotoImageView.frame.size.width)
        self.animateImage(newImageView, finish: -self.fotoImageView.frame.size.width)
    }
    
    func moveImageLeft() {
        self.nextIndexPicture()
        self.setHeartButton()
        self.loadComment()
        let newImageView = self.createImageView(x: self.fotoImageView.frame.size.width)
        self.animateImage(newImageView, finish: self.fotoImageView.frame.size.width)
    }
    
    func setup() {
        if self.photoAlbum.count == 0 {
            self.textField.isHidden = true
            self.fotoImageView.isHidden = true
            self.heartButton.isHidden = true
            self.deleteButtonPressed.isHidden = true
            self.sendButtonPressed.isHidden = true
            return
        }
        self.loadImage(self.fotoImageView)
        self.loadComment()
        self.setHeartButton()
        self.setupSwipeSettings()
    }
    
    func zoomImage() {
        let zoomImageView = UIImageView()
        zoomImageView.frame = self.fotoImageView.frame
        zoomImageView.contentMode = .scaleAspectFill
        zoomImageView.image = self.fotoImageView.image
        zoomImageView.isUserInteractionEnabled = true
        self.view.addSubview(zoomImageView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeZoomImage(_:)))
        zoomImageView.addGestureRecognizer(tap)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
            zoomImageView.frame = self.view.frame
        }
    }
    
    func setupSwipeSettings() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapRecognizer(_:)))
        self.fotoImageView.addGestureRecognizer(tap)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipeDetected(_:)))
        leftSwipe.direction = .left
        self.fotoImageView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipeDetected(_:)))
        rightSwipe.direction = .right
        self.fotoImageView.addGestureRecognizer(rightSwipe)
    }
    
    func setHeartButton() {
        if self.photoAlbum[self.index].heart {
            self.heartButton.setBackgroundImage(UIImage(named: "heartfill"), for: .normal)
        } else {
            self.heartButton.setBackgroundImage(UIImage(named: "heart"), for: .normal)
        }
    }
    
    func setHeartButtonDel() {
        if self.photoAlbum[self.index + 1].heart {
            self.heartButton.setBackgroundImage(UIImage(named: "heartfill"), for: .normal)
        } else {
            self.heartButton.setBackgroundImage(UIImage(named: "heart"), for: .normal)
        }
    }
}
