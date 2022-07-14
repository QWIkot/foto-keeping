import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var customImageView: UIImageView!
    
    func config (with image: UIImage) {
        self.customImageView.image = image
    }
}
