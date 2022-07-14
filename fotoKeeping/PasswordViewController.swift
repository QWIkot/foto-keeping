import UIKit
import SwiftyKeychainKit

class PasswordViewController: UIViewController {
    
    //MARK: - outlets
    @IBOutlet private weak var passWordTextField: UITextField!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var viewTextField: UIView!
    
    //MARK: - let
    let keychain = Keychain(service: "keychain")
    let accesTokenKey = KeychainKey<String>(key: "accesToken")
    
    //MARK: - var
    var password: String?
    
    //MARK: - life cycle funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        self.recognizer()
        self.loadPassword()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewTextField.radius()
        self.menuImageView()
    }
    
    //MARK: - IBActions
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        self.entryConditionsLogin()
        self.passWordTextField.text = ""
    }
    
    @IBAction func changeButtonPressed(_ sender: UIButton) {
        self.alertChange()
    }
    
    @IBAction func tapRecognizer(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    //MARK: - flow funcs
    func navigation () {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "FotoViewController") as? FotoViewController else {
            return
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func loadPassword() {
        let value = try? keychain.get(self.accesTokenKey)
        self.password = value
    }
}

//MARK: - extension
extension UIView {
    func radius (_ radius: Int = 10) {
        self.layer.cornerRadius = CGFloat(radius)
    }
}

private extension PasswordViewController {
    func entryConditionsLogin() {
        if self.password == nil {
            self.alertRegistration()
        } else if self.password == self.passWordTextField.text {
            self.navigation()
        } else if self.password != self.passWordTextField.text {
            self.alertError()
            print(self.index)
        }
    }
    
    func recognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapRecognizer(_:)))
        self.view.addGestureRecognizer(recognizer)
    }
    
    func menuImageView() {
        let image = UIImage(named: "menu")
        self.imageView.image = image
    }
    
    func alertRegistration () {
        let alert = UIAlertController(title: "Login", message: "Create a password", preferredStyle: .alert)
        
        alert.addTextField { (passWordField) in
            passWordField.placeholder = "Password"
            passWordField.isSecureTextEntry = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        let action = UIAlertAction(title: "OK", style: .default, handler: { [self, weak alert] (_) in
            guard let passWordField = alert?.textFields?[0] else {
                print("Issue with Alert TextFields")
                return
            }
            guard let passWord = passWordField.text else {
                print("Issue with TextFields Text")
                return
            }
            if passWord == "" {
                self.enterPassword()
            } else {
                try? keychain.set(passWord, for: self.accesTokenKey)
                self.loadPassword()
            }
        })
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertChange() {
        let alert = UIAlertController(title: "Login", message: "Change password", preferredStyle: .alert)
        
        alert.addTextField { currentPassword in
            currentPassword.placeholder = "Current password"
            currentPassword.isSecureTextEntry = true
        }
        alert.addTextField { newPassword in
            newPassword.placeholder = "Enter new password"
            newPassword.isSecureTextEntry = true
        }
        alert.addTextField { confirmPassword in
            confirmPassword.placeholder = "Confirm password"
            confirmPassword.isSecureTextEntry = true
        }
        
        let canselAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let action = UIAlertAction(title: "Ok", style: .default) { [self, weak alert] (_) in
            guard let currentPassword = alert?.textFields?[0] else {
                return
            }
            guard let newPassword = alert?.textFields?[1] else {
                return
            }
            guard let confirmPassword = alert?.textFields?[2] else {
                return
            }
            guard let current = currentPassword.text else {
                return
            }
            guard let new = newPassword.text else {
                return
            }
            guard let confirm = confirmPassword.text else {
                return
            }
            if current != self.password {
                self.incorrectCurrentPassword()
            } else if current == self.password && new == "" {
                self.enterNewPassword()
            } else if confirm == "" {
                self.enterConfirmPassword()
            } else if current == self.password && new != confirm {
                self.incorrectConfirmPassword()
            } else {
                
                try? keychain.set(new, for: self.accesTokenKey)
                self.loadPassword()
            }
        }
        alert.addAction(canselAction)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func alertError () {
        let alert = UIAlertController(title: "Error", message: "wrong password", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func incorrectCurrentPassword() {
        let alert = UIAlertController(title: "Error", message: "Incorrect current password", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func incorrectConfirmPassword() {
        let alert = UIAlertController(title: "Error", message: "Incorrect confirm password", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func enterPassword() {
        let alert = UIAlertController(title: "Error", message: "Enter password", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func enterNewPassword() {
        let alert = UIAlertController(title: "Error", message: "Enter new password", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func enterConfirmPassword() {
        let alert = UIAlertController(title: "Error", message: "Enter confirm password", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
