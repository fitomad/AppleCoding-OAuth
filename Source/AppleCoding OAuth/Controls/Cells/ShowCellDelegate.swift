//
//  ShowCellDelegate.swift
//  AppleCoding OAuth
//
//  Created by Adolfo Vera Blasco on 28/5/18.
//  Copyright © 2018 desappstre {eStudio}. All rights reserved.
//


import UIKit
import Foundation

internal protocol ShowCellDelegate: AnyObject
{
    /**
        Informa de la selección una serie por parte
        del usuario

        - Parameters:
            - cell: Procendencia de la acción
            - trakID: Idenitificador de la serie
    */
    func showCell(_ cell: ShowCell, didSelectShow trackID: Int) -> Void
}