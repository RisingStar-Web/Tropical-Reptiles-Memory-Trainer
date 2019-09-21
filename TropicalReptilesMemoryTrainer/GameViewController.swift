//
//  GameViewController.swift
//  CrazyAnimalsFlipCards
//
//  Created by Роман Кабиров on 08.11.17.
//  Copyright © 2017 Logical Mind. All rights reserved.
//

import UIKit
import AudioToolbox

class GameViewController: UIViewController {
    var currentLevel = 1
    var visibleCardsCount = 0
    var tryCount = 3
    var topScore = UserDefaults.standard.integer(forKey: "topScore")
    var topLevel = UserDefaults.standard.integer(forKey: "topLevel")
    
    var difficultTimeSec: Double = 0.0
    var flipSpeed: Double = 0.5

    @IBOutlet weak var labelLevel: UILabel!
    @IBOutlet weak var labelScore: UILabel!
    @IBOutlet weak var gameVIew: UIView!
    @IBOutlet weak var viewHearts: UIView!
    
    var score: Int = 0
    
    var tapLocked = false
    var flipLocked = false
    
    var innnerView: UIView?
    var openedCards: [ExCardUIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeToBack))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(swipe)
        
        labelScore.text = "0"
        labelLevel.text = "LEVEL".localized + " \(currentLevel)"
        
        buildScene()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
            // Init AdMob banner
            // self.initAdMobBanner()
        })
    }
    
    @objc func swipeToBack(sender: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    func buildScene() {
        tryCount = 3
        innnerView?.removeFromSuperview()
        
        innnerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 32, height: self.view.frame.height - 32))
        innnerView?.backgroundColor = UIColor.clear

        let cardSize: CGFloat = ((innnerView?.frame.width)! / 3) - 11
        
        var index = 0
        
        let a = Data.levels[currentLevel-1]
        
        if currentLevel < 5 {
            difficultTimeSec = 0
        } else
        if currentLevel < 10 {
            difficultTimeSec = 1.2
            flipSpeed = 0.7
        } else
        if currentLevel < 15 {
            difficultTimeSec = 1.0
            flipSpeed = 0.6
        } else
        if currentLevel < 20 {
            difficultTimeSec = 0.7
            flipSpeed = 0.55
        }
        else
        if currentLevel < 25 {
            difficultTimeSec = 0.5
            flipSpeed = 0.5
        } else
        if currentLevel < 30 {
            difficultTimeSec = 0.4
            flipSpeed = 0.4
        } else
        if currentLevel >= 40 {
            difficultTimeSec = 0.4
            flipSpeed = 0.35
        }

        for row in 0..<4 {
            for col in 0..<3 {
                if index > 11 {
                    continue
                }
                if a[index] == 0 {
                    index += 1
                    continue
                }
                
                let x = (CGFloat(col) * cardSize) + CGFloat(col * 16)
                let y = (CGFloat(row) * cardSize) + CGFloat(row * 16)
                
                let rootFlipView = ExCardUIView(frame: CGRect(x: x, y: y, width: cardSize, height: cardSize))
                
                let cardBack = createCard(0, 0, cardSize, "card")
                
                // let imgCode = Int(arc4random_uniform(UInt32(maxCount)) + 3)
                let imgCode = a[index]
                
                let imageName = "img\(imgCode)"
                let cardImage = createCard(0, 0, cardSize, imageName)
                // cardAnimal.isHidden = true
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
                rootFlipView.isUserInteractionEnabled = true
                rootFlipView.addGestureRecognizer(tap)
                
                rootFlipView.cardBack = cardBack
                rootFlipView.cardImage = cardImage
                rootFlipView.imageName = imageName
                rootFlipView.code = imgCode

                rootFlipView.addSubview(cardImage)
                rootFlipView.addSubview(cardBack)
                
                innnerView?.addSubview(rootFlipView)
                visibleCardsCount += 1
                index += 1
            }
        }
        
        let totalHeight = (cardSize * 4) + 33
        let viewHeight = self.view.frame.height - 160
        let delta = (viewHeight - totalHeight) / 2
        innnerView?.frame.origin.y = delta
        
        gameVIew.addSubview(innnerView!)
    }
    
    func createCard(_ x: CGFloat, _ y: CGFloat, _ size: CGFloat, _ imgName: String) -> UIImageView {
        let frame = CGRect(x: x, y: y, width: size, height: size)
        let card = UIImageView(frame: frame)
        card.image = UIImage(named: imgName)
        
        // card.layer.masksToBounds = true
        card.clipsToBounds = true
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.cgColor
        card.layer.cornerRadius = 8
        
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 2, height: 4)
        card.layer.shadowRadius = 5.0
        card.layer.shadowOpacity = 0.9
        
        return card
    }

    func flipCard(_ card: ExCardUIView) {
        let cardBack = card.cardBack!
        let cardImage = card.cardImage!
        
        if UserDefaults.standard.object(forKey: "opened-\(card.imageName)") == nil {
            UserDefaults.standard.set(true, forKey: "opened-\(card.imageName)")
        }
        
        var showingSide = cardImage
        var hiddenSide = cardBack
        
        if card.showingBack {
            (showingSide, hiddenSide) = (cardBack, cardImage)
            openedCards.append(card)
        } else {
            let i = openedCards.index(of: card)!
            if i >= 0 {
                openedCards.remove(at: i)
            }
        }

        var f = cardHasBeenFlipped
        if openedCards.count == 1 {
            f = {(_) in }
            
            if difficultTimeSec != 0 {
                let time = DispatchTime.now() + Double(difficultTimeSec)
                DispatchQueue.main.asyncAfter(deadline: time, execute: {
                    if (!card.showingBack) && (self.openedCards.count == 1) {
                        self.flipCard(card)
                    }
                })
                
            }
        }
        
        UIView.transition(from: showingSide,
                          to: hiddenSide,
                          duration: flipSpeed,
                          options: UIViewAnimationOptions.transitionFlipFromRight,
                          completion: f)
        
        card.showingBack = !card.showingBack
    }
    
    
    @objc func cardTapped(sender: UITapGestureRecognizer) {
        if tapLocked {
            return
        }
        
        if openedCards.count >= 2 {
            return
        }
        
        let v = sender.view as! ExCardUIView
        if !v.showingBack {
            return
        }
        
        v.tapCount += 1
        
        tapLocked = true
        flipCard(v)
        tapLocked = false

        if openedCards.count == 2 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.closeAllCards()
            })
        }
        
    }
    
    @objc func cardHasBeenFlipped(finished: Bool) {
        if openedCards.count == 2 {
            if flipLocked { return }
            flipLocked = true
            let card1 = openedCards[0]
            let card2 = openedCards[1]
            
            if (card1.code == card2.code) && (!card1.showingBack) && (!card2.showingBack) {
                // setTryCount(3)
                if (card1.tapCount == 1) && (card2.tapCount == 1) {
                    showLabelPopup(text: "Lucky!".localized)
                    incScore(3)
                } else {
                    incScore(2)
                }
                
                UIView.animate(withDuration: 0.3, animations: {
                    card1.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    card2.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                }, completion: {(_) in
                    UIView.animate(withDuration: 0.5, animations: {
                        card1.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                        card2.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    }, completion: {(_) in
                        card1.isHidden = true
                        card2.isHidden = true
                        
                        // print("self.visibleCardsCount: \(self.visibleCardsCount)")
                        
                        self.visibleCardsCount -= 2
                        // if (self.visibleCardsCount == 0) && (self.openedCards.count == 0) {
                        if self.visibleCardsCount == 0 {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                                self.showFinal()
                            })
                            
                        }
                    })
                })
            } else {
                if tryCount <= 0 {
                    innnerView?.removeFromSuperview()
                    showLabelPopup(text: "You lose!")
                    showSuperFinal()
                } else {
                    setTryCount(tryCount - 1)
                }
                if score > 0 {
                    incScore(-1)
                }
            }
            flipLocked = false
        }
    }
    
    func setTryCount(_ count: Int) {
        tryCount = count
        // var index: Int = 0
        
        viewHearts.subviews[0].isHidden = tryCount < 3
        viewHearts.subviews[1].isHidden = tryCount < 2
        viewHearts.subviews[2].isHidden = tryCount < 1

        /*
        for heart in viewHearts.subviews {
            if tryCount > index {
                heart.isHidden = false
            } else {
                heart.isHidden = true
            }
            index += 1
        }
         */
    }
    
    func showFinal() {
        currentLevel += 1
        if currentLevel > topLevel {
            topLevel = currentLevel
            UserDefaults.standard.set(topLevel, forKey: "topLevel")
        }

        if currentLevel <= Data.levels.count {
            showLabelPopup(text: "Congrats!".localized)
            labelLevel.text = "LEVEL".localized + " \(currentLevel)"
        } else {
            showLabelPopup(text: "The end".localized)
            showSuperFinal()
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8, execute: {
            if self.currentLevel <= Data.levels.count {
                self.buildScene()
                /*
                if self.currentLevel % 4 == 0 {
                    if self.interstitial.isReady {
                        self.interstitial.present(fromRootViewController: self)
                    }
                }
                */
            } else {
            }

        })
    }
    
    func showSuperFinal() {
        labelLevel.text = "THE END".localized

        let baseY = (view.frame.height / 2) - 50
        
        let f1 = CGRect(x: 16, y: baseY, width: view.frame.width - 32, height: 160)
        let label = UILabel(frame: f1)
        label.font = UIFont(name: "Arial Rounded MT Bold", size: 28)
        
        
        
        label.text = "Your score:".localized + " \(score)\n" + "Your level:".localized + " \(currentLevel)\n" + "Top score:".localized + " \(topScore)\n" + "Top level:".localized + " \(topLevel)"
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.layer.masksToBounds = true
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.cornerRadius = 8

        view.addSubview(label)

        label.transform = CGAffineTransform(translationX: 0, y: view.frame.height)

        UIView.animate(withDuration: 1.1, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.6, options: .curveEaseIn, animations: {
            label.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
        
    }
    
    func showLabelPopup(text: String) {
        let frame = CGRect(x: 10, y: view.frame.height / 2, width: view.frame.width - 20, height: 40)
        let label = UILabel(frame: frame)
        label.font = UIFont(name: "Arial Rounded MT Bold", size: 30)
        label.text = text
        label.textColor = UIColor.white
        label.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        label.textAlignment = .center

        view.addSubview(label)
        
        UIView.animate(withDuration: 0.9, animations: {
            label.transform = CGAffineTransform(scaleX: 2.9, y: 2.9)
        }, completion: {(_) in
            label.removeFromSuperview()
        })
    }
    
    func incScore(_ increment: Int) {
        score += increment
        labelScore.text = String(score)
        if score > topScore {
            topScore = score
            UserDefaults.standard.set(topScore, forKey: "topScore")
        }
    }
    
    func closeAllCards() {
        for card in openedCards {
            flipCard(card)
        }
    }
    
}

class ExCardUIView: UIView {
    var code = 0
    var cardBack: UIImageView?
    var cardImage: UIImageView?
    var showingBack = true
    var tapCount = 0
    var imageName: String = ""
}
