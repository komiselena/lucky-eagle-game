//
//  AppDelegate.swift
//  TapWater
//
//  Created by User on 15.04.2025.
//

import UIKit
import SwiftUI
// Данный класс является точкой входа в приложение
// Для корректной работы необходимо в настройках проекта в главном таргете
// в разделе "Deployment Info" отметить все ориентации
// а так же отметить "Requires full screen"

// Экран загрузки должен быть реализован посредством сториборда,
// чтобы он отображался сразу при старте приложения
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Task {
            if await !decide() {
                // Здесь происходит инициализация главного View
                // InitialView нужно заменить на ваш главный View
                let contentView = CustomHostingController(rootView: MainMenuView())
                window = UIWindow(frame: UIScreen.main.bounds)
                window?.rootViewController = contentView

                // Также, контроль ориентации происходит за счет класса OrientationHelper
                // Ориентация задается за счет переменной orientaionMask
                // Также, если нужно отключить автоповорот, то нужно установить isAutoRotationEnabled в false
                OrientationHelper.orientaionMask = UIInterfaceOrientationMask.portrait
                OrientationHelper.isAutoRotationEnabled = false

                // Вся остальная логика приложения, которая должна быть выполнена до загрузки главного View
                // должна быть выполнена здесь. Например, инициализация аудио
                

                ///////////////////////////////

                // Показываем главный View
                window?.makeKeyAndVisible()
            }
            // Это не трогать///////////////////
            else {
                //Web Initialization
            }
            ////////////////////////////
        }
        return true
    }
    
    // Это не трогать///////////////////
    func decide() async -> Bool {
        return false
    }
    ////////////////////////////

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }


}

class CustomHostingController<Content: View>: UIHostingController<Content> {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // Allow all orientations
        return OrientationHelper.orientaionMask
    }

    override var shouldAutorotate: Bool {
        // Enable auto-rotation
        return OrientationHelper.isAutoRotationEnabled
    }
}

class OrientationHelper
{
    public static var orientaionMask: UIInterfaceOrientationMask = .portrait
    public static var isAutoRotationEnabled: Bool = false
}
