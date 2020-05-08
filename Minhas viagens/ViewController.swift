//
//  ViewController.swift
//  Minhas viagens
//
//  Created by Victor Rodrigues Novais on 02/05/20.
//  Copyright © 2020 Victoriano. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapa: MKMapView!
    var gerenciadorLocalizacao = CLLocationManager()
    var viagem: Dictionary<String, String> = [:]
    var indiceSelecionado: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configuraGerenciadorLocalizacao()
        
        if let indice = indiceSelecionado {
            
            if indice == -1 { //adicionar
                configuraGerenciadorLocalizacao()
            } else { //listar
                exibirAnotacao(viagem: viagem)
            }
            
        }
        
        // reconhecedor de gestos
        let reconhecedorGesto = UILongPressGestureRecognizer(target: self, action: #selector(self.marcar(gesture:)))
        reconhecedorGesto.minimumPressDuration = 2
        
        mapa.addGestureRecognizer(reconhecedorGesto)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let local = locations.last!
        
        //Exibe local
        let localizacao = CLLocationCoordinate2D.init(latitude: local.coordinate.latitude, longitude: local.coordinate.longitude)
        let span = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        let regiao: MKCoordinateRegion = MKCoordinateRegion.init(center: localizacao, span: span)
        self.mapa.setRegion(regiao, animated: true)
    }
    
    func exibirLocal(latitude: Double, longitude: Double) {
        //Exibe local
        let localizacao = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        let regiao: MKCoordinateRegion = MKCoordinateRegion.init(center: localizacao, span: span)
        self.mapa.setRegion(regiao, animated: true)
    }
    
    func exibirAnotacao(viagem: Dictionary<String,String>) {
        
        if let localViagem = viagem["local"] {
            if let latitudeS = viagem["latitude"] {
                if let longitudeS = viagem["longitude"] {
                    
                    if let latitude = Double(latitudeS) {
                        if let longitude = Double(longitudeS) {
                            //Adicionar anotação
                            let anotacao = MKPointAnnotation()

                            anotacao.coordinate.latitude = latitude
                            anotacao.coordinate.longitude = longitude
                            anotacao.title = localViagem

                            self.mapa.addAnnotation(anotacao)
                            
                            exibirLocal(latitude: latitude, longitude: longitude)
                        }
                    }
                    
                }
            }
        }
        
        
    }
    
    @objc func marcar(gesture: UIGestureRecognizer){
        if gesture.state == UIGestureRecognizer.State.began {
            // Recupera as coordenada do ponto seleciona
            let pontoSelecionado = gesture.location(in: self.mapa)
            let coordenadas = mapa.convert(pontoSelecionado, toCoordinateFrom: self.mapa)
            let localizacao = CLLocation(latitude: coordenadas.latitude, longitude: coordenadas.longitude)
            
            //Recupera endereço do ponto selecionado
            var localCompleto = "Endereço não encontrado!"
            CLGeocoder().reverseGeocodeLocation(localizacao) { (local, erro) in
                if erro == nil {
                    
                    if let dadosLocal = local?.first{
                        
                        if let nome = dadosLocal.name {
                            localCompleto = nome
                        } else {
                            if let endereco = dadosLocal.thoroughfare {
                                localCompleto = endereco
                            }
                        }
                        
                    }
                    
                    //Salvar dados no dispositivo
                    self.viagem = ["local": localCompleto, "latitude": String(coordenadas.latitude), "longitude": String(coordenadas.longitude)]
                    ArmazenamentoDeDados().salvarViagem( viagem: self.viagem )
                    
                    self.exibirAnotacao(viagem: self.viagem)
                    
                }else {
                    print(erro!)
                }
            }

        }
    }
    
    func configuraGerenciadorLocalizacao() {
        // Será gerenciado por essa classe
        gerenciadorLocalizacao.delegate = self
        gerenciadorLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        gerenciadorLocalizacao.requestWhenInUseAuthorization()
        gerenciadorLocalizacao.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedWhenInUse {
            let alertaController = UIAlertController(title: "Permissão de localização", message: "Necessário permissão para acesso à sua localização! por favor habilite.", preferredStyle: .alert)
            
            let acaoConfiguracoes = UIAlertAction(title: "Abrir configurações", style: .default, handler: { (alertaConfiguracoes) in
                if let configuracoes = NSURL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(configuracoes as URL)
                }
            })
            
            let acaoCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
            
            alertaController.addAction(acaoConfiguracoes)
            alertaController.addAction(acaoCancelar)
            
            present(alertaController, animated: true, completion: nil)
        }
    }

}

