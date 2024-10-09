//
//  PopcornTabBarController.swift
//  Popcorn
//
//  Created by 홍정민 on 10/9/24.
//

import UIKit

final class PopcornTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarController()
        setUpTabBarAppearence()
    }
    
    private func configureTabBarController() {
        let trendingVC = TrendingViewController()
        let trendingNav = UINavigationController(rootViewController: trendingVC)
        
        let searchVC = SearchViewController()
        let searchNav = UINavigationController(rootViewController: searchVC)
        
        let favoriteVC = DetailViewController()
        let favoriteNav = UINavigationController(rootViewController: favoriteVC)
        
        trendingVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: Design.Image.home,
            tag: 0
        )
        
        searchVC.tabBarItem = UITabBarItem(
            title: "Top Search",
            image: Design.Image.search,
            tag: 1
        )
        
        favoriteVC.tabBarItem = UITabBarItem(
            title: "Download",
            image: Design.Image.faceSmile,
            tag: 2
        )
        
        setViewControllers([trendingNav, searchNav, favoriteNav], animated: true)
    }
    
    private func setUpTabBarAppearence() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .darkGray
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .white
    }
}
