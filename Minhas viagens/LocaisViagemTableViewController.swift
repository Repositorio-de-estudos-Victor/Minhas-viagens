//
//  LocaisViagemTableViewController.swift
//  Minhas viagens
//
//  Created by Victor Rodrigues Novais on 02/05/20.
//  Copyright © 2020 Victoriano. All rights reserved.
//

import UIKit

class LocaisViagemTableViewController: UITableViewController {
    
    var locaisViagens: [Dictionary<String, String>] = []
    var controleNavigation = "adicionar"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        controleNavigation = "adicionar"
        atualizarViagens()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locaisViagens.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let viagem = locaisViagens[indexPath.row]["local"]
        let celula = tableView.dequeueReusableCell(withIdentifier: "celulaReuso", for: indexPath)
        celula.textLabel?.text = viagem
        
        return celula
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            ArmazenamentoDeDados().removerViagem( indice: indexPath.row )
            atualizarViagens()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.controleNavigation = "listar"
        performSegue(withIdentifier: "verLocal", sender: indexPath.row)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "verLocal" {
            
            let viewControllerDestino = segue.destination as! ViewController
            
            if self.controleNavigation == "listar" {
                if let indiceRecuperado = sender {
                    
                    let indice = indiceRecuperado as! Int
                    viewControllerDestino.viagem = locaisViagens[ indice ]
                    viewControllerDestino.indiceSelecionado = indice
                    
                }
            }else {
                
                viewControllerDestino.viagem = [:]
                viewControllerDestino.indiceSelecionado = -1
                
            }
            
            
        }
    }
    
    func atualizarViagens() {
        locaisViagens = ArmazenamentoDeDados().listarViagens()
        tableView.reloadData()
    }
    
}
