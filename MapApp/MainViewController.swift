import UIKit
import MapKit

class MainViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self

        // キーボード以外をtapした際のアクションをviewに仕込む
        let hideTap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKyeoboard))
        self.view.addGestureRecognizer(hideTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func hideKyeoboard(recognizer : UITapGestureRecognizer){
        self.view.endEditing(true)
    }

    /// キーボードの検索ボタン押下時
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        self.view.endEditing(true)
        // 現在表示中のピンをすべて消す
        self.mapView.removeAnnotations(mapView.annotations)

        guard let address = textField.text else {
            return false
        }

        CLGeocoder().geocodeAddressString(address) { [weak mapView] placemarks, error in
            guard let loc = placemarks?.first?.location?.coordinate else {
                return
            }

            // 地図の中心を設定
            mapView?.setCenter(loc ,animated:true)
            // 縮尺を設定
            let region = MKCoordinateRegion(center: loc,
                                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))

            Map.search(query: "駅", region: region) { (result) in
                switch result {
                case .success(let mapItems):
                    for map in mapItems {
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = map.placemark.coordinate
                        annotation.title = map.name ?? "名前がありません"
                        mapView?.addAnnotation(annotation)
                    }
                case .failure(let error):
                    print("error \(error.localizedDescription)")
                }
            }

            let annotation = MKPointAnnotation()
            annotation.coordinate = loc
            annotation.title = "検索地"
            mapView?.addAnnotation(annotation)

            mapView?.setRegion(region,animated:true)
        }

        self.textField.text = ""

        return true
    }
}

