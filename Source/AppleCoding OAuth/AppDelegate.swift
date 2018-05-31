//
//  AppDelegate.swift
//  AppleCoding OAuth
//
//  Created by Adolfo Vera Blasco on 26/5/18.
//  Copyright © 2018 desappstre {eStudio}. All rights reserved.
//

import UIKit

import CoreTraktTV

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    /**
        Aquí *capturamos* todas las peticiones que reciba el dispositivo 
        con el esquema `serialer://`.

        Una `URL` con el código OAuth debe ser del tipo:
        ```
        serialer://oauth?code=76573f8d3b844705cb8d53772d4891583a3d411a39eab61061f87ca22fd87876
        ```
    */
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        // Comprobamos si alguno de los parámetros de URL es el código
        // para solicitar un token de acceso.
        if let code = components?.queryItems?.filter({ $0.name == "code" }).first?.value
        {
            // Es un código. Vamos a canjearlo por un token
            TraktTVClient.shared.exchange(code: code) { (authenticated: Bool, error: TraktError?) -> Void in
                if authenticated
                {
                    // ¡Estupendo! Tenemos un token de acceso y de refresco.
                    DispatchQueue.main.async
                    {
                        self.window?.rootViewController?.dismiss(animated: true)
                    }
                }
            }
        }
        
        return true
    }
}

