//
//  ContentView.swift
//  MultiPlay
//
//  Created by Uriel Ortega on 29/04/23.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @State private var isGameActive = false
    @State private var areSettingsActive = true
    @State private var isGameOver = false
    
    @State private var questions = [Question]()
    
    var body: some View {
        VStack {
            if areSettingsActive {
                SettingsView(startGameWith: startGame)
            } else if isGameActive {
                GameActiveView(questions: questions, endGameWith: tryAgain)
            }
        }
    }
    
    func startGame(numberOfQuestions: Int, multiplicationTable: Int) -> Void {
        questions.removeAll()
        
        print("You're gonna answer \(numberOfQuestions) questions, up to the table #\(multiplicationTable)")
        
        var multiplicand: Int
        var multiplier: Int
        var product: Int
        var multiplication: String
        var generatedQuestion: Question
        
        for _ in 1...numberOfQuestions {
            multiplicand = Int.random(in: 1...multiplicationTable)
            multiplier = Int.random(in: 1...12)
            product = multiplicand * multiplier
            multiplication = "\(multiplicand) x \(multiplier)"
            
            generatedQuestion = Question(multiplication: multiplication, result: String(product))
            
            questions.append(generatedQuestion)
            print("\(generatedQuestion.multiplication) = \(generatedQuestion.result)")
        }
        
        withAnimation {
            areSettingsActive = false
            isGameActive = true
        }
    }
    
    func tryAgain() -> Void {
        withAnimation {
            isGameActive = false
            areSettingsActive = true
            isGameOver = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SettingsView: View {
    @State private var numberOfQuestions = 5
    @State private var maxMultiplicationTable = 2

    var startGameWith: (Int, Int) -> Void

    var body: some View {
        ZStack {
            AngularGradient(gradient: Gradient(colors: [.pink, .purple, .blue, .pink]), center: .center)
                .ignoresSafeArea()
            VStack {
                Text("Let's begin!")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding()
                Text("Up to what multiplication table do you want to challenge yourself?")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                HStack {
                    Button() {
                        withAnimation {
                            maxMultiplicationTable > 2 ? maxMultiplicationTable -= 1 : nil
                        }
                    } label: {
                        Image(systemName: "minus")
                            .foregroundColor(.white)
                            .padding(20)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text(String(maxMultiplicationTable))
                        .font(.system(size: 120, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    .padding()
                    Spacer()
                    Button() {
                        withAnimation {
                            maxMultiplicationTable < 12 ? maxMultiplicationTable += 1 : nil
                        }
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .padding(20)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                Text("How many questions do you want to answer?")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                Picker("Number of questions", selection: $numberOfQuestions) {
                    Text("5").tag(5)
                    Text("10").tag(10)
                    Text("20").tag(20)
                }
                .pickerStyle(.segmented)
                
                Spacer()
                
                Button {
                    startGameWith(numberOfQuestions, maxMultiplicationTable)
                } label: {
                    Text("Start game")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 72)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.20), radius: 25)
                        .padding()
                }
                .padding()
            }
            .padding()
        }
    }
}

struct GameActiveView: View {
    var questions: [Question]
    var endGameWith: () -> Void

    @State private var numberOfCorrectAnswers = 0
    @State private var numberOfQuestions = 5
    @State private var questionNumber = 0
    @State private var score = 0

    @State private var userAnswer: Int?
    @FocusState private var answerIsFocused: Bool
    
    var endgameTitle = "Game over!"
    @State private var endgameMessage = ""
    @State private var showFinalAlert = false

    var body: some View {
        ZStack {
            AngularGradient(gradient: Gradient(colors: [.blue, .purple, .pink, .blue]), center: .center)
                .ignoresSafeArea()
            VStack(alignment: .center) {
                Text("Solve the next multiplication 🧠")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding()
                Text(questions[questionNumber].multiplication)
                    .font(.system(size: 80, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                TextField("Your answer", value: $userAnswer, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .focused($answerIsFocused)
                Button {
                    checkAnswer()
                } label: {
                    Text("Check")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 48)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.20), radius: 25)
                        .padding()
                }
            }
            .padding()
        }
        .alert(endgameTitle, isPresented: $showFinalAlert) {
            Button("Restart", action: endGameWith)
        } message: {
            Text(endgameMessage)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Done") {
                    answerIsFocused = false
                }
            }
        }
        .onSubmit {
            checkAnswer()
        }
    }
    
    func checkAnswer() {
        answerIsFocused = false

        if questionNumber < questions.count - 1 {
            if String(userAnswer ?? 0) == questions[questionNumber].result {
                score += 1
            }
            questionNumber += 1
        } else {
            if String(userAnswer ?? 0) == questions[questionNumber].result {
                score += 1
                print("score = " + String(score))
            }
            endgameMessage = "You got \(score)/\(questions.count) correct!"
            showFinalAlert = true
        }
        
        userAnswer = nil
        answerIsFocused = true
    }
}
