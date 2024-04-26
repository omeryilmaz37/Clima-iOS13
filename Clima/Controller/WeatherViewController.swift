//
//  WeatherViewController.swift
//  Clima
//
//  Created by Ömer Yılmaz on 20.04.2024.
//

import UIKit
import CoreLocation

// WeatherViewController adında bir UIViewController sınıfı oluşturulmuştur.
class WeatherViewController: UIViewController {

    // Storyboard'daki arayüz elemanlarına erişim için outlet'ler tanımlanmıştır.
    @IBOutlet weak var conditionImageView: UIImageView! // Hava durumu ikonunu gösteren imageView.
    @IBOutlet weak var temperatureLabel: UILabel! // Sıcaklık bilgisini gösteren label.
    @IBOutlet weak var cityLabel: UILabel! // Şehir adını gösteren label.
    @IBOutlet weak var searchTextFeild: UITextField! // Kullanıcının arama yapabileceği metin giriş alanı.

    // Hava durumu ve konum bilgilerini yönetmek için WeatherManager ve CLLocationManager örnekleri oluşturulmuştur.
    var weatherManager = WeatherManager()
    var locationManager = CLLocationManager()

    // ViewController yüklendiğinde çağrılan fonksiyon.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Konum izni isteği yapılmıştır.
        locationManager.requestWhenInUseAuthorization()
        // Delegeler atanmıştır.
        locationManager.delegate = self
        weatherManager.delegate = self
        searchTextFeild.delegate = self
    }

    // Konum butonuna basıldığında çağrılan fonksiyon.
    @IBAction func locationPressed(_ sender: UIButton) {
        // Konum bilgisini iste.
        locationManager.requestLocation()
    }
}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {

    // Arama butonuna basıldığında çağrılan fonksiyon.
    @IBAction func searchPressed(_ sender: UIButton) {
        // Klavyeyi kapat.
        searchTextFeild.endEditing(true)
        // Kullanıcının girdiği şehir ismini konsola yazdır.
        print(searchTextFeild.text!)
    }

    // Return tuşuna basıldığında çağrılan fonksiyon.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Klavyeyi kapat.
        searchTextFeild.endEditing(true)
        // Kullanıcının girdiği şehir ismini konsola yazdır.
        print(searchTextFeild.text!)
        return true
    }

    // Metin giriş alanının düzenlemesi sona erdiğinde çağrılan fonksiyon.
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // Eğer metin giriş alanı boş değilse, düzenlemeyi sonlandır.
        if textField.text != "" {
            return true
        } else {
            // Eğer metin giriş alanı boşsa, kullanıcıya "Type something" mesajını placeholder olarak göster.
            textField.placeholder = "Type something"
            return false
        }
    }

    // Metin giriş alanının düzenlemesi tamamlandığında çağrılan fonksiyon.
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Metin giriş alanı boş değilse, hava durumu bilgisini getir.
        if let city = searchTextFeild.text {
            weatherManager.fetchWeather(cityName: city)
        }
        // Metin giriş alanını temizle.
        searchTextFeild.text = ""
    }
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {

    // Hava durumu güncellendiğinde çağrılan fonksiyon.
    func didUpdateWeather(weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            // Güncel hava durumu bilgileri arayüz elemanlarına atanmıştır.
            self.temperatureLabel.text = weather.temperatureString
            self.cityLabel.text = weather.cityName
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
        }
    }

    // Hava durumu alınırken hata oluştuğunda çağrılan fonksiyon.
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {

    // Konum güncellendiğinde çağrılan fonksiyon.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // En son alınan konumu al.
        if let location = locations.last {
            // Konum güncelleme işlemini durdur.
            locationManager.stopUpdatingLocation()
            // Enlem ve boylam bilgilerini alarak hava durumu bilgisini getir.
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }

    // Konum güncelleme hatası olduğunda çağrılan fonksiyon.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}
