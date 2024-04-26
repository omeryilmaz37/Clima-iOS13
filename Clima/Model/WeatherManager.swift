//
//  WeatherManager.swift
//  Clima
//
//  Created by Ömer Yılmaz on 20.04.2024.
//

import UIKit
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(weatherManager : WeatherManager ,weather : WeatherModel)
    func didFailWithError(error : Error)
}


// WeatherManager yapısı, OpenWeatherMap API'sinden hava durumu verilerini almak için kullanılır.
struct WeatherManager {
    // API'nin temel URL'si
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=0209956f75d9788a3fffbe705415e66f&units=metric"
    
    var delegate : WeatherManagerDelegate?
    // Belirli bir şehir için hava durumu verilerini getirmek için bir fonksiyon.
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherUrl)&q=\(cityName)"
        // URL'yi oluşturup istek fonksiyonunu çağırır.
        performRequest(with: urlString)// Bu fonksiyon, bir URL dizesi alır ve bu URL'ye bir HTTP isteği yapar
    }
    
    func fetchWeather(latitude:CLLocationDegrees, longitude:CLLocationDegrees){
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    // Belirtilen URL üzerinden ağ isteği yapmak için bir fonksiyon.
    func performRequest(with urlString: String) {
        // 1. Adım: URL Oluşturma
        if let url = URL(string: urlString) {
            // 2. Adım: URLSession Oluşturma
            let session = URLSession(configuration: .default)
            
            // 3. Adım: URLSession'a bir görev atama (dataTask)
            // İstek tamamlandığında belirtilen tamamlama bloğunu çağıracak.
            let task = session.dataTask(with: url) { (data, response, error)  in
                // Hata var mı diye kontrol etme
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                // Veri var mı diye kontrol etme ve güvenli bir şekilde veriyi alıp çözme (decode)
                if let safeData = data {
                    if let weather = self.parseJSON(weatherData: safeData){
                        self.delegate?.didUpdateWeather(weatherManager: self, weather: weather)
                    }
                }
            }
            
            // 4. Adım: Görevi başlatma
            task.resume()
        }
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        }catch{
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
