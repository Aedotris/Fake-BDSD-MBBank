import UIKit
import UserNotifications
import SafariServices
import AudioToolbox

class ViewController: UIViewController, UITextFieldDelegate {

    let accountTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 1.1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 10
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Số tài khoản"
        return textField
    }()
    let amountTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 1.1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 10
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Số tiền giao dịch"
        return textField
    }()
    let timeTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 1.1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 10
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Thời gian giao dịch"
        return textField
    }()
    let balanceTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 1.1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 10
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Số dư"
        return textField
    }()
    let descriptionTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 1.1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 10
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Nội dung"
        return textField
    }()
    let scheduleNotificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Thực hiện", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .large)
        activity.color = .black
        activity.translatesAutoresizingMaskIntoConstraints = false
        return activity
    }()

    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.locale = Locale(identifier: "vi_VN")
        return picker
    }()

    let datePickerContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let topSpacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let bottomSpacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let transactionTypeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Nhận tiền", "Trừ tiền"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        segmentedControl.backgroundColor = .clear
        return segmentedControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupLoadingView()

        showLoading()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hideLoading()
            self.setupUI()
            self.checkNotificationPermission()
            UNUserNotificationCenter.current().delegate = self

            self.animateViewsAfterLoading()
        }
    }

    func setupUI() {
        let labels = ["Số tài khoản", "Số tiền giao dịch", "Thời gian giao dịch", "Số dư", "Nội dung"]
        let textFields = [accountTextField, amountTextField, timeTextField, balanceTextField, descriptionTextField]

        for (index, labelText) in labels.enumerated() {
            let label = UILabel()
            label.text = labelText
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.textColor = .black
            label.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(label)

            let textField = textFields[index]
            stackView.addArrangedSubview(textField)

            NSLayoutConstraint.activate([
                textField.heightAnchor.constraint(equalToConstant: 40)
            ])

            textField.delegate = self
            let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Xong", style: .done, target: self, action: #selector(doneButtonTapped))
            toolBar.setItems([flexibleSpace, doneButton], animated: false)
            textField.inputAccessoryView = toolBar

            textField.transform = CGAffineTransform(translationX: view.frame.width, y: 0)
        }

        stackView.addArrangedSubview(scheduleNotificationButton)
        scheduleNotificationButton.addTarget(self, action: #selector(scheduleNotification), for: .touchUpInside)

        datePickerContainer.addSubview(topSpacerView)
        datePickerContainer.addSubview(datePicker)
        datePickerContainer.addSubview(bottomSpacerView)

        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: datePickerContainer.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: datePickerContainer.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            topSpacerView.topAnchor.constraint(equalTo: datePickerContainer.topAnchor),
            topSpacerView.leadingAnchor.constraint(equalTo: datePickerContainer.leadingAnchor),
            topSpacerView.trailingAnchor.constraint(equalTo: datePickerContainer.trailingAnchor),
            topSpacerView.bottomAnchor.constraint(equalTo: datePicker.topAnchor),
            topSpacerView.heightAnchor.constraint(equalTo: datePickerContainer.heightAnchor, multiplier: 0.25)
        ])

        NSLayoutConstraint.activate([
            bottomSpacerView.topAnchor.constraint(equalTo: datePicker.bottomAnchor),
            bottomSpacerView.leadingAnchor.constraint(equalTo: datePickerContainer.leadingAnchor),
            bottomSpacerView.trailingAnchor.constraint(equalTo: datePickerContainer.trailingAnchor),
            bottomSpacerView.bottomAnchor.constraint(equalTo: datePickerContainer.bottomAnchor),
            bottomSpacerView.heightAnchor.constraint(equalTo: datePickerContainer.heightAnchor, multiplier: 0.25)
        ])

        timeTextField.inputView = datePickerContainer

        let toolBarForDatePicker = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        let flexibleSpaceForDatePicker = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButtonForDatePicker = UIBarButtonItem(title: "Xong", style: .done, target: self, action: #selector(donePressed))
        toolBarForDatePicker.setItems([flexibleSpaceForDatePicker, doneButtonForDatePicker], animated: false)
        timeTextField.inputAccessoryView = toolBarForDatePicker

        stackView.addArrangedSubview(transactionTypeSegmentedControl)

        NSLayoutConstraint.activate([
            transactionTypeSegmentedControl.heightAnchor.constraint(equalToConstant: 35)
        ])

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            datePickerContainer.heightAnchor.constraint(equalToConstant: view.frame.height / 2),

            scheduleNotificationButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        stackView.transform = CGAffineTransform(translationX: 0, y: -stackView.frame.height)

        scheduleNotificationButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        scheduleNotificationButton.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
        scheduleNotificationButton.addTarget(self, action: #selector(buttonTouchUpOutside), for: .touchUpOutside)

        accountTextField.delegate = self
        accountTextField.keyboardType = .numberPad

        amountTextField.delegate = self
        amountTextField.keyboardType = .decimalPad

        balanceTextField.delegate = self
        balanceTextField.keyboardType = .decimalPad
    }

    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                print("Quyền thông báo đã được cấp trước đó!")
            } else {
                print("Quyền thông báo chưa được cấp. Yêu cầu quyền thông báo từ người dùng.")
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("Quyền thông báo đã được cấp sau khi yêu cầu!")
                    } else if let error = error {
                        print("Lỗi khi yêu cầu quyền thông báo: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    @objc func scheduleNotification() {
        let account = accountTextField.text ?? ""
        let amount = amountTextField.text ?? ""
        let time = timeTextField.text ?? ""
        let balance = balanceTextField.text ?? ""
        let description = descriptionTextField.text ?? ""

        if account.isEmpty || amount.isEmpty || time.isEmpty || balance.isEmpty || description.isEmpty {
            showAlert(message: "Vui lòng nhập đầy đủ thông tin!")
            return
        }

        let maskedAccount = maskAccountNumber(account: account)

        let transactionType = transactionTypeSegmentedControl.selectedSegmentIndex

        let notificationTitle = "Thông báo biến động số dư"
        let notificationMessage: String

        if transactionType == 0 { // Nhận tiền
            notificationMessage = "TK \(maskedAccount)|GD: +\(amount)VND \(timeTextField.text ?? "") |SD: \(balance)VND|ND: \(description)"
        } else { // Trừ tiền
            notificationMessage = "TK \(maskedAccount)|GD: -\(amount)VND \(timeTextField.text ?? "") |SD: \(balance)VND|ND: \(description)"
        }

        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.body = notificationMessage
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(datePicker.date.timeIntervalSinceNow, 1), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Lỗi khi lên lịch thông báo: \(error.localizedDescription)")
            } else {
                print("Thông báo đã được lên lịch thành công!")
            }
        }
    }

    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Lỗi", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc func donePressed() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy HH:mm"
        formatter.locale = Locale(identifier: "vi_VN")
        timeTextField.text = formatter.string(from: datePicker.date)
        timeTextField.resignFirstResponder()

        UIView.animate(withDuration: 0.3, animations: {
            self.datePickerContainer.frame.origin.y = self.view.frame.height
        })
    }

    @objc func doneButtonTapped() {
        view.endEditing(true)
    }

    func maskAccountNumber(account: String) -> String {
        if account.count >= 5 {
            let start = account.startIndex
            let end = account.index(start, offsetBy: 2)
            let endIndex = account.index(account.endIndex, offsetBy: -3)
            let maskedAccount = account[start..<end] + "xxx" + account[endIndex..<account.endIndex]
            return String(maskedAccount)
        } else {
            return account
        }
    }

    func setupLoadingView() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingView.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
        ])
    }

    func showLoading() {
        loadingView.isHidden = false
        activityIndicator.startAnimating()

        loadingView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 0.8
        }
    }

    func hideLoading() {
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingView.alpha = 0
        }) { _ in
            self.loadingView.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }

    func animateViewsAfterLoading() {
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.stackView.transform = .identity
        }

        let textFields = [self.accountTextField, self.amountTextField, self.timeTextField, self.balanceTextField, self.descriptionTextField]
        for (index, textField) in textFields.enumerated() {
            UIView.animate(withDuration: 0.6, delay: 0.1 * Double(index), usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: .curveEaseInOut) {
                textField.transform = .identity
            }
        }
    }

    @objc func timeTextFieldTapped() {
        timeTextField.inputView = datePickerContainer
        datePickerContainer.frame.origin.y = view.frame.height

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.datePickerContainer.frame.origin.y = self.view.frame.height / 2
        }
    }

    @objc func buttonTouchDown(sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseInOut]) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc func buttonTouchUpInside(sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.allowUserInteraction, .curveEaseInOut]) {
            sender.transform = .identity
        }
    }

    @objc func buttonTouchUpOutside(sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.allowUserInteraction, .curveEaseInOut]) {
            sender.transform = .identity
        }
    }

    // MARK: - UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderColor = UIColor.blue.cgColor
            textField.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderColor = UIColor.lightGray.cgColor
            textField.transform = .identity
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == accountTextField {
            return string.isEmpty || CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
        } else if textField == amountTextField || textField == balanceTextField {
            return string.isEmpty || CharacterSet(charactersIn: "0123456789.,").isSuperset(of: CharacterSet(charactersIn: string))
        }
        return true
    }
}

extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge, .list])
    }
}


extension UIView {
    func shake(count: Float = 4, forDuration duration: TimeInterval = 0.5, withTranslation translation: Float = 5) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration / TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }
}

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
